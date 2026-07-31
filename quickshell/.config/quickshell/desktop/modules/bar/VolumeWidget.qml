// modules/bar/VolumeWidget.qml
// Volume via pactl. Scroll = adjust, click = mute toggle.
// TODO(phase 1+): replace the three polling processes with Quickshell.Services.Pipewire.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    property int    volumePct: 50
    property bool   muted:     false
    property string sinkName:  ""

    function volIcon() {
        if (root.muted || root.volumePct === 0) return "󰝟"
        if (root.volumePct < 33) return "󰕿"
        if (root.volumePct < 66) return "󰖀"
        return "󰕾"
    }

    readonly property color volColor: root.muted ? Theme.danger : Theme.textPrimary

    icon:        root.volIcon()
    iconColor:   root.volColor
    anchorRight: true
    popupWidth:  250
    clickable:   true
    scrollable:  true

    onClicked: if (!muteToggleProc.running) muteToggleProc.running = true

    onScrolled: up => {
        if (volChangeProc.running) return
        volChangeProc.delta   = up ? "+5%" : "-5%"
        volChangeProc.running = true
    }

    // ── Polling ────────────────────────────────────────────────
    Timer {
        interval: 2000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: {
            if (!volProc.running)  volProc.running  = true
            if (!muteProc.running) muteProc.running = true
            if (!sinkProc.running) sinkProc.running = true
        }
    }

    Process {
        id: volProc
        command: ["bash", "-c",
            "pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\\d+(?=%)' | head -1"]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => { var n = parseInt(line.trim()); if (!isNaN(n)) root.volumePct = n }
        }
    }

    Process {
        id: muteProc
        command: ["bash", "-c",
            "pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -c yes || true"]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => { root.muted = line.trim() === "1" }
        }
    }

    Process {
        id: sinkProc
        command: ["bash", "-c", "pactl get-default-sink 2>/dev/null | tr -d '\\n'"]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => { root.sinkName = line.trim() }
        }
    }

    Process {
        id: volChangeProc
        property string delta: "+5%"
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", delta]
        running: false
        onExited: { running = false; volProc.running = true }
    }

    Process {
        id: muteToggleProc
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
        running: false
        onExited: { running = false; muteProc.running = true }
    }

    // ── Popup ──────────────────────────────────────────────────
    PopupHeader {
        icon:       root.volIcon()
        iconColor:  root.volColor
        value:      root.volumePct + "%"
        valueColor: root.volColor
        caption:    root.muted ? "Muted" : "Active"
    }

    StatBar {
        width:        parent.width
        value:        root.volumePct
        fillColor:    root.volColor
        fillDuration: Theme.animNormal
    }

    HintText { text: "Scroll to adjust  •  Click pill to mute" }

    Divider {}

    Text {
        width:          parent.width
        text:           "Sink: " + (root.sinkName || "—")
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        color:          Theme.textSecondary
        elide:          Text.ElideRight
    }

    Row {
        spacing: 6

        Repeater {
            model: ["-20%", "-10%", "-5%", "+5%", "+10%", "+20%"]

            delegate: Rectangle {
                width:  36
                height: 22
                radius: 4
                color:  adjHov.containsMouse ? Theme.hoverFg : Theme.hoverBg

                Text {
                    anchors.centerIn: parent
                    text:             modelData
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontTiny
                    color:            Theme.textPrimary
                }

                MouseArea {
                    id: adjHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        if (volChangeProc.running) return
                        volChangeProc.delta   = modelData
                        volChangeProc.running = true
                    }
                }
            }
        }
    }
}
