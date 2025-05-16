; This should work with AutoHotkey v2

; Alt+Enter to launch wezterm
!Enter::Run "wezterm-gui"

; Alt+b to launch or activate Chrome (always on workspace 2)
!b::
{
    ; First switch to workspace 2 where Chrome should be
    Send "!2"  ; Alt+2 to switch to workspace 2
    Sleep 300  ; Wait for workspace switch to complete
    
    ; Now check if Chrome exists in this workspace
    if WinExist("ahk_exe chrome.exe")
    {
        ; Chrome exists, activate it
        WinActivate "ahk_exe chrome.exe"
    }
    else
    {
        ; Chrome doesn't exist in workspace 2, launch a new instance
        Run "chrome"
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
    Send "!1"  ; Alt+2 to switch to workspace 2
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

; Launch glazewm once the script loads, this will let me know ahk is loaded up
try
{
    Run "C:\Users\JPOPPLE\scoop\apps\glazewm\3.8.1\glazewm.exe"
}
catch Error as e
{
    MsgBox "Error launching GlazeWM: " e.Message
}
