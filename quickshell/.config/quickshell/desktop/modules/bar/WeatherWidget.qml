// modules/bar/WeatherWidget.qml
// Weather via Open-Meteo (Victoria TX). Hover → forecast.

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    readonly property string wttrScript: Quickshell.shellPath("scripts/wttr.py")

    property string barText:     " ?"
    property string tooltipText: "Loading…"

    label:       root.barText
    anchorLeft:  true
    anchorRight: false
    popupMargin: 50
    popupWidth:  290

    Timer {
        interval: 1800000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: if (!wxProc.running) wxProc.running = true
    }

    Process {
        id: wxProc
        command: [root.wttrScript]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => {
                try {
                    var j = JSON.parse(line.trim())
                    if (j.text)    root.barText     = j.text
                    if (j.tooltip) root.tooltipText = j.tooltip
                } catch (e) {}
            }
        }
    }

    Text {
        width:          parent.width
        text:           "󰖩  Weather — Victoria TX"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontHeader
        font.bold:      true
        color:          Theme.textSecondary
    }

    Divider {}

    Repeater {
        model: root.tooltipText.split("\n").filter(l => l.length > 0)

        delegate: Text {
            width:          root.contentWidth
            text:           modelData.replace(/<[^>]+>/g, "")
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontBody
            color:          Theme.textPrimary
            wrapMode:       Text.WordWrap
        }
    }
}
