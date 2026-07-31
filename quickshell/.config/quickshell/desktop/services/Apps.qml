// services/Apps.qml
// Application index for the launcher: ranked search plus frecency.
//
// DesktopEntry.id has no ".desktop" suffix (e.g. "chromium"), but uwsm wants
// the full filename, so launch() appends it.

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // { "<id>": { count: int, last: epochMillis } }
    property var frecency: ({})

    // DesktopEntries scans lazily on first access and takes a second or two to
    // finish. Read fresh on every call rather than caching in a bound property.
    function entries() {
        return DesktopEntries.applications.values.filter(e => !e.noDisplay)
    }

    // QML singletons are constructed on first use, so without this nothing
    // touches DesktopEntries until the user opens the launcher — and the first
    // open would show an empty list while the scan runs. shell.qml calls this
    // at startup to kick the scan off early.
    function warm() {
        return DesktopEntries.applications.values.length
    }

    // ── Persistence ────────────────────────────────────────────
    FileView {
        id: store
        path:         Quickshell.statePath("launcher-frecency.json")
        watchChanges: false
        atomicWrites: true
        printErrors:  false          // absent on first run, which is fine

        onLoaded: {
            try {
                root.frecency = JSON.parse(store.text() || "{}")
            } catch (e) {
                root.frecency = ({})
            }
        }
    }

    function _persist() {
        store.setText(JSON.stringify(root.frecency))
    }

    // ── Ranking ────────────────────────────────────────────────
    // Recent launches count for more than old ones, so the list tracks what
    // you actually use now rather than what you used six months ago.
    function frecencyBoost(id) {
        const e = root.frecency[id]
        if (!e) return 0
        const ageDays = (Date.now() - e.last) / 86400000
        const weight = ageDays < 1  ? 4
                     : ageDays < 7  ? 3
                     : ageDays < 30 ? 2
                     : 1
        return e.count * weight
    }

    // Subsequence match: every char of q appears in s in order. Tighter runs
    // and earlier matches score higher.
    function _fuzzy(s, q) {
        let si = 0, score = 0, streak = 0
        for (let qi = 0; qi < q.length; qi++) {
            const found = s.indexOf(q[qi], si)
            if (found === -1) return -1
            streak = (found === si) ? streak + 1 : 0
            score += 10 + streak * 5 - Math.min(found - si, 10)
            si = found + 1
        }
        return Math.max(1, score - s.length / 4)
    }

    function _score(entry, q) {
        const name    = entry.name.toLowerCase()
        const id      = entry.id.toLowerCase()
        const generic = (entry.genericName || "").toLowerCase()
        const comment = (entry.comment || "").toLowerCase()
        const keys    = (entry.keywords || []).join(" ").toLowerCase()

        if (name === q)          return 10000
        if (name.startsWith(q))  return 9000 - name.length
        if (id.startsWith(q))    return 8000 - id.length

        // start of any word in the name
        for (const word of name.split(/[\s\-_]+/))
            if (word.startsWith(q)) return 7000 - name.length

        if (name.includes(q))    return 6000 - name.length
        if (keys.includes(q))    return 4000
        if (generic.includes(q)) return 3000
        if (comment.includes(q)) return 2000

        const f = root._fuzzy(name, q)
        return f > 0 ? f : -1
    }

    function search(query) {
        const q = (query || "").trim().toLowerCase()

        const all = root.entries()

        if (q === "") {
            // No query: most-used first, then alphabetical
            return all.slice().sort((a, b) => {
                const d = root.frecencyBoost(b.id) - root.frecencyBoost(a.id)
                return d !== 0 ? d : a.name.localeCompare(b.name)
            })
        }

        return all
            .map(e => ({ entry: e, score: root._score(e, q) }))
            .filter(r => r.score >= 0)
            .sort((a, b) => (b.score + root.frecencyBoost(b.entry.id) * 20)
                          - (a.score + root.frecencyBoost(a.entry.id) * 20))
            .map(r => r.entry)
    }

    // ── Launching ──────────────────────────────────────────────
    // uwsm app puts each application in its own systemd scope, matching how
    // the rest of this session launches things.
    function launch(entry) {
        if (!entry) return

        const prev = root.frecency[entry.id] || { count: 0, last: 0 }
        root.frecency[entry.id] = { count: prev.count + 1, last: Date.now() }
        root.frecency = root.frecency        // reassign so bindings re-evaluate
        root._persist()

        Quickshell.execDetached({
            command: ["uwsm", "app", "--", entry.id + ".desktop"]
        })
    }

    function launchAction(entry, action) {
        if (!entry || !action) return
        Quickshell.execDetached({
            command: ["uwsm", "app", "--", entry.id + ".desktop:" + action.id]
        })
    }
}
