# Visual Studio Code Standarding Settings

## keybindings.json

```json
[
  {
    "key": "alt+shift+w",
    "command": "workbench.action.closeOtherEditors"
  },
  {
    "key": "alt+left",
    "command": "workbench.action.navigateBack"
  },
  {
    "key": "alt+right",
    "command": "workbench.action.navigateForward"
  },
  {
    "key": "alt+shift+m",
    "command": "workbench.action.terminal.sendSequence",
    "args": {
      "text": "git status\u000D"
    }
  },
  {
    "key": "shift+alt+r",
    "command": "workbench.action.editorLayoutTwoRows"
  },
  {
    "key": "shift+alt+t",
    "command": "todohighlight.listAnnotations"
  },
  {
    "key": "shift+alt+f",
    "command": "editor.action.formatDocument"
  }
]
```

## settings.json

```json
{
    "editor.suggestSelection": "first",
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "vim.useCtrlKeys": false,
    "editor.largeFileOptimizations": true,
    "breadcrumbs.enabled": true,
    "editor.renderControlCharacters": true,
    "editor.lineNumbers": "relative",
    "window.closeWhenEmpty": true,
    "window.restoreWindows": "all",
    "editor.renderWhitespace": "all",
    "editor.renderIndentGuides": true,
    "files.eol": "\n",
    "files.encoding": "utf8",
    "vim.normalModeKeyBindings": [
        {
            "before": [
                "z",
                "a"
            ],
            "after": [
                "<Esc>",
                "0",
                "f",
                "(",
                "l",
                "y",
                "t",
                ";",
                "0",
                "f",
                "(",
                "a",
                "`",
                "`",
                "<Esc>",
                "h",
                "p",
                "x",
                "a",
                ",",
                "<Esc>"
            ]
        }
    ],
    "editor.minimap.enabled": false,
    "explorer.confirmDelete": false,
    "explorer.openEditors.visible": 0,
    "editor.cursorBlinking": "phase",
    "editor.smoothScrolling": true,
    "editor.tokenColorCustomizations": {
        "textMateRules": [
            {
                "scope": [
                    "entity.name.function",
                    "support.function"
                ],
                "settings": {
                    "fontStyle": "italic bold"
                }
            }
        ]
    },
    "java.configuration.checkProjectSettingsExclusions": false,
    "[html]": {
        "editor.defaultFormatter": "vscode.html-language-features"
    },
    "[json]": {
        "editor.defaultFormatter": "vscode.json-language-features"
    },
    "[javascript]": {
        "editor.defaultFormatter": "vscode.typescript-language-features"
    },
    "terminal.integrated.rendererType": "dom",
    "terminal.integrated.shell.windows": "C:\\Program Files\\PowerShell\\6\\pwsh.exe",
    "window.zoomLevel": 0,
    "html.format.wrapLineLength": 0,
    "editor.fontLigatures": true,
    "editor.fontFamily": "'Cascadia Code', Consolas, 'Courier New', monospace",
    "[jsonc]": {
        "editor.defaultFormatter": "vscode.json-language-features"
    },
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/node_modules/**": true,
        ".vscode": true,
        ".gitlab": true
    },
    "extensions.autoUpdate": false,
    "emmet.triggerExpansionOnTab": true,
    "editor.minimap.showSlider": "mouseover",
    "editor.minimap.enabled": false,
    "editor.acceptSuggestionOnCommitCharacter": false,
    "emmet.triggerExpansionOnTab": true,
    "todohighlight.isEnable": true,
    "todohighlight.keywords": [
        {
          "text": "NOTE:",
          "isWholeLine": true,
          "color": "#0094ff",
          "backgroundColor": "rgba(100, 100, 100, 0.8)",
        },
        {
          "text": "TODO",
          "color": "red",
          "backgroundColor": "rgba(0,0,0,.2)",
          "isWholeLine": true
        }
    ],
    "todohighlight.maxFilesForSearch": 5120
}
```

#vsc #visual studio code
