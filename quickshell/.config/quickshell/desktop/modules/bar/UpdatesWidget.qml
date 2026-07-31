// modules/bar/UpdatesWidget.qml
// Pacman + AUR update count. Click → terminal running yay -Syu.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    property int totalUpdates:    0
    property int officialUpdates: 0
    property int aurUpdates:      0

    readonly property color updColor: root.totalUpdates > 0 ? Theme.accent : Theme.textMuted

    label:       "\uF019 " + root.totalUpdates
    labelSize:   Theme.fontPill
    labelBold:   false
    labelColor:  root.updColor
    anchorRight: true
    popupWidth:  230
    clickable:   true

    onClicked: if (!runUpdateProc.running) runUpdateProc.running = true

    Timer {
        interval: 300000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: if (!updProc.running) updProc.running = true
    }

    Process {
        id: updProc
        command: ["bash", "-c",
            "O=$(checkupdates 2>/dev/null | wc -l); " +
            "A=$(yay -Qteu 2>/dev/null | wc -l); " +
            "echo \"$((O+A)) $O $A\""]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split(" ")
                if (p.length >= 3) {
                    root.totalUpdates    = parseInt(p[0]) || 0
                    root.officialUpdates = parseInt(p[1]) || 0
                    root.aurUpdates      = parseInt(p[2]) || 0
                }
            }
        }
    }

    Process {
        id: runUpdateProc
        command: ["uwsm", "app", "--",
                  "wezterm", "start", "--class", "wezterm-updates",
                  "--", "yay", "-Syu"]
        running: false
        onExited: { running = false; updProc.running = true }
    }

    PopupHeader {
        icon:       "\uF019"
        iconColor:  root.updColor
        value:      root.totalUpdates + " update" + (root.totalUpdates !== 1 ? "s" : "")
        valueSize:  Theme.fontIcon
        valueColor: root.totalUpdates > 0 ? Theme.accent : Theme.textPrimary
        caption:    root.totalUpdates > 0 ? "Click to upgrade" : "System up to date"
    }

    Divider {}

    PopupRow { label: "Official"; value: root.officialUpdates.toString() }
    PopupRow { label: "AUR";      value: root.aurUpdates.toString()      }

    HintText {
        visible: root.totalUpdates > 0
        text:    "Click pill to run yay -Syu"
    }
}
