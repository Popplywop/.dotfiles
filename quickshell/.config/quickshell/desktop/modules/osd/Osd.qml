// modules/osd/Osd.qml
// On-screen display for volume and brightness. Neither had any feedback
// before — the keys changed the value silently.
//
// Volume shows itself: Pipewire pushes changes, so it fires for any volume
// change including ones made by other applications. Brightness cannot be
// observed (sysfs does not notify), so the hyprland brightness keys poke it
// over IPC.

import Quickshell
import Quickshell.Wayland
import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

Item {
    id: root

    // Set true by the control centre so dragging its sliders does not throw an
    // OSD over the panel you are already looking at.
    property bool suppressed: false

    property string mode:  "volume"   // "volume" | "brightness"
    property bool   shown: false

    readonly property int    value: mode === "volume"
        ? (Audio.muted ? 0 : Audio.volume)
        : Brightness.percent

    readonly property string icon: mode === "volume"
        ? Audio.icon()
        : Brightness.icon()

    readonly property color accent: (mode === "volume" && Audio.muted)
        ? Theme.danger
        : Theme.accent

    function flash(which) {
        if (root.suppressed) return
        root.mode  = which
        root.shown = true
        hideTimer.restart()
    }

    function showVolume()     { root.flash("volume") }
    function showBrightness() { root.flash("brightness") }

    Timer {
        id: hideTimer
        interval: Theme.osdTimeout
        onTriggered: root.shown = false
    }

    // ── Volume triggers itself ─────────────────────────────────
    // Ignore the first evaluation so the OSD does not appear at login.
    property bool _primed: false

    Connections {
        target: Audio
        enabled: Audio.ready

        function onVolumeChanged() { if (root._primed) root.showVolume() }
        function onMutedChanged()  { if (root._primed) root.showVolume() }
    }

    Timer {
        interval: 1500
        running:  true
        onTriggered: root._primed = true
    }

    // ── Window ─────────────────────────────────────────────────
    PanelWindow {
        visible: root.shown

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace:     "qs-osd"

        anchors.bottom: true
        margins.bottom: Theme.osdBottomGap

        implicitWidth:  Theme.osdWidth
        implicitHeight: Theme.osdHeight
        color:          "transparent"

        Rectangle {
            id: cardBg
            anchors.fill: parent
            color:        Theme.popupBg
            radius:       Theme.popupRadius
            border.color: Theme.popupBorder
            border.width: Theme.popupBorderWidth

            opacity: root.shown ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

            Column {
                anchors {
                    left: parent.left; right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 18
                }
                spacing: 12

                Row {
                    spacing: 12

                    Text {
                        text:           root.icon
                        font.family:    Theme.fontFamily
                        font.pixelSize: 26
                        color:          root.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text:           (root.mode === "volume" && Audio.muted)
                                      ? "Muted"
                                      : root.value + "%"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontBig
                        font.bold:      true
                        color:          Theme.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                StatBar {
                    width:        parent.width
                    height:       Theme.barThin
                    value:        root.value
                    fillColor:    root.accent
                    fillDuration: Theme.animFast
                }
            }
        }
    }
}
