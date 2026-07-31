// modules/bar/TrayWidget.qml
// System tray via StatusNotifier (DBus).
// Left-click = activate, right-click = secondary activate.

import Quickshell.Services.SystemTray
import QtQuick
import "root:/config"

Row {
    spacing:      4
    rightPadding: 4

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: trayItem

            required property var modelData
            readonly property var tray: modelData

            width:  24
            height: 24
            radius: 4
            color:  trayHov.containsMouse ? Theme.hoverBg : "transparent"

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Image {
                id: trayIcon
                anchors.centerIn: parent
                width:      18
                height:     18
                source:     trayItem.tray.icon
                sourceSize: Qt.size(18, 18)
                fillMode:   Image.PreserveAspectFit
                smooth:     true

                // Fallback: first letter of the title
                Text {
                    anchors.centerIn: parent
                    visible:          trayIcon.status !== Image.Ready
                    text:             (trayItem.tray.title ?? "?").charAt(0).toUpperCase()
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSmall
                    font.bold:        true
                    color:            Theme.textPrimary
                }
            }

            MouseArea {
                id: trayHov
                anchors.fill:    parent
                hoverEnabled:    true
                cursorShape:     Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) trayItem.tray.secondaryActivate()
                    else                                 trayItem.tray.activate()
                }
            }

            // Hover tooltip
            Rectangle {
                visible: trayHov.containsMouse && (trayItem.tray.tooltipTitle ?? "").length > 0
                anchors.bottom:           parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin:     4
                color:        Theme.popupBg
                border.color: Theme.popupBorder
                border.width: 1
                radius:       Theme.pillRadius
                width:        tipText.implicitWidth + 10
                height:       tipText.implicitHeight + 6
                z:            10

                Text {
                    id: tipText
                    anchors.centerIn: parent
                    text:           trayItem.tray.tooltipTitle ?? trayItem.tray.title ?? ""
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                    color:          Theme.textPrimary
                }
            }
        }
    }
}
