// modules/island/Island.qml
// Floating status pill, top centre. Replaces the top bar.
//
// Deliberately small: clock, tray, battery, unread notifications. Anything
// that needs space or interaction lives in the right panel instead.

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import QtQuick
import "root:/config"
import "root:/services"

PanelWindow {
    id: island

    // shell.qml wires these to the right panel
    signal notificationsRequested()
    signal quickSettingsRequested()

    WlrLayershell.layer:         WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace:     "qs-island"
    // Floating chrome: never reserve space, windows go underneath
    exclusionMode: ExclusionMode.Ignore

    anchors.top:  true
    margins.top:  Theme.islandTopMargin

    implicitWidth:  body.implicitWidth + Theme.islandPaddingH * 2
    implicitHeight: Theme.islandHeight
    color:          "transparent"

    // ── Battery ────────────────────────────────────────────────
    readonly property var  batt:     UPower.displayDevice
    // UPower reports a 0..1 fraction, not a percentage
    readonly property real battPct:  batt ? batt.percentage * 100 : 0
    readonly property int  battState: batt ? batt.state : 0
    readonly property bool charging: battState === UPowerDeviceState.Charging
                                  || battState === UPowerDeviceState.PendingCharge
    readonly property bool battLow:  battPct < 20 && battState === UPowerDeviceState.Discharging

    function battIcon() {
        if (island.charging) return "󰂄"
        if (island.battPct >= 90) return "󰁹"
        if (island.battPct >= 70) return "󰂁"
        if (island.battPct >= 50) return "󰁿"
        if (island.battPct >= 30) return "󰁽"
        if (island.battPct >= 15) return "󰁻"
        return "󰂎"
    }

    Rectangle {
        anchors.fill: parent
        color:        Theme.popupBg
        radius:       Theme.islandRadius
        border.color: Theme.popupBorder
        border.width: 1

        Row {
            id: body
            anchors.centerIn: parent
            spacing: Theme.islandSpacing

            // ── Clock ──────────────────────────────────────────
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: clock
                    text:           Qt.formatTime(new Date(), "hh:mm")
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.bold:      true
                    color:          Theme.textPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    id: dateLabel
                    text:           Qt.formatDate(new Date(), "ddd d MMM")
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                    color:          Theme.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Timer {
                    interval: 15000; repeat: true; running: true; triggeredOnStart: true
                    onTriggered: {
                        const now = new Date()
                        clock.text     = Qt.formatTime(now, "hh:mm")
                        dateLabel.text = Qt.formatDate(now, "ddd d MMM")
                    }
                }
            }

            // ── Tray ───────────────────────────────────────────
            Row {
                id: tray
                spacing: 6
                visible: SystemTray.items.values.length > 0
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width:   1
                    height:  14
                    color:   Theme.divider
                    anchors.verticalCenter: parent.verticalCenter
                }

                Repeater {
                    model: SystemTray.items

                    delegate: Item {
                        id: trayItem

                        required property var modelData

                        width:  18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            id: trayIcon
                            anchors.fill: parent
                            source:     trayItem.modelData.icon
                            sourceSize: Qt.size(18, 18)
                            fillMode:   Image.PreserveAspectFit
                            smooth:     true
                            opacity:    trayHov.containsMouse ? 1 : 0.85

                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible:        trayIcon.status !== Image.Ready
                            text:           (trayItem.modelData.title ?? "?").charAt(0).toUpperCase()
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontTiny
                            font.bold:      true
                            color:          Theme.textPrimary
                        }

                        MouseArea {
                            id: trayHov
                            anchors.fill:    parent
                            hoverEnabled:    true
                            cursorShape:     Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton)
                                    trayItem.modelData.secondaryActivate()
                                else
                                    trayItem.modelData.activate()
                            }
                        }
                    }
                }
            }

            Rectangle {
                width:   1
                height:  14
                color:   Theme.divider
                anchors.verticalCenter: parent.verticalCenter
            }

            // ── Battery ────────────────────────────────────────
            // Wrapped in an Item: a MouseArea with anchors.fill cannot be a
            // direct child of a Row without breaking the Row's layout.
            Item {
                width:   battRow.implicitWidth
                height:  18
                visible: island.batt !== null
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: battRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text:           island.battIcon()
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                        color:          island.battLow  ? Theme.danger
                                      : island.charging ? Theme.ok
                                      : Theme.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text:           Math.round(island.battPct) + "%"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontTiny
                        color:          Theme.textSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    island.quickSettingsRequested()
                }
            }

            // ── Notification badge ─────────────────────────────
            Item {
                width:   badgeRow.implicitWidth
                height:  18
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: badgeRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        id: bell
                        text: Notifs.doNotDisturb ? "󰂛"
                            : Notifs.unreadCount > 0 ? "󰂚" : "󰂜"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                        color:          Notifs.doNotDisturb   ? Theme.textMuted
                                      : Notifs.unreadCount > 0 ? Theme.accent
                                      : Theme.textSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        visible: Notifs.unreadCount > 0
                        width:   countText.implicitWidth + 8
                        height:  14
                        radius:  7
                        color:   Theme.accent
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: countText
                            anchors.centerIn: parent
                            text:           Notifs.unreadCount
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontTiny
                            font.bold:      true
                            color:          Theme.bg
                        }
                    }
                }

                // Pulse when something new lands
                SequentialAnimation {
                    id: pulse
                    running: false
                    NumberAnimation { target: bell; property: "scale"; to: 1.35; duration: 140 }
                    NumberAnimation { target: bell; property: "scale"; to: 1.0;  duration: 220 }
                }

                Connections {
                    target: Notifs
                    function onUnreadCountChanged() {
                        if (Notifs.unreadCount > 0) pulse.restart()
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    island.notificationsRequested()
                }
            }
        }
    }
}
