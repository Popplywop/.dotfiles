// services/Audio.qml
// Default sink/source volume via Pipewire.
//
// Replaces the three `pactl | grep` processes the bar used to spawn every two
// seconds. Pipewire pushes changes, so this is event driven and also sees
// volume changes made by other applications.
//
// PwObjectTracker is required: without binding a node, its `audio` properties
// stay unpopulated.

pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property var sink:   Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool ready: sink !== null && sink.audio !== null

    // 0..100 for the UI; Pipewire works in 0..1
    readonly property int  volume: root.ready ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted:  root.ready ? sink.audio.muted : false

    readonly property string sinkName: sink
        ? (sink.description || sink.nickname || sink.name || "")
        : ""

    readonly property bool micReady: source !== null && source.audio !== null
    readonly property int  micVolume: root.micReady ? Math.round(source.audio.volume * 100) : 0
    readonly property bool micMuted:  root.micReady ? source.audio.muted : false

    // Binds the nodes so their audio properties are live
    PwObjectTracker {
        objects: [root.sink, root.source].filter(n => n !== null)
    }

    function setVolume(pct) {
        if (!root.ready) return
        sink.audio.volume = Math.max(0, Math.min(100, pct)) / 100
    }

    function changeVolume(deltaPct) {
        root.setVolume(root.volume + deltaPct)
    }

    function toggleMute() {
        if (!root.ready) return
        sink.audio.muted = !sink.audio.muted
    }

    function toggleMicMute() {
        if (!root.micReady) return
        source.audio.muted = !source.audio.muted
    }

    function icon() {
        if (root.muted || root.volume === 0) return "󰝟"
        if (root.volume < 33) return "󰕿"
        if (root.volume < 66) return "󰖀"
        return "󰕾"
    }
}
