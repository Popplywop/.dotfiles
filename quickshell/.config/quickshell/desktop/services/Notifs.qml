// services/Notifs.qml
// Notification daemon. Owns org.freedesktop.Notifications and exposes:
//   popups  — live notifications currently on screen (real Notification objects)
//   history — plain snapshots, newest first, kept after the popup goes away
//
// History holds snapshots rather than Notification objects on purpose: once a
// notification is untracked the object is destroyed, so anything we kept would
// dangle.

pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    property var  popups:  []
    property var  history: []
    property int  maxHistory: 100
    property bool doNotDisturb: false

    readonly property int unreadCount: history.filter(n => !n.read).length

    // Notification spec: expireTimeout -1 means "server decides"
    function timeoutFor(notif) {
        if (notif.urgency === NotificationUrgency.Critical) return 0   // sticky
        if (notif.expireTimeout > 0) return notif.expireTimeout
        return notif.urgency === NotificationUrgency.Low ? 4000 : 7000
    }

    function dismiss(notif) {
        notif.dismiss()
    }

    function dismissAll() {
        // dismiss() mutates root.popups via onClosed, so iterate a copy
        for (const n of root.popups.slice()) n.dismiss()
    }

    function markAllRead() {
        root.history = root.history.map(e => { e.read = true; return e })
    }

    function clearHistory() {
        root.history = []
    }

    function _snapshot(notif) {
        return {
            id:       notif.id,
            summary:  notif.summary,
            body:     notif.body,
            appName:  notif.appName,
            appIcon:  notif.appIcon,
            image:    notif.image,
            urgency:  notif.urgency,
            time:     new Date(),
            read:     false,
        }
    }

    NotificationServer {
        id: server

        // Survive a config reload without dropping live notifications
        keepOnReload: true

        bodySupported:          true
        bodyMarkupSupported:    true
        bodyImagesSupported:    true
        imageSupported:         true
        actionsSupported:       true
        actionIconsSupported:   true
        persistenceSupported:   true
        inlineReplySupported:   false   // TODO: wire up sendInlineReply()

        onNotification: notif => {
            // Without this the notification is dropped immediately
            notif.tracked = true

            root.history = [root._snapshot(notif), ...root.history].slice(0, root.maxHistory)

            // transient notifications skip the popup stack but stay in history
            if (!root.doNotDisturb && !notif.transient)
                root.popups = [notif, ...root.popups]

            notif.closed.connect(() => {
                root.popups = root.popups.filter(n => n !== notif)
            })
        }
    }
}
