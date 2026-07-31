// modules/notifications/NotificationCard.qml
// One notification popup. Auto-expires unless critical; hovering pauses the
// countdown. Click dismisses, action buttons invoke and dismiss.

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "root:/config"
import "root:/services"

Rectangle {
    id: root

    required property var notif

    readonly property int  timeout:    Notifs.timeoutFor(notif)
    readonly property bool sticky:     timeout <= 0
    readonly property bool isCritical: notif.urgency === NotificationUrgency.Critical
    readonly property bool isLow:      notif.urgency === NotificationUrgency.Low

    readonly property color accentColor: isCritical ? Theme.danger
                                       : isLow      ? Theme.textMuted
                                       : Theme.popupBorder

    // Prefer the notification's own image, fall back to the app icon
    readonly property string iconSource: notif.image !== ""  ? notif.image
                                       : notif.appIcon !== "" ? Quickshell.iconPath(notif.appIcon, true)
                                       : ""

    width:  Theme.notifWidth
    height: layout.implicitHeight + Theme.notifPadding * 2

    color:        Theme.popupBg
    radius:       Theme.popupRadius
    border.color: root.accentColor
    border.width: Theme.popupBorderWidth

    // ── Entry animation ────────────────────────────────────────
    opacity: 0
    x:       Theme.notifWidth

    Component.onCompleted: {
        opacity = 1
        x       = 0
    }

    Behavior on opacity { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
    Behavior on x       { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

    // ── Expiry ─────────────────────────────────────────────────
    property real remaining: root.timeout

    Timer {
        id: countdown
        interval: 50
        repeat:   true
        running:  !root.sticky && !hover.containsMouse
        onTriggered: {
            root.remaining -= interval
            if (root.remaining <= 0) {
                running = false
                root.notif.expire()
            }
        }
    }

    MouseArea {
        id: hover
        anchors.fill:    parent
        hoverEnabled:    true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape:     Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) root.notif.dismiss()
            else if (root.notif.actions.length > 0) {
                root.notif.actions[0].invoke()
                root.notif.dismiss()
            } else {
                root.notif.dismiss()
            }
        }
    }

    Column {
        id: layout
        anchors {
            top: parent.top; left: parent.left; right: parent.right
            margins: Theme.notifPadding
        }
        spacing: 6

        // ── Header ─────────────────────────────────────────────
        Item {
            width:  parent.width
            height: Math.max(icon.height, headerText.implicitHeight)

            // Collapses to zero width when the icon is missing or fails to
            // decode, so a broken icon never leaves a blank gutter.
            Image {
                id: icon
                anchors.left: parent.left
                anchors.top:  parent.top
                source:       root.iconSource
                sourceSize:   Qt.size(Theme.notifIconSize, Theme.notifIconSize)
                width:        status === Image.Ready ? Theme.notifIconSize : 0
                height:       status === Image.Ready ? Theme.notifIconSize : 0
                fillMode:     Image.PreserveAspectFit
                smooth:       true
                asynchronous: true
            }

            Column {
                id: headerText
                anchors.left:       icon.right
                anchors.leftMargin: icon.width > 0 ? 10 : 0
                anchors.right:      closeBtn.left
                anchors.rightMargin: 6
                anchors.top:        parent.top
                spacing: 2

                Text {
                    width:          parent.width
                    text:           root.notif.appName !== "" ? root.notif.appName : "Notification"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                    color:          root.accentColor
                    elide:          Text.ElideRight
                }

                Text {
                    width:          parent.width
                    text:           root.notif.summary
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontHeader
                    font.bold:      true
                    color:          Theme.textPrimary
                    wrapMode:       Text.WordWrap
                    maximumLineCount: 2
                    elide:          Text.ElideRight
                }

                Text {
                    width:          parent.width
                    visible:        root.notif.body !== ""
                    text:           root.notif.body
                    textFormat:     Text.StyledText   // spec allows a small HTML subset
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    color:          Theme.textSecondary
                    wrapMode:       Text.WordWrap
                    maximumLineCount: 6
                    elide:          Text.ElideRight
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }
            }

            // Close button, revealed on hover
            Rectangle {
                id: closeBtn
                anchors.right: parent.right
                anchors.top:   parent.top
                width:   20
                height:  20
                radius:  4
                color:   closeHov.containsMouse ? Theme.hoverDanger : "transparent"
                opacity: hover.containsMouse ? 1 : 0

                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                Behavior on color   { ColorAnimation  { duration: Theme.animFast } }

                Text {
                    anchors.centerIn: parent
                    text:           "✕"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                    color:          closeHov.containsMouse ? Theme.danger : Theme.textMuted
                }

                MouseArea {
                    id: closeHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    root.notif.dismiss()
                }
            }
        }

        // ── Actions ────────────────────────────────────────────
        Row {
            visible: root.notif.actions.length > 0
            spacing: 6

            Repeater {
                model: root.notif.actions

                delegate: Rectangle {
                    id: actionBtn

                    required property var modelData

                    width:  actionLabel.implicitWidth + 20
                    height: 26
                    radius: 5
                    color:  actionHov.containsMouse ? Theme.hoverFg : Theme.hoverBg

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text:           actionBtn.modelData.text
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                        color:          Theme.textPrimary
                    }

                    MouseArea {
                        id: actionHov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            actionBtn.modelData.invoke()
                            root.notif.dismiss()
                        }
                    }
                }
            }
        }

        // ── Time remaining ─────────────────────────────────────
        Rectangle {
            visible: !root.sticky
            width:   parent.width
            height:  2
            radius:  1
            color:   Theme.trackBg

            Rectangle {
                width:  parent.width * Math.max(0, root.remaining) / Math.max(1, root.timeout)
                height: parent.height
                radius: parent.radius
                color:  root.accentColor
            }
        }
    }
}
