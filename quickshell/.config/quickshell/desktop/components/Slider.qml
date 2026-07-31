// components/Slider.qml
// Draggable 0..100 slider. Emits `moved` continuously while dragging.

import QtQuick
import "root:/config"

Item {
    id: root

    property real  value:     0
    property color fillColor: Theme.accent
    property bool  enabled:   true

    signal moved(real value)

    implicitHeight: 18

    function _apply(mx) {
        const pct = Math.max(0, Math.min(100, mx / root.width * 100))
        root.moved(pct)
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width:   parent.width
        height:  Theme.barThin
        radius:  height / 2
        color:   Theme.trackBg
        opacity: root.enabled ? 1 : 0.4

        Rectangle {
            id: fill
            width:  parent.width * Math.max(0, Math.min(100, root.value)) / 100
            height: parent.height
            radius: parent.radius
            color:  root.fillColor

            // No animation while dragging, or the handle lags the pointer
            Behavior on width {
                enabled: !drag.pressed
                NumberAnimation { duration: Theme.animFast }
            }
        }
    }

    Rectangle {
        id: handle
        width:   14
        height:  14
        radius:  7
        color:   root.fillColor
        border.color: Theme.bg
        border.width: 2
        anchors.verticalCenter: parent.verticalCenter
        x:       fill.width - width / 2
        visible: root.enabled
        scale:   drag.pressed ? 1.2 : (drag.containsMouse ? 1.1 : 1.0)

        Behavior on scale { NumberAnimation { duration: Theme.animFast } }
        Behavior on x {
            enabled: !drag.pressed
            NumberAnimation { duration: Theme.animFast }
        }
    }

    MouseArea {
        id: drag
        anchors.fill:   parent
        anchors.margins: -6      // easier to grab than a 6px track
        enabled:        root.enabled
        hoverEnabled:   true
        cursorShape:    Qt.PointingHandCursor
        preventStealing: true

        onPressed:          mouse => root._apply(mouse.x)
        onPositionChanged:  mouse => { if (pressed) root._apply(mouse.x) }
    }
}
