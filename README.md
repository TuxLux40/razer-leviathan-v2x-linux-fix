# Razer Leviathan V2 X – Linux "driver" fix

Makes the soundbar work out of the box like on Windows: correct hardware
volume on every plug-in/boot, software volume control via PipeWire.

    ./install.sh            # install (udev rule + WirePlumber rule)
    ./install.sh uninstall

Needs `alsa-utils` (amixer) and PipeWire/WirePlumber 0.5+.

## Why
The firmware attenuates far more than its USB descriptor claims and boots at
~16% hardware volume, so hw-volume-driven mixers produce near silence.
- `90-razer-leviathan-v2x.rules` sets the hw volume to 100/151 whenever the card appears.
- `51-leviathan-v2x-soft-mixer.conf` makes PipeWire use software volume (`api.alsa.soft-mixer`).

Controls are matched by name, not numid (numids changed in kernel 7.1.2).
Upstream-proper fix would be a snd-usb-audio quirk for 1532:054a.
