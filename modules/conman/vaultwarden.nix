{
	lib,
	config,
	...
}: let
	cfg = config.my.conman.containers.vaultwarden;
	inherit (config.my.conman) containers;
	stateDirectory = config.containers.vaultwarden.config.systemd.services.vaultwarden.serviceConfig.StateDirectory;
in {
	options.my.conman.containers.vaultwarden = {
		enable = lib.mkEnableOption "Vaultwarden for secrets management.";
		dataDir = {
			container =
				lib.mkOption {
					type = lib.types.path;
					# This is the same as in https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/security/vaultwarden/default.nix#L17
					default = "/var/lib/${stateDirectory}";
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
				default = ../../secrets/vault-secrets.age;
			};
		targetDomain =
			lib.mkOption {
				type = lib.types.nonEmptyStr;
				default = "vault.${containers.caddy.apex}";
			};
	};

	config =
		lib.mkIf cfg.enable {
			containers =
				{
					vaultwarden.config = {config, ...}: {
						age.secrets.vault-secrets.file = cfg.secretsFile;

						services.vaultwarden = {
							enable = true;
							config =
								{
									DOMAIN = "https://${cfg.targetDomain}";
									ROCKET_ADDRESS = "0.0.0.0";
									ROCKET_PORT = 8000;
									SIGNUPS_ALLOWED = false;
									PASSWORD_HINTS_ALLOWED = false;
									TRASH_AUTO_DELETE_DAYS = 14;
								}
								// lib.optionalAttrs containers.stalwart.enable {
									SMTP_HOST = containers.stalwart.targetDomain;
									SMTP_FROM = "vault-internal@${containers.caddy.apex}";
									SMTP_USERNAME = "vault-internal@${containers.caddy.apex}";
									SMTP_SECURITY = "force_tls";
								};
							environmentFile = config.age.secrets.vault-secrets.path;
						};

						networking.firewall.allowedTCPPorts = [8000];
					};
				}
				// lib.optionalAttrs containers.caddy.enable {
					caddy.config.services.caddy.virtualHosts.${cfg.targetDomain}.extraConfig = ''
						reverse_proxy vaultwarden:8000 {
							header_up X-Real-Ip {http.request.header.Cf-Connecting-Ip}
						}
					'';
				};
		};
}
