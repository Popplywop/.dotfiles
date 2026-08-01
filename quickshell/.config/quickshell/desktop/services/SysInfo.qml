// services/SysInfo.qml
// CPU, memory, disk and network for the dashboard.
//
// One long-lived python process streams a JSON line every few seconds,
// replacing the four separate poll-and-spawn widgets the bar used to carry
// (cpu 5s, mem 10s, disk 60s, network 10s). Keeping the process alive also
// means CPU and network deltas come from real consecutive samples rather than
// a fresh 2-second sleep on every tick.

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int    cpu:       0
    property int    mem:       0
    property real   memUsed:   0
    property real   memTotal:  0
    property int    disk:      0
    property string diskUsed:  "—"
    property string diskTotal: "—"
    property real   netRx:     0    // KiB/s
    property real   netTx:     0

    // Updates. `ok` distinguishes "nothing pending" from "the check failed",
    // which the old count-only version could not: any failure came back as 0
    // and rendered as "System up to date".
    property var  repoUpdates:  []
    property var  aurUpdates:   []
    property bool updatesOk:    true
    property var  updatesErrors: []

    // The AUR query can take a minute. Until the first result lands the counts
    // are just initial values, and rendering them as "up to date" would be the
    // same false reassurance the old silent-zero produced.
    property bool updatesChecked: false
    readonly property bool updatesBusy: updProc.running

    readonly property int updates:         repoUpdates.length + aurUpdates.length
    readonly property int updatesOfficial: repoUpdates.length
    readonly property int updatesAur:      aurUpdates.length

    // History for the sparklines
    signal sampled(int cpu, int mem, real rx, real tx)

    Process {
        id: stats
        running: true
        command: ["python3", "-u", "-c", `
import json, time, os

def cpu_times():
    with open("/proc/stat") as f:
        v = [int(x) for x in f.readline().split()[1:]]
    return sum(v), v[3]

def netbytes():
    rx = tx = 0
    with open("/proc/net/dev") as f:
        for line in f.readlines()[2:]:
            name, rest = line.split(":", 1)
            if name.strip() in ("lo",):
                continue
            p = rest.split()
            rx += int(p[0]); tx += int(p[8])
    return rx, tx

def meminfo():
    d = {}
    with open("/proc/meminfo") as f:
        for line in f:
            k, v = line.split(":", 1)
            d[k] = int(v.split()[0])
    total = d["MemTotal"]; avail = d["MemAvailable"]
    used = total - avail
    return round(used * 100 / total), used / 1048576.0, total / 1048576.0

def disk():
    s = os.statvfs("/")
    total = s.f_blocks * s.f_frsize
    free  = s.f_bavail * s.f_frsize
    used  = total - free
    def h(n):
        for u in ("B","K","M","G","T"):
            if n < 1024: return f"{n:.0f}{u}"
            n /= 1024
        return f"{n:.0f}P"
    return round(used * 100 / total), h(used), h(total)

INTERVAL = 3.0
pt, pi = cpu_times()
prx, ptx = netbytes()

while True:
    time.sleep(INTERVAL)
    t, i = cpu_times()
    dt, di = t - pt, i - pi
    pt, pi = t, i
    c = round((dt - di) * 100 / dt) if dt else 0

    rx, tx = netbytes()
    drx = (rx - prx) / 1024.0 / INTERVAL
    dtx = (tx - ptx) / 1024.0 / INTERVAL
    prx, ptx = rx, tx

    m, mu, mt = meminfo()
    dp, du, dt_ = disk()
    print(json.dumps({"cpu": c, "mem": m, "memUsed": round(mu, 1),
                      "memTotal": round(mt, 1), "disk": dp, "diskUsed": du,
                      "diskTotal": dt_, "rx": round(drx, 1), "tx": round(dtx, 1)}))
`]
        stdout: SplitParser {
            onRead: line => {
                try {
                    const d = JSON.parse(line.trim())
                    root.cpu       = d.cpu
                    root.mem       = d.mem
                    root.memUsed   = d.memUsed
                    root.memTotal  = d.memTotal
                    root.disk      = d.disk
                    root.diskUsed  = d.diskUsed
                    root.diskTotal = d.diskTotal
                    root.netRx     = d.rx
                    root.netTx     = d.tx
                    root.sampled(d.cpu, d.mem, d.rx, d.tx)
                } catch (e) {}
            }
        }
    }

    // ── Updates ────────────────────────────────────────────────
    // Every run makes checkupdates sync a temporary package database over the
    // network, so this is deliberately infrequent. refreshUpdates() covers the
    // "I want to know now" case.
    Timer {
        interval: 1800000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: root.refreshUpdates()
    }

    function refreshUpdates() {
        if (!updProc.running) updProc.running = true
    }

    Process {
        id: updProc
        command: [Quickshell.shellPath("scripts/check-updates")]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => {
                try {
                    const d = JSON.parse(line.trim())
                    root.repoUpdates   = d.repo   || []
                    root.aurUpdates    = d.aur    || []
                    root.updatesErrors = d.errors || []
                    root.updatesOk     = d.ok
                    root.updatesChecked = true
                } catch (e) {}
            }
        }
    }

    function runUpdates() {
        Quickshell.execDetached({
            command: ["uwsm", "app", "--", "wezterm", "start",
                      "--class", "wezterm-updates", "--", "yay", "-Syu"]
        })
    }

    function fmtRate(kib) {
        if (kib >= 1024) return (kib / 1024).toFixed(1) + " MB/s"
        return kib.toFixed(0) + " KB/s"
    }
}
