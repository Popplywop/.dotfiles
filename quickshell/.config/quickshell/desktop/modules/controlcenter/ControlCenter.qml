// modules/controlcenter/ControlCenter.qml
// Bar widget opening a panel with output/brightness sliders, media transport,
// Bluetooth and wifi.

import Quickshell
import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

BarWidget {
    id: root

    // The OSD hides itself while this is open — see shell.qml
    signal openedChanged(bool open)
    onPopupOpenChanged: root.openedChanged(root.popupOpen)

    icon:        "󰕮"
    iconSize:    Theme.fontPill
    clickable:   true
    openOnHover: false
    anchorRight: true
    popupMargin: 8
    popupWidth:  340

    onClicked: root.popupOpen = !root.popupOpen

    // ── Output ─────────────────────────────────────────────────
    SectionHeader { text: "Output" }

    Row {
        width:   parent.width
        spacing: 10

        Text {
            width:          22
            text:           Audio.icon()
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontIcon
            color:          Audio.muted ? Theme.danger : Theme.textPrimary
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    Audio.toggleMute()
            }
        }

        Slider {
            width:     parent.width - 22 - 40 - 20
            value:     Audio.muted ? 0 : Audio.volume
            fillColor: Audio.muted ? Theme.danger : Theme.accent
            enabled:   Audio.ready
            onMoved:   v => Audio.setVolume(v)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            width:          40
            text:           Audio.volume + "%"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSmall
            color:          Theme.textSecondary
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Text {
        width:          parent.width
        text:           Audio.sinkName || "—"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontTiny
        color:          Theme.textMuted
        elide:          Text.ElideRight
    }

    // ── Brightness ─────────────────────────────────────────────
    SectionHeader {
        text:    "Brightness"
        visible: Brightness.available
    }

    Row {
        visible: Brightness.available
        width:   parent.width
        spacing: 10

        Text {
            width:          22
            text:           Brightness.icon()
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontIcon
            color:          Theme.accent
            anchors.verticalCenter: parent.verticalCenter
        }

        Slider {
            width:     parent.width - 22 - 40 - 20
            value:     Brightness.percent
            fillColor: Theme.accent
            onMoved:   v => Brightness.set(v)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            width:          40
            text:           Brightness.percent + "%"
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSmall
            color:          Theme.textSecondary
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Divider {}

    MediaSection { contentWidth: root.contentWidth }

    Divider {}

    BluetoothSection { contentWidth: root.contentWidth }

    Divider {}

    WifiSection {
        contentWidth: root.contentWidth
        active:       root.popupOpen
    }
}
