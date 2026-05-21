import type { ExtensionAPI, Theme, ThemeColor } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

export { createFancyFooterExtension as default };

const BADGE_LEFT = "";
const BADGE_RIGHT = "";
const FALLBACK_BADGE = "PI";
const MINIMUM_GAP_WIDTH = 2;
const SESSION_COLORS = ["accent", "success", "error", "warning", "mdLink", "syntaxFunction", "syntaxType", "syntaxNumber"] as const satisfies readonly ThemeColor[];

type FooterColor = "success" | "warning" | "error";
type SessionColor = (typeof SESSION_COLORS)[number];

type ContextStatus = Readonly<{
	color: FooterColor;
	icon: string;
}>;

type StatusLineOptions = Readonly<{
	leftText: string;
	rightText: string;
	width: number;
}>;

/** Install a quiet statusline footer with session identity and context pressure. */
function createFancyFooterExtension(pi: ExtensionAPI): void {
	pi.on("session_start", (_event, context) => {
		context.ui.setFooter((tui, theme, footerData) => {
			const unsubscribeBranch = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsubscribeBranch,
				invalidate() {},
				render(width: number): string[] {
					const contextUsage = context.getContextUsage();
					const contextPercent = contextUsage?.percent;
					const contextStatus = getContextStatus(contextPercent);
					const sessionName = context.sessionManager.getSessionName();
					const badgeText = sessionName ?? FALLBACK_BADGE;
					const badgeColor = sessionName === undefined ? "muted" : getSessionColor(sessionName);
					const badgeForeground = sessionName === undefined ? "userMessageBg" : "customMessageBg";
					const badge = createBadge({
						background: badgeColor,
						foreground: badgeForeground,
						text: badgeText,
						theme,
					});
					const statusText = getStatusText(footerData.getExtensionStatuses());
					const projectText = getProjectText({
						branch: footerData.getGitBranch(),
						cwd: context.sessionManager.getCwd(),
						formatBranch: (branch) => theme.fg("text", branch),
						formatProject: (project) => theme.fg("muted", project),
					});
					const leftDetailText = statusText === "" ? projectText : `${projectText}  ${theme.fg("muted", statusText)}`;
					const leftText = `${badge}  ${leftDetailText}`;
					const rightText = joinSegments([
						theme.fg("muted", `󰚩 ${context.model?.id ?? "no-model"}`),
						`${theme.fg(contextStatus.color, contextStatus.icon)} ${theme.fg("muted", getContextPercentLabel(contextPercent))}`,
					], "  ");
					const line = createStatusLine({ leftText, rightText, width });

					return [truncateToWidth(line, width, theme.fg("dim", "…"))];
				},
			};
		});
	});
}

/** Replace the home directory with a terse glyph-friendly path. */
function getDirectoryName(path: string): string {
	const directoryName = path.split("/").filter((part) => part !== "").at(-1) ?? path;

	return directoryName;
}

/** Render project and branch as one compact path-like segment. */
function getProjectText(options: Readonly<{
	branch: string | null;
	cwd: string;
	formatBranch: (text: string) => string;
	formatProject: (text: string) => string;
}>): string {
	const directoryName = getDirectoryName(options.cwd);
	const projectText = options.formatProject(`󰏗 ${directoryName}`);
	const branchText = options.branch == null || options.branch === "" ? "" : `/${options.formatBranch(` ${options.branch}`)}`;
	const text = `${projectText}${branchText}`;

	return text;
}

/** Format context usage as a terse pressure percentage. */
function getContextPercentLabel(contextPercent: number | null | undefined): string {
	const label = contextPercent == null ? "?%" : `${contextPercent.toFixed(0)}%`;

	return label;
}

/** Pick an icon and urgency color for context pressure. */
function getContextStatus(contextPercent: number | null | undefined): ContextStatus {
	const percent = contextPercent ?? 0;
	const status = percent > 90
		? { color: "error", icon: "󰁹" } satisfies ContextStatus
		: percent > 70
			? { color: "warning", icon: "󰁾" } satisfies ContextStatus
			: { color: "success", icon: "󰁺" } satisfies ContextStatus;

	return status;
}

/** Convert extension status map into a deterministic one-line segment. */
function getStatusText(statuses: ReadonlyMap<string, string>): string {
	const statusText = Array.from(statuses.entries())
		.sort(([leftKey], [rightKey]) => leftKey.localeCompare(rightKey))
		.map(([_statusKey, text]) => sanitizeSingleLine(text))
		.filter((text) => text !== "")
		.join(" ");

	return statusText;
}

/** Strip control whitespace from status text before footer rendering. */
function sanitizeSingleLine(text: string): string {
	const sanitized = text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();

	return sanitized;
}

/** Right-align model and context while truncating the left detail first. */
function createStatusLine(options: StatusLineOptions): string {
	const rightTextWidth = visibleWidth(options.rightText);
	const leftTextWidth = Math.max(0, options.width - rightTextWidth - MINIMUM_GAP_WIDTH);
	const leftText = truncateToWidth(options.leftText, leftTextWidth, "…");
	const gapWidth = Math.max(MINIMUM_GAP_WIDTH, options.width - visibleWidth(leftText) - rightTextWidth);
	const line = `${leftText}${" ".repeat(gapWidth)}${options.rightText}`;

	return line;
}

/** Derive stable non-grey identity color from the session name. */
function getSessionColor(sessionName: string): SessionColor {
	const hash = Array.from(sessionName).reduce((value, character) => (value * 31 + character.charCodeAt(0)) >>> 0, 0);
	const color = SESSION_COLORS[hash % SESSION_COLORS.length];

	return color;
}

function joinSegments(segments: readonly (string | undefined)[], separator = "  "): string {
	const text = segments.filter((segment): segment is string => segment !== undefined && segment !== "").join(separator);

	return text;
}

function createBadge(options: Readonly<{
	background: ThemeColor;
	foreground: Parameters<Theme["bg"]>[0];
	text: string;
	theme: Theme;
}>): string {
	const capLeft = getForegroundFromThemeForeground({ color: options.background, text: BADGE_LEFT, theme: options.theme });
	const body = getThemeForegroundOnThemeBackground({
		background: options.background,
		foreground: options.foreground,
		text: options.text,
		theme: options.theme,
	});
	const capRight = getForegroundFromThemeForeground({ color: options.background, text: BADGE_RIGHT, theme: options.theme });
	const badge = `${capLeft}${body}${capRight}`;

	return badge;
}

/** Render text with a theme foreground color converted into a background. */
function getThemeForegroundOnThemeBackground(options: Readonly<{
	background: ThemeColor;
	foreground: Parameters<Theme["bg"]>[0];
	text: string;
	theme: Theme;
}>): string {
	const backgroundAnsi = options.theme.getFgAnsi(options.background).replace("[38;", "[48;");
	const foregroundAnsi = options.theme.getBgAnsi(options.foreground).replace("[48;", "[38;");
	const text = `${backgroundAnsi}${foregroundAnsi}${options.text}\x1b[0m`;

	return text;
}

/** Render glyph foreground with an exact theme foreground color. */
function getForegroundFromThemeForeground(options: Readonly<{ color: ThemeColor; text: string; theme: Theme }>): string {
	const foregroundAnsi = options.theme.getFgAnsi(options.color);
	const text = `${foregroundAnsi}${options.text}\x1b[0m`;

	return text;
}
