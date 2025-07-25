{
	outputs,
	lib,
	pkgs,
	...
}: {
	nixpkgs = {
		config.allowUnfree = true;
		overlays = [outputs.overlays.unstable-pkgs];
	};
	nix = {
		channel.enable = false;
		settings = {
			experimental-features = "nix-command flakes";
			auto-optimise-store = true;
		};
	};

	i18n.defaultLocale = "en_GB.UTF-8";
	time = {
		timeZone = "Europe/London";
		hardwareClockInLocalTime = true;
	};

	networking.networkmanager.enable = true;

	console = {
		earlySetup = true;
		font = "Lat2-Terminus16";
		keyMap = "uk";
	};

	programs = {
		git = {
			enable = true;
			config = {
				init.defaultBranch = "main";
				commit.gpgSign = true;
				tag.gpgSign = true;
				gpg.format = "ssh";
			};
		};
		nano.enable = false;
		nh = {
			enable = true;
			clean = {
				enable = true;
				extraArgs = "--keep-since 7d --keep 5";
			};
		};
		ssh = {
			startAgent = true;
			extraConfig = ''
				AddKeysToAgent yes
			'';
		};
	};

	environment.defaultPackages = [];
	environment.systemPackages = with pkgs; [
		vim
		neovim
		home-manager
		# Replace as much GNU software as possible
		(lib.hiPrio pkgs.unstable.uutils-coreutils-noprefix)
		(lib.hiPrio pkgs.uutils-findutils)
		# Currently disabled - incomplete:
		# (lib.hiPrio pkgs.uutils-diffutils)
	];
	documentation.nixos.enable = false;
}
