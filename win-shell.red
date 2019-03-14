Red []

win-shell: context [
	#system [
		#import [
			"shell32.dll" stdcall [
				;execute: routine [
				_win-exec: "ShellExecuteA" [
					hwndParent  [integer!]
					Operation   [c-string!]
					File        [c-string!]
					Parameters  [c-string!]
					Directory   [c-string!]
					ShowCmd     [integer!]
					return:     [integer!]
				] 

				; Operation values
				;   "open"
				;   "print"
				;   "explore"
				; ShowCmd values
				;     0   Hides the window and passes activation to another window.
				;
				;     1   Activates and displays a window. If the window is minimized
				;         or maximized, Windows restores it to its original size and
				;         position (same as 9).
				;
				;     2   Activates a window and displays it as an icon.
				;
				;     3   Activates a window and displays it as a maximized window.
				;
				;     4   Displays a window in its most recent size and position. The
				;         window that is currently active remains active.
				;
				;     5   Activates a window and displays it in its current size and
				;         position.
				;
				;     6   Minimizes the specified window and activates the top-level
				;         window in the system's list.
				;
				;     7   Displays a window as an icon. The window that is currently
				;         active remains active.
				;
				;     8   Displays a window in its current state. The window that is
				;         currently active remains active.
				;
				;     9   Activates and displays a window. If the window is minimized
				;         or maximized, Windows restores it to its original size and
				;         position (same as 1).

				_find-executable: "FindExecutableA" [
					File        [c-string!]
					Directory   [c-string!]
					Result      [c-string!]
					return:     [integer!]
				] 
			]

			"user32.dll" stdcall [
				_get-foreground-window: "GetForegroundWindow" [
					return:     [integer!]
				] 

				_get-desktop-window: "GetDesktopWindow" [
					return:     [integer!]
				] 

			; The active window is thread aware.
			;     get-active-window: routine [
			;         return:     [integer!]
			;     ] win-user "GetActiveWindow"

				_get-window: "GetWindow" [
					hWnd     [integer!] ; handle to window or control
					uCmd     [integer!] ; relationship flag
					return:  [integer!]
				] 

				;_find-window: "FindWindowA" [
				;	ClassName   [integer! c-string!]
				;	WindowName  [integer! c-string!]
				;	return:     [integer!]
				;] 

				_find-window-by-class: "FindWindowA" [
					ClassName   [c-string!]
					WindowName  [integer!]
					return:     [integer!]
				] 

				_find-window-by-name: "FindWindowA" [
					ClassName   [integer!]
					WindowName  [c-string!]
					return:     [integer!]
				] 

				_get-window-text: "GetWindowTextA" [
					hWnd     [integer!] ; handle to window or control
					lpString [c-string!]  ; address of buffer for text
					cch      [integer!] ; maximum number of characters to copy
					return:  [integer!] ; If the function succeeds, returns length in characters,
										; not including the terminating null character
				] 

				_get-window-text-length: "GetWindowTextLengthA" [
					hWnd     [integer!] ; handle to window or control
					return:  [integer!] ; If the function succeeds, returns length in characters.
				] 
			;--
				_send-message: "SendMessageA" [
					hWnd    [integer!]
					wMsg    [integer!]
					wParam  [integer!]
					lParam  [integer!]
					return: [integer!]
				] 

				_send-message-str: "SendMessageA" [
					hWnd    [integer!]
					wMsg    [integer!]
					wParam  [integer!]
					lParam  [c-string!]
					return: [integer!]
				] 

					;The lParam parameter is particularly interesting. It is a 32-bit
					;integer, which happens to be the size of a pointer, and this value
					;is often used to pass a pointer to a string or a UDT. In other words,
					;lParam is typeless.

				_window?: "IsWindow" [
					hWnd    [integer!]
					return: [integer!]
				] 

				_iconic?: "IsIconic" [
					hWnd    [integer!]
					return: [integer!]
				] 

				_zoomed?: "IsZoomed" [
					hWnd    [integer!]
					return: [integer!]
				] 

				_visible?: "IsWindowVisible" [
					hWnd    [integer!]
					return: [integer!]
				] 

				_open-icon: "OpenIcon" [
					hWnd    [integer!]
					return: [integer!]
				] 

				_set-active-window: "SetActiveWindow" [
					hWnd    [integer!]
					return: [integer!]
				] 

				_set-foreground-window: "SetForegroundWindow" [
					hWnd    [integer!]
					return: [integer!]
				] 

				_set-window-pos: "SetWindowPos" [
					hWnd    [integer!]      ; window handle
					hWndInsAfter [integer!] ; placement-order handle (HWND_XXX)
					x       [integer!]      ; horz position
					y       [integer!]      ; vertical position
					cx      [integer!]      ; width
					cy      [integer!]      ; height
					flags   [integer!]      ; window-positioning flags (SWP_XXX)
					return: [integer!]      ; Returns nonzero value on success.
				] 
			;--
				_keybd-event: "keybd_event" [
					vk-code     [integer!]
					scan-code   [integer!]
					flags       [integer!]
					extra-info  [integer!]
					return:     [integer!]
				] 

				_get-keyboard-layout: "GetKeyboardLayout" [
					thread-id   [integer!]  ; Use zero for current thread.
					return:     [integer!]
				] 

				_map-virtual-key: "MapVirtualKeyA" [
					vk-code     [integer!]
					map-type    [integer!]
					return:     [integer!]
				] 

				_map-virtual-key-ex: "MapVirtualKeyExA" [
					vk-code     [integer!]
					map-type    [integer!]
					h-keybd-lyt [integer!] ; keyboard layout handle
					return:     [integer!]
				] 

				_vk-key-scan: "VkKeyScanA" [
					ch      [byte!]   ; TCHAR character to translate
					return: [integer!]
				] 

				_vk-key-scan-ex: "VkKeyScanExA" [
					ch          [byte!]     ; character to translate
					h-keybd-lyt [integer!]  ; keyboard layout handle
					return:     [integer!]
				] 
			]
		]
		
		get-window-title: func [
			hWnd     [integer!] 
			result   [red-string!] 
			len      [integer!] 
			return:  [red-string!] 
			/local 
				lpString [c-string!]
				title [red-string!]
		][
			lpString: as c-string! result
			_get-window-text hWnd lpString len
			title: string/load lpString length? lpString UTF-8
			;SET_RETURN(title)
			return as red-string! stack/set-last as red-value! title
		]
	]

    null-buff: func [
        {Returns a null-filled string buffer of the specified length.}
        len [integer!]
    ][
		append/dup make string! len #"^@" len
		;make string! len
        ;to-string array/initial len #"^@"
    ]
	;execute: routine [
    win-exec: routine [
        hwndParent  [integer!]
        Operation   [string!]
        File        [string!]
        Parameters  [string!]
        Directory   [string!]
        ShowCmd     [integer!]
        return:     [integer!]
    ] [_win-exec 
		hwndParent 
		as c-string! Operation 
		as c-string! File 
		as c-string! Parameters 
		as c-string! Directory 
		ShowCmd
	]

    ; Operation values
    ;   "open"
    ;   "print"
    ;   "explore"
    ; ShowCmd values
    ;     0   Hides the window and passes activation to another window.
    ;
    ;     1   Activates and displays a window. If the window is minimized
    ;         or maximized, Windows restores it to its original size and
    ;         position (same as 9).
    ;
    ;     2   Activates a window and displays it as an icon.
    ;
    ;     3   Activates a window and displays it as a maximized window.
    ;
    ;     4   Displays a window in its most recent size and position. The
    ;         window that is currently active remains active.
    ;
    ;     5   Activates a window and displays it in its current size and
    ;         position.
    ;
    ;     6   Minimizes the specified window and activates the top-level
    ;         window in the system's list.
    ;
    ;     7   Displays a window as an icon. The window that is currently
    ;         active remains active.
    ;
    ;     8   Displays a window in its current state. The window that is
    ;         currently active remains active.
    ;
    ;     9   Activates and displays a window. If the window is minimized
    ;         or maximized, Windows restores it to its original size and
    ;         position (same as 1).

    find-executable: routine [
        File        [string!]
        Directory   [string!]
        Result      [string!]
        return:     [integer!]
    ] [_find-executable 
		as c-string! File 
		as c-string! Directory 
		as c-string! Result
	]

    get-foreground-window: routine [
        return:     [integer!]
    ] [_get-foreground-window]

    get-desktop-window: routine [
        return:     [integer!]
    ] [_get-desktop-window]

; The active window is thread aware.
;     get-active-window: routine [
;         return:     [integer!]
;     ] win-user "GetActiveWindow"

    get-window: routine [
        hWnd     [integer!] ; handle to window or control
        uCmd     [integer!] ; relationship flag
        return:  [integer!]
    ] [_get-window hWnd uCmd]
    ; GetWindow() Constants
    ;GW_HWNDFIRST:  0
    ;GW_HWNDLAST    1
    GW_HWNDNEXT:   2
    ;GW_HWNDPREV    3
    ;GW_OWNER       4
    GW_CHILD:      5
    ;GW_MAX         5

    ;find-window: routine [
    ;    ClassName   ;[integer! string!]
    ;    WindowName  ;[integer! string!]
    ;    return:     [integer!]
    ;] [
	;	if not TYPE_INTEGER(ClassName) [find-window-by-class ClassName WindowName]
	;	if not TYPE_INTEGER(WindowName) [find-window-by-name ClassName WindowName]
	;	;_find-window ClassName WindowName
	;]

    find-window-by-class: routine [
        ClassName   [string!]
        WindowName  [integer!]
        return:     [integer!]
    ] [_find-window-by-class as c-string! ClassName WindowName]

    find-window-by-name: routine [
        ClassName   [integer!]
        WindowName  [string!]
        return:     [integer!]
    ] [_find-window-by-name ClassName as c-string! WindowName]

    get-window-text: routine [
        hWnd     [integer!] ; handle to window or control
        lpString [string!]  ; address of buffer for text
        cch      [integer!] ; maximum number of characters to copy
        return:  [integer!] ; If the function succeeds, returns length in characters,
                            ; not including the terminating null character
    ] [
		_get-window-text hWnd as c-string! lpString cch
	]
	get-wTitle: routine [hWnd [integer!] result [string!] len [integer!] return: [string!]][
		get-window-title hWnd result len
	]
	
    get-window-text-length: routine [
        hWnd     [integer!] ; handle to window or control
        return:  [integer!] ; If the function succeeds, returns length in characters.
    ] [_get-window-text-length hWnd]
	
	window-title: func [hwnd [integer!] /local len result title] [
        ; The "add 1" accounts for the trailing null
        result: null-buff len: add 1 get-window-text-length hwnd
		if len > 1 [
			title: get-wTitle hwnd result len
			;print [hwnd title]
		]
		title
    ]

    active-window-title: does [window-title get-foreground-window]

    find-window-by-name-ex: func [
        {Allows you to specify an inexact window title. If the name you specify,
        which can include wildcards, is contained in a window title, it will match.}
        name [string!]
        /local hwnd
    ][
        hwnd: get-desktop-window
        ; can't call get-desktop-window inline here or it chokes.
        hWnd: get-window hwnd GW_CHILD
        while [hwnd <> 0] [;print [mold window-title hwnd mold name]
            if find window-title hwnd name [;/any  
                return hwnd
            ]
            hWnd: get-window hwnd GW_HWNDNEXT
        ]
    ]
;--
    send-message: routine [
        hWnd    [integer!]
        wMsg    [integer!]
        wParam  [integer!]
        lParam  [integer!]
        return: [integer!]
    ] [_send-message hWnd wMsg wParam lParam]

    send-message-str: routine [
        hWnd    [integer!]
        wMsg    [integer!]
        wParam  [integer!]
        lParam  [string!]
        return: [integer!]
    ] [_send-message-str hWnd wMsg wParam as c-string! lParam]

    WM_CLOSE:   to-integer #{00000010}  ; no parameters, returns 0 on success.
    WM_COMMAND: to-integer #{00000111}
    WM_USER:    to-integer #{00000400}

        ;The lParam parameter is particularly interesting. It is a 32-bit
        ;integer, which happens to be the size of a pointer, and this value
        ;is often used to pass a pointer to a string or a UDT. In other words,
        ;lParam is typeless.

    window?: routine [
        hWnd    [integer!]
        return: [integer!]
    ] [_window? hWnd]

    iconic?: routine [
        hWnd    [integer!]
        return: [integer!]
    ] [_iconic? hWnd]

    zoomed?: routine [
        hWnd    [integer!]
        return: [integer!]
    ] [_zoomed? hWnd]

    visible?: routine [
        hWnd    [integer!]
        return: [integer!]
    ] [_visible? hWnd]

    open-icon: routine [
        hWnd    [integer!]
        return: [integer!]
    ] [_open-icon hWnd]

    set-active-window: routine [
        hWnd    [integer!]
        return: [integer!]
    ] [_set-active-window hWnd]

    set-foreground-window: routine [
        hWnd    [integer!]
        return: [integer!]
    ] [_set-foreground-window hWnd]

    set-window-pos: routine [
        hWnd    [integer!]      ; window handle
        hWndInsAfter [integer!] ; placement-order handle (HWND_XXX)
        x       [integer!]      ; horz position
        y       [integer!]      ; vertical position
        cx      [integer!]      ; width
        cy      [integer!]      ; height
        flags   [integer!]      ; window-positioning flags (SWP_XXX)
        return: [integer!]      ; Returns nonzero value on success.
    ] [_set-window-pos hWnd hWndInsAfter x y cx cy flags]
;--
;     /*
;      * SetWindowPos Flags
;      */
;     #define SWP_NOSIZE          0x0001
;     #define SWP_NOMOVE          0x0002
;     #define SWP_NOZORDER        0x0004
;     #define SWP_NOREDRAW        0x0008
;     #define SWP_NOACTIVATE      0x0010
;     #define SWP_FRAMECHANGED    0x0020  /* The frame changed: send WM_NCCALCSIZE */
;     #define SWP_SHOWWINDOW      0x0040
;     #define SWP_HIDEWINDOW      0x0080
;     #define SWP_NOCOPYBITS      0x0100
;     #define SWP_NOOWNERZORDER   0x0200  /* Don't do owner Z ordering */
;     #define SWP_NOSENDCHANGING  0x0400  /* Don't send WM_WINDOWPOSCHANGING */
;
;     #define SWP_DRAWFRAME       SWP_FRAMECHANGED
;     #define SWP_NOREPOSITION    SWP_NOOWNERZORDER
;
;     #if(WINVER >= 0x0400)
;     #define SWP_DEFERERASE      0x2000
;     #define SWP_ASYNCWINDOWPOS  0x4000
;     #endif /* WINVER >= 0x0400 */
    swp-nosize: to-integer 16#{0001}
    swp-nomove: to-integer 16#{0002}
    swp-noactivate: to-integer 16#{0010}
    swp-show: to-integer 16#{0040}
    swp-hide: to-integer 16#{0080}
;
;     #define HWND_TOP        ((HWND)0)
;     #define HWND_BOTTOM     ((HWND)1)
;     #define HWND_TOPMOST    ((HWND)-1)
;     #define HWND_NOTOPMOST  ((HWND)-2)
    hwnd-topmost: -1

    ; a.k.a. app-activate
    activate: func [title [string!] /local hwnd] [
        either 0 <> hwnd: find-window-by-name 0 title [
            either 0 <> set-foreground-window hwnd [true][false]
        ][
            if 0 <> hwnd: find-window-by-name-ex title [
                either 0 <> set-foreground-window hwnd [true][false]
            ]
        ]
    ]

    keybd-event: routine [
        vk-code     [integer!]
        scan-code   [integer!]
        flags       [integer!]
        extra-info  [integer!]
        return:     [integer!]
    ] [_keybd-event vk-code scan-code flags extra-info]

    get-keyboard-layout: routine [
        thread-id   [integer!]  ; Use zero for current thread.
        return:     [integer!]
    ] [_get-keyboard-layout thread-id]

    ; If defined as a function, it will crash things (see send-keys below)
    ;cur-keyboard-layout: does [get-keyboard-layout 0]
    cur-keyboard-layout: get-keyboard-layout 0

    map-virtual-key: routine [
        vk-code     [integer!]
        map-type    [integer!]
        return:     [integer!]
    ] [_map-virtual-key vk-code map-type]

    map-virtual-key-ex: routine [
        vk-code     [integer!]
        map-type    [integer!]
        h-keybd-lyt [integer!] ; keyboard layout handle
        return:     [integer!]
    ] [_map-virtual-key-ex vk-code map-type h-keybd-lyt]

    vk-key-scan: routine [
        ch      [char!]   ; TCHAR character to translate
        return: [integer!]
    ] [_vk-key-scan as byte! ch/value]

    vk-key-scan-ex: routine [
        ch          [char!]     ; character to translate
        h-keybd-lyt [integer!]  ; keyboard layout handle
        return:     [integer!]
    ] [_vk-key-scan-ex as byte! ch/value h-keybd-lyt]
    ; If the function succeeds, the low-order byte of the return value contains
    ; the virtual-key code and the high-order byte contains the shift state,
    ; which can be a combination of the following flag bits.
    ; Bit Meaning
    ;     1 Either shift key is pressed.
    ;     2 Either CTRL key is pressed.
    ;     4 Either ALT key is pressed.
    ;     8 The Hankaku key is pressed
    ;     16 Reserved (defined by the keyboard layout driver).
    ;     32 Reserved (defined by the keyboard layout driver).
    key-scan-shift: to-integer #{0001}
    key-scan-ctrl:  to-integer #{0002}
    key-scan-alt:   to-integer #{0004}

    keyeventf-extendedkey: to-integer #{0001}
    keyeventf-keyup:       to-integer #{0002}


    ; If the key we're sending is uppercase, we have to send the shift code ourselves.
    send-key: func [key [integer! char!] /up /extended /local key-code kbd-lay] [
        ; Need to look further into VkKeyScan, just to be safe.
        ;if char? key [key: vk-key-scan key and to-integer #{FF}]
        ;key-code: map-virtual-key to-integer key 0
        ; cur-keyboard-layout is the culprit somehow. Even without using the
        ; other -ex functions, it crashes when I call this. If I define it
        ; as a value, rather than a function, all is well and it can even
        ; be used inline
        kbd-lay: cur-keyboard-layout ; Inlining chokes this
        if char? key [key: (to integer! #{FF}) and vk-key-scan-ex key kbd-lay]
        ;key-code: map-virtual-key key 0
        key-code: map-virtual-key-ex key 0 kbd-lay

        extended: either extended [keyeventf-extendedkey][0]
        up: either up [keyeventf-keyup][0]
        ;keybd-event key-code 0 (extended or up) 0
        keybd-event (to integer! key) key-code (extended or up) 0
    ]

    ;dummy: func [x] []  ; crash
    ;dummy: has [x] []  ; crash
    dummy: does []     ; OK

]


; mk-string: func [n[integer!] ch[string!]][to-string array/initial n ch]
;
; ;win-shell/execute 0 "open" "notepad.exe" "" "" 1
; ;win-shell/execute 0 "open" "calc.exe" "" "" 1
;
; result: mk-string 260 " "
; win-shell/find-executable "notepad.exe" "" result
; print ["<" trim result ">"]
;
; print win-shell/get-foreground-window
;
;print hwnd: win-shell/find-window "REBOL" "REBOL/View"

; print hwnd: win-shell/get-foreground-window ;find-window 0 0 ;-by-name 0 "REBOL/View"
; print win-shell/window-title hwnd
; print hwnd: win-shell/find-window-by-name-ex "MSDN*"
; print win-shell/window-title hwnd
; halt

; print win-shell/find-window-by-class "Winamp v1.x" 0
;
; winamp-hwnd: win-shell/find-window-by-class "Winamp v1.x" 0
; print win-shell/send-message winamp-hwnd win-shell/WM_COMMAND 40029 0
;

;halt


