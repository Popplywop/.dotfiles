// shell.qml
// Entry point for the whole desktop shell.
//   qs -c desktop
//
// Everything lives in one instance so components share Theme and state.
// External triggers (keybinds, scripts) arrive over IPC:
//   qs -c desktop ipc call wallpicker toggle
//   qs -c desktop ipc call notifs dnd

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/modules/bar"
import "root:/modules/launcher"
import "root:/modules/notifications"
import "root:/modules/osd"
import "root:/modules/wallpicker"
import "root:/services"

ShellRoot {
    // Start the desktop-entry scan now instead of on first launcher open
    Component.onCompleted: Apps.warm()

    Bar {
        onLauncherRequested: launcher.toggle()
    }

    NotificationPopups {}

    Osd { id: osd }

    Launcher { id: launcher }

    WallPicker { id: wallPicker }

    IpcHandler {
        target: "launcher"

        function toggle(): void { launcher.toggle() }
        function open():   void { launcher.show()   }
        function close():  void { launcher.hide()   }
    }

    IpcHandler {
        target: "wallpicker"

        function toggle(): void { wallPicker.toggle() }
        function open():   void { wallPicker.show()   }
        function close():  void { wallPicker.cancel() }
    }

    // Brightness has no change notification of its own, so the hyprland
    // brightness keys route through here instead of calling brightnessctl.
    IpcHandler {
        target: "osd"

        function brightnessUp():   void { Brightness.change(5);  osd.showBrightness() }
        function brightnessDown(): void { Brightness.change(-5); osd.showBrightness() }
        function brightness(pct: int): void { Brightness.set(pct); osd.showBrightness() }
        function showVolume():     void { osd.showVolume() }
    }

    IpcHandler {
        target: "notifs"

        function dnd(): string {
            Notifs.doNotDisturb = !Notifs.doNotDisturb
            return Notifs.doNotDisturb ? "on" : "off"
        }
        function dismissAll(): void { Notifs.dismissAll()  }
        function clear():      void { Notifs.clearHistory() }
        function count():      int  { return Notifs.history.length }
    }
}
