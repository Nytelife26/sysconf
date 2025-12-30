{
	config,
	lib,
	...
}: let
	cfg = config.my.conman.containers.radicle;
	inherit (config.my.conman) containers;
in {
	options.my.conman.containers.radicle = {
		enable = lib.mkEnableOption "Radicle for decentralized forging.";

		dataDir = {
			container =
				lib.mkOption {
					type = lib.types.path;
					default = "/var/lib/radicle";
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
				default = ../../secrets/radicle-priv-key.age;
			};

		targetDomain =
			lib.mkOption {
				type = lib.types.nonEmptyStr;
				default = "rad.${containers.caddy.apex}";
			};

		publicKey =
			lib.mkOption {
				type = lib.types.nonEmptyStr;
			};

		pinned =
			lib.mkOption {
				type = lib.types.listOf lib.types.nonEmptyStr;
				description = "Radicle repositories to pin.";
				default = [];
			};
	};

	config =
		lib.mkIf cfg.enable {
			containers =
				{
					radicle = {
						forwardPorts = [{hostPort = 8776;}];
						config = {config, ...}: {
							age.secrets.radicle-priv-key.file = cfg.secretsFile;

							services = {
								radicle = {
									enable = true;
									inherit (cfg) publicKey;
									privateKeyFile = config.age.secrets.radicle-priv-key.path;
									node = {
										openFirewall = true;
										listenAddress = "0.0.0.0";
									};
									settings = {
										web.pinned.repositories = cfg.pinned;
										node = {
											alias = cfg.targetDomain;
											externalAddresses = ["${cfg.targetDomain}:8776"];
											seedingPolicy.default = "block";
										};
									};
									httpd = {
										enable = true;
										listenAddress = "0.0.0.0";
									};
								};
							};

							networking.firewall.allowedTCPPorts = [8080];
						};
					};
				}
				// lib.optionalAttrs containers.caddy.enable {
					caddy.config.services.caddy.virtualHosts.${cfg.targetDomain}.extraConfig = ''
						reverse_proxy radicle:8080
					'';
				};
		};
}
