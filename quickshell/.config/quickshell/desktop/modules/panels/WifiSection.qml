// modules/controlcenter/WifiSection.qml
// Wifi toggle and nearby networks. Known networks connect on click; secured
// unknown ones reveal an inline passphrase field.

import Quickshell
import Quickshell.Networking
import QtQuick
import "root:/config"
import "root:/components"

Column {
    id: root

    property real contentWidth: parent ? parent.width : 0

    // Set by the panel so scanning only runs while it is visible
    property bool active: false

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) || null
    readonly property bool on: Networking.wifiEnabled

    // Which network has its passphrase field open
    property var pskTarget: null

    readonly property var networks: {
        if (!root.device) return []
        return root.device.networks.values.slice().sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            return (b.signalStrength || 0) - (a.signalStrength || 0)
        })
    }

    function signalGlyph(pct) {
        if (pct >= 75) return "󰤨"
        if (pct >= 50) return "󰤥"
        if (pct >= 25) return "󰤢"
        return "󰤟"
    }

    function isOpen(n) {
        return n.security === WifiSecurityType.Open || n.security === WifiSecurityType.Owe
    }

    // Scanning costs power; only do it while the panel is open
    onActiveChanged: if (root.device) root.device.scannerEnabled = root.active && root.on

    width:   root.contentWidth
    spacing: 4
    visible: root.device !== null

    SectionHeader {
        text: "Wi-Fi"

        Toggle {
            checked: root.on
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    Text {
        visible:        !root.on
        width:          parent.width
        text:           "Off"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        color:          Theme.textMuted
        bottomPadding:  4
    }

    Repeater {
        model: root.on ? root.networks.slice(0, 6) : []

        delegate: Column {
            id: netRow

            required property var modelData

            readonly property bool busy: netRow.modelData.stateChanging
            readonly property bool pskOpen: root.pskTarget === netRow.modelData

            width:   root.contentWidth
            spacing: 4

            Rectangle {
                width:  parent.width
                height: 32
                radius: 6
                color:  netHov.containsMouse ? Theme.hoverBg : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Text {
                    id: netIcon
                    anchors.left:           parent.left
                    anchors.leftMargin:     8
                    anchors.verticalCenter: parent.verticalCenter
                    text:           root.signalGlyph(netRow.modelData.signalStrength || 0)
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontIcon
                    color:          netRow.modelData.connected ? Theme.ok : Theme.textSecondary
                }

                Text {
                    anchors.left:           netIcon.right
                    anchors.leftMargin:     10
                    anchors.right:          netMeta.left
                    anchors.rightMargin:    6
                    anchors.verticalCenter: parent.verticalCenter
                    text:           netRow.modelData.name || "(hidden)"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.bold:      netRow.modelData.connected
                    color:          Theme.textPrimary
                    elide:          Text.ElideRight
                }

                Row {
                    id: netMeta
                    anchors.right:          parent.right
                    anchors.rightMargin:    8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        visible:        !root.isOpen(netRow.modelData)
                        text:           "󰌾"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontTiny
                        color:          Theme.textMuted
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: netRow.busy ? "…"
                            : netRow.modelData.connected ? "connected"
                            : netRow.modelData.known ? "saved" : ""
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontTiny
                        color:          netRow.modelData.connected ? Theme.ok : Theme.textMuted
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: netHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        const n = netRow.modelData
                        if (netRow.busy) return

                        if (n.connected)                     { n.disconnect(); return }
                        if (n.known || root.isOpen(n))       { n.connect(null); return }

                        // Needs a passphrase we do not have yet
                        root.pskTarget = netRow.pskOpen ? null : n
                    }
                }
            }

            // Inline passphrase entry
            Rectangle {
                visible: netRow.pskOpen
                width:   parent.width
                height:  30
                radius:  6
                color:   Theme.hoverBg
                border.color: Theme.popupBorder
                border.width: 1

                TextInput {
                    id: pskField
                    anchors.fill:        parent
                    anchors.leftMargin:  10
                    anchors.rightMargin: 10
                    verticalAlignment:   TextInput.AlignVCenter
                    echoMode:            TextInput.Password
                    font.family:         Theme.fontFamily
                    font.pixelSize:      Theme.fontBody
                    color:               Theme.textPrimary
                    clip:                true

                    onVisibleChanged: if (visible) forceActiveFocus()

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            netRow.modelData.connectWithPsk(pskField.text)
                            pskField.text  = ""
                            root.pskTarget = null
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            pskField.text  = ""
                            root.pskTarget = null
                            event.accepted = true
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible:        pskField.text.length === 0
                        text:           "Passphrase, then Enter"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                        color:          Theme.textMuted
                    }
                }
            }
        }
    }
}
