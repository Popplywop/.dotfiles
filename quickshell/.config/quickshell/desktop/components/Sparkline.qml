// components/Sparkline.qml
// Rolling history bar chart. Push values with `push(v)`; oldest fall off the
// left. Cheap on purpose — Repeater of rectangles, no Canvas repaint.

import QtQuick
import "root:/config"

Item {
    id: root

    property int    slots:     32
    property color  fillColor: Theme.accent
    property var    history:   []

    function push(v) {
        const next = root.history.concat([Math.max(0, Math.min(100, v))])
        root.history = next.slice(-root.slots)
    }

    implicitHeight: 34

    Row {
        anchors.fill: parent
        spacing: 1
        layoutDirection: Qt.LeftToRight

        Repeater {
            model: root.history

            delegate: Rectangle {
                required property real modelData

                width:  (root.width - (root.slots - 1)) / root.slots
                height: Math.max(1, root.height * modelData / 100)
                y:      root.height - height
                radius: 1
                color:  root.fillColor
                opacity: 0.35 + 0.65 * (modelData / 100)

                Behavior on height { NumberAnimation { duration: 180 } }
            }
        }
    }
}
