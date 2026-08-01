// modules/panels/DashboardPanel.qml
// Left flyout: system monitoring as graphs rather than the bar's pills.

import Quickshell
import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

SlidePanel {
    id: root

    fromRight: false

    function statColor(pct, warn, danger) {
        if (pct >= danger) return Theme.danger
        if (pct >= warn)   return Theme.warn
        return Theme.accent
    }

    // Feed the sparklines
    Connections {
        target: SysInfo
        function onSampled(cpu, mem, rx, tx) {
            cpuLine.push(cpu)
            memLine.push(mem)
            // Network is unbounded, so scale against a rolling ceiling
            const peak = Math.max(64, netLine.peak, rx + tx)
            netLine.peak = peak * 0.98
            netLine.push((rx + tx) / peak * 100)
        }
    }

    Text {
        text:           "System"
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontHeader
        font.bold:      true
        color:          Theme.textSecondary
    }

    Divider {}

    // ── CPU ────────────────────────────────────────────────────
    Column {
        width:   parent.width
        spacing: 4

        Item {
            width:  parent.width
            height: 16
            Text {
                anchors.left: parent.left
                text: "CPU"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                color: Theme.textSecondary
            }
            Text {
                anchors.right: parent.right
                text: SysInfo.cpu + "%"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                font.bold: true
                color: root.statColor(SysInfo.cpu, 60, 85)
            }
        }

        Sparkline {
            id: cpuLine
            width:     parent.width
            fillColor: root.statColor(SysInfo.cpu, 60, 85)
        }
    }

    // ── Memory ─────────────────────────────────────────────────
    Column {
        width:   parent.width
        spacing: 4

        Item {
            width:  parent.width
            height: 16
            Text {
                anchors.left: parent.left
                text: "Memory"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                color: Theme.textSecondary
            }
            Text {
                anchors.right: parent.right
                text: SysInfo.memUsed.toFixed(1) + " / " + SysInfo.memTotal.toFixed(1) + " G"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                font.bold: true
                color: root.statColor(SysInfo.mem, 75, 90)
            }
        }

        Sparkline {
            id: memLine
            width:     parent.width
            fillColor: root.statColor(SysInfo.mem, 75, 90)
        }
    }

    // ── Network ────────────────────────────────────────────────
    Column {
        width:   parent.width
        spacing: 4

        Item {
            width:  parent.width
            height: 16
            Text {
                anchors.left: parent.left
                text: "Network"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                color: Theme.textSecondary
            }
            Text {
                anchors.right: parent.right
                text: "↓ " + SysInfo.fmtRate(SysInfo.netRx) + "   ↑ " + SysInfo.fmtRate(SysInfo.netTx)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontTiny
                color: Theme.textPrimary
            }
        }

        Sparkline {
            id: netLine
            property real peak: 64
            width:     parent.width
            fillColor: Theme.blue
        }
    }

    Divider {}

    // ── Disk ───────────────────────────────────────────────────
    Column {
        width:   parent.width
        spacing: 6

        Item {
            width:  parent.width
            height: 16
            Text {
                anchors.left: parent.left
                text: "Disk  /"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                color: Theme.textSecondary
            }
            Text {
                anchors.right: parent.right
                text: SysInfo.diskUsed + " / " + SysInfo.diskTotal
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                font.bold: true
                color: root.statColor(SysInfo.disk, 80, 90)
            }
        }

        StatBar {
            width:     parent.width
            value:     SysInfo.disk
            fillColor: root.statColor(SysInfo.disk, 80, 90)
        }
    }

    Divider {}

    // ── Updates ────────────────────────────────────────────────
    Rectangle {
        width:  parent.width
        height: 46
        radius: 8
        color:  updHov.containsMouse ? Theme.hoverBg : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Text {
            id: updIcon
            anchors.left:           parent.left
            anchors.leftMargin:     6
            anchors.verticalCenter: parent.verticalCenter
            text:           ""
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontIcon
            opacity:        SysInfo.updatesBusy ? 0.45 : 1.0
            color:          !SysInfo.updatesChecked ? Theme.textMuted
                          : !SysInfo.updatesOk      ? Theme.danger
                          : SysInfo.updates > 0     ? Theme.accent
                          : Theme.textMuted

            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
        }

        Column {
            anchors.left:           updIcon.right
            anchors.leftMargin:     12
            anchors.right:          parent.right
            anchors.rightMargin:    6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: !SysInfo.updatesChecked ? "Checking for updates…"
                    : !SysInfo.updatesOk      ? "Update check failed"
                    : SysInfo.updates + " update" + (SysInfo.updates !== 1 ? "s" : "")
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.bold:      true
                color:          !SysInfo.updatesChecked ? Theme.textSecondary
                              : !SysInfo.updatesOk      ? Theme.danger
                              : SysInfo.updates > 0     ? Theme.accent
                              : Theme.textPrimary
            }
            Text {
                width: parent.width
                text: !SysInfo.updatesChecked
                    ? "querying repos and AUR"
                    : !SysInfo.updatesOk
                        ? (SysInfo.updatesErrors[0] || "unknown error")
                        : SysInfo.updates > 0
                            ? SysInfo.updatesOfficial + " repo · " + SysInfo.updatesAur + " AUR"
                            : "System up to date"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontTiny
                color:          Theme.textMuted
                elide:          Text.ElideRight
            }
        }

        MouseArea {
            id: updHov
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            // A failed check retries rather than launching an upgrade against
            // results we do not trust.
            onClicked: {
                if (!SysInfo.updatesOk) { SysInfo.refreshUpdates(); return }
                if (SysInfo.updates > 0) { SysInfo.runUpdates(); root.hide() }
            }
        }
    }

    // ── Pending packages ───────────────────────────────────────
    Repeater {
        model: SysInfo.updatesOk
            ? SysInfo.repoUpdates.map(u => ({ u: u, aur: false }))
                .concat(SysInfo.aurUpdates.map(u => ({ u: u, aur: true })))
                .slice(0, 12)
            : []

        delegate: Item {
            id: upd

            required property var modelData

            // parent is the panel's content Column; SlidePanel exposes no
            // contentWidth, so asking root for one silently gave 0 width.
            width:  parent ? parent.width : 0
            height: 26

            Text {
                id: updName
                anchors.left:           parent.left
                anchors.leftMargin:     6
                anchors.verticalCenter: parent.verticalCenter
                text:           upd.modelData.u.name
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                color:          Theme.textPrimary
            }

            // AUR packages build arbitrary code from a PKGBUILD, so they are
            // called out rather than blended in with signed repo packages.
            Rectangle {
                visible: upd.modelData.aur
                anchors.left:           updName.right
                anchors.leftMargin:     6
                anchors.verticalCenter: parent.verticalCenter
                width:   aurLabel.implicitWidth + 8
                height:  14
                radius:  3
                color:   Theme.hoverAccent

                Text {
                    id: aurLabel
                    anchors.centerIn: parent
                    text:           "AUR"
                    font.family:    Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                    color:          Theme.accent
                }
            }

            Text {
                anchors.right:          parent.right
                anchors.rightMargin:    6
                anchors.verticalCenter: parent.verticalCenter
                width:          120
                text:           upd.modelData.u.new
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontTiny
                color:          Theme.textMuted
                elide:          Text.ElideLeft
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
