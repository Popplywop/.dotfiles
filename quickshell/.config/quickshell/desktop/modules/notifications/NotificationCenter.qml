// modules/notifications/NotificationCenter.qml
// Bar widget: bell + unread count, click opens notification history.

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

BarWidget {
    id: root

    readonly property int unread: Notifs.unreadCount

    function bellIcon() {
        if (Notifs.doNotDisturb) return "󰂛"
        return root.unread > 0 ? "󰂚" : "󰂜"
    }

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

    icon:        root.bellIcon()
    iconSize:    Theme.fontPill
    iconColor:   Notifs.doNotDisturb ? Theme.textMuted
               : root.unread > 0     ? Theme.accent
               : Theme.textPrimary
    label:       root.unread > 0 ? root.unread.toString() : ""
    labelSize:   Theme.fontSmall
    labelColor:  Theme.accent

    clickable:   true
    openOnHover: false
    anchorRight: true
    popupMargin: 8
    popupWidth:  400

    onClicked: {
        root.popupOpen = !root.popupOpen
        if (root.popupOpen) Notifs.markAllRead()
    }

    // ── Header ─────────────────────────────────────────────────
    Item {
        width:  parent.width
        height: 22

        Text {
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            text:           "Notifications"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontHeader
            font.bold:      true
            color:          Theme.textSecondary
        }

        Row {
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            // Do not disturb toggle
            Rectangle {
                width:  26
                height: 20
                radius: 4
                color:  Notifs.doNotDisturb ? Theme.hoverAccent
                      : dndHov.containsMouse ? Theme.hoverBg
                      : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

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

            // Clear history
            Rectangle {
                width:   44
                height:  20
                radius:  4
                visible: Notifs.history.length > 0
                color:   clearHov.containsMouse ? Theme.hoverDanger : Theme.hoverBg

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

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

    Divider {}

    // ── Empty state ────────────────────────────────────────────
    Text {
        visible:        Notifs.history.length === 0
        width:          parent.width
        text:           Notifs.doNotDisturb
                      ? "Do not disturb is on."
                      : "Nothing here yet."
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontBody
        color:          Theme.textMuted
        topPadding:     8
        bottomPadding:  8
        horizontalAlignment: Text.AlignHCenter
    }

    // ── History ────────────────────────────────────────────────
    ListView {
        visible: Notifs.history.length > 0
        width:   parent.width
        height:  Math.min(contentHeight, 420)
        clip:    true
        spacing: 4

        model: Notifs.history

        delegate: Rectangle {
            id: entry

            required property var modelData

            width:  ListView.view.width
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
                    left: parent.left; right: parent.right
                    top: parent.top
                    leftMargin: 10; rightMargin: 8; topMargin: 6
                }
                spacing: 2

                Item {
                    width:  parent.width
                    height: appLabel.implicitHeight

                    Text {
                        id: appLabel
                        text:           entry.modelData.appName !== "" ? entry.modelData.appName : "Notification"
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
