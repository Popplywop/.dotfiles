// components/BarPill.qml
// Plain click-only pill (no popup). For popup-bearing items use BarWidget.
//
// Usage:
//   BarPill { label: "󱓞"; labelColor: Theme.blue; onClicked: doThing() }

import QtQuick
import QtQuick.Layouts
import "root:/config"

Rectangle {
    id: root

    property alias label:      lbl.text
    property color labelColor: Theme.textPrimary
    property alias fontSize:   lbl.font.pixelSize
    property color hoverBg:    Theme.hoverBg

    signal clicked()

    implicitWidth:    lbl.implicitWidth + Theme.pillPadding
    implicitHeight:   Theme.pillHeight
    Layout.alignment: Qt.AlignVCenter
    radius:           Theme.pillRadius
    color:            ma.containsMouse ? root.hoverBg : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Text {
        id: lbl
        anchors.centerIn: parent
        font.family:      Theme.fontFamily
        font.pixelSize:   Theme.fontPill
        font.bold:        true
        color:            root.labelColor
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.clicked()
    }
}
