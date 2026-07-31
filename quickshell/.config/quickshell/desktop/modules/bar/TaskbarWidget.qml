// modules/bar/TaskbarWidget.qml
// Running windows. Click to focus, middle-click to close.

import Quickshell.Wayland
import QtQuick
import "root:/config"

Row {
    spacing:     4
    leftPadding: 6

    Repeater {
        model: ToplevelManager.toplevels

        delegate: Item {
            id: taskItem

            required property var modelData
            readonly property var  tl:     modelData
            readonly property bool active: tl.activated

            width:  taskBtn.width
            height: Theme.pillHeight

            Rectangle {
                id: taskBtn
                width:  Math.min(taskLabel.implicitWidth + Theme.pillPadding, 140)
                height: Theme.pillHeight
                anchors.verticalCenter: parent.verticalCenter
                radius: Theme.pillRadius

                color: taskItem.active            ? Theme.hoverAccent
                     : taskHover.containsMouse    ? Theme.hoverBg
                     : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Text {
                    id: taskLabel
                    anchors.centerIn: parent
                    width:            parent.width - 8
                    text:             taskItem.tl.title.length > 0 ? taskItem.tl.title : taskItem.tl.appId
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSmall
                    color:            taskItem.active ? Theme.accent : Theme.textPrimary
                    elide:            Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: taskHover
                    anchors.fill:    parent
                    hoverEnabled:    true
                    cursorShape:     Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton) taskItem.tl.close()
                        else taskItem.tl.activate()
                    }
                }
            }
        }
    }
}
