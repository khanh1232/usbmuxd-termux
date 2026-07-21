# usbmuxd-termux

A lightweight interactive Bash script to run `usbmuxd` and pair iOS devices inside Termux without root access. Designed primarily for Android phones & tablets, with support for Android TV devices.

---

## Prerequisites

1. Install **[Termux](https://github.com/termux/termux-app/releases)**.
2. Install **[Termux:API APK](https://github.com/termux/termux-api/releases)** (Required for USB access).
3. Connect via OTG to the iPhone to run the script.

> **Note for Android TV users:** > System USB permission popups will not show on TV screens unless overlay permission is granted.  
> Go to **Settings** -> **Apps** -> **Termux:API** -> enable **Display over other apps**.

---

## Quick Start

Open Termux and run:

`pkg update && pkg install git -y
`
`git clone https://github.com/khanh12322/usbmuxd-termux.git`

`chmod +x main.sh`

`./main.sh`

---

## Workflow

1. Option 1 (Setup): Installs required packages (⁠libusb⁠, ⁠libimobiledevice⁠, ⁠termux-api⁠, usbmuxd,).
2. Option 2 (USB Selection & Permission): Scans ⁠/dev/bus/usb/⁠ paths and requests Android USB permission.
3. Option 3 (Start usbmuxd): Spawns ⁠usbmuxd⁠ in background mode attached to the selected USB port.
4. Option 4 (Test Pairing): Performs 2-step pairing test. Unlock your iPhone, tap Trust, and enter your screen passcode when prompted
.

---

## Troubleshooting

1. ⁠No such device⁠ error: Re-plug the cable and re-select the port in Option 2 to clean the path variable.
2. No permission popup on Android : Ensure Display over other apps is enabled for ⁠Termux:API⁠ in TV settings.
3. Pairing untrusted: Make sure the iPhone screen is unlocked and passcode was entered promptly after tapping "Trust".
4. ⁠usbmuxd⁠ port busy: Option 3 automatically kills existing ⁠usbmuxd⁠ instances before launching a new one.

---

### License

This project is licensed under the MIT License - see the LICENSE file for details.


