// modules/bar/MemWidget.qml
// RAM usage via /proc/meminfo. Hover → used/available/total.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    property int    memPct:   0
    property string memUsed:  "—"
    property string memTotal: "—"
    property string memAvail: "—"

    function memColor(pct) {
        if (pct >= 90) return Theme.danger
        if (pct >= 75) return Theme.warn
        return Theme.textPrimary
    }

    icon:        "󰍛"
    iconSize:    Theme.fontPill
    iconColor:   root.memColor(root.memPct)
    anchorRight: true
    popupWidth:  230

    Timer {
        interval: 10000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: if (!memProc.running) memProc.running = true
    }

    Process {
        id: memProc
        command: ["bash", "-c", `
awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}/MemFree/{f=$2}/Cached:/{c=$2}END{
    u=t-a; printf "%d %.1f %.1f %.1f\\n",(u*100/t),(u/1048576),(t/1048576),(a/1048576)
}' /proc/meminfo`]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split(" ")
                if (p.length >= 4) {
                    root.memPct   = parseInt(p[0])
                    root.memUsed  = p[1] + " G"
                    root.memTotal = p[2] + " G"
                    root.memAvail = p[3] + " G"
                }
            }
        }
    }

    PopupHeader {
        icon:       "󰍛"
        iconColor:  root.memColor(root.memPct)
        value:      root.memPct + "%"
        valueColor: root.memColor(root.memPct)
        caption:    "RAM"
    }

    StatBar {
        width:     parent.width
        value:     root.memPct
        fillColor: root.memColor(root.memPct)
    }

    Divider {}

    PopupRow { label: "Used";      value: root.memUsed  }
    PopupRow { label: "Available"; value: root.memAvail }
    PopupRow { label: "Total";     value: root.memTotal }
}
