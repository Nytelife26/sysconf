{
	config,
	lib,
	inputs,
	...
}: let
	cfg = config.my.conman.containers.matrix-postmoogle;
	inherit (config.my.conman) containers;
	matrixDomain = containers.matrix.targetDomain;
	caddyOpts =
		if containers.caddy.enable
		then {
			postmoogleUser = {
				user = "caddy";
				group = "caddy";
			};
			users = {
				users.caddy = {
					group = "caddy";
					uid = config.ids.uids.caddy;
					isSystemUser = true;
				};
				groups.caddy.gid = config.ids.gids.caddy;
			};
			tls = {
				POSTMOOGLE_TLS_REQUIRED = "1";
				POSTMOOGLE_TLS_CERT = "/var/lib/certs/${matrixDomain}.crt";
				POSTMOOGLE_TLS_KEY = "/var/lib/certs/${matrixDomain}.key";
			};
			# TODO: make this more robust - caddy also uses ZeroSSL, or other endpoints
			# see services.caddy.acmeCA
			tlsMount."/var/lib/certs".hostPath = "${containers.caddy.dataDir.hostPath}/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${matrixDomain}";
		}
		else {
			postmoogleUser = {};
			users = {};
			tls = {};
			tlsMount = {};
		};
	userName = config.my.user.name;
in {
	options.my.conman.containers.matrix-postmoogle = {
		enable = lib.mkEnableOption "Postmoogle for Matrix<->Email bridging.";
		dataDir = {
			container =
				lib.mkOption {
					type = lib.types.path;
					default = config.containers.matrix-postmoogle.config.systemd.services.matrix-postmoogle.serviceConfig.WorkingDirectory;
				};
			hostPath =
				lib.mkOption {
					type = lib.types.path;
					default = cfg.dataDir.container;
				};
		};
		secretsFile =
			lib.mkOption {
				type = lib.types.path;
				default = ../../secrets/mail-secrets.age;
			};
	};

	config =
		lib.mkIf cfg.enable {
			assertions = [
				{
					assertion = containers.matrix.enable;
					message = "Container 'matrix-postmoogle' requires container 'matrix'.";
				}
			];
			containers.matrix-postmoogle = {
				additionalCapabilities = ["CAP_NET_ADMIN"];
				forwardPorts = [
					{hostPort = 25;}
					{hostPort = 587;}
				];
				bindMounts =
					{
						"/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
						${cfg.dataDir.container} = {
							inherit (cfg.dataDir) hostPath;
							isReadOnly = false;
						};
					}
					// caddyOpts.tlsMount;
				config = {config, ...}: {
					imports = [../postmoogle.nix ../age.nix inputs.age.nixosModules.age];

					age.secrets.mail-secrets.file = cfg.secretsFile;

					inherit (caddyOpts) users;

					services.matrix-postmoogle =
						{
							enable = true;
							environmentFiles = [config.age.secrets.mail-secrets.path];
							environment =
								{
									POSTMOOGLE_HOMESERVER = "https://${matrixDomain}";
									POSTMOOGLE_LOGIN = "postmoogle";
									POSTMOOGLE_DOMAINS = containers.caddy.apex;
									POSTMOOGLE_MAILBOXES_ACTIVATION = "notify";
									POSTMOOGLE_ADMINS = "@${userName}:${containers.caddy.apex}";
								}
								// caddyOpts.tls;
						}
						// caddyOpts.postmoogleUser;

					networking.firewall.allowedTCPPorts = [25 587];
				};
			};
		};
}
