const vscode = require('vscode');
const path = require('path');
const fs = require('fs');


const debugChannel = vscode.window.createOutputChannel("Mijn ASM Debugger");
debugChannel.appendLine("Started");
let z80_regex = "";

// 1. Definieer de stijl (pas de kleuren aan naar smaak)
const keywordDecoration = vscode.window.createTextEditorDecorationType({
    color: '#9CDCFE', // Oranje voor je MSX/ASM tokens
    fontWeight: 'normal'
});


function formatLineText(originalText) {
    if (!originalText) {
        return originalText;
    }

    if (originalText.trim().startsWith(';')) {
        // only comment.
        return originalText;
    }

    const parts = originalText.split(';');
    const codePart = parts[0].trimEnd().replace("\t", "    ");
    const commentPart = parts.slice(1).join(';').trim();
    let tab = "";
    if (!codePart.startsWith("    ")) {
        tab = "    ";

    }
    if (codePart.includes(":")) {
        tab = "";
    }

    const paddingCount = 35 - codePart.length - tab.length;
    const padding = " ".repeat(Math.max(1, paddingCount));

    if (parts.length == 1) {
        // no comment
        return `${tab}${codePart}`;
    }

    // code + comment
    return `${tab}${codePart}${padding}; ${commentPart}`;
}

function formatWholeDocument(document) {
    const edit = new vscode.WorkspaceEdit();
    for (let i = 0; i < document.lineCount; i++) {
        const line = document.lineAt(i);
        const formatted = formatLineText(line.text); // Jouw gedeelde functie
        if (formatted !== line.text) {
            edit.replace(document.uri, line.range, formatted);
        }
    }
    vscode.workspace.applyEdit(edit);
}

class OnEnterFormatter {
    provideOnTypeFormattingEdits(document, position, ch, options) {

        const line = document.lineAt(position.line);
        const edits = [];

        if (ch === '\n' && position.line > 0) {
            const lastLine = document.lineAt(position.line - 1);
            const originalText = lastLine.text;
            const newText = formatLineText(originalText);

            if (newText !== originalText) {
                edits.push(vscode.TextEdit.replace(lastLine.range, newText));
            }
        }

        return edits;
    }
}

function activate(context) {

    PrepareDecoration();

    const dropEditProvider = {
        async provideDocumentDropEdits(document, position, dataTransfer, token) {
            const item = dataTransfer.get('text/uri-list');
            if (!item) return;

            // 0. Get first file from drag operation
            const uriList = await item.asString();
            const uriString = uriList.split(/\r?\n/)[0];
            const uri = vscode.Uri.parse(uriString);
            const filePath = uri.fsPath;

            // 1. Calc relatieve link
            let relativePath = path.relative(path.dirname(document.uri.fsPath), filePath);
            relativePath = relativePath.replace(/\\/g, '/');

            // 1B. included libraries don't need path
            const splitted = relativePath.split("/");
            if (relativePath.includes("_libraries")) {
                relativePath = splitted[splitted.length - 1];
            }

            // 1C. determine label
            let label = splitted[splitted.length - 1].split(".")[0];
            label = label.charAt(0).toUpperCase() + label.slice(1);

            // 2. Find the comment
            let comment = "";
            const content = fs.readFileSync(filePath, 'utf8');
            const lines = content.split(/\r?\n/);

            let index = lines.findIndex(line => line.includes(label + ":"));
            if (index >= 0 && lines[index - 1].startsWith(";")) {
                comment = lines[index - 1]
            }

            // 3. create the snippet
            const workspaceEdit = new vscode.WorkspaceEdit();
            const lineStart = new vscode.Position(position.line, 0);

            if (filePath.endsWith('.as') || filePath.endsWith('.asm')) {
                workspaceEdit.insert(document.uri, lineStart, `\t${comment}\r\n\tinclude "${relativePath}"\r\n`);
            }
            if (filePath.endsWith('.asc')) {
                let spaces = " ".repeat(Math.max(1, 19 - label.length));
                let callstr = `\tCALL ${label}${spaces}${comment}\r\n`;
                workspaceEdit.insert(document.uri, lineStart, callstr);
            }
            if (filePath.endsWith('.inc')) {
                workspaceEdit.insert(document.uri, lineStart, content);
            }

            return {
                insertText: "",
                additionalEdit: workspaceEdit
            };
        }
    };

    const selector = { language: 'z80' };

    let lastLineIndex = -1;
    context.subscriptions.push(
        vscode.window.onDidChangeTextEditorSelection(event => {
            try {
                const editor = event.textEditor;
                const currentLineIndex = editor.selection.active.line;
                const document = editor.document;

                if (lastLineIndex !== -1 && lastLineIndex !== currentLineIndex && document.languageId === 'z80') {
                    const lineToFormat = document.lineAt(lastLineIndex);
                    const formatted = formatLineText(lineToFormat.text); // Jouw gedeelde functie

                    if (formatted !== lineToFormat.text) {
                        const edit = new vscode.WorkspaceEdit();
                        edit.replace(document.uri, lineToFormat.range, formatted);
                        vscode.workspace.applyEdit(edit);
                    }
                }
                lastLineIndex = currentLineIndex;
            } catch (err) {
                console.error("formatting error:", err);
            }
        })
    );

    context.subscriptions.push(
        vscode.workspace.onDidOpenTextDocument(doc => {
            if (doc.languageId === 'z80') {
                formatWholeDocument(doc);
                updateDecorations();
            }
        })
    );

    context.subscriptions.push(
        vscode.languages.registerDocumentDropEditProvider(selector, dropEditProvider)
    );
    context.subscriptions.push(
        vscode.languages.registerOnTypeFormattingEditProvider(selector, new OnEnterFormatter(), '\n')
    );


    context.subscriptions.push(
        vscode.window.onDidChangeActiveTextEditor(editor => {
            activeEditor = editor;
            if (editor) updateDecorations();
        }, null, context.subscriptions));

    context.subscriptions.push(
        vscode.workspace.onDidChangeTextDocument(event => {
            if (activeEditor && event.document === activeEditor.document) {
                updateDecorations();
            }
        }, null, context.subscriptions));

}


function PrepareDecoration() {
    debugChannel.appendLine("--- Start prepareDecorations ---");

    // 2. Pad naar je externe bestand (bijv. in de huidige workspace)
    const workspaceFolder = vscode.workspace.workspaceFolders?.[0].uri.fsPath;
    if (!workspaceFolder) return;
    const listPath = 'D:\\MSX\\code\\_libraries\\Macros.asc';

    if (!fs.existsSync(listPath)) return;

    // 3. Lees woorden en maak Regex
    const content = fs.readFileSync(listPath, 'utf8');
    const matches = content.match(/"([^"]+)"/g); // Zoekt alles tussen " "
    if (!matches) return;

    const cleanWords = matches.map(m => {
        let word = m.replace(/"/g, ''); // Verwijder de quotes
        return word.replace(/\.[^/.]+$/, ""); // Verwijder de extensie (alles na de laatste punt)
        // "vdp.asm" wordt nu "vdp"
    });

    // Maak de woorden veilig voor de zoekmachine (escape speciale tekens)
    const escapedWords = cleanWords.map(w => w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
    z80_regex = new RegExp(`\\b(${escapedWords.join('|')})\\b`, 'g');

}

function updateDecorations() {


    if (!activeEditor || activeEditor.document.languageId !== 'z80') return;

    const text = activeEditor.document.getText();
    const decorations = [];
    let match;

    while ((match = z80_regex.exec(text))) {
        const startPos = activeEditor.document.positionAt(match.index);
        const endPos = activeEditor.document.positionAt(match.index + match[0].length);
        decorations.push({ range: new vscode.Range(startPos, endPos), hoverMessage: 'Macro' });
    }

    debugChannel.appendLine("decorations:");
    decorations.forEach(element => {
        debugChannel.appendLine(element);
    });

    activeEditor.setDecorations(keywordDecoration, decorations);
};


exports.activate = activate;
