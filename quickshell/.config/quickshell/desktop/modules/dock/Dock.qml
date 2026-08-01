// modules/dock/Dock.qml
// Floating auto-hiding dock: pinned apps and workspace pills.
//
// No running-window list on purpose — windows are switched with Super+num, so
// a taskbar would be dead weight.
//
// Hiding uses two windows: a 2px hover strip pinned to the screen edge that is
// always present, and the dock itself which only exists while revealed. A
// single always-present dock window would swallow clicks along the bottom of
// the screen even when invisible.

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "root:/config"
import "root:/services"

Item {
    id: root

    property bool revealed: false

    // Tracked separately: the pointer can be over the edge strip, over the
    // dock itself, or over both as the dock slides up through the strip.
    property bool _overStrip: false
    property bool _overDock:  false

    // Every enter/exit funnels through here. Relying on the dock card's exit
    // alone left the dock stuck open forever whenever it was revealed at a
    // point the card does not cover.
    function updateHover() {
        if (root._overStrip || root._overDock) {
            root.revealed = true
            hideTimer.stop()
        } else {
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: Theme.dockHideDelay
        onTriggered: if (!root._overStrip && !root._overDock) root.revealed = false
    }

    // DesktopEntries scans asynchronously and byId() returns null until it
    // finishes. Touching `values` first makes this binding depend on the
    // model's change signal, so the dock fills in once the scan lands —
    // otherwise it latches the empty result from startup and stays iconless.
    readonly property var entries: {
        DesktopEntries.applications.values.length
        return Pins.ids
            .map(id => DesktopEntries.byId(id))
            .filter(e => e !== null)
    }

    // ── Edge hover strip ───────────────────────────────────────
    PanelWindow {
        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace:     "qs-dock-reveal"
        // Floating chrome: never reserve space, windows go underneath
        exclusionMode: ExclusionMode.Ignore

        // Only anchored to the bottom, so the compositor centres it. A
        // full-width strip meant brushing the bottom edge anywhere on screen
        // popped the dock, even far from where it actually sits.
        anchors.bottom: true

        implicitWidth:  Theme.dockRevealWidth
        implicitHeight: Theme.dockRevealHeight
        color:          "transparent"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { root._overStrip = true;  root.updateHover() }
            onExited:  { root._overStrip = false; root.updateHover() }
        }
    }

    // ── Dock ───────────────────────────────────────────────────
    PanelWindow {
        id: panel

        // Stay mapped while sliding out, or the dock would vanish instantly
        visible: root.revealed || slide.running

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace:     "qs-dock"
        // Floating chrome: never reserve space, windows go underneath
        exclusionMode: ExclusionMode.Ignore

        anchors.bottom: true
        margins.bottom: Theme.dockBottomMargin

        implicitWidth:  card.width
        implicitHeight: card.height + Theme.dockSlide
        color:          "transparent"

        Rectangle {
            id: card

            width:  content.implicitWidth  + Theme.dockPadding * 2
            height: content.implicitHeight + Theme.dockPadding * 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:           parent.bottom

            color:        Theme.popupBg
            radius:       Theme.dockRadius
            border.color: Theme.popupBorder
            border.width: 1

            // Slides up from below the screen edge
            y: root.revealed ? 0 : height + Theme.dockBottomMargin

            Behavior on y {
                NumberAnimation {
                    id: slide
                    duration: Theme.dockSlide
                    easing.type: Easing.OutCubic
                }
            }

            // HoverHandler, not MouseArea: a MouseArea here reports exited the
            // moment the pointer moves onto an app icon's own MouseArea, which
            // started the hide timer and made the dock flicker while hovering
            // icons. HoverHandler does not consume events and stays hovered
            // while descendants are.
            HoverHandler {
                onHoveredChanged: {
                    root._overDock = hovered
                    root.updateHover()
                }
            }

            Row {
                id: content
                anchors.centerIn: parent
                spacing: Theme.dockSpacing

                // ── Pinned apps ────────────────────────────────
                Repeater {
                    model: root.entries

                    delegate: Item {
                        id: appItem

                        required property var modelData

                        width:  Theme.dockIconSize
                        height: Theme.dockIconSize

                        scale: appHov.containsMouse ? 1.18 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 120; easing.type: Easing.OutBack }
                        }

                        Image {
                            id: appIcon
                            anchors.fill:    parent
                            anchors.margins: 2
                            source:     Quickshell.iconPath(appItem.modelData.icon, true)
                            sourceSize: Qt.size(Theme.dockIconSize, Theme.dockIconSize)
                            fillMode:   Image.PreserveAspectFit
                            smooth:     true
                            asynchronous: true
                        }

                        // Fallback when the theme has no icon for this app
                        Rectangle {
                            anchors.fill:    parent
                            anchors.margins: 2
                            visible: appIcon.status !== Image.Ready
                            radius:  10
                            color:   Theme.hoverBg

                            Text {
                                anchors.centerIn: parent
                                text:           (appItem.modelData.name || "?").charAt(0).toUpperCase()
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontBig
                                font.bold:      true
                                color:          Theme.textPrimary
                            }
                        }

                        MouseArea {
                            id: appHov
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: Apps.launch({
                                entry:  appItem.modelData,
                                action: null,
                                key:    appItem.modelData.id,
                            })
                        }

                        // Name on hover, above the dock
                        Rectangle {
                            visible: appHov.containsMouse
                            anchors.bottom:           parent.top
                            anchors.bottomMargin:     10
                            anchors.horizontalCenter: parent.horizontalCenter
                            width:  tipLabel.implicitWidth + 14
                            height: tipLabel.implicitHeight + 8
                            radius: 6
                            color:        Theme.popupBg
                            border.color: Theme.popupBorder
                            border.width: 1
                            z: 20

                            Text {
                                id: tipLabel
                                anchors.centerIn: parent
                                text:           appItem.modelData.name
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSmall
                                color:          Theme.textPrimary
                            }
                        }
                    }
                }

                // ── Divider ────────────────────────────────────
                Rectangle {
                    width:  1
                    height: Theme.dockIconSize - 12
                    color:  Theme.divider
                    anchors.verticalCenter: parent.verticalCenter
                }

                // ── Workspace pills ────────────────────────────
                Row {
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: Hyprland.workspaces

                        delegate: Rectangle {
                            id: ws

                            required property var modelData

                            readonly property bool active: Hyprland.focusedWorkspace
                                && Hyprland.focusedWorkspace.id === ws.modelData.id

                            width:  ws.active ? 26 : 22
                            height: 22
                            radius: 6

                            color: ws.active          ? Theme.accent
                                 : wsHov.containsMouse ? Theme.hoverMagenta
                                 : Theme.hoverBg

                            Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                            Behavior on width { NumberAnimation { duration: Theme.animNormal } }

                            Text {
                                anchors.centerIn: parent
                                text:           ws.modelData.id
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSmall
                                font.bold:      true
                                color:          ws.active ? Theme.bg : Theme.textPrimary
                            }

                            MouseArea {
                                id: wsHov
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked:    Hyprland.dispatch("workspace " + ws.modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}
