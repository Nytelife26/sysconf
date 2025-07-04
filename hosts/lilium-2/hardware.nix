{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  hardware = {
    asus.battery.chargeUpto = 80;
    # TODO: loading common.gpu.intel.alder-lake would make this unnecessary
    intelgpu.vaapiDriver = "intel-media-driver";
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "vmd"
        "nvme"
        "usb_storage"
        "sd_mod"
        "cryptd"
        "tpm"
        "btrfs"
      ];
      kernelModules = [];

      # NOTE: this is required for tpm2 on boot
      systemd.enable = true;

      luks.devices."root".device = "/dev/disk/by-partlabel/root";
    };

    kernelModules = ["kvm-intel"];
    kernelParams = ["quiet" "splash"];
    extraModulePackages = [];
  };

  hardware.graphics.enable = true;
  security.tpm2.enable = true;

  fileSystems = {
    "/" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["defaults" "x-mount.mkdir" "ssd" "compress=zstd" "subvol=@root"];
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
      options = ["umask=0077"];
    };
    "/swap" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["defaults" "x-mount.mkdir" "ssd" "compress=zstd" "noatime" "subvol=@swap"];
    };
    "/nix" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["defaults" "x-mount.mkdir" "ssd" "compress=zstd" "noatime" "subvol=@nix"];
    };
    "/.snapshots" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["defaults" "x-mount.mkdir" "ssd" "compress=zstd" "subvol=@snapshots"];
    };
    "/home" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = ["defaults" "x-mount.mkdir" "ssd" "compress=zstd" "subvol=@home"];
    };
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 20 * 1024;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
