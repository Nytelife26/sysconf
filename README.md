# sysconf

A Nix flake for my system configurations.

## Systems

| Name     | Hardware         | Type   | Description                          |
|:--------:|:----------------:|:------:|:-------------------------------------|
| lilium-2 | ASUS Vivobook 15 | PC     | Primary development laptop           |
| piforce  | Raspberry Pi 4b  | Server | Network security                     |
| iris     | Raspberry Pi 5   | Server | Media server and network share       |
| sludge   | RS 1000 G11      | Server | KCS services and external networking |

All systems have one primary administrator: yours truly.

## Modules

| Name         | Description                                                 |
|:------------:|:------------------------------------------------------------|
| `age`        | Agenix secrets configuration                                |
| `audio`      | Audio configuration via [RealtimeKit] and [PipeWire]        |
| `bat`        | Power management setup for battery-powered systems          |
| `config`     | Main system configuration, including Git and SSH            |
| `conman`     | Container management system with automatic networking       |
| `minsys`     | Minimizing system configuration                             |
| `neovim`     | Neovim configuration, requiring [NixVim]                    |
| `network`    | Network configuration via [NetworkManager]                  |
| `openssh`    | OpenSSH server configuration, with permissions and keys     |
| `secboot`    | (Experimental) Secure boot setup, requiring [Lanzaboote]    |
| `shell`      | Base and extended suite of command-line tools               |
| `style`      | System theming, requiring [Stylix]                          |
| `tpm`        | TPM2 support for system security at `initrd`-time           |
| `wm`         | [Wayland] and [SwayFX] configuration, with [swayalt] tiling |

[RealtimeKit]: https://gitlab.freedesktop.org/pipewire/rtkit
[PipeWire]: https://pipewire.org
[NixVim]: https://github.com/nix-community/nixvim
[NeworkManager]: https://networkmanager.dev
[Lanzaboote]: https://github.com/nix-community/lanzaboote
[Stylix]: https://github.com/nix-community/stylix
[Wayland]: https://wayland.freedesktop.org/
[SwayFX]: https://github.com/WillPower3309/swayfx
[swayalt]: https://github.com/nytelife26/swayalt-rs

## Credit

`sysconf` is based entirely on [drainpixie]'s [keystone]. All core improvements
are submitted upstream if applicable, and all credit for the structure and
internal workings should be directed upstream.

Some general inspiration and library functions have been taken from
[Henry-Hiles] of [Federated Nexus]'s [`nixos`].

[drainpixie]: https://drainpixie.xyz
[keystone]: https://git.sr.ht/~pixie/keystone
[Henry-Hiles]: https://henryhiles.com
[Federated Nexus]: https://federated.nexus
[`nixos`]: https://git.federated.nexus/Henry-Hiles/nixos
