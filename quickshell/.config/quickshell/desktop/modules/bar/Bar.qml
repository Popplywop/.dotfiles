// modules/bar/Bar.qml
// Top bar panel.

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/config"
import "root:/components"
import "root:/modules/notifications"

PanelWindow {
    id: bar

    WlrLayershell.namespace: "qs-bar"
    WlrLayershell.layer:     WlrLayer.Top

    anchors.top:   true
    anchors.left:  true
    anchors.right: true
    exclusiveZone:  Theme.barHeight
    implicitHeight: Theme.barHeight
    color:          Theme.barBg

    RowLayout {
        anchors.fill:        parent
        anchors.leftMargin:  Theme.barMargin
        anchors.rightMargin: Theme.barMargin
        spacing:             Theme.barSpacing

        // ── Left ───────────────────────────────────────────────
        RowLayout {
            spacing: Theme.barSpacing

            // TODO(phase 2): replace wofi with a native quickshell launcher
            BarPill {
                label:      "󱓞"
                labelColor: Theme.blue
                onClicked:  launchProc.running = true

                Process {
                    id: launchProc
                    command: ["wofi", "--show", "drun"]
                    running: false
                    onExited: running = false
                }
            }

            WeatherWidget {}
            ClockWidget   {}
            TaskbarWidget {}
        }

        Item { Layout.fillWidth: true }

        // ── Centre ─────────────────────────────────────────────
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Workspaces {}
        }

        Text {
            text:                Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
            color:               Theme.textSecondary
            font.family:         Theme.fontFamily
            font.pixelSize:      Theme.fontSmall
            elide:               Text.ElideRight
            Layout.maximumWidth: 380
            visible:             text.length > 0
            leftPadding:         8
        }

        Item { Layout.fillWidth: true }

        // ── Right ──────────────────────────────────────────────
        RowLayout {
            spacing: Theme.barSpacing

            TrayWidget         {}
            NotificationCenter {}
            BatteryWidget      {}
            VolumeWidget    {}
            BacklightWidget {}
            CpuWidget       {}
            MemWidget       {}
            DiskWidget      {}
            UpdatesWidget   {}
            NetworkWidget   {}

            Rectangle {
                width:  1
                height: 18
                color:  Theme.divider
                Layout.alignment:   Qt.AlignVCenter
                Layout.leftMargin:  4
                Layout.rightMargin: 4
            }

            BarPill {
                label:      "\uF023 "
                labelColor: Theme.textPrimary
                onClicked:  lockProc.running = true

                Process {
                    id: lockProc
                    command: ["bash", "-c", "(sleep 0.5; hyprlock) & disown"]
                    running: false
                    onExited: running = false
                }
            }

            PowerWidget {}
        }
    }
}
