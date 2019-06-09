# Visual Studio Code Standarding Settings

## keybindings.json

```json
[{
    "key": "alt+shift+w",
    "command": "workbench.action.closeOtherEditors"
}, {
    "key": "ctrl+alt+left",
    "command": "workbench.action.navigateBack"
}, {
    "key": "ctrl+alt+right",
    "command": "workbench.action.navigateForward"
}]
```

## settings.json

```json
{
    "vim.useCtrlKeys": false,
    "editor.largeFileOptimizations": true,
    "breadcrumbs.enabled": true,
    "editor.renderControlCharacters": true,
    "editor.lineNumbers": "relative",    
    "window.closeWhenEmpty": true,
    "window.restoreWindows": "all",    
    "editor.renderWhitespace":"all",
    "editor.renderIndentGuides": true,
    "files.eol": "\n",
    "files.encoding": "utf8",
    "vim.normalModeKeyBindings": [
        {
            "before": [ "z", "a" ],
            "after": [ "<Esc>", "0", "f", "(", "l", "y", "t", ";", "0", "f", "(", "a", "`", "`", "<Esc>", "h", "p", "x", "a", ",", "<Esc>" ]
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
    }
}
```

#vsc #visual studio code
