// modules/bar/NetworkWidget.qml
// Network status. Hover → SSID, signal strength, IP, gateway.
// TODO(phase 3): swap the poll for Quickshell.Networking and add a wifi picker.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    property string ssid:      ""
    property string ipAddr:    ""
    property string gateway:   ""
    property string iface:     ""
    property int    signalPct: 0
    property bool   connected: false
    property bool   isWifi:    true

    // NOTE: all three wifi strength levels rendered the same glyph in the
    // original; strength is conveyed by colour and the popup gauge instead.
    function netIcon() {
        if (!root.connected) return "󰈂"
        if (!root.isWifi)    return "󰈁"
        return "\uF1EB"
    }

    function signalColor() {
        if (!root.connected)     return Theme.danger
        if (root.signalPct < 40) return Theme.warn
        return Theme.textPrimary
    }

    icon:        root.netIcon()
    iconSize:    Theme.fontPill
    iconColor:   root.signalColor()
    anchorRight: true
    popupWidth:  260

    Timer {
        interval: 10000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: if (!netProc.running) netProc.running = true
    }

    Process {
        id: netProc
        command: ["bash", "-c",
            "IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}'); " +
            "IP=$(ip -4 addr show \"$IFACE\" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1); " +
            "GW=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $3; exit}'); " +
            "SSID=$(iwgetid \"$IFACE\" -r 2>/dev/null); " +
            "SIG=$(awk -v iface=\"$IFACE\" '$1==iface\":\"{gsub(/[^0-9]/,\"\",$3); print int($3*100/70)}' /proc/net/wireless 2>/dev/null); " +
            "echo \"${IFACE:-?} ${IP:-N/A} ${GW:-N/A} ${SSID:-ethernet} ${SIG:-0}\""
        ]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split(" ")
                if (p.length >= 5) {
                    root.iface     = p[0]
                    root.ipAddr    = p[1]
                    root.gateway   = p[2]
                    root.ssid      = p[3]
                    root.signalPct = Math.min(100, parseInt(p[4]) || 0)
                    root.isWifi    = p[3] !== "ethernet"
                    root.connected = p[1] !== "N/A"
                }
            }
        }
    }

    PopupHeader {
        icon:         root.netIcon()
        iconColor:    root.signalColor()
        value:        root.isWifi ? root.ssid : "Ethernet"
        valueSize:    15
        caption:      root.connected ? "Connected" : "Disconnected"
        captionColor: root.connected ? Theme.ok : Theme.danger
    }

    StatBar {
        visible:      root.isWifi
        width:        parent.width
        value:        root.signalPct
        fillDuration: 300
        fillColor:    root.signalPct >= 70 ? Theme.ok
                    : root.signalPct >= 40 ? Theme.warn
                    : Theme.danger
    }

    HintText {
        visible: root.isWifi
        text:    "Signal: " + root.signalPct + "%"
    }

    Divider {}

    PopupRow { label: "Interface"; value: root.iface   }
    PopupRow { label: "IP";        value: root.ipAddr  }
    PopupRow { label: "Gateway";   value: root.gateway }
}
