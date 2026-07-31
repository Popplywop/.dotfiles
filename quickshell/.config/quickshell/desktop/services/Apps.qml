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

    // Frecency key: apps by id, actions by "id:actionId" so "New Incognito
    // Window" can outrank plain Chromium if that is what you actually use.
    function keyFor(entry, action) {
        return action ? entry.id + ":" + action.id : entry.id
    }

    // Results are wrappers, not raw entries, so an app and its desktop actions
    // ("New Window", "Play-Pause") can sit side by side in one list.
    function _result(entry, action) {
        return {
            entry:    entry,
            action:   action || null,
            key:      root.keyFor(entry, action),
            label:    action ? action.name : entry.name,
            sublabel: action ? entry.name
                             : (entry.comment !== "" ? entry.comment : (entry.genericName || "")),
            icon:     (action && action.icon) ? action.icon : entry.icon,
        }
    }

    function search(query) {
        const q = (query || "").trim().toLowerCase()
        const all = root.entries()

        if (q === "") {
            // No query: apps only, most-used first, then alphabetical
            return all.slice()
                .sort((a, b) => {
                    const d = root.frecencyBoost(b.id) - root.frecencyBoost(a.id)
                    return d !== 0 ? d : a.name.localeCompare(b.name)
                })
                .map(e => root._result(e, null))
        }

        const scored = []

        for (const e of all) {
            const s = root._score(e, q)
            if (s >= 0) scored.push({ res: root._result(e, null), score: s })

            // An action matches on its own name or on "app action" together,
            // so both "incognito" and "chromium incog" find it.
            for (const a of e.actions) {
                const an = a.name.toLowerCase()
                const combined = (e.name + " " + a.name).toLowerCase()

                let as = -1
                if (an === q)                as = 9500
                else if (an.startsWith(q))   as = 8500 - an.length
                else if (an.includes(q))     as = 5500 - an.length
                else if (combined.includes(q)) as = 4500
                else {
                    const f = root._fuzzy(combined, q)
                    if (f > 0) as = f * 0.8      // rank under a direct app hit
                }

                if (as >= 0) scored.push({ res: root._result(e, a), score: as })
            }
        }

        return scored
            .sort((x, y) => (y.score + root.frecencyBoost(y.res.key) * 20)
                          - (x.score + root.frecencyBoost(x.res.key) * 20))
            .map(r => r.res)
    }

    // ── Launching ──────────────────────────────────────────────
    // uwsm app puts each application in its own systemd scope, matching how
    // the rest of this session launches things.
    // Takes a result from search(). uwsm addresses an action as
    // "<id>.desktop:<actionId>".
    function launch(result) {
        if (!result || !result.entry) return

        const key = result.key
        const prev = root.frecency[key] || { count: 0, last: 0 }
        root.frecency[key] = { count: prev.count + 1, last: Date.now() }
        root.frecency = root.frecency        // reassign so bindings re-evaluate
        root._persist()

        const target = result.action
            ? result.entry.id + ".desktop:" + result.action.id
            : result.entry.id + ".desktop"

        Quickshell.execDetached({ command: ["uwsm", "app", "--", target] })
    }
}
