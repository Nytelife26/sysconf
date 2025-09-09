# sysconf

A Nix flake for system configuration.

## Systems

| Name     | Hardware         | Type   | Description                          |
|:--------:|:----------------:|:------:|:-------------------------------------|
| lilium-2 | ASUS Vivobook 15 | PC     | Primary development laptop           |
| piforce  | Raspberry Pi 4b  | Server | Network security                     |
| iris     | Raspberry Pi 5   | Server | Media server and network share       |
| sludge   | RS 1000 G11      | Server | KCS services and external networking |

All systems have one primary administrator: yours truly.

## Modules

| Name      | Description                                                 |
|:---------:|:------------------------------------------------------------|
| `audio`   | Audio configuration via RealtimeKit and [PipeWire]          |
| `bat`     | Power management setup for battery-powered systems          |
| `config`  | Main system configuration, including Git and SSH            |
| `network` | Network configuration via [NetworkManager]                  |
| `secboot` | (Experimental) Secure boot setup, requiring [Lanzaboote]    |
| `shell`   | Base and extended suite of command-line tools               |
| `style`   | System theming, requiring [Stylix]                          |
| `tpm`     | TPM2 support for system security at `initrd`-time           |
| `wm`      | [Wayland] and [SwayFX] configuration, with [swayalt] tiling |

[PipeWire]: https://pipewire.org
[NeworkManager]: https://networkmanager.dev
[Lanzaboote]: https://github.com/nix-community/lanzaboote
[Stylix]: https://github.com/nix-community/stylix
[Wayland]: https://wayland.freedesktop.org/
[SwayFX]: https://github.com/WillPower3309/swayfx
[swayalt]: https://github.com/nytelife26/swayalt-rs

## Credit

`sysconf` is based entirely on [drainpixie]'s [rin]. All core improvements are
submitted upstream if applicable, and all credit for the structure and internal
workings should be directed upstream.

[drainpixie]: https://github.com/drainpixie
[rin]: https://github.com/drainpixie/rin
