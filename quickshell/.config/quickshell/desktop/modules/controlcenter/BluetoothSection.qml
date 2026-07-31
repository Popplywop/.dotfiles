// modules/controlcenter/BluetoothSection.qml
// Adapter toggle plus known/nearby devices. Click a row to connect or
// disconnect.

import Quickshell
import Quickshell.Bluetooth
import QtQuick
import "root:/config"
import "root:/components"

Column {
    id: root

    property real contentWidth: parent ? parent.width : 0

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter !== null && adapter.enabled

    // Paired devices first, then whatever else is in range
    readonly property var devices: {
        if (!root.adapter) return []
        return root.adapter.devices.values.slice().sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            if (a.paired    !== b.paired)    return a.paired    ? -1 : 1
            return (a.deviceName || a.name || "").localeCompare(b.deviceName || b.name || "")
        })
    }

    width:   root.contentWidth
    spacing: 4
    visible: root.adapter !== null

    SectionHeader {
        text: "Bluetooth"

        Toggle {
            checked: root.on
            onToggled: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
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

    Text {
        visible:        root.on && root.devices.length === 0
        width:          parent.width
        text:           "No devices"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        color:          Theme.textMuted
        bottomPadding:  4
    }

    Repeater {
        model: root.on ? root.devices.slice(0, 6) : []

        delegate: Rectangle {
            id: dev

            required property var modelData

            readonly property bool busy: dev.modelData.state === BluetoothDeviceState.Connecting
                                      || dev.modelData.state === BluetoothDeviceState.Disconnecting

            width:  root.contentWidth
            height: 34
            radius: 6
            color:  devHov.containsMouse ? Theme.hoverBg : "transparent"

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Text {
                id: devIcon
                anchors.left:           parent.left
                anchors.leftMargin:     8
                anchors.verticalCenter: parent.verticalCenter
                text:           dev.modelData.connected ? "󰂱" : "󰂯"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontIcon
                color:          dev.modelData.connected ? Theme.ok : Theme.textMuted
            }

            Column {
                anchors.left:           devIcon.right
                anchors.leftMargin:     10
                anchors.right:          devStatus.left
                anchors.rightMargin:    6
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    width:          parent.width
                    text:           dev.modelData.deviceName || dev.modelData.name || dev.modelData.address
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    color:          Theme.textPrimary
                    elide:          Text.ElideRight
                }
                Text {
                    width:          parent.width
                    visible:        text.length > 0
                    text: {
                        if (dev.busy) return dev.modelData.state === BluetoothDeviceState.Connecting
                            ? "connecting…" : "disconnecting…"
                        if (dev.modelData.connected) return "connected"
                        return dev.modelData.paired ? "paired" : ""
                    }
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                    color:          Theme.textMuted
                    elide:          Text.ElideRight
                }
            }

            Text {
                id: devStatus
                anchors.right:          parent.right
                anchors.rightMargin:    8
                anchors.verticalCenter: parent.verticalCenter
                visible:        dev.modelData.batteryAvailable
                text:           Math.round(dev.modelData.battery * 100) + "%"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontTiny
                color:          Theme.textSecondary
            }

            MouseArea {
                id: devHov
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    if (dev.busy) return
                    if (dev.modelData.connected)   dev.modelData.disconnect()
                    else if (dev.modelData.paired) dev.modelData.connect()
                    else                           dev.modelData.pair()
                }
            }
        }
    }
}
