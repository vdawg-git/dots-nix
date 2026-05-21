import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function fitToWidth(line: string, width: number): string {
	const lineWidth = visibleWidth(line);
	if (lineWidth === width) return line;
	if (lineWidth < width) return `${line}${" ".repeat(width - lineWidth)}`;
	return truncateToWidth(line, width, "");
}

class FancyInputEditor extends CustomEditor {
	private outerMarginX = 0;

	override setPaddingX(padding: number): void {
		const nextMargin = Number.isFinite(padding) ? Math.max(0, Math.floor(padding)) : 0;
		if (this.outerMarginX !== nextMargin) {
			this.outerMarginX = nextMargin;
			this.tui.requestRender();
		}
		super.setPaddingX(0);
	}

	override getPaddingX(): number {
		return this.outerMarginX;
	}

	override render(width: number): string[] {
		if (width < 3) return super.render(width);

		const safeMarginX = Math.min(this.outerMarginX, Math.max(0, Math.floor((width - 3) / 2)));
		const editorWidth = Math.max(1, width - safeMarginX * 2 - 2);
		const lines = super.render(editorWidth);
		if (lines.length === 0) return lines;

		const margin = " ".repeat(safeMarginX);
		const color = (text: string) => this.borderColor(text);
		const decorate = (left: string, line: string, right: string): string => {
			const base = fitToWidth(line, editorWidth);
			const rendered = `${margin}${color(left)}${base}${color(right)}`;
			return visibleWidth(rendered) <= width ? rendered : truncateToWidth(rendered, width, "");
		};

		return lines.map((line, index) => {
			if (index === 0) return decorate("╭", line, "╮");
			if (index === lines.length - 1) return decorate("╰", line, "╯");
			return decorate("│", line, "│");
		});
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui, theme, keybindings) => new FancyInputEditor(tui, theme, keybindings));
	});
}
