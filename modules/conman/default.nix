{
	lib,
	config,
	tools,
	...
}: let
	cfg = config.my.conman;
	enabled =
		builtins.attrNames (lib.filterAttrs (_: value: value.enable) cfg.containers);
in {
	imports = [
		./caddy.nix
		./matrix.nix
		./matrix-ooye.nix
		./matrix-postmoogle.nix
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
						config = {
							imports = [../minsys.nix];
							services.resolved.enable = lib.mkForce true;
							networking = {
								hosts = cfg.networkHosts;
								useHostResolvConf = lib.mkForce false;
							};
						};
					});
		};
}
