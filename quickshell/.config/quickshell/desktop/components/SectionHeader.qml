// components/SectionHeader.qml
// Small caps-ish heading with an optional trailing control slot.

import QtQuick
import "root:/config"

Item {
    id: root

    property string text: ""
    default property alias trailing: slot.data

    width:  parent ? parent.width : 0
    height: 18

    Text {
        anchors.left:           parent.left
        anchors.verticalCenter: parent.verticalCenter
        text:           root.text
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        font.bold:      true
        color:          Theme.textSecondary
    }

    Item {
        id: slot
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth:  childrenRect.width
        implicitHeight: childrenRect.height
        width:  implicitWidth
        height: implicitHeight
    }
}
