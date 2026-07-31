// components/Divider.qml
// Hairline rule inside a PopupCard. Defaults to the card's content width.

import QtQuick
import "root:/config"

Rectangle {
    width:  parent ? parent.width : 0
    height: 1
    color:  Theme.divider
}
