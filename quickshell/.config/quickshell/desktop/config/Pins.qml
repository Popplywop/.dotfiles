// config/Pins.qml
// Dock pin list, in order. Each entry is a DesktopEntry id — the .desktop
// filename without its extension. Check with:
//
//   ls /usr/share/applications ~/.local/share/applications
//
// Ids are case sensitive: SteamLink ships as com.valvesoftware.SteamLink.

pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property var ids: [
        "org.wezfurlong.wezterm",
        "chromium",
        "com.valvesoftware.SteamLink",
        "cider",
    ]
}
