// services/Brightness.qml
// Backlight via brightnessctl.
//
// There is no brightness equivalent of the Pipewire service, and sysfs does
// not emit inotify events, so this cannot be pushed at us. Instead of polling
// on a timer like the old widget did, we re-read only after our own writes and
// when something tells us to (the hyprland brightness keys call refresh over
// IPC). A slow timer stays as a safety net for changes made behind our back.

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int  percent: 50
    property bool available: true

    signal changed()

    function icon() {
        if (root.percent < 34) return "󰃞"
        if (root.percent < 67) return "󰃟"
        return "󰃠"
    }

    function refresh() {
        if (!readProc.running) readProc.running = true
    }

    // Absolute set is linear, so a slider at 94% reports back 94%. The
    // exponential curve is only applied to relative steps, where it makes key
    // presses feel even across the range — using it here would land "set 94%"
    // at a reported 78%.
    function set(pct) {
        const clamped = Math.max(1, Math.min(100, Math.round(pct)))
        root._runWrite(clamped + "%", false)
    }

    function change(deltaPct) {
        // brightnessctl spells decrements "10%-", not "-10%"
        root._runWrite(deltaPct >= 0 ? "+" + deltaPct + "%" : Math.abs(deltaPct) + "%-", true)
    }

    function _runWrite(arg, curve) {
        if (writeProc.running) return
        writeProc.arg   = arg
        writeProc.curve = curve
        writeProc.running = true
    }

    // brightnessctl -m prints: name,class,value,percent%,max
    Process {
        id: readProc
        command: ["brightnessctl", "-m"]
        running: true
        onExited: code => {
            running = false
            if (code !== 0) root.available = false
        }
        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(",")
                if (parts.length < 4) return
                const n = parseInt(parts[3])
                if (isNaN(n)) return
                root.available = true
                if (n !== root.percent) {
                    root.percent = n
                    root.changed()
                }
            }
        }
    }

    // -e4 -n2: exponential curve with a floor of 2, carried over from the
    // hyprland keybinds so key presses feel the same as before.
    Process {
        id: writeProc
        property string arg:   "+5%"
        property bool   curve: true
        command: writeProc.curve
            ? ["brightnessctl", "-e4", "-n2", "set", writeProc.arg]
            : ["brightnessctl", "set", writeProc.arg]
        running: false
        onExited: {
            running = false
            root.refresh()
        }
    }

    // Safety net for external changes (power profile switches, other tools)
    Timer {
        interval: 30000
        repeat:   true
        running:  root.available
        onTriggered: root.refresh()
    }
}
