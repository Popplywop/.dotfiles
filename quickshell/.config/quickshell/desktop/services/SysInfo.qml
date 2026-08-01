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

    property int    updates:   0
    property int    updatesOfficial: 0
    property int    updatesAur:      0

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
    Timer {
        interval: 300000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: if (!updProc.running) updProc.running = true
    }

    Process {
        id: updProc
        command: ["bash", "-c",
            "O=$(checkupdates 2>/dev/null | wc -l); " +
            "A=$(yay -Qteu 2>/dev/null | wc -l); " +
            "echo \"$((O+A)) $O $A\""]
        running: false
        onExited: running = false
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim().split(" ")
                if (p.length >= 3) {
                    root.updates         = parseInt(p[0]) || 0
                    root.updatesOfficial = parseInt(p[1]) || 0
                    root.updatesAur      = parseInt(p[2]) || 0
                }
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
