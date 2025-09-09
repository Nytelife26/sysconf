{
	lib,
	modulesPath,
	...
}: {
	imports = [
		./part.nix
		(modulesPath + "/installer/scan/not-detected.nix")
	];

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
				"btrfs"
			];
			kernelModules = [];
		};

		kernelModules = ["kvm-intel"];
		blacklistedKernelModules = ["ucsi_acpi" "typec_ucsi"];
		kernelParams = ["quiet" "splash"];
		extraModulePackages = [];
	};

	networking.useDHCP = lib.mkDefault true;
}
