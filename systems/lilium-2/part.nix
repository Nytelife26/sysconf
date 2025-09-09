{
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
}
