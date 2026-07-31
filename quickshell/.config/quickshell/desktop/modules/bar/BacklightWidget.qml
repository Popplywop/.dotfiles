// modules/bar/BacklightWidget.qml
// Brightness via brightnessctl. Scroll to adjust.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    property int brightPct: 50

    function blIcon(pct) {
        if (pct < 34) return "󰃞"
        if (pct < 67) return "󰃟"
        return "󰃠"
    }

    icon:        root.blIcon(root.brightPct)
    iconSize:    Theme.fontPill
    anchorRight: true
    popupWidth:  220
    scrollable:  true

    onScrolled: up => {
        if (blChangeProc.running) return
        blChangeProc.step    = up ? "+5%" : "5%-"
        blChangeProc.running = true
    }

    Timer {
        interval: 5000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: if (!blProc.running) blProc.running = true
    }

    Process {
        id: blProc
        command: ["bash", "-c", "echo $(( $(brightnessctl g) * 100 / $(brightnessctl m) ))"]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => { var n = parseInt(line.trim()); if (!isNaN(n)) root.brightPct = n }
        }
    }

    Process {
        id: blChangeProc
        property string step: "+5%"
        command: ["brightnessctl", "set", step]
        running: false
        onExited: { running = false; blProc.running = true }
    }

    PopupHeader {
        icon:       root.blIcon(root.brightPct)
        iconColor:  Theme.accent
        value:      root.brightPct + "%"
        valueColor: Theme.accent
        caption:    "Brightness"
    }

    StatBar {
        width:        parent.width
        value:        root.brightPct
        fillColor:    Theme.accent
        fillDuration: Theme.animNormal
    }

    HintText { text: "Scroll to adjust" }
}
