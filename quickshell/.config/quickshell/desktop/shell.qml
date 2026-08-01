// shell.qml
// Entry point for the whole desktop shell.
//   qs -c desktop
//
// No bar. Chrome is a floating status island (top centre), an auto-hiding
// floating dock (bottom centre), and two edge flyouts:
//   left  — system dashboard, upper-left hot corner
//   right — quick settings, media, network and notifications
//
// External triggers arrive over IPC:
//   qs -c desktop ipc call launcher   toggle
//   qs -c desktop ipc call panel      left|right
//   qs -c desktop ipc call wallpicker toggle
//   qs -c desktop ipc call osd        brightnessUp|brightnessDown

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/components"
import "root:/modules/dock"
import "root:/modules/island"
import "root:/modules/launcher"
import "root:/modules/notifications"
import "root:/modules/osd"
import "root:/modules/panels"
import "root:/modules/wallpicker"
import "root:/services"

ShellRoot {
    id: shell

    // Start the desktop-entry scan now instead of on first launcher open
    Component.onCompleted: Apps.warm()

    // ── Chrome ─────────────────────────────────────────────────
    Island {
        onNotificationsRequested: quickPanel.toggle()
        onQuickSettingsRequested: quickPanel.toggle()
    }

    Dock {}

    // ── Flyouts ────────────────────────────────────────────────
    HotCorner {
        atTop:  true
        atLeft: true
        onTriggered: dashboard.show()
    }

    DashboardPanel { id: dashboard }

    QuickPanel {
        id: quickPanel

        onPowerRequested: action => {
            switch (action) {
            case "lock":     Quickshell.execDetached({ command: ["bash", "-c", "(sleep 0.5; hyprlock) & disown"] }); break
            case "logout":   Quickshell.execDetached({ command: ["hyprctl", "dispatch", "exit"] });                  break
            case "reboot":   Quickshell.execDetached({ command: ["systemctl", "reboot"] });                          break
            case "shutdown": Quickshell.execDetached({ command: ["systemctl", "poweroff"] });                        break
            }
        }
    }

    // ── Overlays ───────────────────────────────────────────────
    NotificationPopups {}

    Osd {
        id: osd
        // Do not throw a duplicate readout over the panel's own sliders
        suppressed: quickPanel.open
    }

    Launcher { id: launcher }

    WallPicker { id: wallPicker }

    // ── IPC ────────────────────────────────────────────────────
    IpcHandler {
        target: "launcher"

        function toggle(): void { launcher.toggle() }
        function open():   void { launcher.show()   }
        function close():  void { launcher.hide()   }
    }

    IpcHandler {
        target: "panel"

        function left():  void { dashboard.toggle() }
        function right(): void { quickPanel.toggle() }
        function close(): void { dashboard.hide(); quickPanel.hide() }
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
