{
	lib,
	inputs,
	config,
	...
}: let
	cfg = config.my.conman.containers.matrix-ooye;
	inherit (config.my.conman) containers;
in {
	options.my.conman.containers.matrix-ooye = {
		enable = lib.mkEnableOption "OOYE for Matrix<->Discord bridging.";
		dataDir = {
			container =
				lib.mkOption {
					type = lib.types.path;
					default = config.containers.matrix-ooye.config.systemd.services.matrix-ooye.serviceConfig.WorkingDirectory;
				};
			hostPath =
				lib.mkOption {
					type = lib.types.path;
					default = cfg.dataDir.container;
				};
		};
		secrets = {
			tokenFile =
				lib.mkOption {
					type = lib.types.path;
					default = ../../secrets/ooye-token.age;
				};
			clientSecretFile =
				lib.mkOption {
					type = lib.types.path;
					default = ../../secrets/ooye-secret.age;
				};
		};
		targetDomain =
			lib.mkOption {
				type = lib.types.nonEmptyStr;
				default = "ooye.${containers.caddy.apex}";
			};
	};

	config =
		lib.mkIf cfg.enable {
			assertions = [
				{
					assertion = containers.matrix.enable;
					message = "Container 'matrix-ooye' requires container 'matrix'.";
				}
			];
			containers =
				{
					matrix-ooye = {
						bindMounts = {
							"/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
							${cfg.dataDir.container} = {
								inherit (cfg.dataDir) hostPath;
								isReadOnly = false;
							};
						};
						config = {config, ...}: {
							imports = [../age.nix inputs.ooye.modules.default inputs.age.nixosModules.age];

							age.secrets = {
								ooye-token.file = cfg.secrets.tokenFile;
								ooye-secret.file = cfg.secrets.clientSecretFile;
							};

							services.matrix-ooye = {
								enable = true;
								homeserver = "https://${containers.matrix.targetDomain}";
								homeserverName = containers.caddy.apex;
								discordTokenPath = config.age.secrets.ooye-token.path;
								discordClientSecretPath = config.age.secrets.ooye-secret.path;
								bridgeOrigin = "https://${cfg.targetDomain}";
							};

							networking.firewall.allowedTCPPorts = [6693];
						};
					};
				}
				// lib.optionalAttrs containers.caddy.enable {
					caddy.config.services.caddy.virtualHosts.${cfg.targetDomain}.extraConfig = ''
						reverse_proxy matrix-ooye:6693
					'';
				};
		};
}
