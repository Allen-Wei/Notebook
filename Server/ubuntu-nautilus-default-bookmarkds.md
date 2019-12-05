The is no setting for this in Nautilus preferences or gesettings. Instead, the default bookarks are hard-coded be built from ~/.config/user-dirs.dirs.

It's not enough to just edit~/.config/user-dirs.dirs, however, since the directory list is rebuilt on login from /etc/xdg/user-dirs.defaults.

The solution is to comment out the directories that you do not want to show in Nautilus from both user-dir files. After logging out and back in, the unwanted bookmarks go away.

Testing showed that you need to edit both files. Only editing one or the other was not enough.

The easiest way to edit the file in /etc is to use sudo with a textual mode editor, such as sudo nano /etc/xdg/user-dirs.defaults.
