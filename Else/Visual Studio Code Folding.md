# Folding

[Source](https://code.visualstudio.com/docs/editor/codebasics#_folding)

You can fold regions of source code using the folding icons on the gutter between line numbers and line start. Move the mouse over the gutter and click to fold and unfold regions. Use `Shift + Click` on the folding icon to fold or unfold the region and all regions inside.

![folding](https://code.visualstudio.com/assets/docs/editor/codebasics/folding.png)

You can also use the following actions:

* Fold (`Ctrl+Shift+[`) folds the innermost uncollapsed region at the cursor.
* Unfold (`Ctrl+Shift+]`) unfolds the collapsed region at the cursor.
* Fold Recursively (`Ctrl+K Ctrl+[`) folds the innermost uncollapsed region at the cursor and all regions inside that region.
* Unfold Recursively (`Ctrl+K Ctrl+]`) unfolds the region at the cursor and all regions inside that region.
* Fold All (`Ctrl+K Ctrl+0`) folds all regions in the editor.
* Unfold All (`Ctrl+K Ctrl+J`) unfolds all regions in the editor.
* Fold Level X (`Ctrl+K Ctrl+2` for level 2) folds all regions of level X, except the region at the current cursor position.
* Fold All Block Comments (`Ctrl+K Ctrl+/`) folds all regions that start with a block comment token.
* Folding ranges are by default evaluated based on the indentation of lines. A folding range starts when a line has a smaller indent than one or more following lines, and ends when there is a line with the same or smaller indent.

Since the 1.22 release, folding ranges can also be computed based on syntax tokens of the editor's configured language. The following languages already provide syntax aware folding: Markdown, HTML, CSS, LESS, SCSS, and JSON.

If you prefer to switch back to indentation-based folding for one (or all) of the languages above, use:

```json
  "[html]": {
    "editor.foldingStrategy": "indentation"
  },
 ```

Regions can also be defined by markers defined by each language. The following languages currently have markers defined:

* C#: `#region` and `#endregion`
* C/C++: `#pragma` region and `#pragma` endregion
* CSS/Less/SCSS: `/*#region*/` and `/*#endregion*/`
* Coffeescript: `#region` and `#endregion`
* F#: `//#region` and `//#endregion` and `(#_region)` and `(#_endregion)`
* Java: `//#region` and `// #endregion` and `//<editor-fold>` and `//</editor-fold>`
* HTML:
* PHP: `#region` and `#endregion`
* Powershell: `#region` and `#endregion`
* Python: `#region` and `#endregion`
* TypeScript/JavaScript: `//#region` and `/#endregion` and `//region` and `//endregion`
* VB: `#Region` and `#End Region`
* Bat: ::#region and ::#endregion
* Markdown: `<!-- #region -->` and `<!-- #endregion -->`

To fold and unfold only the regions defined by markers use:

* Fold Marker Regions (`Ctrl+K Ctrl+8`) folds all marker regions.
* Unfold Marker Regions (`Ctrl+K Ctrl+9`) unfolds all marker regions.