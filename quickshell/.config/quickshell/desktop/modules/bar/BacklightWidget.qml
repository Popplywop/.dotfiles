// modules/bar/BacklightWidget.qml
// Brightness. Scroll to adjust.

import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

BarWidget {
    id: root

    visible:     Brightness.available
    icon:        Brightness.icon()
    iconSize:    Theme.fontPill
    anchorRight: true
    popupWidth:  220
    scrollable:  true

    onScrolled: up => Brightness.change(up ? 5 : -5)

    PopupHeader {
        icon:       Brightness.icon()
        iconColor:  Theme.accent
        value:      Brightness.percent + "%"
        valueColor: Theme.accent
        caption:    "Brightness"
    }

    StatBar {
        width:        parent.width
        value:        Brightness.percent
        fillColor:    Theme.accent
        fillDuration: Theme.animNormal
    }

    HintText { text: "Scroll to adjust" }
}
