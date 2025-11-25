{
	lib,
	config,
	inputs,
	...
}: let
	cfg = config.my.conman.containers;
	conmanCfg = config.my.conman;
in {
	options.my.conman.containers.matrix = {
		enable = lib.mkEnableOption "Continuwuity for Matrix.";
		dataDir = {
			container =
				lib.mkOption {
					type = lib.types.path;
					default = config.containers.matrix.config.services.matrix-continuwuity.settings.global.database_path;
				};
			hostPath =
				lib.mkOption {
					type = lib.types.path;
					default = cfg.matrix.dataDir.container;
				};
		};
		targetDomain =
			lib.mkOption {
				type = lib.types.nonEmptyStr;
				default = "matrix.${cfg.caddy.apex}";
			};
	};

	config =
		lib.mkIf cfg.matrix.enable {
			containers =
				{
					matrix = {
						bindMounts.${cfg.matrix.dataDir.container} = {
							inherit (cfg.matrix.dataDir) hostPath;
							isReadOnly = false;
						};
						config = {pkgs, ...}: {
							nixpkgs.overlays = import ../../overlays {inherit inputs;};

							services.matrix-continuwuity = {
								enable = true;
								package = pkgs.unstable.matrix-continuwuity;
								settings.global = {
									server_name = cfg.caddy.apex;
									allow_registration = false;
									allow_encryption = true;
									allow_federation = true;
									trusted_servers = ["matrix.org" "techncs.de" "maunium.net"];
									address = builtins.attrValues conmanCfg.hostMap.matrix;
								};
							};

							networking.firewall.allowedTCPPorts = [6167];
						};
					};
				}
				// lib.optionalAttrs cfg.caddy.enable {
					caddy.config.services.caddy.virtualHosts.${cfg.matrix.targetDomain}.extraConfig = ''
						handle /_matrix/* {
							reverse_proxy matrix:6167 {
								header_up X-Forwarded-Port {http.request.port}
								header_up X-Forwarded-TlsProto {tls_protocol}
								header_up X-Forwarded-TlsCipher {tls_cipher}
								header_up X-Forwarded-HttpsProto {proto}
							}
						}

						error * "Not found" 404
					'';
				};
		};
}
