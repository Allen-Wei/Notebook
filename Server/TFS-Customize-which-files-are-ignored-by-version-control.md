# TFS: Customize which files are ignored by version control

By default certain types of files (for example, .dll files) are ignored by version control. As a result:

* When you add ignored files to folders that are mapped in a local workspace, they do not appear in the __Pending Changes__ page in Team Explorer.
* When you try to add ignored files using the Add to Source Control dialog box (for example by dragging them into Source Control Explorer), they automatically appear in the __Excluded items__ tab.

You can configure which kinds of files are ignored by placing text file called __.tfignore__ in the folder where you want rules to apply. The effects of the .tfignore file are recursive. However, you can create .tfignore files in sub-folders to override the effects of a .tfignore file in a parent folder.

## .tfignore file rules

The following rules apply to a .tfignore file:

* `#` begins a comment line
* The `*` and `?` wildcards are supported.
* A filespec is recursive unless prefixed by the `\` character.
* `!` negates a filespec (files that match the pattern are not ignored)

## .tfignore file example

```base
######################################
# Ignore .cpp files in the ProjA sub-folder and all its subfolders
ProjA\*.cpp
#
# Ignore .txt files in this folder
\*.txt
#
# Ignore .xml files in this folder and all its sub-folders
*.xml
#
# Ignore all files in the Temp sub-folder
\Temp
#
# Do not ignore .dll files in this folder nor in any of its sub-folders
!*.dll
```

## Create and use a .tfignore file

While you can manually create a .tfignore text file using the above rules, you can also automatically generate one when the __Pending Changes__ page has detected a change.

> This only applies when using a local workspace. Files changed when working in a server workspace will check in without showing as a pending change in Team Explorer.

## To automatically generate a .tfignore file

1. In the __Pending Changes__ page, in the __Excluded Changes__ section, select the __Detected__ link. The __Promote Candidate Changes__ dialog box appears.
2. Select a file, open its context menu, and choose __Ignore this local item__, __Ignore by extension__, __Ignore by file name__, or __Ignore by folder__.
3. Choose __OK__ or __Cancel__ to close the __Promote Candidate Changes__ dialog box.
4. A `.tfignore` file appears in the __Included Changes__ section of the __Pending Changes__ page. You can open this file and modify it to meet your needs.

The .tfignore file is automatically added as an included pending change so that the rules you have created will apply to each team member who gets the file.

[Source](https://docs.microsoft.com/en-us/vsts/tfvc/add-files-server)