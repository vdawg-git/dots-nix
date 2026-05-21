import { Type } from "typebox";

type AbortSignal = unknown;
type ExtensionContext = { cwd: string };
type ExtensionAPI = {
	exec(command: string, args: string[], options: { cwd?: string; signal?: AbortSignal; timeout?: number }): Promise<{
		stdout?: string;
		stderr?: string;
		code?: number | null;
		killed?: boolean;
	}>;
	registerTool(definition: unknown): void;
};
declare const process: { env: Record<string, string | undefined> };

export { createWebSearchExtension as default };

type Status = "ok" | "fallback" | "error";
type Mode = "web_search" | "web_answer" | "web_search_fallback";
type Reason =
	| "missing_key"
	| "command_failed"
	| "timeout"
	| "invalid_json"
	| "answer_rate_limited"
	| "answer_timeout"
	| "answer_failed"
	| "fallback_failed";

type JsonEnvelope = {
	status: Status;
	mode: Mode;
	reason?: Reason;
	message?: string;
	result?: unknown;
	exitCode?: number | null;
	primaryError?: MinimalError;
	fallbackError?: MinimalError;
};

type MinimalError = {
	reason: Reason;
	message?: string;
	exitCode?: number | null;
};

type ExecJsonOk = {
	ok: true;
	result: unknown;
	exitCode: number;
};

type ExecJsonError = {
	ok: false;
	reason: Reason;
	message: string;
	exitCode?: number | null;
	stderr?: string;
	stdout?: string;
};

type ExecJsonResult = ExecJsonOk | ExecJsonError;

type WebSearchParams = {
	query: string;
	maxResults?: number;
	includeSites?: string[];
};

type WebAnswerParams = {
	query: string;
};

const SEARCH_TIMEOUT_MS = 20_000;
const ANSWER_TIMEOUT_MS = 30_000;
const DEFAULT_MAX_RESULTS = 8;
const MIN_MAX_RESULTS = 1;
const MAX_MAX_RESULTS = 10;

function createWebSearchExtension(pi: ExtensionAPI): void {
	pi.registerTool({
		name: "web_search",
		label: "Web Search",
		description: "Find source-grounded web context with URLs for current information, documentation, APIs, errors, versions, and evidence.",
		promptSnippet: "Find source-grounded web context with URLs.",
		promptGuidelines: [
			"Use web_search when URLs, evidence, docs, APIs, errors, versions, or source discovery matter.",
		],
		parameters: Type.Object({
			query: Type.String({ description: "Search query" }),
			maxResults: Type.Optional(Type.Integer({ minimum: MIN_MAX_RESULTS, maximum: MAX_MAX_RESULTS, description: "Maximum number of results, from 1 to 10" })),
			includeSites: Type.Optional(Type.Array(Type.String({ description: "Domain to include" }), { description: "Optional domains to include" })),
		}),
		async execute(_toolCallId: unknown, params: WebSearchParams, signal: AbortSignal, _onUpdate: unknown, ctx: ExtensionContext) {
			const envelope = await runWebSearch(pi, params, signal, ctx, "web_search");
			return toolResult(envelope);
		},
	});

	pi.registerTool({
		name: "web_answer",
		label: "Web Answer",
		description: "Answer broad current-facts questions with a synthesized web-grounded response. May not include source URLs.",
		promptSnippet: "Answer broad current-facts questions with a synthesized web-grounded response.",
		promptGuidelines: [
			"Use web_answer for broad synthesized current-facts answers. It may not include source URLs.",
			"web_answer may fall back to web_search; check status/mode in the JSON result.",
		],
		parameters: Type.Object({
			query: Type.String({ description: "Question to answer" }),
		}),
		async execute(_toolCallId: unknown, params: WebAnswerParams, signal: AbortSignal, _onUpdate: unknown, ctx: ExtensionContext) {
			const envelope = await runWebAnswer(pi, params, signal, ctx);
			return toolResult(envelope);
		},
	});
}

async function runWebSearch(
	pi: ExtensionAPI,
	params: WebSearchParams,
	signal: AbortSignal,
	ctx: ExtensionContext,
	mode: "web_search" | "web_search_fallback" = "web_search",
): Promise<JsonEnvelope> {
	const query = params.query?.trim();
	if (!query) {
		return errorEnvelope(mode, "command_failed", "Query must not be empty");
	}

	const searchKey = process.env.BX_SEARCH_KEY;
	if (!searchKey) {
		return errorEnvelope(mode, "missing_key", "Required key is not set");
	}

	const maxResults = clampInteger(params.maxResults ?? DEFAULT_MAX_RESULTS, MIN_MAX_RESULTS, MAX_MAX_RESULTS);
	const includeSites = normalizeSites(params.includeSites);
	const args = [
		"--api-key",
		searchKey,
		"context",
		query,
		"--count",
		String(maxResults),
		"--max-urls",
		String(maxResults),
		"--max-tokens",
		"6000",
		"--threshold",
		"balanced",
		...includeSites.flatMap((site) => ["--include-site", site]),
	];

	const result = await runBxJson(pi, args, SEARCH_TIMEOUT_MS, signal, ctx, false);
	if (!result.ok) {
		return errorEnvelope(mode, result.reason, result.message, result.exitCode);
	}

	return {
		status: "ok",
		mode,
		result: result.result,
		exitCode: result.exitCode,
	};
}

async function runWebAnswer(
	pi: ExtensionAPI,
	params: WebAnswerParams,
	signal: AbortSignal,
	ctx: ExtensionContext,
): Promise<JsonEnvelope> {
	const query = params.query?.trim();
	if (!query) {
		return errorEnvelope("web_answer", "command_failed", "Query must not be empty");
	}

	const answersKey = process.env.BX_ANSWERS_KEY;
	if (!answersKey) {
		return errorEnvelope("web_answer", "missing_key", "Required key is not set");
	}

	const answerResult = await runBxJson(
		pi,
		["--api-key", answersKey, "answers", query, "--no-stream"],
		ANSWER_TIMEOUT_MS,
		signal,
		ctx,
		true,
	);

	if (answerResult.ok && !isInvalidAnswerPayload(answerResult.result)) {
		return {
			status: "ok",
			mode: "web_answer",
			result: answerResult.result,
			exitCode: answerResult.exitCode,
		};
	}

	const primaryError = answerResult.ok
		? { reason: "answer_failed" as const, message: "Answer payload was empty or invalid", exitCode: answerResult.exitCode }
		: minimalError(answerResult);

	if (isNonFallbackAnswerFailure(primaryError, answerResult)) {
		return errorEnvelope("web_answer", primaryError.reason, primaryError.message ?? "Answer request failed", primaryError.exitCode);
	}

	const fallback = await runWebSearch(pi, { query }, signal, ctx, "web_search_fallback");
	if (fallback.status === "ok") {
		return {
			status: "fallback",
			mode: "web_search_fallback",
			reason: primaryError.reason,
			result: fallback.result,
			exitCode: fallback.exitCode,
		};
	}

	return {
		status: "error",
		mode: "web_answer",
		reason: "fallback_failed",
		primaryError,
		fallbackError: {
			reason: fallback.reason ?? "fallback_failed",
			message: fallback.message,
			exitCode: fallback.exitCode,
		},
	};
}

async function runBxJson(
	pi: ExtensionAPI,
	args: string[],
	timeout: number,
	signal: AbortSignal,
	ctx: ExtensionContext,
	forAnswer: boolean,
): Promise<ExecJsonResult> {
	try {
		const result = await pi.exec("bx", args, {
			cwd: ctx.cwd,
			signal,
			timeout,
		});
		const exitCode = result.code ?? null;
		const stdout = result.stdout ?? "";
		const stderr = result.stderr ?? "";
		const timedOut = result.killed === true && exitCode !== 0;

		if (timedOut) {
			return {
				ok: false,
				reason: forAnswer ? "answer_timeout" : "timeout",
				message: "Request timed out",
				exitCode,
				stderr,
				stdout,
			};
		}

		if (exitCode !== 0) {
			return {
				ok: false,
				reason: classifyCommandFailure(stderr, stdout, forAnswer),
				message: "Command failed",
				exitCode,
				stderr,
				stdout,
			};
		}

		if (!stdout.trim()) {
			return {
				ok: false,
				reason: "invalid_json",
				message: "Response was empty",
				exitCode,
				stderr,
				stdout,
			};
		}

		try {
			return { ok: true, result: JSON.parse(stdout), exitCode: 0 };
		} catch {
			return {
				ok: false,
				reason: "invalid_json",
				message: "Response was not valid JSON",
				exitCode,
				stderr,
				stdout,
			};
		}
	} catch (error) {
		const rawMessage = error instanceof Error ? error.message : "Command failed";
		const timedOut = /timed?\s*out|timeout/i.test(rawMessage);
		return {
			ok: false,
			reason: timedOut ? (forAnswer ? "answer_timeout" : "timeout") : "command_failed",
			message: timedOut ? "Request timed out" : "Command failed",
			exitCode: null,
			stderr: rawMessage,
		};
	}
}

function classifyCommandFailure(stderr: string, stdout: string, forAnswer: boolean): Reason {
	const text = `${stderr}\n${stdout}`.toLowerCase();
	if (/rate\s*limit|too many requests|\b429\b/.test(text)) {
		return forAnswer ? "answer_rate_limited" : "command_failed";
	}
	if (/timed?\s*out|timeout/.test(text)) {
		return forAnswer ? "answer_timeout" : "timeout";
	}
	return forAnswer ? "answer_failed" : "command_failed";
}

function isNonFallbackAnswerFailure(primaryError: MinimalError, answerResult: ExecJsonResult): boolean {
	if (primaryError.reason === "missing_key") {
		return true;
	}
	if (!answerResult.ok) {
		const text = `${answerResult.stderr ?? ""}\n${answerResult.stdout ?? ""}\n${answerResult.message}`.toLowerCase();
		return /unauthori[sz]ed|invalid\s*(api\s*)?key|forbidden|\b401\b|\b403\b|not found|enoent|no such file/.test(text);
	}
	return false;
}

function isInvalidAnswerPayload(result: unknown): boolean {
	if (result == null) {
		return true;
	}
	if (typeof result === "string") {
		return result.trim().length === 0;
	}
	if (Array.isArray(result)) {
		return result.length === 0;
	}
	if (typeof result === "object") {
		return Object.keys(result).length === 0;
	}
	return false;
}

function errorEnvelope(mode: Mode, reason: Reason, message: string, exitCode?: number | null): JsonEnvelope {
	return {
		status: "error",
		mode,
		reason,
		message,
		...(exitCode !== undefined ? { exitCode } : {}),
	};
}

function minimalError(error: ExecJsonError): MinimalError {
	return {
		reason: error.reason,
		message: error.message,
		exitCode: error.exitCode,
	};
}

function toolResult(envelope: JsonEnvelope) {
	return {
		content: [{ type: "text" as const, text: JSON.stringify(stripContentMetadata(stripUndefined(envelope)), null, 2) }],
		details: stripUndefined({
			status: envelope.status,
			mode: envelope.mode,
			reason: envelope.reason,
			exitCode: envelope.exitCode,
		}),
	};
}

function stripContentMetadata<T>(value: T): T {
	if (Array.isArray(value)) {
		return value.map(stripContentMetadata) as T;
	}
	if (value && typeof value === "object") {
		return Object.fromEntries(
			Object.entries(value)
				.filter(([key]) => key !== "exitCode")
				.map(([key, entry]) => [key, stripContentMetadata(entry)]),
		) as T;
	}
	return value;
}

function stripUndefined<T>(value: T): T {
	if (Array.isArray(value)) {
		return value.map(stripUndefined) as T;
	}
	if (value && typeof value === "object") {
		return Object.fromEntries(
			Object.entries(value).filter(([, entry]) => entry !== undefined).map(([key, entry]) => [key, stripUndefined(entry)]),
		) as T;
	}
	return value;
}

function clampInteger(value: number, min: number, max: number): number {
	if (!Number.isFinite(value)) {
		return DEFAULT_MAX_RESULTS;
	}
	return Math.min(max, Math.max(min, Math.trunc(value)));
}

function normalizeSites(sites: string[] | undefined): string[] {
	return [...new Set((sites ?? []).map((site) => site.trim()).filter(Boolean))];
}
