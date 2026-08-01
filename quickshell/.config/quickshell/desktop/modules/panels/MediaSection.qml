// modules/controlcenter/MediaSection.qml
// Now-playing plus transport controls for the active MPRIS player.

import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import "root:/config"
import "root:/components"

Column {
    id: root

    property real contentWidth: parent ? parent.width : 0

    // Prefer something actually playing, else the first player that exists
    readonly property var player: {
        const ps = Mpris.players.values
        if (ps.length === 0) return null
        return ps.find(p => p.isPlaying) || ps[0]
    }

    readonly property bool has: player !== null

    width:   root.contentWidth
    spacing: 6

    SectionHeader { text: "Media" }

    Text {
        visible:        !root.has
        width:          parent.width
        text:           "Nothing playing"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        color:          Theme.textMuted
        bottomPadding:  4
    }

    Row {
        visible: root.has
        width:   parent.width
        spacing: 10

        Image {
            id: art
            width:      status === Image.Ready ? 48 : 0
            height:     status === Image.Ready ? 48 : 0
            source:     root.has ? (root.player.trackArtUrl || "") : ""
            sourceSize: Qt.size(48, 48)
            fillMode:   Image.PreserveAspectCrop
            smooth:     true
            asynchronous: true
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width:   parent.width - (art.width > 0 ? art.width + 10 : 0)
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter

            Text {
                width:          parent.width
                text:           root.has ? (root.player.trackTitle || "Unknown track") : ""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.bold:      true
                color:          Theme.textPrimary
                elide:          Text.ElideRight
            }
            Text {
                width:          parent.width
                visible:        text.length > 0
                text:           root.has ? (root.player.trackArtist || "") : ""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                color:          Theme.textSecondary
                elide:          Text.ElideRight
            }
            Text {
                width:          parent.width
                visible:        text.length > 0
                text:           root.has ? (root.player.identity || "") : ""
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontTiny
                color:          Theme.textMuted
                elide:          Text.ElideRight
            }
        }
    }

    Row {
        visible: root.has
        spacing: 4

        Repeater {
            model: [
                { glyph: "󰒮", act: "prev" },
                { glyph: "󰐊", act: "play" },
                { glyph: "󰒭", act: "next" },
            ]

            delegate: Rectangle {
                id: btn

                required property var modelData

                readonly property bool isPlay: btn.modelData.act === "play"
                readonly property bool usable: {
                    if (!root.has) return false
                    if (btn.modelData.act === "prev") return root.player.canGoPrevious
                    if (btn.modelData.act === "next") return root.player.canGoNext
                    return root.player.canTogglePlaying
                }

                width:  36
                height: 26
                radius: 5
                color:  ctrlHov.containsMouse && btn.usable ? Theme.hoverFg : Theme.hoverBg
                opacity: btn.usable ? 1 : 0.35

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Text {
                    anchors.centerIn: parent
                    // Play button reflects state: pause glyph while playing
                    text: btn.isPlay && root.has && root.player.isPlaying
                        ? "󰏤"
                        : btn.modelData.glyph
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontIcon
                    color:          Theme.textPrimary
                }

                MouseArea {
                    id: ctrlHov
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled:      btn.usable
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        if (!root.has) return
                        switch (btn.modelData.act) {
                        case "prev": root.player.previous(); break
                        case "next": root.player.next();     break
                        case "play": root.player.togglePlaying(); break
                        }
                    }
                }
            }
        }
    }
}
