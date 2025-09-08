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
		};

		kernelModules = ["kvm-intel"];
		blacklistedKernelModules = ["ucsi_acpi" "typec_ucsi"];
		kernelParams = ["quiet" "splash"];
		extraModulePackages = [];
	};

	hardware.graphics.enable = true;
	security.tpm2.enable = true;

	disko.devices.disk.main = let
		mountOptions = ["defaults" "x-mount.mkdir" "ssd" "compress=zstd" "noatime"];
	in {
		type = "disk";
		device = "/dev/nvme0n1";
		content = {
			type = "gpt";
			partitions = {
				boot = {
					size = "1G";
					type = "EF00";
					device = "/dev/disk/by-partlabel/boot";
					content = {
						type = "filesystem";
						format = "vfat";
						mountpoint = "/boot";
						mountOptions = ["umask=0077"];
					};
				};
				root = {
					size = "100%";
					device = "/dev/disk/by-partlabel/root";
					content = {
						type = "luks";
						name = "root";
						settings = {};
						content = {
							type = "btrfs";
							extraArgs = ["-f"];
							subvolumes = {
								"@root" = {
									mountpoint = "/";
									inherit mountOptions;
								};
								"@swap" = {
									mountpoint = "/swap";
									inherit mountOptions;
									swap.swapfile.size = "4G";
								};
								"@nix" = {
									mountpoint = "/nix";
									inherit mountOptions;
								};
								"@snapshots" = {
									mountpoint = "/.snapshots";
									inherit mountOptions;
								};
								"@home" = {
									mountpoint = "/home";
									inherit mountOptions;
								};
							};
						};
					};
				};
			};
		};
	};

	# Enables DHCP on each ethernet and wireless interface. In case of scripted networking
	# (the default) this is the recommended approach. When using systemd-networkd it's
	# still possible to use this option, but it's recommended to use it in conjunction
	# with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
	networking.useDHCP = lib.mkDefault true;
	# networking.interfaces.wlo1.useDHCP = lib.mkDefault true;
	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
