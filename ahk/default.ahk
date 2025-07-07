; This should work with AutoHotkey v2

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
