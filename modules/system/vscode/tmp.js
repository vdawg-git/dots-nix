const vscode = require("vscode")
const fs = require("fs")
const os = require("os")
const path = require("path")
const msg = require("./messages").messages
const fetch = require("node-fetch")
const Url = require("url")

const loc = locateWorkbench()
const [workbenchDir, htmlPath] = loc

function locateWorkbench() {
	const appDir = require.main
		? path.dirname(require.main.filename)
		: globalThis._VSCODE_FILE_ROOT
	if (!appDir) {
		vscode.window.showInformationMessage(
			msg.unableToLocateVsCodeInstallationPath
		)
		return null
	}

	const basePath = path.join(appDir, "vs", "code")
	const workbenchDirCandidates = [
		// v1.102+ path
		path.join(basePath, "electron-browser", "workbench"),
		path.join(basePath, "electron-browser"),
		// old path
		path.join(basePath, "electron-sandbox", "workbench"),
		path.join(basePath, "electron-sandbox"),
	]

	const htmlFileNameCandidates = [
		"workbench-dev.html", // VSCode dev
		"workbench.esm.html", // VSCode ESM
		"workbench.html", // VSCode
		"workbench-apc-extension.html", // Cursor
	]

	for (const workbenchDirCandidate of workbenchDirCandidates) {
		for (const htmlFileNameCandidate of htmlFileNameCandidates) {
			const htmlPathCandidate = path.join(
				workbenchDirCandidate,
				htmlFileNameCandidate
			)
			if (fs.existsSync(htmlPathCandidate)) {
				return [workbenchDirCandidate, htmlPathCandidate]
			}
		}
	}

	vscode.window.showInformationMessage(msg.unableToLocateVsCodeInstallationPath)
	return null
}

function resolveVariable(key) {
	const variables = {
		cwd: () => process.cwd(),
		userHome: () => os.homedir(),
		workspaceFolder: () =>
			vscode.workspace.workspaceFolders?.[0]?.uri.fsPath || "",
		execPath: () => process.env.VSCODE_EXEC_PATH ?? process.execPath,
		pathSeparator: () => path.sep,
		"/": () => path.sep,
	}

	if (key in variables) return variables[key]()

	if (key.startsWith("env:")) {
		const [_, envKey, optionalDefault] = key.split(":")
		return process.env[envKey] ?? optionalDefault ?? ""
	}
}
function parsedUrl(url) {
	if (/^file:/.test(url)) {
		// regex matches any "${<RESOLVE>}" and replaces with resolveVariable(<RESOLVE>)
		// eg:  "HELLO ${userHome} WORLD" -> "HELLO /home/username WORLD"
		return url.replaceAll(
			/\$\{([^\{\}]+)\}/g,
			(substr, key) => resolveVariable(key) ?? substr
		)
	} else {
		return url
	}
}

async function getContent(url) {
	if (/^file:/.test(url.toString())) {
		const fp = Url.fileURLToPath(url)
		return await fs.promises.readFile(fp)
	} else {
		const response = await fetch(url)
		return response.buffer()
	}
}

// #### Patching ##############################################################

async function performPatch(uuidSession) {
	const config = vscode.workspace.getConfiguration("vscode_custom_css")
	if (!patchIsProperlyConfigured(config)) {
		return vscode.window.showInformationMessage(msg.notConfigured)
	}

	let html = await fs.promises.readFile(htmlPath, "utf-8")
	html = clearExistingPatches(html)

	const injectHTML = await patchHtml(config)
	html = html.replace(
		/<meta\s+http-equiv="Content-Security-Policy"[\s\S]*?\/>/,
		""
	)

	html = html.replace(
		/(<\/html>)/,
		`<!-- !! VSCODE-CUSTOM-CSS-SESSION-ID ${uuidSession} !! -->\n` +
			"<!-- !! VSCODE-CUSTOM-CSS-START !! -->\n" +
			indicatorJS +
			injectHTML +
			"<!-- !! VSCODE-CUSTOM-CSS-END !! -->\n</html>"
	)
	try {
		await fs.promises.writeFile(htmlPath, html, "utf-8")
	} catch (e) {
		vscode.window.showInformationMessage(msg.admin)
		disabledRestart()
		return
	}
}
function clearExistingPatches(html) {
	html = html.replace(
		/<!-- !! VSCODE-CUSTOM-CSS-START !! -->[\s\S]*?<!-- !! VSCODE-CUSTOM-CSS-END !! -->\n*/,
		""
	)
	html = html.replace(
		/<!-- !! VSCODE-CUSTOM-CSS-SESSION-ID [\w-]+ !! -->\n*/g,
		""
	)
	return html
}

function patchIsProperlyConfigured(config) {
	return config && config.imports && config.imports instanceof Array
}

async function patchHtml(config) {
	let res = ""
	for (const item of config.imports) {
		const imp = await patchHtmlForItem(item)
		if (imp) res += imp
	}
	return res
}
async function patchHtmlForItem(url) {
	if (!url) return ""
	if (typeof url !== "string") return ""

	// Copy the resource to a staging directory inside the extension dir
	let parsed = new Url.URL(url)
	const ext = path.extname(parsed.pathname)

	parsed = parsedUrl(url)
	const fetched = await getContent(parsed)
	if (ext === ".css") {
		return `<style>${fetched}</style>`
	} else if (ext === ".js") {
		return `<script>${fetched}</script>`
	}
	throw new Error(`Unsupported extension type: ${ext}`)
}

console.log("vscode-custom-css is active!")
console.log("Workbench directory", workbenchDir)
console.log("Main HTML file", htmlPath)
