// modules/panels/QuickPanel.qml
// Right flyout: quick settings, media, bluetooth, wifi, notification history,
// and power actions in the header.

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

SlidePanel {
    id: root

    fromRight: true

    // Set by the island so clicking the bell lands on notifications
    property bool focusNotifications: false

    signal lockRequested()
    signal powerRequested(string action)

    function fmtTime(d) {
        const diff = (Date.now() - d.getTime()) / 1000
        if (diff < 60)    return "now"
        if (diff < 3600)  return Math.floor(diff / 60) + "m"
        if (diff < 86400) return Math.floor(diff / 3600) + "h"
        return Math.floor(diff / 86400) + "d"
    }

    function urgencyColor(u) {
        if (u === NotificationUrgency.Critical) return Theme.danger
        if (u === NotificationUrgency.Low)      return Theme.textMuted
        return Theme.popupBorder
    }

    onOpenChanged: if (root.open) Notifs.markAllRead()

    // ── Header: user + power actions ───────────────────────────
    Item {
        width:  parent.width
        height: 28

        Text {
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            text:           Quickshell.env("USER") || "user"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontHeader
            font.bold:      true
            color:          Theme.textPrimary
        }

        Row {
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Repeater {
                model: [
                    { glyph: "󰌾", act: "lock",     tip: "Lock"     },
                    { glyph: "󰍃", act: "logout",   tip: "Log out"  },
                    { glyph: "󰑐", act: "reboot",   tip: "Reboot"   },
                    { glyph: "󰐥", act: "shutdown", tip: "Shut down"},
                ]

                delegate: Rectangle {
                    id: pwr

                    required property var modelData

                    width:  28
                    height: 24
                    radius: 5
                    color:  pwrHov.containsMouse ? Theme.hoverDanger : Theme.hoverBg

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Text {
                        anchors.centerIn: parent
                        text:           pwr.modelData.glyph
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                        color:          pwrHov.containsMouse ? Theme.danger : Theme.textSecondary
                    }

                    MouseArea {
                        id: pwrHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            root.hide()
                            root.powerRequested(pwr.modelData.act)
                        }
                    }
                }
            }
        }
    }

    Divider {}

    // ── Output ─────────────────────────────────────────────────
    SectionHeader { text: "Output" }

    Row {
        width:   parent.width
        spacing: 10

        Text {
            width:          22
            text:           Audio.icon()
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontIcon
            color:          Audio.muted ? Theme.danger : Theme.textPrimary
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    Audio.toggleMute()
            }
        }

        Slider {
            width:     parent.width - 22 - 44 - 20
            value:     Audio.muted ? 0 : Audio.volume
            fillColor: Audio.muted ? Theme.danger : Theme.accent
            enabled:   Audio.ready
            onMoved:   v => Audio.setVolume(v)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            width:          44
            text:           Audio.volume + "%"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSmall
            color:          Theme.textSecondary
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ── Brightness ─────────────────────────────────────────────
    SectionHeader {
        text:    "Brightness"
        visible: Brightness.available
    }

    Row {
        visible: Brightness.available
        width:   parent.width
        spacing: 10

        Text {
            width:          22
            text:           Brightness.icon()
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontIcon
            color:          Theme.accent
            anchors.verticalCenter: parent.verticalCenter
        }

        Slider {
            width:     parent.width - 22 - 44 - 20
            value:     Brightness.percent
            fillColor: Theme.accent
            onMoved:   v => Brightness.set(v)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            width:          44
            text:           Brightness.percent + "%"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSmall
            color:          Theme.textSecondary
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Divider {}

    MediaSection { contentWidth: parent.width }

    Divider {}

    BluetoothSection { contentWidth: parent.width }

    Divider {}

    WifiSection {
        contentWidth: parent.width
        active:       root.open
    }

    Divider {}

    // ── Notifications ──────────────────────────────────────────
    SectionHeader {
        text: "Notifications"

        Row {
            spacing: 6

            Rectangle {
                width:  26
                height: 20
                radius: 4
                color:  Notifs.doNotDisturb ? Theme.hoverAccent
                      : dndHov.containsMouse ? Theme.hoverBg
                      : "transparent"

                Text {
                    anchors.centerIn: parent
                    text:           "󰂛"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    color:          Notifs.doNotDisturb ? Theme.accent : Theme.textMuted
                }

                MouseArea {
                    id: dndHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    Notifs.doNotDisturb = !Notifs.doNotDisturb
                }
            }

            Rectangle {
                visible: Notifs.history.length > 0
                width:   44
                height:  20
                radius:  4
                color:   clearHov.containsMouse ? Theme.hoverDanger : Theme.hoverBg

                Text {
                    anchors.centerIn: parent
                    text:           "Clear"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                    color:          clearHov.containsMouse ? Theme.danger : Theme.textSecondary
                }

                MouseArea {
                    id: clearHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    Notifs.clearHistory()
                }
            }
        }
    }

    Text {
        visible:        Notifs.history.length === 0
        width:          parent.width
        text:           Notifs.doNotDisturb ? "Do not disturb is on." : "Nothing here yet."
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        color:          Theme.textMuted
        bottomPadding:  6
    }

    Repeater {
        model: Notifs.history.slice(0, 20)

        delegate: Rectangle {
            id: entry

            required property var modelData

            width:  parent.width
            height: entryCol.implicitHeight + 12
            radius: 6
            color:  entryHov.containsMouse ? Theme.hoverBg : "transparent"

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Rectangle {
                anchors.left:         parent.left
                anchors.top:          parent.top
                anchors.bottom:       parent.bottom
                anchors.topMargin:    4
                anchors.bottomMargin: 4
                width:  2
                radius: 1
                color:  root.urgencyColor(entry.modelData.urgency)
            }

            Column {
                id: entryCol
                anchors {
                    left: parent.left; right: parent.right; top: parent.top
                    leftMargin: 10; rightMargin: 8; topMargin: 6
                }
                spacing: 2

                Item {
                    width:  parent.width
                    height: appLabel.implicitHeight

                    Text {
                        id: appLabel
                        text:           entry.modelData.appName || "Notification"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontTiny
                        color:          root.urgencyColor(entry.modelData.urgency)
                    }
                    Text {
                        anchors.right:  parent.right
                        text:           root.fmtTime(entry.modelData.time)
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontTiny
                        color:          Theme.textMuted
                    }
                }

                Text {
                    width:          parent.width
                    text:           entry.modelData.summary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.bold:      true
                    color:          Theme.textPrimary
                    elide:          Text.ElideRight
                }

                Text {
                    width:          parent.width
                    visible:        entry.modelData.body !== ""
                    text:           entry.modelData.body
                    textFormat:     Text.StyledText
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                    color:          Theme.textSecondary
                    wrapMode:       Text.WordWrap
                    maximumLineCount: 3
                    elide:          Text.ElideRight
                }
            }

            MouseArea {
                id: entryHov
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }
}
