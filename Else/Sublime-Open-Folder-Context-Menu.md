# 添加 "Open with Sublime Text 3" 到右键菜单




	@echo off
	SET st3Path=C:\Program Files\Sublime Text 3\sublime_text.exe
	 
	rem add it for all file types
	@reg add "HKEY_CLASSES_ROOT\*\shell\Open with Sublime Text 3"         /t REG_SZ /v "" /d "Open with Sublime Text 3"   /f
	@reg add "HKEY_CLASSES_ROOT\*\shell\Open with Sublime Text 3"         /t REG_EXPAND_SZ /v "Icon" /d "%st3Path%,0" /f
	@reg add "HKEY_CLASSES_ROOT\*\shell\Open with Sublime Text 3\command" /t REG_SZ /v "" /d "%st3Path% \"%%1\"" /f
	 
	rem add it for folders
	@reg add "HKEY_CLASSES_ROOT\Folder\shell\Open with Sublime Text 3"         /t REG_SZ /v "" /d "Open with Sublime Text 3"   /f
	@reg add "HKEY_CLASSES_ROOT\Folder\shell\Open with Sublime Text 3"         /t REG_EXPAND_SZ /v "Icon" /d "%st3Path%,0" /f
	@reg add "HKEY_CLASSES_ROOT\Folder\shell\Open with Sublime Text 3\command" /t REG_SZ /v "" /d "%st3Path% \"%%1\"" /f
	pause

上面的代码保存到`OpenWithSublimeText3.bat`文件, 然后执行.
PS: 如果安装ST3的之后已经勾选了"Open with Sublime Text 3", 上面的`rem add it for all file types`下的三行代码去掉.