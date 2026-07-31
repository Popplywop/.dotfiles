// components/Toggle.qml
// Small on/off switch.

import QtQuick
import "root:/config"

Rectangle {
    id: root

    property bool checked: false
    signal toggled()

    width:  34
    height: 18
    radius: 9
    color:  root.checked ? Theme.accent : Theme.trackBg

    Behavior on color { ColorAnimation { duration: Theme.animNormal } }

    Rectangle {
        width:  14
        height: 14
        radius: 7
        color:  root.checked ? Theme.bg : Theme.textMuted
        anchors.verticalCenter: parent.verticalCenter
        x:      root.checked ? parent.width - width - 2 : 2

        Behavior on x     { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation  { duration: Theme.animNormal } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.toggled()
    }
}
