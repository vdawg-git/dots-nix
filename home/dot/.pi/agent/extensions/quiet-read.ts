import { createReadToolDefinition, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text, truncateToWidth, type Component } from "@earendil-works/pi-tui";
import { homedir } from "node:os";

export { createQuietReadExtension as default };

type ReadTool = ReturnType<typeof createReadToolDefinition>;

const readTools = new Map<string, ReadTool>();

class EmptyComponent implements Component {
	render(): string[] {
		return [];
	}

	invalidate(): void {}
}

function createQuietReadExtension(pi: ExtensionAPI): void {
	const initialReadTool = getReadTool(process.cwd());

	pi.registerTool({
		name: "read",
		label: initialReadTool.label,
		description: initialReadTool.description,
		promptSnippet: initialReadTool.promptSnippet,
		promptGuidelines: initialReadTool.promptGuidelines,
		parameters: initialReadTool.parameters,
		prepareArguments: initialReadTool.prepareArguments,
		executionMode: initialReadTool.executionMode,

		async execute(toolCallId, params, signal, onUpdate, context) {
			const readTool = getReadTool(context.cwd);

			return readTool.execute(toolCallId, params, signal, onUpdate, context);
		},

		renderCall(args, theme, context) {
			const component = context.lastComponent instanceof Text ? context.lastComponent : new Text("", 0, 0);
			const path = args.path === "" ? "…" : shortenPath(args.path);
			const range = formatRange(args.offset, args.limit);
			const text = `${theme.fg("toolTitle", theme.bold("read"))} ${theme.fg("accent", path)}${theme.fg("muted", range)}`;

			component.setText(text);

			return component;
		},

		renderResult(result, _options, theme, context) {
			if (context.isError) {
				const message = result.content.find((item) => item.type === "text")?.text.split("\n")[0] ?? "Read failed";

				return new Text(theme.fg("error", truncateToWidth(message, 160, "…")), 0, 0);
			}

			return new EmptyComponent();
		},
	});
}

function getReadTool(cwd: string): ReadTool {
	const existing = readTools.get(cwd);

	if (existing !== undefined) {
		return existing;
	}

	const readTool = createReadToolDefinition(cwd);
	readTools.set(cwd, readTool);

	return readTool;
}

function shortenPath(path: string): string {
	const home = homedir();

	if (path === home) {
		return "~";
	}

	if (path.startsWith(`${home}/`)) {
		return `~/${path.slice(home.length + 1)}`;
	}

	return path;
}

function formatRange(offset: number | undefined, limit: number | undefined): string {
	if (offset === undefined && limit === undefined) {
		return "";
	}

	const start = offset ?? 1;

	if (limit === undefined) {
		return `:${start}`;
	}

	return `:${start}-${start + limit - 1}`;
}
