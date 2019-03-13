Red [
    title:  "send-keys"
    file:   %send-keys.red
    author: "Gregg Irwin"
    email:  gregg@pointillistic.com
    version: 0.0.1
    history: [
        0.0.1 [{initial release}]
    ]
	ported-by: "Toomas Vooglaid"
	ported-at: 2019-03-13
	Needs: View
]

;if not value? 'win-shell [
#include %win-shell.red
;]


win-key-sender: make object! [
	mod-words: [shift ctrl alt]

    key-modifiers: [
        VK_SHIFT    shift   #{10}
        VK_CTRL     ctrl    #{11}
        ;VK_CONTROL  control #{11}
        VK_ALT      alt     #{12}
        ;VK_MENU     menu    #{12}
    ]
    ; Translate binary hex values to integers
    ;key-modifiers: head  ; for View < 1.3
    parse key-modifiers [some [s:
        change binary! (to integer! s/1)
    ]]

    ; This list corresponds to the KF_/VK_ codes from Windows
    key-codes: [
    ; The KF_xxx Keystroke Message Flags are used when sending WM_KEY/WM_SYSKEY messages.
    ;     KF_EXTENDED      extended      #{0100}
    ;     KF_DLGMODE       dlgmode       #{0800}
    ;     KF_MENUMODE      menumode      #{1000}
    ;     KF_ALTDOWN       altdown       #{2000}
    ;     KF_REPEAT        repeat        #{4000}
    ;     KF_UP            up            #{8000}
        VK_LBUTTON       lbutton       #{01}
        VK_RBUTTON       rbutton       #{02}
        VK_CANCEL        cancel        #{03}
        VK_MBUTTON       mbutton       #{04}
        VK_BACK          back          #{08}
        VK_TAB           tab           #{09}
        VK_CLEAR         clear         #{0C}
        VK_RETURN        return        #{0D}
        VK_SHIFT         shift         #{10}
        VK_CONTROL       control       #{11}
        VK_ALT           alt           #{12}
        VK_MENU          menu          #{12}
        VK_PAUSE         pause         #{13}
        VK_CAPITAL       capital       #{14}
        VK_ESCAPE        escape        #{1B}
        VK_SPACE         space         #{20}
        VK_PRIOR         prior         #{21}
        VK_NEXT          next          #{22}
        VK_END           end           #{23}
        VK_HOME          home          #{24}
        VK_LEFT          left          #{25}
        VK_UP            up            #{26}
        VK_RIGHT         right         #{27}
        VK_DOWN          down          #{28}
        VK_SELECT        select        #{29}
        VK_PRINT         print         #{2A}
        VK_EXECUTE       execute       #{2B}
        VK_SNAPSHOT      snapshot      #{2C}
        VK_INSERT        insert        #{2D}
        VK_DELETE        delete        #{2E}
        VK_HELP          help          #{2F}
        VK_LWIN          lwin          #{5B}
        VK_RWIN          rwin          #{5C}
        VK_APPS          apps          #{5D}
        VK_NUMPAD0       numpad0       #{60}
        VK_NUMPAD1       numpad1       #{61}
        VK_NUMPAD2       numpad2       #{62}
        VK_NUMPAD3       numpad3       #{63}
        VK_NUMPAD4       numpad4       #{64}
        VK_NUMPAD5       numpad5       #{65}
        VK_NUMPAD6       numpad6       #{66}
        VK_NUMPAD7       numpad7       #{67}
        VK_NUMPAD8       numpad8       #{68}
        VK_NUMPAD9       numpad9       #{69}
        VK_MULTIPLY      multiply      #{6A}
        VK_ADD           add           #{6B}
        VK_SEPARATOR     separator     #{6C}
        VK_SUBTRACT      subtract      #{6D}
        VK_DECIMAL       decimal       #{6E}
        VK_DIVIDE        divide        #{6F}
        VK_F1            f1            #{70}
        VK_F2            f2            #{71}
        VK_F3            f3            #{72}
        VK_F4            f4            #{73}
        VK_F5            f5            #{74}
        VK_F6            f6            #{75}
        VK_F7            f7            #{76}
        VK_F8            f8            #{77}
        VK_F9            f9            #{78}
        VK_F10           f10           #{79}
        VK_F11           f11           #{7A}
        VK_F12           f12           #{7B}
        VK_F13           f13           #{7C}
        VK_F14           f14           #{7D}
        VK_F15           f15           #{7E}
        VK_F16           f16           #{7F}
        VK_F17           f17           #{80}
        VK_F18           f18           #{81}
        VK_F19           f19           #{82}
        VK_F20           f20           #{83}
        VK_F21           f21           #{84}
        VK_F22           f22           #{85}
        VK_F23           f23           #{86}
        VK_F24           f24           #{87}
        VK_NUMLOCK       numlock       #{90}
        VK_SCROLL        scroll        #{91}
        VK_LSHIFT        lshift        #{A0}
        VK_RSHIFT        rshift        #{A1}
        VK_LCONTROL      lcontrol      #{A2}
        VK_RCONTROL      rcontrol      #{A3}
        VK_LMENU         lmenu         #{A4}
        VK_RMENU         rmenu         #{A5}
        VK_PROCESSKEY    processkey    #{E5}
        VK_ATTN          attn          #{F6}
        VK_CRSEL         crsel         #{F7}
        VK_EXSEL         exsel         #{F8}
        VK_EREOF         ereof         #{F9}
        VK_PLAY          play          #{FA}
        VK_ZOOM          zoom          #{FB}
        VK_NONAME        noname        #{FC}
        VK_PA1           pa1           #{FD}
        VK_OEM_CLEAR     oem-clear     #{FE}
    ]
    ; Translate binary hex values to integers
    ;key-codes: head  ; for View < 1.3
    parse key-codes [some [s:
        change binary! (to integer! s/1)
    ]]

    keyeventf-extendedkey: to integer! #{0001}
    keyeventf-keyup:       to integer! #{0002}

    key-scan-mods: reduce [
        'shift to integer! #{0001}
        'ctrl  to integer! #{0002}
        'alt   to integer! #{0004}
    ]

    ;---
    target-window: target-hwnd: none
    delay: 0 ;.01
    modifiers: copy []
    count: keys: mod: time: none

    rules: [
        some [
            'wait set time [number! | time!] (wait time) |
            set mod ['shift | 'ctrl | 'alt] (_set-mod :mod) |
            ;set mod ['shift-up | 'ctrl-up | 'alt-up] (_clear-mod :mod) |
            set keys [word! | string! | char! | block!]
                set count opt integer! (_send-keys)
        ]
    ]
    ;---
;    print "" ; prevents crash

;     byte: func [
;         pos   [integer!] "A value fro 1 to 4, indicating which byte you want"
;         value [integer! binary!]
;     ][
;         value: value and pick [#{000000FF} #{0000FF00} #{00FF0000} #{FF000000}] pos
;         value: to integer! divide to integer! value (256 ** (pos - 1))
;         value and to integer! #{000000FF}
;     ]

    _vk-code-from-char: func [
        {Translates a character to the corresponding virtual-key code.}
        char [char!]
        /local result
    ][
        result: win-shell/vk-key-scan-ex char win-shell/cur-keyboard-layout
        result and to integer! #{FF}
    ]

    _shift-state-from-char: func [
        {Translates a character to the corresponding shift state.}
        char [char!]
        /local result
    ][
        result: win-shell/vk-key-scan-ex char win-shell/cur-keyboard-layout
        divide result and (to integer! #{FF00}) 256
    ]

COMMENT { Win APi docs on extended keys:
The extended-key flag indicates whether the keystroke message originated from
one of the additional keys on the enhanced keyboard. The extended keys consist
of the alt and ctrl keys on the right-hand side of the keyboard; the ins, del,
home, end, page up, page down and arrow keys in the clusters to the left of the
numeric keypad; the num lock key; the break (ctrl+pause) key; the print scrn
key; and the divide (/) and enter keys in the numeric keypad. The extended-key
flag is set if the key is an extended key.}

    _apply-shift-state-mods: func [shift-state [integer!] /up] [
        foreach [mod val] key-scan-mods [
            if (shift-state and val) <> 0 [
                ;print [key "applying" mod tab shift-state val either up ["up"]["down"]]
                either up [_clear-mod :mod][_set-mod :mod]
            ]
        ]
    ]

    _press-mod: func ['word [word!]] [
        _send-one-key key-modifiers/:word
    ]

    _release-mod: func ['word [word!]] [
        _send-one-key/up key-modifiers/:word
    ]

    ;_press-mod: func ['word [word!]] [_send-one-key key-modifiers/:word]
    ;_release-mod: func ['word [word!]] [_send-one-key/up key-modifiers/:word]

    _release-all-mods: does [
        foreach mod mod-words [
            _release-mod :mod
        ]
    ]

    _set-mod: func ['word [word!]] [
        if none? find modifiers word [
            _press-mod :word
            if not none? delay [wait delay]
        ]
        append modifiers word
    ]

    _clear-mod: func ['word [word!]] [
        remove find modifiers word
        if none? find modifiers word [
            _release-mod :word
            if not none? delay [wait delay]
        ]
    ]

    _send-one-key: func [
        key [integer! char! binary!]
        /up {Send a key-up event, rather than key-down}
        /extended {Send an extended key value.}
        /local key-code kbd-lay
    ][
		if binary? key [key: to-integer key]
        ;kbd-lay: win-shell/cur-keyboard-layout ; Inlining chokes this
        if char? key [key: _vk-code-from-char key]
        key-code: win-shell/map-virtual-key-ex key 0 win-shell/cur-keyboard-layout ;kbd-lay
        extended: either extended [keyeventf-extendedkey][0]
        up: either up [keyeventf-keyup][0]

        ; The last thing we'll do, before sending the key, is make sure the window
        ; that they want things sent to is active.
        ; This is a little tricky. If we activate the target window every
        ; time, it will hose things up like dialogs that come to the front
        ; as part of the response to keystrokes, that we may want to send
        ; keys to as well. This is really in the hands of the caller sending
        ; the keys. If they send keys that they know will bring up a dialog,
        ; they should *not* specify a target window.
        if all [
            target-hwnd <> 0
            target-hwnd <> win-shell/get-foreground-window
        ][
            win-shell/set-foreground-window target-hwnd
        ]

        win-shell/keybd-event key key-code (extended or up) 0
    ]

    _send-key: func [
        key [char! word!]
        /local key-code
    ][
        if char? key [_apply-shift-state-mods _shift-state-from-char key]
        key-code: either char? key [key][key-codes/:key]
        ;print ["_send-key" tab key tab key-code]
        _send-one-key key-code
        _send-one-key/up key-code
        if char? key [_apply-shift-state-mods/up _shift-state-from-char key]
        if not none? delay [wait delay]
    ]

    _send-keys: has [pos mod] [
        ;print [mold modifiers tab keys tab count]
        ; blockify the set of keys so we can treat them uniformly
        foreach item compose [(keys)] [
            ; You can't specify a repeat count for more than one item.
            ; i.e. no repeats inside blocks. Do we need that ability?
            loop any [count 1] [
                ; If we want to allow them to enter specific commands for 
                ; releasing modifier keys, we probably need to check them 
                ; here. It only makes sense to use them inside blocks of 
                ; course because they will be released automatically for 
                ; all other items.
                either pos: find [shift-up ctrl-up alt-up] item [
                    mod: pick mod-words index? pos
                    _clear-mod :mod
                ][
                    either series? item [
                        foreach key to string! item [_send-key key]
                    ][
                        _send-key item
                    ]
                ]
            ]
        ]
        _release-all-mods
        clear modifiers
    ]


    uppercase?: func [
        ch [char!]
    ][
        all [(ch >= #"A") (ch <= #"Z")]
    ]

    send: func [
        {Set target-window and delay before calling this if you don't use
        the global win-send-keys function.}
        key-spec [any-block!]
    ][
		target-hwnd: either none? target-window [
            none
        ][
            either integer? target-window [
                target-window
            ][
                win-shell/activate target-window
                win-shell/get-foreground-window
            ]
        ]
        ; Should we make sure modifiers are released before we start?
        _release-all-mods
        parse key-spec rules
        _release-all-mods
    ]

    ; win-send-keys is a global function
    set 'win-send-keys func [
        key-spec [any-block!]
        /to-window
            window [string! integer!]
        /delay
            time [time! number! none!]
        /local
            sender
    ][
        time: either delay [time] [.005]
        ;sender: make win-key-sender compose [target-window: (window) delay: (time)]
		;sender/send key-spec
		
		win-key-sender/target-window: window 
		win-key-sender/delay: time
        win-key-sender/send key-spec
    ]
]
view [
	below
	code: area 500 focus {win-send-keys/to-window ["Whatever"] "Untitled - Notepad"} 
	button "Evaluate" [do code/text]
]




