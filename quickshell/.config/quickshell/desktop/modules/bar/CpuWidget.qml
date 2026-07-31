// modules/bar/CpuWidget.qml
// CPU usage via /proc/stat diff (2-second sample). Hover → usage gauge.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    property int cpuPct: 0

    function cpuColor(pct) {
        if (pct >= 85) return Theme.danger
        if (pct >= 60) return Theme.warn
        return Theme.textPrimary
    }

    icon:        "\uF2DB"
    iconSize:    Theme.fontPill
    iconColor:   root.cpuColor(root.cpuPct)
    anchorRight: true
    popupWidth:  220

    Timer {
        interval: 5000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: if (!cpuProc.running) cpuProc.running = true
    }

    Process {
        id: cpuProc
        command: ["python3", "-c",
            "import time, re\n" +
            "def r():\n" +
            "    v=list(map(int,re.search(r'cpu\\\\s+(.+)',open('/proc/stat').read()).group(1).split()))\n" +
            "    return sum(v),v[3]\n" +
            "t,i=r(); time.sleep(2); t2,i2=r()\n" +
            "dt=t2-t; di=i2-i\n" +
            "print(round((dt-di)*100/dt) if dt else 0)"
        ]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => { var n = parseInt(line.trim()); if (!isNaN(n)) root.cpuPct = n }
        }
    }

    PopupHeader {
        icon:       "\uF2DB"
        iconColor:  root.cpuColor(root.cpuPct)
        value:      root.cpuPct + "%"
        valueColor: root.cpuColor(root.cpuPct)
        caption:    "CPU Usage"
    }

    StatBar {
        width:     parent.width
        height:    Theme.barThick
        value:     root.cpuPct
        fillColor: root.cpuColor(root.cpuPct)
    }

    HintText { text: "Updated every 5 s  (2 s sample)" }
}
