// modules/bar/Workspaces.qml
// Hyprland workspace switcher.

import Quickshell.Hyprland
import QtQuick
import "root:/config"

Row {
    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            id: wsItem

            required property var modelData
            readonly property var  ws:     modelData
            readonly property bool active: Hyprland.focusedWorkspace
                                        && Hyprland.focusedWorkspace.id === ws.id

            width:  btn.width
            height: Theme.pillHeight

            Rectangle {
                id: btn
                width:  Math.max(24, wsLabel.implicitWidth + Theme.pillPadding)
                height: Theme.pillHeight
                anchors.verticalCenter: parent.verticalCenter
                radius: Theme.pillRadius

                color: wsItem.active            ? Theme.accent
                     : btnHover.containsMouse   ? Theme.hoverMagenta
                     : Theme.hoverBg

                Behavior on color { ColorAnimation { duration: Theme.animNormal } }

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    text:           wsItem.ws.id
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontHeader
                    font.bold:      true
                    color:          wsItem.active ? Theme.bg : Theme.textPrimary

                    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                }

                MouseArea {
                    id: btnHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    Hyprland.dispatch("workspace " + wsItem.ws.id)
                }
            }
        }
    }
}
