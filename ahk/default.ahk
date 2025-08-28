#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
#WinActivateForce

ProcessSetPriority "H"

SetWinDelay -1
SetControlDelay -1

#Include "C:\Sandboxes\VD.ahk\VD.ah2"

VD.animation_on:=false

; Alt+b to launch or activate Chrome (always on workspace 2)
!b::
{
    ; First switch to workspace 2 where Chrome should be
    Send "!2"  ; Alt+2 to switch to workspace 2
    Sleep 300  ; Wait for workspace switch to complete
    
    ; Now check if Chrome exists in this workspace
    if WinExist("ahk_exe zen.exe")
    {
        ; Chrome exists, activate it
        WinActivate "ahk_exe zen.exe"
    }
    else
    {
        ; Chrome doesn't exist in workspace 2, launch a new instance
        Run "zen"
    }
}

; Win+Shift+r to reload the script
#+r::Reload

; Win+Shift+C Launch VSCode (Always workspace 3)
#+c::
{
  ; First switch to workspace 3 where VS Code should
    Send "!3"
    Sleep 300

    if WinExist("ahk_exe Code.exe")
    {
      WinActivate "ahk_exe Code.exe"
  }
  else
  {
      exe := '"' . StrReplace(A_AppData, "Roaming", "Local\Programs\Microsoft VS Code\code") . '"'
      Run(exe)
  }
}

; Win+Shift+T MS Teams
#+t::
{
    Send "!4"  ; Alt+4 to switch to workspace 4
    Sleep 300  ; Wait for workspace switch to complete
    
    if WinExist("ahk_exe ms-teams.exe")
    {
        ; Chrome exists, activate it
        WinActivate "ahk_exe ms-teams.exe"
    }
    else
    {
        Run "ms-teams"
    }
}

; Media Keys
; Alt+f11
!f9::Run "ahk_exe Cider.exe"
!f10::Media_Prev
!f11::Media_Play_Pause
!f12::Media_Next

; Virtal Desktop Switching
VD.createUntil(5) ;create until we have atleast 5 desktops

; This is a jump back keybind to the previous desktop
VD.RegisterDesktopNotifications()
VD.DefineProp("CurrentVirtualDesktopChanged", {Call:CurrentVirtualDesktopChanged})
VD.previous_desktopNum:=1
CurrentVirtualDesktopChanged(desktopNum_Old, desktopNum_New) {
  VD.previous_desktopNum:=desktopNum_Old
}
!+O::VD.goToDesktopNum(VD.previous_desktopNum)

; Move windows to specified desktop and follow
!+1::VD.MoveWindowToDesktopNum("A",1).follow()
!+2::VD.MoveWindowToDesktopNum("A",2).follow()
!+3::VD.MoveWindowToDesktopNum("A",3).follow()
!+4::VD.MoveWindowToDesktopNum("A",4).follow()
!+5::VD.MoveWindowToDesktopNum("A",5).follow()

; Move to specified desktop
!1::VD.goToDesktopNum(1)
!2::VD.goToDesktopNum(2)
!3::VD.goToDesktopNum(3)
!4::VD.goToDesktopNum(4)
!5::VD.goToDesktopNum(5)
