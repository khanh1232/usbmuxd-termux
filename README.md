# usbmuxd-termux

A lightweight interactive Bash script to run `usbmuxd` and pair iOS devices inside Termux without root access. Designed primarily for Android phones & tablets, with support for Android TV devices.

---

## Features

* **No Root Required:** Uses `termux-api` (`termux-usb`) to handle USB communication.
* **Status Monitoring:** Real-time display of connected iOS device state (`DISCONNECTED`, `UNTRUSTED`, or `TRUSTED`).
* **Auto USB Filtering:** Scans `/dev/bus/usb/` paths and filters out JSON formatting clutter.
* **Guided Pairing:** Handles 2-step `idevicepair` sequence smoothly.

---

## Prerequisites

1. Install **[Termux](https://github.com/termux/termux-app/releases)**.
2. Install **[Termux:API APK](https://github.com/termux/termux-api/releases)** (Required for USB access).

> **Note for Android TV users:**  
> On TV screens, system USB permission popups won't show up unless overlay permission is enabled. Go to **Settings** -> **Apps** -> **Termux:API** -> enable **Display over other apps**.

---

## Quick Start

Open Termux and run:

```bash
pkg update && pkg install git -y
git clone [https://github.com/](https://github.com/khanh12322/usbmuxd-termux.git
cd usbmuxd-termux
chmod +x main.sh
./main.sh
