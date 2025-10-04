{
	config,
	tools,
	inputs,
	...
}: {
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
			enableIPv6 = true;
			internalInterfaces = ["ve-+"];
			externalInterface = "ens3";
		};
		networkmanager.unmanaged = ["ens3:ve-*"];
		firewall.allowedTCPPorts = [80 443];
	};

	containers = let
		homePath = config.users.users.${config.my.user.name}.home;
		hostMap =
			(tools.containersToHostMap [
					"matrix"
					"matrix-ooye"
					"matrix-postmoogle"
				])
			// {
				host = {
					hostAddress = "192.168.1.10";
					hostAddress6 = "fc00::";
				};
			};
		hosts = tools.hostMapToHosts hostMap;
	in {
		caddy = {
			autoStart = true;

			bindMounts = {
				"/var/www".hostPath = "${homePath}/www";
				"/var/lib/caddy" = {
					hostPath = "${homePath}/caddy";
					isReadOnly = false;
				};
				"/etc/ssh/ssh_host_ed25519_key".hostPath = "/etc/ssh/ssh_host_ed25519_key";
			};

			config = {
				config,
				pkgs,
				lib,
				...
			}: {
				imports = [../../modules/minsys.nix ../../modules/age.nix inputs.age.nixosModules.age];

				age.secrets."cf-api".file = ../../secrets/cf-api.age;

				services.caddy = {
					enable = true;
					package =
						pkgs.caddy.withPlugins {
							plugins = ["github.com/caddy-dns/cloudflare@v0.2.1"];
							hash = "sha256-p9AIi6MSWm0umUB83HPQoU8SyPkX5pMx989zAi8d/74=";
						};
					configFile = ./Caddyfile;
					environmentFile = config.age.secrets.cf-api.path;
				};

				networking = {
					inherit hosts;
					firewall.allowedTCPPorts = [80 443];
				};
			};
		};
		matrix = {
			autoStart = true;
			privateNetwork = true;
			inherit (hostMap.host) hostAddress hostAddress6;
			inherit (hostMap.matrix) localAddress localAddress6;

			bindMounts."/var/lib/continuwuity" = {
				hostPath = "${homePath}/continuwuity/data";
				isReadOnly = false;
			};

			config = {
				config,
				pkgs,
				lib,
				...
			}: {
				imports = [../../modules/minsys.nix];

				nixpkgs.overlays = import ../../overlays {inherit inputs;};

				services = {
					matrix-continuwuity = {
						enable = true;
						package = pkgs.unstable.matrix-continuwuity;
						settings.global = {
							server_name = "kludgecs.com";
							allow_registration = false;
							allow_encryption = true;
							allow_federation = true;
							trusted_servers = ["matrix.org" "techncs.de" "maunium.net"];
							address = builtins.attrValues hostMap.matrix;
						};
					};
					resolved.enable = true;
				};

				networking = {
					useHostResolvConf = lib.mkForce false;
					firewall.allowedTCPPorts = [6167];
				};
			};
		};
		matrix-ooye = {
			autoStart = true;
			privateNetwork = true;
			inherit (hostMap.host) hostAddress hostAddress6;
			inherit (hostMap.matrix-ooye) localAddress localAddress6;

			bindMounts = {
				"/etc/ssh/ssh_host_ed25519_key".hostPath = "/etc/ssh/ssh_host_ed25519_key";
				"/var/lib/matrix-ooye" = {
					hostPath = "${homePath}/ooye";
					isReadOnly = false;
				};
			};

			config = {
				config,
				pkgs,
				lib,
				...
			}: {
				imports = [../../modules/minsys.nix ../../modules/age.nix inputs.ooye.modules.default inputs.age.nixosModules.age];

				age.secrets = {
					ooye-token.file = ../../secrets/ooye-token.age;
					ooye-secret.file = ../../secrets/ooye-secret.age;
				};

				services = {
					matrix-ooye = {
						enable = true;
						homeserver = "https://matrix.kludgecs.com";
						homeserverName = "kludgecs.com";
						discordTokenPath = config.age.secrets.ooye-token.path;
						discordClientSecretPath = config.age.secrets.ooye-secret.path;
						bridgeOrigin = "https://ooye.kludgecs.com";
					};
					resolved.enable = true;
				};

				networking = {
					firewall.allowedTCPPorts = [6693];
					useHostResolvConf = lib.mkForce false;
				};
			};
		};
		matrix-postmoogle = {
			autoStart = true;
			privateNetwork = true;
			additionalCapabilities = ["CAP_NET_ADMIN"];
			inherit (hostMap.host) hostAddress hostAddress6;
			inherit (hostMap.matrix-postmoogle) localAddress localAddress6;

			forwardPorts = [
				{
					hostPort = 25;
					containerPort = 25;
				}
				{
					hostPort = 587;
					containerPort = 587;
				}
			];

			bindMounts = {
				"/etc/ssh/ssh_host_ed25519_key".hostPath = "/etc/ssh/ssh_host_ed25519_key";
				"/var/lib/matrix-postmoogle" = {
					hostPath = "${homePath}/mail/data";
					isReadOnly = false;
				};
				"/var/lib/certs".hostPath = "${homePath}/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
			};

			config = {
				config,
				pkgs,
				lib,
				...
			}: {
				imports = [../../modules/minsys.nix ../../modules/postmoogle.nix ../../modules/age.nix inputs.age.nixosModules.age];

				age.secrets.mail-secrets.file = ../../secrets/mail-secrets.age;

				users.users.caddy = {
					group = "caddy";
					uid = config.ids.uids.caddy;
					isSystemUser = true;
				};
				users.groups.caddy.gid = config.ids.gids.caddy;

				services = {
					matrix-postmoogle = {
						enable = true;
						user = "caddy";
						group = "caddy";
						environmentFiles = [config.age.secrets.mail-secrets.path];
						environment = {
							POSTMOOGLE_HOMESERVER = "https://matrix.kludgecs.com";
							POSTMOOGLE_LOGIN = "postmoogle";
							POSTMOOGLE_DOMAINS = "kludgecs.com";

							POSTMOOGLE_TLS_REQUIRED = "1";
							POSTMOOGLE_TLS_CERT = "/var/lib/certs/matrix.kludgecs.com/matrix.kludgecs.com.crt";
							POSTMOOGLE_TLS_KEY = "/var/lib/certs/matrix.kludgecs.com/matrix.kludgecs.com.key";

							POSTMOOGLE_MAILBOXES_ACTIVATION = "notify";
							POSTMOOGLE_ADMINS = "@lveneris:kludgecs.com";
						};
					};
					resolved.enable = true;
				};

				networking = {
					useHostResolvConf = lib.mkForce false;
					firewall.allowedTCPPorts = [25 587];
				};
			};
		};
	};
}
