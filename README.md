# Spotifier
#### v1.010
A free, portable Spotify notifier/miniplayer. 
Currently only works when Spotify main window is open, not minimized to tray.
Shift + Control + F12 to show/hide Miniplayer by default.

The code is written entirely in AutoHotKey for now.

## Known Bugs (as of v1.010):
- When in aggressive mode, the Spotify main window
will be repeatedly forced to the front
as long as the notification window is open.

## For Future Updates (not implemented as of v1.010):
- Put preferences in GUI window, not just editable INI file.
- Possible picture or gradient background
- Drop shadows on buttons/prettify buttons
- Use [nSpotify](https://github.com/stefan-baumann/nSpotify) to 
communicate with Spotify even when the main window is closed.
- Add "no tray icon" option
