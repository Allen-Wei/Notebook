
## DOS Commands: 


	:: Created by: Shawn Brink
	:: http://www.eightforums.com
	:: Tutorial:  http://www.eightforums.com/tutorials/9611-jump-lists-reset-clear-windows-8-a.html


	del /F /Q %APPDATA%\Microsoft\Windows\Recent\*

	del /F /Q %APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*

	del /F /Q %APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*

	taskkill /f /im explorer.exe

	start explorer.exe


