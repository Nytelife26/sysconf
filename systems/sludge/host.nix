{
	imports = [
		../../modules/conman
		../../modules/neovim

		../../modules/openssh.nix
		../../modules/shell.nix
	];

	my = {
		conman = {
			enable = true;
			hosts = {
				withHost = {
					hostAddress = "192.168.1.10";
					hostAddress6 = "fc00::";
				};
				offset4 = 10;
			};
			containers = {
				caddy = {
					enable = true;
					www = "/var/www";
				};
				matrix.enable = true;
				matrix-ooye.enable = true;
				stalwart.enable = true;
			};
		};
		openssh = {
			enable = true;
			hookPam = true;
			keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVsjcUps7PpHK/zMl206IpyvRKEqHT3DhdZ+s91Gbqy"];
		};
		shell.enable = true;
	};

	services.fail2ban = {
		enable = true;
		bantime = "1h";
		bantime-increment.enable = true;
	};

	containers.caddy.config.services.caddy.virtualHosts = {
		"tam-mockup.kludgecs.com".extraConfig = ''
			handle {
				root /var/www/tam-mockup
				try_files {path} {path}/ {path}.html
				file_server
			}
		'';
		"kludgecs.com" = {
			serverAliases = ["www.kludgecs.com"];
			extraConfig = ''
				handle_path /.well-known/matrix/* {
					header {
						Access-Control-Allow-Origin *
						Content-Type application/json
					}
					root /var/www/matrix
					file_server
				}

				handle {
					root /var/www/kludgecs.com
					try_files {path} {path}/ {path}.html
					file_server {
						precompressed
					}
				}

				handle_errors {
					rewrite * /{err.status_code}.html
					file_server
				}
			'';
		};
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
