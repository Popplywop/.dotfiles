// modules/panels/OutputSection.qml
// Audio output device picker. Click a row to make it the default sink.
// Hidden when there is only one device to choose from.

import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

Column {
    id: root

    property real contentWidth: parent ? parent.width : 0

    width:   root.contentWidth
    spacing: 2
    visible: Audio.sinks.length > 1

    Repeater {
        model: Audio.sinks

        delegate: Rectangle {
            id: dev

            required property var modelData

            readonly property bool current: Audio.sink !== null && dev.modelData.id === Audio.sink.id

            width:  root.contentWidth
            height: 30
            radius: 6
            color:  devHov.containsMouse ? Theme.hoverBg : "transparent"

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Text {
                id: devIcon
                anchors.left:           parent.left
                anchors.leftMargin:     8
                anchors.verticalCenter: parent.verticalCenter
                text:           dev.current ? "󰓃" : "󰓄"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontIcon
                color:          dev.current ? Theme.accent : Theme.textMuted
            }

            Text {
                anchors.left:           devIcon.right
                anchors.leftMargin:     10
                anchors.right:          parent.right
                anchors.rightMargin:    8
                anchors.verticalCenter: parent.verticalCenter
                text:           Audio.label(dev.modelData)
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.bold:      dev.current
                color:          dev.current ? Theme.textPrimary : Theme.textSecondary
                elide:          Text.ElideRight
            }

            MouseArea {
                id: devHov
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    Audio.setDefaultSink(dev.modelData)
            }
        }
    }
}
