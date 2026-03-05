const vscode = require('vscode');
const path = require('path');
const fs = require('fs'); 

function formatLineText(originalText) {
    if (originalText.trim().startsWith(';')) {
        // only comment.
        return originalText; 
    }

    const parts = originalText.split(';');
    const codePart = parts[0].trim();
    const commentPart = parts.slice(1).join(';').trim();

    const targetColumn = 29;
    const tabWidth = 4;
    const paddingCount = targetColumn - tabWidth - codePart.length;
    const padding = " ".repeat(Math.max(1, paddingCount));

    if (parts.length == 1) {
        // no comment
        return `\t${codePart}`;
    } 

    // code + comment
    return `\t${codePart}${padding}; ${commentPart}`;
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
vscode.window.showInformationMessage("Formatter getriggerd!");

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

            if (filePath.endsWith('.as')) {
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

    const editDocument = document => {
        vscode.window.showInformationMessage("Formatter actief lang=" + document.languageId);
        if (document.languageId === 'z80') {
            const edit = new vscode.WorkspaceEdit();
            for (let i = 0; i < document.lineCount; i++) {
                const line = document.lineAt(i);
                const formatted = formatLineText(line.text);
                if (formatted !== line.text) {
                    edit.replace(document.uri, line.range, formatted);
                }
            }
            vscode.workspace.applyEdit(edit);
        }
    };

    const selector = { language: 'z80' };
    // const selector = [
    //     { pattern: '**/*.as' },
    //     { pattern: '**/*.asc' },
    //     { pattern: '**/*.inc' }
    // ];

    context.subscriptions.push(
        vscode.workspace.onDidOpenTextDocument(doc => {
            if (doc.languageId === 'z80') {
                formatWholeDocument(doc);
            }
        })
    );

    context.subscriptions.push(
        vscode.languages.registerDocumentDropEditProvider(selector, dropEditProvider)
    );
    context.subscriptions.push(
        vscode.languages.registerOnTypeFormattingEditProvider(selector, new OnEnterFormatter(), '\n')
    );
}

exports.activate = activate;
