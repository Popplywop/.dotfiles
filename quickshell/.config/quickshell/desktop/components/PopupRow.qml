// components/PopupRow.qml
// One label + value line inside a PopupCard.

import QtQuick
import "root:/config"

Row {
    property alias label: lbl.text
    property alias value: val.text

    spacing: 8

    Text {
        id:             lbl
        width:          100
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        color:          Theme.textSecondary
        wrapMode:       Text.NoWrap
    }
    Text {
        id:             val
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontBody
        font.bold:      true
        color:          Theme.textPrimary
    }
}
