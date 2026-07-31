// components/BarWidget.qml
// Base for every hover-popup bar item: a pill in the bar, plus a PopupCard
// that opens on hover and closes after a short grace period.
//
// Usage:
//   BarWidget {
//       icon: "󰕾"; iconColor: Theme.danger
//       popupWidth: 250; anchorRight: true
//       Text { ... }          // anything here lands in the popup
//   }

import QtQuick
import QtQuick.Layouts
import "root:/config"

Item {
    id: root

    implicitWidth:  pill.implicitWidth
    implicitHeight: Theme.barHeight
    Layout.alignment: Qt.AlignVCenter

    // ── Pill content ───────────────────────────────────────────
    property string icon:       ""
    property color  iconColor:  Theme.textPrimary
    property int    iconSize:   Theme.fontIcon

    property string label:      ""
    property color  labelColor: Theme.textPrimary
    property int    labelSize:  Theme.fontPill
    property bool   labelBold:  true

    // ── Pill appearance / interaction ──────────────────────────
    property color hoverBg:     Theme.hoverBg
    property bool  active:      false   // render as hovered regardless of pointer
    property real  pillOpacity: 1.0     // battery uses this to blink
    property bool  clickable:   false
    property bool  scrollable:  false

    // ── Popup ──────────────────────────────────────────────────
    property bool  anchorLeft:  false
    property bool  anchorRight: true
    property real  popupMargin: 8
    property real  popupWidth:  240
    property bool  popupOpen:   false

    // Gauges open on hover; click-driven panels (notification centre) set this
    // false so they only open on click and stay put.
    property bool  openOnHover: true

    // Usable width inside the popup — children size themselves off this
    readonly property real contentWidth: root.popupWidth - Theme.popupPadding * 2

    default property alias popupContent: card.content

    signal clicked()
    signal scrolled(bool up)

    // Keep the popup up (e.g. pointer moved from pill onto the card)
    function holdOpen() { root.popupOpen = true; hideTimer.stop() }
    function releaseOpen() { hideTimer.restart() }

    // Hover entry/exit. With openOnHover false, hovering never opens the popup
    // and never closes one that a click opened.
    function _hoverEnter() { if (root.openOnHover) root.holdOpen(); else hideTimer.stop() }
    function _hoverExit()  { if (root.openOnHover) root.releaseOpen() }

    Timer {
        id: hideTimer
        interval: Theme.hideDelay
        onTriggered: root.popupOpen = false
    }

    // ── Pill ───────────────────────────────────────────────────
    Rectangle {
        id: pill
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth:  pillRow.implicitWidth + Theme.pillPadding
        height:         Theme.pillHeight
        radius:         Theme.pillRadius
        opacity:        root.pillOpacity
        color:          (pillHov.containsMouse || root.active) ? root.hoverBg : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 5

            Text {
                visible:        root.icon.length > 0
                text:           root.icon
                font.family:    Theme.fontFamily
                font.pixelSize: root.iconSize
                color:          root.iconColor
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible:        root.label.length > 0
                text:           root.label
                font.family:    Theme.fontFamily
                font.pixelSize: root.labelSize
                font.bold:      root.labelBold
                color:          root.labelColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: pillHov
            anchors.fill:    parent
            hoverEnabled:    true
            acceptedButtons: Qt.LeftButton
            cursorShape:     root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onEntered:       root._hoverEnter()
            onExited:        root._hoverExit()
            onClicked:       root.clicked()
        }

        WheelHandler {
            enabled:         root.scrollable
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => root.scrolled(event.angleDelta.y > 0)
        }
    }

    // ── Popup ──────────────────────────────────────────────────
    PopupCard {
        id: card
        visible:      root.popupOpen
        anchorLeft:   root.anchorLeft
        anchorRight:  root.anchorRight
        marginLeft:   root.anchorLeft  ? root.popupMargin : 0
        marginRight:  root.anchorRight ? root.popupMargin : 0
        popupWidth:   root.popupWidth

        onPopupEntered: root._hoverEnter()
        onPopupExited:  root._hoverExit()
    }
}
