// components/PopupHeader.qml
// Popup headline: big icon, headline value, caption underneath.

import QtQuick
import "root:/config"

Row {
    id: root

    property string icon:        ""
    property color  iconColor:   Theme.textPrimary
    property int    iconSize:    Theme.fontHuge

    property string value:       ""
    property color  valueColor:  Theme.textPrimary
    property int    valueSize:   Theme.fontBig

    property string caption:     ""
    property color  captionColor: Theme.textSecondary

    spacing: 8

    Text {
        text:           root.icon
        font.family:    Theme.fontFamily
        font.pixelSize: root.iconSize
        color:          root.iconColor
    }

    Column {
        spacing: 2

        Text {
            text:           root.value
            font.family:    Theme.fontFamily
            font.pixelSize: root.valueSize
            font.bold:      true
            color:          root.valueColor
        }
        Text {
            visible:        root.caption.length > 0
            text:           root.caption
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontSmall
            color:          root.captionColor
        }
    }
}
