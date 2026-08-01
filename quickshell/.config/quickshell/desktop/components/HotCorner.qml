// components/HotCorner.qml
// Tiny invisible trigger region pinned to a screen corner.

import Quickshell
import Quickshell.Wayland
import QtQuick
import "root:/config"

PanelWindow {
    id: corner

    property bool atTop:  true
    property bool atLeft: true

    signal triggered()

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace:     "qs-hotcorner"
    // Floating chrome: never reserve space, windows go underneath
    exclusionMode: ExclusionMode.Ignore

    anchors.top:    corner.atTop
    anchors.bottom: !corner.atTop
    anchors.left:   corner.atLeft
    anchors.right:  !corner.atLeft

    implicitWidth:  Theme.hotCornerSize
    implicitHeight: Theme.hotCornerSize
    color:          "transparent"

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered:    corner.triggered()
    }
}
