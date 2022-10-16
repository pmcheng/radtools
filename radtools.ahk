; RadTools
; by Phillip Cheng MD MS
; phillip.cheng@med.usc.edu

; This script provides miscellaneous functionality to improve radiologist productivity
; at USC.  It adds the following keybindings:

; Alt-Q: show Synapse 5 PowerJacket.  
; Alt-W: show Synapse 5 Worklist.
; F11: maximize Synapse 5 Viewer or Worklist across dual displays.

; Mouse keepalive function that is active when run on VDI.
; Citrix keepalive function

#SingleInstance force
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

Menu, Tray, Add, About, about
Menu, Tray, Add

Menu, Tray, NoStandard
Menu, Tray, Icon, radtools.ico
Menu, Tray, Add, Mouse Move, mouse_mode

mouse:=0
if Instr(A_ComputerName,"DHSVDI") {
    Menu, Tray, ToggleCheck, Mouse Move
    mouse:=1
}

Menu, Tray, Add, Citrix KeepAlive, citrix_mode
Menu, Tray, ToggleCheck, Citrix KeepAlive
citrix:=1
Menu, Tray, Add
;Menu, Tray, Add, Synapse 5 functions
Menu, Tray, Add, F11 maximizes window, f11_mode
Menu, Tray, ToggleCheck, F11 maximizes window
f11:=1
Menu, Tray, Add, Alt-Q toggles PowerJacket, alt_q_mode
Menu, Tray, ToggleCheck, Alt-Q toggles PowerJacket
altq:=1
Menu, Tray, Add, Alt-W toggles Worklist, alt_w_mode
Menu, Tray, ToggleCheck, Alt-W toggles Worklist
altw:=1
Menu, Tray, Add
Menu, Tray, Add, Exit, exit


SetTitleMatchMode, 2

f11toggle:=0
delay := 3*60*1000  ; 3 minute wait
SetTimer, check_idle, %delay%
return

mouse_mode:
    Menu, Tray, ToggleCheck, Mouse Move
    mouse:=!mouse
    return

citrix_mode:
    Menu, Tray, ToggleCheck, Citrix KeepAlive
    citrix:=!citrix
    return

f11_mode:
    Menu, Tray, ToggleCheck, F11 maximizes window
    f11:=!f11
    return

alt_q_mode:    
    Menu, Tray, ToggleCheck, Alt-Q toggles PowerJacket
    altq:=!altq
    return

alt_w_mode:    
    Menu, Tray, ToggleCheck, Alt-W toggles Worklist
    altw:=!altw
    return

about:
    Gui +OwnDialogs
    Msgbox,,RadTools,
(
RadTools: Radiology Tools for USC
v. 2021-04-17

by Phillip Cheng MD MS
phillip.cheng@med.usc.edu

Mouse Move: make periodic tiny mouse movements if idle.
Citrix KeepAlive: keep Citrix session alive.
F11: maximize Synapse 5 Viewer/Worklist across dual displays.
Alt-Q: toggle Synapse 5 PowerJacket.
Alt-W: toggle Synapse 5 Worklist.
)
    Return


exit:
    ExitApp    
    
check_idle:
if (A_TimeIdle > %delay%) and (mouse) {
    MouseMove,1,0,,R
    MouseMove,-1,0,,R
}
if (citrix) {
    ControlSend,,{F15},\\Remote
}
return

$!q::
if (altq) {
    WinGet, ExStyle, ExStyle, PowerJacket
    WinGet, State, MinMax, PowerJacket
    If ((ExStyle & 0x8) and (State!=-1)) or WinActive("PowerJacket") {
        ; toggle off PowerJacket if it is either (AlwaysOnTop and not minimized), or active
        WinSet, AlwaysOnTop, Off, PowerJacket
        WinSet, Top,, Viewer
        WinActivate, Viewer
    } else if WinActive("Viewer") {
        Send !i
        WinWaitActive, PowerJacket,,1
        WinSet, AlwaysOnTop, On, PowerJacket
    } else if WinActive("Worklist") {
        WinActivate, Viewer
        WinActivate, PowerJacket
        WinSet, AlwaysOnTop, On, PowerJacket
    } else {
        Send !q
    }
} else {
    Send !q
}
return

~!w::
if (altw) {
    if WinActive("Viewer") or WinActive("PowerJacket") {
        WinActivate, Worklist
        WinSet, AlwaysOnTop, Off, PowerJacket
    } else if WinActive("Worklist") {
        WinActivate, Viewer
    }
}
return



$F11::
if (WinActive("Viewer") or WinActive("Worklist")) and (f11) {
 
    SysGet, MCount, MonitorCount
    SysGet, Mon1, MonitorWorkArea, 1
    if (MCount == 2) {
        SysGet, Mon2, MonitorWorkArea, 2
        if (Mon2Left<Mon1Left) {  ; 2 1
            SysGet, Mon1, MonitorWorkArea, 2
            SysGet, Mon2, MonitorWorkArea, 1  
        }
    }
    if (MCount == 3) { ; we assume that the left most monitor is the non-image monitor, and test common cases
        SysGet, Mon2, MonitorWorkArea, 2
        SysGet, Mon3, MonitorWorkArea, 3
        if (Mon3Left<Mon2Left) and (Mon3Left<Mon1Left) {
            if (Mon2Left<Mon1Left) {  ; 3 2 1
                SysGet, Mon1, MonitorWorkArea, 3
                SysGet, Mon3, MonitorWorkArea, 1  
            } else {  ; 3 1 2
                SysGet, Mon1, MonitorWorkArea, 3            
                SysGet, Mon2, MonitorWorkArea, 1
                SysGet, Mon3, MonitorWorkArea, 2
            }
        } else if (Mon1Left<Mon2Left) and (Mon3Left<Mon2Left) { ; 1 3 2
            SysGet, Mon2, MonitorWorkArea, 3
            SysGet, Mon3, MonitorWorkArea, 2
        }
    }
    WinRestore
    win10:=8 ; account for "invisible border" in Windows 10
    if (f11toggle == 0) { ; expand
        Switch MCount {
            case 1: WinMove,,, Mon1Left-win10, Mon1Top, Mon1Right-Mon1Left+2*win10, Mon1Bottom-Mon1Top+win10
            case 2: WinMove,,, Mon1Left-win10, Mon1Top, Mon2Right-Mon1Left+2*win10, Mon1Bottom-Mon1Top+win10
            case 3: WinMove,,, Mon2Left-win10, Mon2Top, Mon3Right-Mon2Left+2*win10, Mon2Bottom-Mon2Top+win10
        }
    } else {
        Switch MCount {
            case 1: WinMove,,, Mon1Left-win10, Mon1Top, Mon1Right-Mon1Left+2*win10, Mon1Bottom-Mon1Top+win10
            ; case 2: WinMove,,, Mon1Left-win10, Mon1Top, Mon1Right-Mon1Left+2*win10, Mon1Bottom-Mon1Top+win10 ; Set to left monitor
            case 2: WinMove,,, Mon2Left-win10, Mon2Top, Mon2Right-Mon2Left+2*win10, Mon2Bottom-Mon2Top+win10 ; Set to right monitor
            case 3: WinMove,,, Mon2Left-win10, Mon2Top, Mon2Right-Mon2Left+2*win10, Mon2Bottom-Mon2Top+win10
        }
    }
    f11toggle:=!f11toggle
} else {
    send {F11}
}
return
