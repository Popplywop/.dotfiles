// config/Theme.qml
// Single source of truth for colours, metrics, type and motion.
// Palette: gruber-darker.

pragma Singleton

import Quickshell
import QtQuick

Singleton {
    // ── Palette ────────────────────────────────────────────────
    readonly property color bg:      "#181818"
    readonly property color bgAlt:   "#282828"
    readonly property color fg:      "#e4e4ef"
    readonly property color fgBright: "#f4f4ff"
    readonly property color dimAlt:  "#453d41"
    readonly property color red:     "#f43841"
    readonly property color green:   "#73c936"
    readonly property color yellow:  "#ffdd33"
    readonly property color blue:    "#96a6c8"
    readonly property color magenta: "#9e95c7"
    readonly property color dim:     "#54494e"

    // ── Semantic colours ───────────────────────────────────────
    readonly property color barBg:         "#181818"
    readonly property color popupBg:       "#ee181818"
    readonly property color popupBorder:   magenta

    readonly property color textPrimary:   fg
    readonly property color textSecondary: blue
    readonly property color textMuted:     dim
    readonly property color textFaint:     dimAlt
    readonly property color divider:       dim

    readonly property color surface:       bgAlt        // inset panels, thumbnails
    readonly property color surfaceBorder: dimAlt

    readonly property color accent:        yellow
    readonly property color danger:        red
    readonly property color ok:            green
    readonly property color warn:          yellow

    // Translucent overlays (hover states, progress-bar tracks)
    readonly property color hoverBg:        "#22ffffff"
    readonly property color hoverBgStrong:  "#33ffffff"
    readonly property color trackBg:        "#33ffffff"
    readonly property color hoverDanger:    "#22f43841"
    readonly property color hoverAccent:    "#22ffdd33"
    readonly property color hoverMagenta:   "#339e95c7"
    readonly property color hoverFg:        "#33e4e4ef"

    // ── Metrics ────────────────────────────────────────────────
    readonly property int barHeight:    36
    readonly property int pillHeight:   28
    readonly property int pillRadius:   5
    readonly property int pillPadding:  14   // total horizontal padding
    readonly property int barMargin:    6
    readonly property int barSpacing:   2

    readonly property int popupRadius:      12
    readonly property int popupBorderWidth: 2
    readonly property int popupPadding:     12
    readonly property int popupSpacing:     6

    readonly property int barThin:  6   // progress bar height, small
    readonly property int barThick: 8   // progress bar height, large

    // Launcher
    readonly property int launcherWidth:     640
    readonly property int launcherMaxHeight: 420
    readonly property int launcherRowHeight: 52
    readonly property int launcherIconSize:  32

    // Notifications
    readonly property int notifWidth:      380
    readonly property int notifSpacing:    8
    readonly property int notifMargin:     10
    readonly property int notifPadding:    12
    readonly property int notifIconSize:   40
    readonly property int notifMaxVisible: 5

    // ── Type ───────────────────────────────────────────────────
    readonly property string fontFamily: "monospace"

    readonly property int fontTiny:   10   // hints, footnotes
    readonly property int fontSmall:  11   // labels, captions
    readonly property int fontBody:   12   // popup values
    readonly property int fontHeader: 13   // popup headers
    readonly property int fontPill:   14   // bar pill text
    readonly property int fontIcon:   16   // bar pill icon
    readonly property int fontBig:    18   // popup headline value
    readonly property int fontHuge:   20   // popup headline icon

    // ── Motion ─────────────────────────────────────────────────
    readonly property int animFast:   80    // hover fades
    readonly property int animNormal: 150   // colour/width transitions
    readonly property int animSlow:   400   // gauge fills
    readonly property int hideDelay:  300   // popup dismiss grace period
}
