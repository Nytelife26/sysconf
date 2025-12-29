{
	lib,
	config,
	tools,
	inputs,
	...
}: let
	cfg = config.my.conman;
	enabled =
		builtins.attrNames (lib.filterAttrs (_: value: value.enable) cfg.containers);
	hasSecrets = name: cfg.containers.${name} ? secrets || cfg.containers.${name} ? secretsFile;
in {
	imports = [
		./caddy.nix
		./matrix.nix
		./matrix-ooye.nix
		./stalwart.nix
		./vaultwarden.nix
	];

	options.my.conman = {
		enable = lib.mkEnableOption "conman for container management.";
		hosts = {
			withHost = {
				hostAddress =
					lib.mkOption {
						type = lib.types.nullOr lib.types.str;
						default = null;
						description = "The IPv4 address to assign the host side of the interfaces.";
					};
				hostAddress6 =
					lib.mkOption {
						type = lib.types.nullOr lib.types.str;
						default = null;
						description = "The IPv6 address to assign the host side of the interfaces.";
					};
			};
			offset4 =
				lib.mkOption {
					type = lib.types.ints.unsigned;
					default = 0;
					description = "The offset to begin assigning IPv4 addresses from.";
				};
			offset6 =
				lib.mkOption {
					type = lib.types.ints.unsigned;
					default = 0;
					description = "The offset to begin assigning IPv6 addresses from.";
				};
		};
		hostMap =
			lib.mkOption {
				# TODO: tighten this
				# should be an attrs of one host and many containers
				type = lib.types.attrsOf (lib.types.attrsOf (lib.types.nullOr lib.types.str));
				default =
					tools.containersToHostMap {
						inherit (cfg.hosts) offset4 offset6;
						containers = enabled;
					}
					// {host = cfg.hosts.withHost;};
			};
		networkHosts =
			lib.mkOption {
				type = lib.types.attrsOf (lib.types.listOf lib.types.str);
				default = tools.hostMapToHosts cfg.hostMap;
			};
	};

	config =
		lib.mkIf cfg.enable {
			containers =
				lib.genAttrs enabled (name: {
						autoStart = true;
						privateNetwork = true;
						inherit (cfg.hostMap.host) hostAddress hostAddress6;
						inherit (cfg.hostMap.${name}) localAddress localAddress6;
						bindMounts =
							{}
							// (lib.optionalAttrs (cfg.containers.${name} ? dataDir) {
									${cfg.containers.${name}.dataDir.container} = {
										inherit (cfg.containers.${name}.dataDir) hostPath;
										isReadOnly = false;
									};
								})
							// (lib.optionalAttrs (hasSecrets name) {
									"/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
								});
						config = {
							imports = [../minsys.nix] ++ (lib.optionals (hasSecrets name) [inputs.age.nixosModules.age ../age.nix]);
							services.resolved.enable = lib.mkForce true;
							networking = {
								hosts = cfg.networkHosts;
								useHostResolvConf = lib.mkForce false;
							};
						};
					});
		};
}
