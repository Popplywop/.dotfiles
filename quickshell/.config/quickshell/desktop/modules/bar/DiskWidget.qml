// modules/bar/DiskWidget.qml
// Disk usage for /. Hover → used/free/total.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    property int    diskPct:   0
    property string diskUsed:  "—"
    property string diskTotal: "—"
    property string diskFree:  "—"

    function diskColor(pct) {
        if (pct >= 90) return Theme.danger
        if (pct >= 80) return Theme.warn
        return Theme.textPrimary
    }

    icon:        "󰋊"
    iconSize:    Theme.fontPill
    iconColor:   root.diskColor(root.diskPct)
    anchorRight: true
    popupWidth:  230

    Timer {
        interval: 60000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: if (!diskProc.running) diskProc.running = true
    }

    Process {
        id: diskProc
        command: ["bash", "-c", "df -h / | awk 'NR==2{print $5+0, $3, $2, $4}'"]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split(" ")
                if (p.length >= 4) {
                    root.diskPct   = parseInt(p[0])
                    root.diskUsed  = p[1]
                    root.diskTotal = p[2]
                    root.diskFree  = p[3]
                }
            }
        }
    }

    PopupHeader {
        icon:       "󰋊"
        iconColor:  root.diskColor(root.diskPct)
        value:      root.diskPct + "%"
        valueColor: root.diskColor(root.diskPct)
        caption:    "Disk  (/)"
    }

    StatBar {
        width:     parent.width
        value:     root.diskPct
        fillColor: root.diskColor(root.diskPct)
    }

    Divider {}

    PopupRow { label: "Used";  value: root.diskUsed  }
    PopupRow { label: "Free";  value: root.diskFree  }
    PopupRow { label: "Total"; value: root.diskTotal }
}
