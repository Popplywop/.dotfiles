// modules/wallpicker/WallPicker.qml
// Wallpaper switcher. Previews live as you navigate; Enter keeps, Esc restores.
//
// Was a standalone one-shot config that called Qt.quit(); now a persistent
// hidden window that open()/close() toggles, so it opens instantly.

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "root:/config"

Item {
    id: root

    property bool   open:         false
    property string originalWall: ""
    property string pendingWall:  ""

    ListModel { id: wallModel }

    function show() {
        wallModel.clear()
        root.pendingWall = ""
        readOrigProc.running = true
        listProc.running     = true
        root.open = true
    }

    function hide() {
        debounce.stop()
        root.open = false
    }

    function toggle() {
        if (root.open) cancel()
        else           show()
    }

    // Enter / double-click: wallpaper is already live, just close
    function confirm() {
        root.hide()
    }

    // Esc: restore the wallpaper we started with
    function cancel() {
        debounce.stop()
        if (root.originalWall !== "" && root.pendingWall !== root.originalWall)
            awwwProc.apply(root.originalWall, false)
        root.hide()
    }

    function queuePreview(path) {
        root.pendingWall = path
        debounce.restart()
    }

    // ── Current wallpaper, from the awww cache ─────────────────
    Process {
        id: readOrigProc
        command: ["bash", "-c",
            "grep -oE '/[^ ]+\\.(jpg|jpeg|png|webp|gif)' " +
            "$HOME/.cache/awww/0.12.0/eDP-1 2>/dev/null | head -1"
        ]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim()
                if (p) root.originalWall = p
            }
        }
    }

    // ── Available wallpapers ───────────────────────────────────
    Process {
        id: listProc
        command: ["bash", "-c",
            "find \"$HOME/Pictures/Wallpapers\" -maxdepth 1 -type f " +
            "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"
        ]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim()
                if (p) wallModel.append({ path: p })
            }
        }
        onExited: {
            running = false
            if (wallModel.count > 0) {
                grid.currentIndex = 0
                root.queuePreview(wallModel.get(0).path)
            }
        }
    }

    // ── Wallpaper setter ───────────────────────────────────────
    // Instant transition while previewing, default fade when restoring.
    Process {
        id: awwwProc
        property string nextPath:   ""
        property bool   hasPending: false
        property bool   preview:    true

        command: preview
            ? ["awww", "img", "--transition-type", "none", nextPath]
            : ["awww", "img", nextPath]
        running: false

        onExited: {
            if (hasPending) {
                hasPending = false
                running    = true
            }
        }

        function apply(path, isPreview) {
            preview  = (isPreview !== false)
            nextPath = path
            if (running) {
                hasPending = true
                running    = false   // kill current; onExited restarts
            } else {
                running = true
            }
        }
    }

    // Avoid hammering awww during fast navigation
    Timer {
        id: debounce
        interval: 180
        repeat:   false
        onTriggered: if (root.pendingWall !== "") awwwProc.apply(root.pendingWall, true)
    }

    // ── Window ─────────────────────────────────────────────────
    PanelWindow {
        id: panel

        visible: root.open

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace:     "wall-picker"

        // No edge anchors → compositor centers the window
        anchors.top:    false
        anchors.bottom: false
        anchors.left:   false
        anchors.right:  false

        implicitWidth:  960
        implicitHeight: 580
        color:          "transparent"

        onVisibleChanged: if (visible) grid.forceActiveFocus()

        Rectangle {
            anchors.fill: parent
            color:        Theme.popupBg
            radius:       14
            border.color: Theme.popupBorder
            border.width: Theme.popupBorderWidth

            ColumnLayout {
                anchors.fill:    parent
                anchors.margins: 16
                spacing:         10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text:           "󰋩  Wallpaper Switcher"
                        color:          Theme.fgBright
                        font.pixelSize: 15
                        font.bold:      true
                        font.family:    Theme.fontFamily
                    }
                    Text {
                        text:             wallModel.count + " wallpapers"
                        color:            Theme.textSecondary
                        font.pixelSize:   Theme.fontBody
                        font.family:      Theme.fontFamily
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

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
                        if (event.key === Qt.Key_Escape)
                            root.cancel()
                        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                            root.confirm()
                    }

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < wallModel.count)
                            root.queuePreview(wallModel.get(currentIndex).path)
                    }

                    delegate: Item {
                        id: cell

                        width:  grid.cellWidth
                        height: grid.cellHeight

                        readonly property bool active: grid.currentIndex === index

                        Rectangle {
                            anchors { fill: parent; margins: 6 }
                            radius:       8
                            color:        cell.active ? Theme.hoverMagenta  : Theme.surface
                            border.color: cell.active ? Theme.popupBorder   : Theme.surfaceBorder
                            border.width: cell.active ? 2 : 1

                            Behavior on color        { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Image {
                                id: thumb
                                anchors {
                                    top: parent.top; left: parent.left; right: parent.right
                                    bottom: fname.top
                                    margins: 4; bottomMargin: 2
                                }
                                source:       "file://" + path
                                fillMode:     Image.PreserveAspectCrop
                                smooth:       true
                                clip:         true
                                asynchronous: true
                                sourceSize:   Qt.size(440, 290)   // 2x cell — caps decode size

                                Rectangle {
                                    anchors.fill: parent
                                    color:        Theme.surface
                                    visible:      thumb.status !== Image.Ready
                                    radius:       4
                                    Text {
                                        anchors.centerIn: parent
                                        text:             "⏳"
                                        font.pixelSize:   Theme.fontIcon
                                    }
                                }
                            }

                            Text {
                                id: fname
                                anchors {
                                    bottom: parent.bottom; left: parent.left; right: parent.right
                                    bottomMargin: 5
                                }
                                text:                path.split("/").pop()
                                color:               cell.active ? Theme.fgBright : Theme.textSecondary
                                font.pixelSize:      Theme.fontTiny
                                font.family:         Theme.fontFamily
                                elide:               Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter

                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            }

                            MouseArea {
                                anchors.fill:    parent
                                hoverEnabled:    true
                                onEntered:       grid.currentIndex = index
                                onClicked:       grid.currentIndex = index
                                onDoubleClicked: root.confirm()
                            }
                        }
                    }
                }

                Text {
                    text:           "  ↑ ↓ ← →  navigate    Enter / double-click  confirm    Esc  cancel & restore"
                    color:          Theme.textFaint
                    font.pixelSize: Theme.fontSmall
                    font.family:    Theme.fontFamily
                }
            }
        }
    }
}
