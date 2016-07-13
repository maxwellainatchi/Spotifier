;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;; ;;;;;                                                                        ;;;;;
;;;;    ;     ;     ;     ;     ;     ;     ;     ;     ;     ;     ;     ;   ;;;;                                                                           ;;;;
;;;                                                                            ;;; 
;;;      ███████╗██████╗  ██████╗ ████████╗██╗███████╗██╗███████╗██████╗       ;;;
;;;;     ██╔════╝██╔══██╗██╔═══██╗╚══██╔══╝██║██╔════╝██║██╔════╝██╔══██╗     ;;;;
;;;;;    ███████╗██████╔╝██║   ██║   ██║   ██║█████╗  ██║█████╗  ██████╔╝    ;;;;;
;;;;     ╚════██║██╔═══╝ ██║   ██║   ██║   ██║██╔══╝  ██║██╔══╝  ██╔══██╗     ;;;;
;;;      ███████║██║     ╚██████╔╝   ██║   ██║██║     ██║███████╗██║  ██║      ;;;
;;;;     ╚══════╝╚═╝      ╚═════╝    ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝     ;;;;
;;;;;              (font name: ANSI Shadow, from patorjk.com)                ;;;;;
;;;;   ╔═══════════════════════════════════════════════════════════════╗      ;;;;
;;;    ║ ███████████████████████████████████████████████████████████████       ;;;
;;;;   ║ ██  Spotifier: Spotify Notifications/Miniplayer              ██      ;;;;
;;;;;  ║ ██  By Maxwell Ainatchi                                      ██     ;;;;;
;;;;   ║ ██  v1.010                                                   ██      ;;;;
;;;    ║ ██═══════════════════════════════════════════════════════════██       ;;;
;;;    ║ ██═══════════════════════════════════════════════════════════██       ;;;
;;;;   ║ ██  A free Spotify notifier/miniplayer. Only works when      ██      ;;;;
;;;;;  ║ ██  Spotify main window is open, not minimized to tray.      ██     ;;;;;
;;;;   ║ ██  Shift + Control + F12 to show/hide Miniplayer by default.██      ;;;;
;;;    ║ ██───────────────────────────────────────────────────────────██       ;;;
;;;;   ║ ██  KNOWN BUGS (as of v1.000):                               ██      ;;;;
;;;;;  ║ ██     - when in aggressive mode, the Spotify main window    ██     ;;;;;
;;;;   ║ ██       will be repeatedly forced to the front while the    ██      ;;;;
;;;    ║ ██       notification window is open while the main window   ██       ;;;
;;;;   ║ ██       being forced open.                                  ██      ;;;;
;;;;;  ║ ██───────────────────────────────────────────────────────────██     ;;;;;
;;;;   ║ ██  FOR FUTURE UPDATES (not implemented as of v1.010):       ██      ;;;;
;;;    ║ ██     - put preferences in GUI window, not just editable    ██       ;;;
;;;;   ║ ██       INI file.                                           ██      ;;;;
;;;;;  ║ ██     - possible picture or gradient background             ██     ;;;;;
;;;;   ║ ██     - drop shadows on buttons/prettify buttons            ██      ;;;;
;;;    ║ ██     - investigate fetching title from the tray icon, so   ██       ;;;
;;;;   ║ ██       even if the main window is minimized to the tray,   ██      ;;;;
;;;;;  ║ ██       you can still get notifications                     ██     ;;;;;
;;;;   ║ ██     - add "no tray icon" option                           ██      ;;;;
;;;    ╚═███████████████████████████████████████████████████████████████       ;;;
;;;     ;     ;     ;     ;     ;     ;     ;     ;     ;     ;     ;     ;    ;;;
;;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;   ;;;  ;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance, Force ;ensure that it can only run once

;Config Options - Can be changed
	MiniPlayerTrigger = +^F12 ;Hotkey for the miniplayer
	FontSize = 12 ;the font size
	FontColor = White ;the font color
	NotificationDisplayTime = 5 ;number of seconds the notification displays for
	CheckInterval = 100 ;checks for song change every x milliseconds
	GuiColor = 009ACD ;background color for the GUI
	GuiPosition = 4 ;location of the Gui: in order, top left, top right, bottom left, bottom right
	Agressive = false ;If the app is aggressive, it will force Spotify to open if the main window isn't detected
	Persistent = false ;If the app is persistent, the main window will not disappear
	AlwaysOnTop = false ;Only applies if persistent

;DO NOT CHANGE - will possibly destroy functionality
	Hidden = true ;whether the GUI is shown
	Title = ;no initial title
	PauseTitle = Spotify ;to check against
	NoTitle = ;to check against
	PauseMessage = Paused ;what to display if Spotify is paused
	SpotifyClosedMessage = Please open the Spotify Main Window! `r`n Click to launch... ;what to display if the spotify window is closed
	LoadingMessage = Opening Spotify...
	GuiWindowTitle = Max Ainatchi - Spotify Notifications ;name of the window - not shown
	SpotifyWindowClass = SpotifyMainWindow ;the ahk_class of the spotify main window
 
	;File sources
		SpotifySource = %userprofile%/AppData/Roaming/Spotify/spotify.exe ;source of the spotify app
		IconSource = ./lib/img/tray.ico ;path to the thumbnail
		PlaySource = ./lib/img/play.png ;path to the play button icon
		PauseSource = ./lib/img/pause.png ;path to the pause button icon
		NextSource = ./lib/img/next.png ;path to the next button icon
		PreviousSource = ./lib/img/previous.png ;path to the previous button icon
		IniSource = ./lib/config/preferences.ini
		DefaultIniSource = ./lib/config/default_preferences.ini

Gosub, initialize ;initialize the app

;-------------------------------------------------------

initialize: ;set initialization params
	Gosub, ReadAllPrefs
	SetTimer, CheckWindow, %CheckInterval% ;checks to see if the title has changed every .1 seconds
	Hotkey, %MiniPlayerTrigger%, TriggerMiniPlayer ;binds the hotkey
	Menu, Tray, NoStandard ;removes the standard menu items from the tray menu
	Menu, Tray, Click, 1 ;click the icon once to launch the interface
	Menu, Tray, Icon, %IconSource% ;sets the tray icon
	Menu, Tray, Add, Open/Close MiniPlayer (F12), TriggerMiniPlayer ;add the open/close item
	Menu, Tray, Add ;add a separator
	Menu, Tray, Add, Open Preferences, OpenPreferences
	Menu, Tray, Add, Reset Default Preferences, ResetPreferences
	Menu, Tray, Add ;add a separator
	Menu, Tray, Add, Exit, ExitApp ;add an exit button
	Menu, Tray, Default, Open/Close MiniPlayer (F12) ;make the open/close the default option - makes the tray icon click do this
	Return
;--------------------------------------------------------

SetPosition: ;set the gui position
	xPos = 0 ;the left edge horizontal position
	yPos = 0 ;the top edge vertical position
	SysGet, MonitorWorkArea, MonitorWorkArea ;find the area of the monitor
	WinGetPos,,,GuiWidth, GuiHeight, %GuiWindowTitle% ;get the width and height of the gui window, which is dynamically calculated
	if (GuiPosition == "1") { ;top left
		xPos = 0
		yPos = 0
	} else if (GuiPosition == "2") { ;top right
		xPos := MonitorWorkAreaRight - GuiWidth
		yPos = 0
	} else if (GuiPosition == "3") { ;bottom left 
		xPos = 0
		yPos := MonitorWorkAreaBottom - GuiHeight
	} else { ;bottom right
		xPos := MonitorWorkAreaRight - GuiWidth
		yPos := MonitorWorkAreaBottom - GuiHeight
	}
	WinMove, %GuiWindowTitle%,, %xPos%, %yPos% ;move the vindow to the indicated position
	Return
;-------------------------------------------------------

CheckWindow: ;checks to see if the window's title has changed

	WinGetTitle, AltTitle, ahk_class SpotifyMainWindow ;fetches the song info and stores it in AltTitle

	if (AltTitle == PauseTitle) { ;if the music is paused
		AltTitle = %PauseMessage% ;warn that the music is paused
	}

	if (AltTitle == NoTitle) { ;if spotify isn't detected
		if (Agressive == "false") { ;if the program won't be aggressive in enforcing functionality
			AltTitle = %SpotifyClosedMessage% ;warn that the app won't work, and inform that you can click to reopen
		} Else { ;if the program is aggressive
			AltTitle = %LoadingMessage% ;notify the user that spotify is opening
			Gosub, LabelClick ;force spotify open
		}
	}

	if (title != AltTitle) { ;if the title has changed
		Gui, destroy ;kills the old notification, if it isn't dead already
		Gosub, createGui ;recreates the gui window
		Title = %AltTitle% ;corrects the title
		LoopSize := NotificationDisplayTime * (1000/CheckInterval) ;convert loop time to the desired number of seconds
		loop, %LoopSize% { ;displays notification for LoopSize seconds
			WinGetTitle, AltTitle, ahk_class %SpotifyWindowClass% ;find the spotify main window
			if (title != AltTitle or hidden == true) { ;makes sure the title doesnt change in the meantime
				GoSub, checkwindow ;if it does, go through the change again
			}
			sleep, %CheckInterval% ;waits for CheckInterval seconds
		}
		;if (Persistent == false) { ;BROKEN
			Gui, destroy ;kills the Gui
			hidden = true ;the window is no longer visible
		;}
	}

	old = %MiniPlayerTrigger% ;the old hotkey
	IniRead, MiniPlayerTrigger, %IniSource%, NoRestart, MiniPlayerTrigger, +^F12 ;read the INI pref for the hotkey
	if (old != MiniPlayerTrigger) { ;if the hotkey was changed
		Hotkey, %old%, TriggerMiniPlayer, Off ;disables the old hotkey
		Hotkey, %MiniPlayerTrigger%, TriggerMiniPlayer, On ;binds the hotkey
	}
	Return
;--------------------------------------------------------

NextSong: ;goes to the next song
	SendInput, {Media_Next} ;activate the virtual next song button
	Return

LastSong: ;goes to the last song
	SendInput, {Media_Prev} ;activate the virtual previous song button
	Return

PlayPause: ;toggles play/pause song
	SendInput, {Media_Play_Pause} ;activate the virtual play/pause song button
	Return
;--------------------------------------------------------

TriggerMiniPlayer: ;trigger the gui to open or close, as necessary
	if (hidden == "true") { ;if the gui isn't shown
		Gosub, createGui ;show the gui
	} else { ;if the gui is already visible
		Gui, destroy ;hide it
		hidden = true ;the gui is not visible
	}
	Return 

CreateGui: ;create the gui and set the text
	Gosub, ReloadPrefs ;reload the preferences before initializing the GUI

	;if (Persistent == "true" && AlwaysOnTop == "false") { ;BROKEN
	;	Gui, -SysMenu +Owner ;creates an immutable Gui
	;} else {
		Gui, +AlwaysOnTop -SysMenu +Owner ;creates an immutable Gui
	;}

	StringReplace, TextBody, AltTitle, - , `r`n Song: ;sets up the message to display
	if (TextBody != PauseMessage and TextBody != SpotifyClosedMessage and TextBody != LoadingMessage) { ;so long as a song is playing
		TextBody = Artist: %TextBody% ;set the message to the correct song info
	}

	Gui, add, Picture, w20 h20 xp+0 yp+10 gLastSong, %PreviousSource% ;add the previous button
	if (textbody != PauseMessage) { ;if a song is playing
		Gui, add, Picture, w20 h20 xp+30 yp+0 gPlayPause, %PauseSource% ;add the pause button
	} Else { ;if a song is paused
		Gui, add, Picture, w20 h20 xp+30 yp+0 gPlayPause, %PlaySource% ;add the play button
	}
	Gui, add, Picture, w20 h20 xp+30 yp+0 gNextSong, %NextSource% ;add the next button

	Gui, Font, s%FontSize% c%FontColor% ; Set font size and color
	Gui, add, Text, h%FontSize% xp-60 yp+25 gLabelClick, %textbody% ;displays the song info

	Gui, color, %GuiColor% ;sets the gui color
	Menu, Tray, Tip, Spotify Notifier/Miniplayer `r`n %TextBody% ;set the tray tip to display the song info
	Gui, Show, AutoSize NoActivate x0 y0 h50, %GuiWindowTitle% ;shows the Gui at the top left corner
	WinSet, Style, -0xC00000, %GuiWindowTitle% ; remove the titlebar and border(s)
	GoSub, SetPosition ;moves the gui to the specified position
	hidden = false ;the gui is now shown
	return 

LabelClick: ;set the action to be taken on clicking the song info/message
	run %SpotifySource% ;launch spotify
	Return
;--------------------------------------------------------

ReadAllPrefs: ;reads the preferences from the INI file
	Gosub, ReadReconfigurablePrefs
	IniRead, FontSize, %IniSource%, RestartRequired, FontSize, 12
	IniRead, CheckInterval, %IniSource%, RestartRequired, CheckInterval, 100
	IniRead, Persistent, %IniSource%, RestartRequired, Persistent, 100
	IniRead, AlwaysOnTop, %IniSource%, RestartRequired, AlwaysOnTop, 100
	Return

ReadReconfigurablePrefs: ;reads only those preferences that don't require restart
	IniRead, FontColor, %IniSource%, NoRestart, FontColor, White
	IniRead, GuiColor, %IniSource%, NoRestart, GuiColor, 009ACD
	IniRead, MiniPlayerTrigger, %IniSource%, NoRestart, MiniPlayerTrigger, +^F12
	IniRead, NotificationDisplayTime, %IniSource%, NoRestart, NotificationDisplayTime, 5
	IniRead, GuiPosition, %IniSource%, NoRestart, GuiPosition, 4
	IniRead, Agressive, %IniSource%, NoRestart, Agressive, False
	Return

ReloadPrefs: ;properly reloads the preferences configuration
	old = %MiniPlayerTrigger% ;the old
	Gosub, ReadReconfigurablePrefs ;read the preferences to the proper variables
	if (old != MiniPlayerTrigger) { ;if the hotkey was changed
		Hotkey, %old%, TriggerMiniPlayer, Off ;disables the old hotkey
		Hotkey, %MiniPlayerTrigger%, TriggerMiniPlayer, On ;binds the hotkey
	}
	GoSub, SetPosition ;set the position of the GUI
	Return

OpenPreferences: 
	Run %IniSource%
	Return

ResetPreferences:
	MsgBox, 4,, Are you sure you want to reset your preferences to the default? (press Yes or No)
	IfMsgBox Yes
    	Gosub, CopyDefaultToUserPrefs
    Else
    	MsgBox, Cancelled.
	Return

CopyDefaultToUserPrefs:
	FileCopy, %DefaultIniSource%, %IniSource%, True
	MsgBox, Completed.
	Return
;--------------------------------------------------------

ExitApp: ;quit the app
	ExitApp ;close the app
	Return
;--------------------------------------------------------