// components/HintText.qml
// Small muted footnote inside a PopupCard.

import QtQuick
import "root:/config"

Text {
    font.family:    Theme.fontFamily
    font.pixelSize: Theme.fontTiny
    color:          Theme.textMuted
}
