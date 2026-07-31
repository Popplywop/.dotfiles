// modules/launcher/Launcher.qml
// Application launcher. Persistent hidden window toggled over IPC, so it
// opens instantly instead of paying process startup like wofi did.

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "root:/config"
import "root:/services"

Item {
    id: root

    property bool open:    false
    property var  results: []

    function show() {
        search.text = ""
        root.refresh()
        root.open = true
    }

    function hide() {
        root.open = false
        search.text = ""
    }

    function toggle() {
        if (root.open) root.hide()
        else           root.show()
    }

    function refresh() {
        root.results = Apps.search(search.text)
        list.currentIndex = root.results.length > 0 ? 0 : -1
    }

    // The app scan finishes after startup; refresh so an open launcher fills in
    // rather than sitting on the empty snapshot refresh() took.
    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() { if (root.open) root.refresh() }
    }

    function activate(index) {
        if (index < 0 || index >= root.results.length) return
        Apps.launch(root.results[index])
        root.hide()
    }

    PanelWindow {
        id: panel

        visible: root.open

        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace:     "qs-launcher"

        // No edge anchors → compositor centres the window
        anchors.top:    false
        anchors.bottom: false
        anchors.left:   false
        anchors.right:  false

        implicitWidth:  Theme.launcherWidth
        implicitHeight: card.implicitHeight
        color:          "transparent"

        onVisibleChanged: if (visible) search.forceActiveFocus()

        Rectangle {
            id: card
            width:  parent.width
            implicitHeight: content.implicitHeight + Theme.popupPadding * 2

            color:        Theme.popupBg
            radius:       Theme.popupRadius
            border.color: Theme.popupBorder
            border.width: Theme.popupBorderWidth

            ColumnLayout {
                id: content
                anchors {
                    top: parent.top; left: parent.left; right: parent.right
                    margins: Theme.popupPadding
                }
                spacing: 8

                // ── Search field ───────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text:           "󱓞"
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontHuge
                        color:          Theme.blue
                    }

                    TextInput {
                        id: search

                        Layout.fillWidth: true
                        font.family:      Theme.fontFamily
                        font.pixelSize:   Theme.fontBig
                        color:            Theme.textPrimary
                        selectionColor:   Theme.hoverMagenta
                        selectedTextColor: Theme.fgBright
                        clip:             true

                        onTextChanged: root.refresh()

                        Keys.onPressed: event => {
                            switch (event.key) {
                            case Qt.Key_Escape:
                                root.hide(); event.accepted = true; break
                            case Qt.Key_Down:
                                list.incrementCurrentIndex(); event.accepted = true; break
                            case Qt.Key_Up:
                                list.decrementCurrentIndex(); event.accepted = true; break
                            case Qt.Key_Return:
                            case Qt.Key_Enter:
                                root.activate(list.currentIndex); event.accepted = true; break
                            case Qt.Key_Tab:
                                list.incrementCurrentIndex(); event.accepted = true; break
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible:        search.text.length === 0
                            text:           "Search applications…"
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontBig
                            color:          Theme.textMuted
                        }
                    }

                    Text {
                        text:           root.results.length + ""
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                        color:          Theme.textMuted
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color:  Theme.divider
                }

                // ── Empty state ────────────────────────────────
                Text {
                    Layout.fillWidth: true
                    visible:        root.results.length === 0
                    text:           "No matches"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    color:          Theme.textMuted
                    topPadding:     12
                    bottomPadding:  12
                    horizontalAlignment: Text.AlignHCenter
                }

                // ── Results ────────────────────────────────────
                ListView {
                    id: list

                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, Theme.launcherMaxHeight)
                    visible: root.results.length > 0
                    clip:    true

                    model: root.results

                    keyNavigationWraps: true
                    highlightMoveDuration: 90

                    delegate: Rectangle {
                        id: row

                        required property var  modelData
                        required property int  index

                        readonly property bool selected: list.currentIndex === row.index
                        readonly property string iconSource:
                            row.modelData.icon !== ""
                                ? Quickshell.iconPath(row.modelData.icon, true)
                                : ""

                        width:  list.width
                        height: Theme.launcherRowHeight
                        radius: 8
                        color:  row.selected            ? Theme.hoverMagenta
                              : rowHov.containsMouse    ? Theme.hoverBg
                              : "transparent"

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Image {
                            id: rowIcon
                            anchors.left:           parent.left
                            anchors.leftMargin:     10
                            anchors.verticalCenter: parent.verticalCenter
                            source:     row.iconSource
                            sourceSize: Qt.size(Theme.launcherIconSize, Theme.launcherIconSize)
                            width:      status === Image.Ready ? Theme.launcherIconSize : 0
                            height:     status === Image.Ready ? Theme.launcherIconSize : 0
                            fillMode:   Image.PreserveAspectFit
                            smooth:     true
                            asynchronous: true
                        }

                        Column {
                            anchors.left:           rowIcon.right
                            anchors.leftMargin:     rowIcon.width > 0 ? 12 : 0
                            anchors.right:          parent.right
                            anchors.rightMargin:    10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                width:          parent.width
                                text:           row.modelData.name
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontHeader
                                font.bold:      row.selected
                                color:          row.selected ? Theme.fgBright : Theme.textPrimary
                                elide:          Text.ElideRight
                            }
                            Text {
                                width:          parent.width
                                visible:        text.length > 0
                                text:           row.modelData.comment !== ""
                                              ? row.modelData.comment
                                              : (row.modelData.genericName || "")
                                font.family:    Theme.fontFamily
                                font.pixelSize: Theme.fontSmall
                                color:          Theme.textSecondary
                                elide:          Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: rowHov
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onEntered:    list.currentIndex = row.index
                            onClicked:    root.activate(row.index)
                        }
                    }
                }

                // ── Footer ─────────────────────────────────────
                Text {
                    Layout.fillWidth: true
                    text:           "↑ ↓  navigate    Enter  launch    Esc  close"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                    color:          Theme.textFaint
                }
            }
        }
    }
}
