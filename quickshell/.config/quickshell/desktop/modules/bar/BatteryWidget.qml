// modules/bar/BatteryWidget.qml
// Battery via UPower. Icon reflects state; blinks when critical.

import Quickshell.Services.UPower
import QtQuick
import "root:/config"
import "root:/components"

BarWidget {
    id: root

    readonly property var  dev:   UPower.displayDevice
    readonly property real pct:   dev ? dev.percentage : 0
    readonly property int  state: dev ? dev.state      : 0

    readonly property bool warn: pct < 20 && state === UPowerDeviceState.Discharging
    readonly property bool crit: pct < 10 && state === UPowerDeviceState.Discharging

    readonly property color battColor: crit ? Theme.danger
                                     : warn ? Theme.warn
                                     : state === UPowerDeviceState.Charging ? Theme.ok
                                     : Theme.textPrimary

    function battIcon(pct, state) {
        if (state === UPowerDeviceState.Charging || state === UPowerDeviceState.PendingCharge) {
            if (pct >= 90) return "󰂅"
            if (pct >= 80) return "󰂋"
            if (pct >= 70) return "󰂊"
            if (pct >= 60) return "󰢞"
            if (pct >= 50) return "󰂉"
            if (pct >= 40) return "󰢝"
            if (pct >= 30) return "󰂈"
            if (pct >= 20) return "󰂇"
            if (pct >= 10) return "󰂆"
            return "󰢜"
        }
        if (state === UPowerDeviceState.FullyCharged) return "󰁹"
        if (pct >= 90) return "󰁹"
        if (pct >= 80) return "󰂂"
        if (pct >= 70) return "󰂁"
        if (pct >= 60) return "󰂀"
        if (pct >= 50) return "󰁿"
        if (pct >= 40) return "󰁾"
        if (pct >= 30) return "󰁽"
        if (pct >= 20) return "󰁼"
        if (pct >= 10) return "󰁺"
        return "󰂎"
    }

    function fmtTime(secs) {
        if (!secs || secs <= 0) return "—"
        var h = Math.floor(secs / 3600)
        var m = Math.floor((secs % 3600) / 60)
        return h > 0 ? h + "h " + m + "m" : m + "m"
    }

    function stateLabel() {
        if (root.state === UPowerDeviceState.Charging)      return "⚡ Charging"
        if (root.state === UPowerDeviceState.Discharging)   return "🔋 Discharging"
        if (root.state === UPowerDeviceState.FullyCharged)  return "✓ Full"
        if (root.state === UPowerDeviceState.PendingCharge) return "⏳ Pending"
        return "Unknown"
    }

    icon:        root.battIcon(root.pct, root.state)
    iconColor:   root.battColor
    anchorRight: true
    popupWidth:  250
    pillOpacity: root.crit ? blink.value : 1.0

    QtObject { id: blink; property real value: 1.0 }

    SequentialAnimation {
        running: root.crit
        loops:   Animation.Infinite
        NumberAnimation { target: blink; property: "value"; to: 0.2; duration: 500 }
        NumberAnimation { target: blink; property: "value"; to: 1.0; duration: 500 }
    }

    PopupHeader {
        icon:       root.battIcon(root.pct, root.state)
        iconColor:  root.battColor
        iconSize:   22
        value:      Math.round(root.pct) + "%"
        valueColor: root.battColor
        caption:    root.stateLabel()
    }

    StatBar {
        width:     parent.width
        value:     root.pct
        fillColor: root.battColor
    }

    Divider {}

    PopupRow {
        label: "Time remaining"
        value: root.state === UPowerDeviceState.Charging
             ? root.fmtTime(root.dev ? root.dev.timeToFull  : 0)
             : root.fmtTime(root.dev ? root.dev.timeToEmpty : 0)
    }
    PopupRow {
        label: "Power draw"
        value: root.dev ? root.dev.changeRate.toFixed(1) + " W" : "—"
    }
    PopupRow {
        label: "Battery health"
        value: root.dev && root.dev.healthSupported
             ? Math.round(root.dev.healthPercentage) + "%"
             : "—"
    }
    PopupRow {
        label: "Energy"
        value: root.dev
             ? root.dev.energy.toFixed(1) + " / " + root.dev.energyCapacity.toFixed(1) + " Wh"
             : "—"
    }
}
