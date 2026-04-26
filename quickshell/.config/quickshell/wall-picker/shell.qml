import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // ── State ─────────────────────────────────────────────────────────────
    property string originalWall: ""
    property string pendingWall: ""
    property bool   quitting: false

    ListModel { id: wallModel }

    // ── Read original wallpaper from awww cache ────────────────────────────
    Process {
        id: readOrigProc
        command: ["bash", "-c",
            "grep -oE '/[^ ]+\\.(jpg|jpeg|png|webp|gif)' " +
            "$HOME/.cache/awww/0.12.0/eDP-1 2>/dev/null | head -1"
        ]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim()
                if (p) root.originalWall = p
            }
        }
    }

    // ── List wallpapers ────────────────────────────────────────────────────
    Process {
        id: listProc
        command: ["bash", "-c",
            "find \"$HOME/Pictures/Wallpapers\" -maxdepth 1 -type f " +
            "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"
        ]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim()
                if (p) wallModel.append({ path: p })
            }
        }
        onExited: {
            // After file list loads, preview the first entry
            if (wallModel.count > 0)
                root.queuePreview(wallModel.get(0).path)
        }
    }

    // ── Wallpaper setter ───────────────────────────────────────────────────
    // Uses instant transition for preview; default (simple fade) for confirm/cancel restore.
    Process {
        id: awwwProc
        property string nextPath: ""
        property bool   hasPending: false
        property bool   preview: true

        command: preview
            ? ["awww", "img", "--transition-type", "none", nextPath]
            : ["awww", "img", nextPath]
        running: false

        onExited: {
            if (hasPending) {
                hasPending = false
                running = true
            } else if (root.quitting) {
                Qt.quit()
            }
        }

        function apply(path, isPreview) {
            preview  = (isPreview !== false)
            nextPath = path
            if (running) {
                // Kill current and queue restart via onExited
                hasPending = true
                running    = false
            } else {
                running = true
            }
        }
    }

    // ── Preview debounce (avoid hammering awww during fast nav) ───────────
    Timer {
        id: debounce
        interval: 180
        repeat:   false
        onTriggered: {
            if (root.pendingWall !== "")
                awwwProc.apply(root.pendingWall, true)
        }
    }

    function queuePreview(path) {
        pendingWall = path
        debounce.restart()
    }

    // Enter or double-click: wallpaper is already live, just close
    function confirm() {
        debounce.stop()
        quitting = true
        if (awwwProc.running) {
            // Let onExited handle Qt.quit()
        } else {
            Qt.quit()
        }
    }

    // Esc: restore original and close
    function cancel() {
        debounce.stop()
        quitting = true
        if (originalWall !== "" && pendingWall !== originalWall) {
            awwwProc.apply(originalWall, false)
            // Qt.quit() called from onExited after restore finishes
        } else {
            Qt.quit()
        }
    }

    // ── Window ─────────────────────────────────────────────────────────────
    PanelWindow {
        id: panel

        // Layer shell config
        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace:     "wall-picker"

        // No edge anchors → compositor centers the window
        anchors.top:    false
        anchors.bottom: false
        anchors.left:   false
        anchors.right:  false

        width:  960
        height: 580
        color:  "transparent"

        // ── Panel surface ─────────────────────────────────────────────────
        Rectangle {
            anchors.fill:  parent
            color:         "#ee181818"
            radius:        14
            border.color:  "#9e95c7"
            border.width:  2

            ColumnLayout {
                anchors.fill:    parent
                anchors.margins: 16
                spacing:         10

                // ── Header ────────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text:           "󰋩  Wallpaper Switcher"
                        color:          "#f4f4ff"
                        font.pixelSize: 15
                        font.bold:      true
                        font.family:    "monospace"
                    }

                    Text {
                        text:           wallModel.count + " wallpapers"
                        color:          "#96a6c8"
                        font.pixelSize: 12
                        font.family:    "monospace"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // ── Thumbnail grid ────────────────────────────────────────
                GridView {
                    id: grid

                    Layout.fillWidth:  true
                    Layout.fillHeight: true

                    cellWidth:  220
                    cellHeight: 145
                    clip:       true
                    focus:      true

                    model:        wallModel
                    currentIndex: 0

                    Keys.onPressed: event => {
                        if      (event.key === Qt.Key_Escape)                 root.cancel()
                        else if (event.key === Qt.Key_Return ||
                                 event.key === Qt.Key_Enter)                  root.confirm()
                    }

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < wallModel.count)
                            root.queuePreview(wallModel.get(currentIndex).path)
                    }

                    delegate: Item {
                        id: cell
                        width:  grid.cellWidth
                        height: grid.cellHeight

                        property bool active: grid.currentIndex === index

                        Rectangle {
                            anchors {
                                fill:    parent
                                margins: 6
                            }
                            radius:        8
                            color:         cell.active ? "#339e95c7" : "#282828"
                            border.color:  cell.active ? "#9e95c7"   : "#453d41"
                            border.width:  cell.active ? 2 : 1

                            Behavior on color        { ColorAnimation { duration: 80 } }
                            Behavior on border.color { ColorAnimation { duration: 80 } }

                            // Thumbnail image
                            Image {
                                id: thumb
                                anchors {
                                    top:          parent.top
                                    left:         parent.left
                                    right:        parent.right
                                    bottom:       fname.top
                                    margins:      4
                                    bottomMargin: 2
                                }
                                source:       "file://" + path
                                fillMode:     Image.PreserveAspectCrop
                                smooth:       true
                                clip:         true
                                asynchronous: true
                                sourceSize:   Qt.size(440, 290)  // 2x cell — limits decoded resolution

                                // Loading placeholder
                                Rectangle {
                                    anchors.fill: parent
                                    color:        "#282828"
                                    visible:      thumb.status !== Image.Ready
                                    radius:       4
                                    Text {
                                        anchors.centerIn: parent
                                        text:             "⏳"
                                        font.pixelSize:   16
                                    }
                                }
                            }

                            // Filename label
                            Text {
                                id: fname
                                anchors {
                                    bottom:       parent.bottom
                                    left:         parent.left
                                    right:        parent.right
                                    bottomMargin: 5
                                }
                                text:                path.split("/").pop()
                                color:               cell.active ? "#f4f4ff" : "#96a6c8"
                                font.pixelSize:      10
                                font.family:         "monospace"
                                elide:               Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter

                                Behavior on color { ColorAnimation { duration: 80 } }
                            }

                            // Mouse interaction
                            MouseArea {
                                anchors.fill:  parent
                                hoverEnabled:  true
                                onEntered:     grid.currentIndex = index
                                onClicked:     grid.currentIndex = index
                                onDoubleClicked: root.confirm()
                            }
                        }
                    }
                }

                // ── Footer hints ──────────────────────────────────────────
                Text {
                    text: "  ↑ ↓ ← →  navigate    Enter / double-click  confirm    Esc  cancel & restore"
                    color:          "#453d41"
                    font.pixelSize: 11
                    font.family:    "monospace"
                }
            }
        }
    }
}
