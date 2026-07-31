// components/StatBar.qml
// Horizontal progress bar used by every gauge popup.

import QtQuick
import "root:/config"

Rectangle {
    id: root

    property real  value:    0    // 0..100
    property color fillColor: Theme.textPrimary
    property int   fillDuration: Theme.animSlow

    height: Theme.barThin
    radius: height / 2
    color:  Theme.trackBg

    Rectangle {
        width:  parent.width * Math.max(0, Math.min(100, root.value)) / 100
        height: parent.height
        radius: parent.radius
        color:  root.fillColor

        Behavior on width { NumberAnimation { duration: root.fillDuration } }
    }
}
