// modules/bar/ClockWidget.qml
// Live clock. Hover → date + world times.

import Quickshell.Io
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    property string barText:  Qt.formatTime(new Date(), "hh:mm")
    property string dateText: Qt.formatDate(new Date(), "dddd dd MMMM yyyy")
    property var    tzTimes:  ({})

    readonly property var cities: [
        { flag: "🇺🇸", city: "Victoria TX",  tz: "America/Chicago"     },
        { flag: "🇺🇸", city: "New York",     tz: "America/New_York"    },
        { flag: "🇺🇸", city: "Los Angeles",  tz: "America/Los_Angeles" },
        { flag: "🇬🇧", city: "London",       tz: "Europe/London"       },
        { flag: "🇯🇵", city: "Tokyo",        tz: "Asia/Tokyo"          },
        { flag: "🇦🇺", city: "Sydney",       tz: "Australia/Sydney"    },
    ]

    label:       root.barText
    anchorLeft:  true
    anchorRight: false
    popupMargin: 50
    popupWidth:  260

    Timer {
        interval: 15000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            root.barText  = Qt.formatTime(now, "hh:mm")
            root.dateText = Qt.formatDate(now, "dddd dd MMMM yyyy")
        }
    }

    // Only polls while the popup is open
    Timer {
        interval: 60000; repeat: true; running: root.popupOpen; triggeredOnStart: true
        onTriggered: if (!tzProc.running) tzProc.running = true
    }

    Process {
        id: tzProc
        command: ["python3", "-c",
            "import json\nfrom datetime import datetime\nfrom zoneinfo import ZoneInfo\n" +
            "tzs=['America/Chicago','America/New_York','America/Los_Angeles','Europe/London','Asia/Tokyo','Australia/Sydney']\n" +
            "print(json.dumps({tz:datetime.now(ZoneInfo(tz)).strftime('%H:%M') for tz in tzs}))"
        ]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => {
                try { root.tzTimes = JSON.parse(line.trim()) } catch (e) {}
            }
        }
    }

    Text {
        text:           "  " + root.dateText
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontHeader
        font.bold:      true
        color:          Theme.accent
    }

    Divider {}

    Repeater {
        model: root.cities

        delegate: Row {
            spacing: 6

            Text {
                text:           modelData.flag + "  " + modelData.city.padEnd(16)
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontBody
                color:          Theme.textSecondary
            }
            Text {
                text:           root.tzTimes[modelData.tz] ?? "--:--"
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.bold:      true
                color:          Theme.textPrimary
            }
        }
    }
}
