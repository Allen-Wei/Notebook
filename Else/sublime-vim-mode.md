# Sublime open vim mode
## Vintage Mode

### Overview

Vintage is a vi mode editing package for Sublime Text 2. It allows you to combine vi's command mode with Sublime Text's features, including multiple selections.
Vintage mode is developed in the open, and patches are more than welcome. If you'd like to contribute, details are on the GitHub page.

### Enabling Vintage

Vintage is disabled by default, via the ignored_packages setting. If you remove "Vintage" from the list of ignored packages, you'll be able to edit with vi keys:

1. Select the Preferences/Settings - Default menu item
2. Edit the ignored_packages setting, changing it from:

    "ignored_packages": ["Vintage"]

to:

    "ignored_packages": []

3. now save the file.

Vintage mode is now enabled - you'll see "INSERT MODE" listed in the status bar
Vintage starts in insert mode by default. This can be changed by adding:

    "vintage_start_in_command_mode": true

to your User Settings. 

