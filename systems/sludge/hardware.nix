{modulesPath, ...}: {
	imports = [
		./part.nix
		(modulesPath + "/profiles/qemu-guest.nix")
	];

	boot = {
		initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "sd_mod" "sr_mod"];
		kernelParams = ["quiet"];
		loader = {
			systemd-boot.enable = true;
			timeout = 1;
		};
	};

	services.qemuGuest.enable = true;
}
