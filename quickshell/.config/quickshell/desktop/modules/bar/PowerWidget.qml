// modules/bar/PowerWidget.qml
// Power button → Lock / Logout / Reboot / Shutdown menu.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    icon:        "⏻"
    iconColor:   Theme.danger
    hoverBg:     Theme.hoverDanger
    active:      root.popupOpen
    clickable:   true
    anchorRight: true
    popupMargin: 4
    popupWidth:  180

    onClicked: {
        root.popupOpen = !root.popupOpen
        if (root.popupOpen) root.holdOpen()
    }

    Process { id: lockCmd;     command: ["bash", "-c", "(sleep 0.5; hyprlock) & disown"]; running: false; onExited: running = false }
    Process { id: logoutCmd;   command: ["hyprctl", "dispatch", "exit"];                  running: false; onExited: running = false }
    Process { id: rebootCmd;   command: ["systemctl", "reboot"];                          running: false; onExited: running = false }
    Process { id: shutdownCmd; command: ["systemctl", "poweroff"];                        running: false; onExited: running = false }

    Repeater {
        model: [
            { icon: "󰌾", label: "Lock",     action: "lock"     },
            { icon: "󰍃", label: "Logout",   action: "logout"   },
            { icon: "󰑐", label: "Reboot",   action: "reboot"   },
            { icon: "󰐥", label: "Shutdown", action: "shutdown" },
        ]

        delegate: Rectangle {
            width:  root.contentWidth
            height: 38
            radius: 6
            color:  menuHov.containsMouse ? Theme.hoverDanger : "transparent"

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:           parent.left
                anchors.leftMargin:     10
                spacing:                10

                Text {
                    text:           modelData.icon
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontIcon
                    color:          Theme.danger
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text:           modelData.label
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontPill
                    font.bold:      menuHov.containsMouse
                    color:          Theme.textPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: menuHov
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked: {
                    root.popupOpen = false
                    switch (modelData.action) {
                        case "lock":     if (!lockCmd.running)     lockCmd.running     = true; break
                        case "logout":   if (!logoutCmd.running)   logoutCmd.running   = true; break
                        case "reboot":   if (!rebootCmd.running)   rebootCmd.running   = true; break
                        case "shutdown": if (!shutdownCmd.running) shutdownCmd.running = true; break
                    }
                }
            }
        }
    }
}
