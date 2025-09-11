{
	disko.devices.disk.main = let
		mountOptions = ["defaults" "x-mount.mkdir" "compress=zstd" "noatime"];
	in {
		type = "disk";
		device = "/dev/sda";
		content = {
			type = "gpt";
			partitions = {
				boot = {
					priority = 1;
					name = "boot";
					size = "1G";
					type = "EF00";
					content = {
						type = "filesystem";
						format = "vfat";
						mountpoint = "/boot";
						mountOptions = ["umask=0077"];
					};
				};
				root = {
					name = "root";
					size = "100%";
					content = {
						type = "btrfs";
						extraArgs = ["-f"];
						subvolumes = {
							"@root" = {
								mountpoint = "/";
								inherit mountOptions;
							};
							"@nix" = {
								mountpoint = "/nix";
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
}
