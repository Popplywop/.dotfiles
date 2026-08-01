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
    readonly property color popupBg:       "#ee181818"
    // Panels are large and text-dense; popupBg's 93% lets window content bleed
    // through enough to hurt legibility at that size.
    readonly property color panelBg:       "#fa181818"
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
    readonly property int popupRadius:      12
    readonly property int popupBorderWidth: 2
    readonly property int popupPadding:     12
    readonly property int popupSpacing:     6

    readonly property int barThin:  6   // progress bar height, small
    readonly property int barThick: 8   // progress bar height, large

    // Island — floating status pill, top centre
    readonly property int islandHeight:    30
    readonly property int islandRadius:    15
    readonly property int islandTopMargin: 8
    readonly property int islandPaddingH:  14
    readonly property int islandSpacing:   12

    // Dock — floating, auto-hiding, bottom centre
    readonly property int dockIconSize:     44
    readonly property int dockRadius:       18
    readonly property int dockBottomMargin: 10
    readonly property int dockPadding:      8
    readonly property int dockSpacing:      6
    readonly property int dockRevealHeight: 3     // hover strip at the screen edge
    // Fixed, not derived from the dock's width: the dock window is unmapped
    // while hidden, so its card reports a stale near-zero width at startup.
    readonly property int dockRevealWidth:  560
    readonly property int dockHideDelay:    450
    readonly property int dockSlide:        220   // show/hide animation

    // Slide-out panels
    readonly property int panelWidth:   340
    readonly property int panelMargin:   10
    readonly property int panelRadius:   16
    readonly property int panelSlide:   200
    readonly property int hotCornerSize: 16

    // OSD
    readonly property int osdWidth:      280
    readonly property int osdHeight:     96
    readonly property int osdBottomGap:  120
    readonly property int osdTimeout:    1600

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
