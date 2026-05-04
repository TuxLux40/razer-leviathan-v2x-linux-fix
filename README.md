# Razer Leviathan V2 X – Linux Volume Fix

A fix for the Razer Leviathan V2 X soundbar being **extremely quiet on Linux**, even when the system volume is set to 100%.

---

## The short version

Run this in a terminal:

```bash
bash install.sh
```

That's it. You will be asked for your password once. The fix is permanent.

---

## Table of contents

1. [Does this affect me?](#1-does-this-affect-me)
2. [Why is it quiet? A plain-English explanation](#2-why-is-it-quiet-a-plain-english-explanation)
3. [What this fix actually does](#3-what-this-fix-actually-does)
4. [Installation](#4-installation)
5. [Adjusting the volume level](#5-adjusting-the-volume-level)
6. [Uninstalling](#6-uninstalling)
7. [Frequently asked questions](#7-frequently-asked-questions)

---

## 1. Does this affect me?

You are in the right place if **all** of the following are true:

- You own a **Razer Leviathan V2 X** soundbar
- You are using **Linux** (any distribution: Ubuntu, Fedora, Arch, SteamOS, etc.)
- The soundbar is connected via **USB-C**
- The volume sounds **much quieter than expected**, even at 100% system volume
- On Windows with Razer Synapse installed, the same device sounds significantly louder

---

## 2. Why is it quiet? A plain-English explanation

Think of the soundbar like an amplifier with **two volume knobs in series** — both knobs have to be turned up for sound to come out at full power.

```
Your music → [Knob 1: your volume slider] → [Knob 2: hidden inside the device] → speakers
```

- **Knob 1** is the volume slider you see on your screen. Linux controls this one just fine.
- **Knob 2** is a second, internal volume level built into the device itself. Linux does not touch it.

The problem is that **Knob 2 ships from the factory at about 29%**. On Windows, Razer's official software (Razer Synapse) silently turns Knob 2 up when it starts — but Razer Synapse does not exist for Linux. So Knob 2 stays at 29% forever, no matter how high you push Knob 1.

This fix turns Knob 2 up to a comfortable level (~66%) and makes sure it stays there.

---

## 3. What this fix actually does

The fix makes **one change** to your system:

It raises the soundbar's hidden internal volume from ~29% to ~66%, then saves that setting so Linux restores it automatically every time you plug the soundbar in or restart your computer.

Nothing else is changed. No drivers are installed. No background services are added. No new files are placed in system folders — the setting is saved into a file that already exists on your system specifically for storing audio device settings.

---

## 4. Installation

### Step 1 – Download this project

If you have `git` installed, open a terminal and run:

```bash
git clone https://github.com/YOUR_USERNAME/razer-leviathan-v2x-linux-fix
cd razer-leviathan-v2x-linux-fix
```

Or download the ZIP from GitHub and extract it somewhere, then open a terminal in that folder.

### Step 2 – Plug in your soundbar

Make sure the Razer Leviathan V2 X is connected via USB-C before continuing.

### Step 3 – Run the installer

```bash
bash install.sh
```

You will see output like this:

```
Razer Leviathan V2 X – Linux Volume Fix
────────────────────────────────────────

→ Looking for your Razer Leviathan V2 X...
✓ Found Razer Leviathan V2 X

→ Checking current internal volume setting...
✓ Current internal volume: about 29%

→ Applying fix (raising internal volume from ~29% to ~66%)...
✓ Done.

→ Saving the setting so it survives reboots and unplugging...

  You will be asked for your password — this is required to save the
  setting to a system file. Nothing else will be changed.

[sudo] password for oliver:
✓ Setting saved permanently.

All done!
```

### What the password prompt is for

Saving the setting requires writing to a system file, which needs administrator permission — the same kind of permission you give when installing software. The installer only uses this to save the audio setting. Nothing else.

---

## 5. Adjusting the volume level

The installer raises the hidden internal volume to **~66%**, which is a safe starting point. If that doesn't feel right, you can adjust it:

### If it's crackling or too loud

```bash
bash tune.sh lower
```

Run this multiple times until it sounds clean.

### If it's still too quiet

```bash
tune.sh louder
```

Run this until you're happy with the loudness at full system volume.

### Setting an exact level

```bash
bash tune.sh set 80
```

Replace `80` with any number from 0 (silent) to 100 (maximum).

### Checking the current level

```bash
bash tune.sh show
```

### What level should I use?

| Level | Character |
|-------|-----------|
| 29%   | Factory default — too quiet |
| 50%   | Conservative — quiet but clean |
| **66%**   | **Recommended (what the installer sets)** |
| 80%   | Loud — good for open rooms |
| 100%  | Maximum — may distort on loud audio |

Start at the default and adjust from there with `tune.sh louder` / `tune.sh lower`.

---

## 6. Uninstalling

To completely undo the fix and go back to the original quiet state:

```bash
bash uninstall.sh
```

---

## 7. Frequently asked questions

### Does this work with Bluetooth?

The fix only applies to the USB-C connection. Bluetooth audio is a completely separate path and is not affected — and doesn't need this fix.

### Will this break anything?

No. The only thing changed is one audio setting stored in a file your system already manages. You can undo it at any time with `uninstall.sh`.

### Do I need to reinstall this after a system update?

No. System updates do not touch audio device settings.

### The physical volume buttons control the system volume slider — is that normal?

Yes, and it's correct. The physical buttons send standard volume signals over USB, which Linux passes to your desktop environment just like a keyboard media key would. They control the same slider you see on screen.

### Why doesn't openrazer fix this?

[openrazer](https://github.com/openrazer/openrazer) is focused on RGB lighting and gaming features (keyboard LEDs, mouse DPI, etc.). Audio volume is outside its scope.

### I have a different Razer soundbar — does this work for me?

Probably not without testing. This fix is written specifically for the Razer Leviathan V2 X. Other models have different internals.

### Why doesn't Razer fix this themselves?

Razer only officially supports Windows. Their software (Razer Synapse) sets the internal volume automatically on Windows, but it doesn't exist for Linux. This fix does that one thing.

### How do I know the fix is still applied after a reboot?

Run `bash tune.sh show`. If it shows anything other than ~29%, the fix is active.

---

## Technical reference

<details>
<summary>Click to expand — for those who want the full picture</summary>

**Device**: Razer Leviathan V2 X · USB ID `1532:054a`

**USB interfaces**:
- Interface 0: HID — handles physical button presses (volume keys → consumer control events → desktop)
- Interface 1: USB AudioControl — audio mixer/volume controls, managed by `snd-usb-audio`
- Interface 2: USB AudioStreaming — the actual audio stream, 16-bit PCM, 48 kHz stereo

**Root cause**: The USB AudioControl Feature Unit (bUnitID 9) has two volume controls:
- Per-channel L/R volume (`numid=3`) — surfaced by PipeWire as the user-visible slider
- Master sub-level (`numid=4`) — invisible to any GUI, initialises at ~29% of its range

**The fix**: `amixer -c <card> cset numid=4 100`, persisted via `sudo alsactl store <card>`.

The ALSA state file (`/var/lib/alsa/asound.state`) is restored on hotplug automatically by `/usr/lib/udev/rules.d/90-alsa-restore.rules` (part of `alsa-utils`, present on all major distributions).

**HID report descriptor** (from `usbhid-dump`):
```
05 0C 09 01 A1 01        -- Usage Page: Consumer, Usage: Consumer Control
85 01                    -- Report ID 1 (physical buttons)
09 E9 09 EA 09 E2 ...    -- Volume Inc, Volume Dec, Mute, Play/Pause, Next, Prev, FF, RW
85 03 ...                -- Report ID 3: 92-byte vendor output (RGB/config commands)
85 05 ...                -- Report ID 5: 16-byte vendor input (responses)
85 07 ...                -- Report ID 7: 91-byte vendor feature (RGB state)
```

RGB control requires 91-byte reports with Report ID 7 — see [openrazer PR #2644](https://github.com/openrazer/openrazer/pull/2644).

</details>
