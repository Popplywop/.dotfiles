// modules/bar/VolumeWidget.qml
// Volume via Pipewire. Scroll = adjust, click = mute toggle.

import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

BarWidget {
    id: root

    readonly property color volColor: Audio.muted ? Theme.danger : Theme.textPrimary

    icon:        Audio.icon()
    iconColor:   root.volColor
    anchorRight: true
    popupWidth:  250
    clickable:   true
    scrollable:  true

    onClicked: Audio.toggleMute()
    onScrolled: up => Audio.changeVolume(up ? 5 : -5)

    PopupHeader {
        icon:       Audio.icon()
        iconColor:  root.volColor
        value:      Audio.volume + "%"
        valueColor: root.volColor
        caption:    Audio.muted ? "Muted" : "Active"
    }

    StatBar {
        width:        parent.width
        value:        Audio.volume
        fillColor:    root.volColor
        fillDuration: Theme.animNormal
    }

    HintText { text: "Scroll to adjust  •  Click pill to mute" }

    Divider {}

    Text {
        width:          parent.width
        text:           "Sink: " + (Audio.sinkName || "—")
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        color:          Theme.textSecondary
        elide:          Text.ElideRight
    }

    PopupRow {
        visible: Audio.micReady
        label:   "Microphone"
        value:   Audio.micMuted ? "muted" : Audio.micVolume + "%"
    }

    Row {
        spacing: 6

        Repeater {
            model: [-20, -10, -5, 5, 10, 20]

            delegate: Rectangle {
                id: adjBtn

                required property int modelData

                width:  36
                height: 22
                radius: 4
                color:  adjHov.containsMouse ? Theme.hoverFg : Theme.hoverBg

                Text {
                    anchors.centerIn: parent
                    text:             (adjBtn.modelData > 0 ? "+" : "") + adjBtn.modelData + "%"
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontTiny
                    color:            Theme.textPrimary
                }

                MouseArea {
                    id: adjHov
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    Audio.changeVolume(adjBtn.modelData)
                }
            }
        }
    }
}
