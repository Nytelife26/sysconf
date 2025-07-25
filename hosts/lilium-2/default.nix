{
	pkgs,
	lib,
	...
}: {
	imports = [
		../../common/sys/audio.nix
		../../common/sys/system.nix
		../../common/stylix.nix

		./hardware.nix
	];

	boot = {
		lanzaboote = {
			enable = true;
			pkiBundle = "/var/lib/sbctl";
		};
		loader = {
			# NOTE: lanzaboote replaces systemd-boot for now, review this later (as of 0.4.2)
			systemd-boot.enable = false;
			efi.canTouchEfiVariables = true;
		};
	};

	networking.hostName = "lilium-2";

	security.polkit.enable = true;

	environment.systemPackages = with pkgs; [
		brightnessctl
		acpi
		powertop
		sbctl
	];

	programs.dconf.enable = true;

	powerManagement.powertop.enable = true;

	services = {
		libinput.enable = true;
		upower.enable = true;
	};

	users.users.lveneris = {
		uid = 1000;
		home = "/home/lveneris";

		shell = pkgs.nushell;
		isNormalUser = true;
		initialPassword = "changeme";

		extraGroups = [
			"wheel"
			"audio"
			"video"
			"networkmanager"
		];
	};

	# https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
	system.stateVersion = "24.11";
}
