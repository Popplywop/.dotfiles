// components/PopupCard.qml
// Floating card that hangs below the bar. The caller controls `visible`
// and positions it with anchorLeft/anchorRight + margin.

import Quickshell
import Quickshell.Wayland
import QtQuick
import "root:/config"

PanelWindow {
    id: popup

    // ── Public API ─────────────────────────────────────────────
    property bool anchorLeft:  false
    property bool anchorRight: false
    property real marginLeft:  0
    property real marginRight: 0
    property real popupWidth:  260

    // Usable width inside the padding — children size themselves off this
    readonly property real contentWidth: popupWidth - Theme.popupPadding * 2

    // Content slot
    default property alias content: body.data

    // Hover callbacks so the parent can cancel its hide timer
    signal popupEntered()
    signal popupExited()

    // ── Window ──────────────────────────────────────────────────
    WlrLayershell.layer:     WlrLayer.Overlay
    WlrLayershell.namespace: "qs-bar-popup"

    anchors.top:   true
    anchors.left:  popup.anchorLeft
    anchors.right: popup.anchorRight
    margins.top:   Theme.barHeight
    margins.left:  popup.marginLeft
    margins.right: popup.marginRight

    implicitWidth:  popup.popupWidth
    implicitHeight: body.implicitHeight + Theme.popupPadding * 2
    color:          "transparent"

    Rectangle {
        anchors.fill: parent
        color:        Theme.popupBg
        border.color: Theme.popupBorder
        border.width: Theme.popupBorderWidth
        radius:       Theme.popupRadius
    }

    Column {
        id: body
        anchors {
            top: parent.top; left: parent.left; right: parent.right
            margins: Theme.popupPadding
        }
        spacing: Theme.popupSpacing
    }

    // Keeps hovering the popup itself from triggering a hide
    MouseArea {
        anchors.fill:            parent
        hoverEnabled:            true
        propagateComposedEvents: true
        onEntered:               popup.popupEntered()
        onExited:                popup.popupExited()
        onClicked: mouse => mouse.accepted = false
    }
}
