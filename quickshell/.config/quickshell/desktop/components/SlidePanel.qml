// components/SlidePanel.qml
// Edge flyout that slides in from the left or right and closes when the
// pointer leaves or Escape is pressed.
//
// The window is full height and panel-width; the card inside is what slides,
// so the compositor never has to resize a surface mid-animation.

import Quickshell
import Quickshell.Wayland
import QtQuick
import "root:/config"

Item {
    id: root

    property bool fromRight: false
    property bool open:      false

    // Escape needs keyboard focus, which steals it from the focused window —
    // only grab it while actually open.
    property bool grabsKeyboard: true

    default property alias content: body.data

    function show() { root.open = true;  hideTimer.stop() }
    function hide() { root.open = false }
    function toggle() { if (root.open) root.hide(); else root.show() }
    function requestHide() { hideTimer.restart() }

    Timer {
        id: hideTimer
        interval: 400
        onTriggered: if (!hover.containsMouse) root.hide()
    }

    PanelWindow {
        id: panel

        visible: root.open || slide.running

        WlrLayershell.layer:     WlrLayer.Overlay
        WlrLayershell.namespace: "qs-panel"
        // Floating chrome: never reserve space, windows go underneath
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: (root.open && root.grabsKeyboard)
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        anchors.top:    true
        anchors.bottom: true
        anchors.left:   !root.fromRight
        anchors.right:  root.fromRight

        implicitWidth: Theme.panelWidth + Theme.panelMargin * 2
        color:         "transparent"

        Rectangle {
            id: card

            width: Theme.panelWidth
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            anchors.topMargin:  Theme.panelMargin
            anchors.bottomMargin: Theme.panelMargin

            color:        Theme.panelBg
            radius:       Theme.panelRadius
            border.color: Theme.popupBorder
            border.width: 1

            // Off-screen when closed, margin-inset when open
            readonly property real shownX:  root.fromRight
                ? Theme.panelMargin
                : Theme.panelMargin
            readonly property real hiddenX: root.fromRight
                ? Theme.panelWidth + Theme.panelMargin * 2
                : -(Theme.panelWidth + Theme.panelMargin)

            x: root.open ? card.shownX : card.hiddenX

            Behavior on x {
                NumberAnimation {
                    id: slide
                    duration: Theme.panelSlide
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onExited:     root.requestHide()
                onEntered:    hideTimer.stop()
                // Let children handle their own clicks
                acceptedButtons: Qt.NoButton
            }

            Keys.onEscapePressed: root.hide()
            focus: root.open

            Flickable {
                id: scroll
                anchors.fill:    parent
                anchors.margins: Theme.popupPadding
                contentHeight:   body.implicitHeight
                clip:            true
                boundsBehavior:  Flickable.StopAtBounds
                interactive:     contentHeight > height

                Column {
                    id: body
                    width:   scroll.width
                    spacing: 10
                }
            }
        }
    }
}
