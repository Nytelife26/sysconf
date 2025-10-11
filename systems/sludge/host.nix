{
	imports = [
		../../modules/neovim

		../../modules/conman.nix
		../../modules/openssh.nix
		../../modules/shell.nix
	];

	my = {
		containers = {
			enable = true;
			sourceFrom = ./containers.nix;
			hosts = {
				withHost = {
					hostAddress = "192.168.1.10";
					hostAddress6 = "fc00::";
				};
				containers = ["matrix" "matrix-ooye" "matrix-postmoogle"];
				offset4 = 10;
				applyTo = ["caddy"];
			};
		};
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
			enableIPv6 = true;
			internalInterfaces = ["ve-+"];
			externalInterface = "ens3";
		};
		interfaces.ens3.ipv6.addresses = [
			{
				address = "2a0a:4cc0:0:1a3::1";
				prefixLength = 64;
			}
		];
		defaultGateway6 = {
			address = "fe80::1";
			interface = "ens3";
		};
		firewall.allowedTCPPorts = [80 443];
	};
}
