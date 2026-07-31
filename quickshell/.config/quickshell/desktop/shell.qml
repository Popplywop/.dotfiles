// shell.qml
// Entry point for the whole desktop shell.
//   qs -c desktop
//
// Everything lives in one instance so components share Theme and state.
// External triggers (keybinds, scripts) arrive over IPC:
//   qs -c desktop ipc call wallpicker toggle

import Quickshell
import Quickshell.Io
import "root:/modules/bar"
import "root:/modules/wallpicker"

ShellRoot {
    Bar {}

    WallPicker { id: wallPicker }

    IpcHandler {
        target: "wallpicker"

        function toggle(): void { wallPicker.toggle() }
        function open():   void { wallPicker.show()   }
        function close():  void { wallPicker.cancel() }
    }
}
