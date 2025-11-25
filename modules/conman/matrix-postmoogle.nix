{
	config,
	lib,
	inputs,
	...
}: let
	cfg = config.my.conman.containers;
	caddyOpts =
		if cfg.caddy.enable
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
			tls = let
				matrixDomain = cfg.matrix.targetDomain;
			in {
				POSTMOOGLE_TLS_REQUIRED = "1";
				POSTMOOGLE_TLS_CERT = "/var/lib/certs/${matrixDomain}/${matrixDomain}.crt";
				POSTMOOGLE_TLS_KEY = "/var/lib/certs/${matrixDomain}/${matrixDomain}.key";
			};
			# TODO: make this more robust - caddy also uses ZeroSSL, or other endpoints
			# see services.caddy.acmeCA
			tlsMount."/var/lib/certs".hostPath = "${cfg.caddy.dataDir.hostPath}/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
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
					default = cfg.matrix-postmoogle.dataDir.container;
				};
		};
		secretsFile =
			lib.mkOption {
				type = lib.types.path;
				default = ../../secrets/mail-secrets.age;
			};
	};

	config =
		lib.mkIf cfg.matrix-postmoogle.enable {
			assertions = [
				{
					assertion = cfg.matrix.enable;
					message = "Container 'matrix-postmoogle' requires container 'matrix'.";
				}
			];
			containers.matrix-postmoogle = {
				additionalCapabilities = ["CAP_NET_ADMIN"];
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
				bindMounts =
					{
						"/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
						${cfg.matrix-postmoogle.dataDir.container} = {
							inherit (cfg.matrix-postmoogle.dataDir) hostPath;
							isReadOnly = false;
						};
					}
					// caddyOpts.tlsMount;
				config = {config, ...}: {
					imports = [../postmoogle.nix ../age.nix inputs.age.nixosModules.age];

					age.secrets.mail-secrets.file = cfg.matrix-postmoogle.secretsFile;

					inherit (caddyOpts) users;

					services.matrix-postmoogle =
						{
							enable = true;
							environmentFiles = [config.age.secrets.mail-secrets.path];
							environment =
								{
									POSTMOOGLE_HOMESERVER = "https://${cfg.matrix.targetDomain}";
									POSTMOOGLE_LOGIN = "postmoogle";
									POSTMOOGLE_DOMAINS = cfg.caddy.apex;
									POSTMOOGLE_MAILBOXES_ACTIVATION = "notify";
									POSTMOOGLE_ADMINS = "@${userName}:${cfg.caddy.apex}";
								}
								// caddyOpts.tls;
						}
						// caddyOpts.postmoogleUser;

					networking.firewall.allowedTCPPorts = [25 587];
				};
			};
		};
}
