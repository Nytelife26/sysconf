{config, ...}: {
	imports = [
		../../modules/neovim
		../../modules/network.nix

		../../modules/openssh.nix
		../../modules/shell.nix
	];

	my = {
		networking = true;
		openssh = {
			enable = true;
			hookPam = true;
			keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVsjcUps7PpHK/zMl206IpyvRKEqHT3DhdZ+s91Gbqy"];
		};
		shell.enable = true;
	};

	nix.settings.trusted-users = ["@wheel"];

	networking = {
		nat = {
			enable = true;
			internalInterfaces = ["ve-+"];
			externalInterface = "ens3";
			enableIPv6 = true;
		};
		networkmanager.unmanaged = ["ens3:ve-*"];
	};

	containers = let
		homePath = config.users.users.${config.my.user.name}.home;
	in {
		matrix = {
			autoStart = true;
			privateNetwork = true;

			hostAddress = "192.168.100.10";
			localAddress = "192.168.100.12";
			hostAddress6 = "fc00::1";
			localAddress6 = "fc00::3";

			bindMounts = {
				"/var/lib/continuwuity" = {
					hostPath = "${homePath}/continuwuity/data";
					isReadOnly = false;
				};
			};

			config = {
				config,
				pkgs,
				lib,
				...
			}: {
				imports = [../../modules/minsys.nix];

				services = {
					matrix-continuwuity = {
						enable = true;
						settings.global = {
							server_name = "kludgecs.com";
							allow_registration = false;
							allow_encryption = true;
							allow_federation = true;
							trusted_servers = ["matrix.org"];
						};
					};
					resolved.enable = true;
				};

				networking = {
					firewall.allowedTCPPorts = [443 8448];
					useHostResolvConf = lib.mkForce false;
				};
			};
		};
		# webserver = {};
		# mailserver = {};
		# caddy = {};
	};
}
