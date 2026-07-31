// modules/notifications/NotificationPopups.qml
// Stack of live notification popups, top-right under the bar.
// The window only exists while something is on screen, so it never eats clicks.

import Quickshell
import Quickshell.Wayland
import QtQuick
import "root:/config"
import "root:/services"

PanelWindow {
    id: popups

    visible: Notifs.popups.length > 0

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "qs-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors.top:   true
    anchors.right: true
    margins.top:   Theme.barHeight + Theme.notifMargin
    margins.right: Theme.notifMargin

    implicitWidth:  Theme.notifWidth
    implicitHeight: Math.max(1, stack.implicitHeight)
    color:          "transparent"

    Column {
        id: stack
        anchors.top:   parent.top
        anchors.right: parent.right
        spacing:       Theme.notifSpacing

        Repeater {
            model: Notifs.popups.slice(0, Theme.notifMaxVisible)

            delegate: NotificationCard {
                required property var modelData
                notif: modelData
            }
        }
    }
}
