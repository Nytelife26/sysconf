{
	lib,
	config,
	tools,
	...
} @ args: let
	cfg = config.my.containers;
in {
	options.my.containers = {
		enable = lib.mkEnableOption "conman for container management.";
		sourceFrom =
			lib.mkOption {
				type = lib.types.nullOr lib.types.path;
				default = null;
				description = "The module to import containers from.";
			};
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
			containers =
				lib.mkOption {
					type = lib.types.listOf lib.types.str;
					default = [];
					description = "The containers to generate a host map for.";
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
			applyTo =
				lib.mkOption {
					type = lib.types.listOf lib.types.str;
					default = [];
					description = "The containers to apply the generated hosts file to.";
				};
		};
	};

	config =
		lib.mkIf cfg.enable {
			containers = let
				hostMap =
					(tools.containersToHostMap {inherit (cfg.hosts) containers offset4 offset6;}) // {host = cfg.hosts.withHost;};
				hosts = tools.hostMapToHosts hostMap;
				homePath = config.users.users.${config.my.user.name}.home;
				# NOTE: this cannot be replaced with lib.mkIf
				sourceFrom =
					if (cfg.sourceFrom != null)
					then import cfg.sourceFrom
					else {};
			in
				lib.mkMerge [
					(lib.genAttrs cfg.hosts.containers (name: {
								autoStart = true;
								privateNetwork = true;
								inherit (hostMap.host) hostAddress hostAddress6;
								inherit (hostMap.${name}) localAddress localAddress6;
								config = {
									imports = [./minsys.nix];
									services.resolved.enable = true;
									networking.useHostResolvConf = lib.mkForce false;
								};
							}))
					(lib.genAttrs cfg.hosts.applyTo (_: {config.networking.hosts = hosts;}))
					(
						if builtins.isFunction sourceFrom
						then sourceFrom (args // {inherit homePath hosts hostMap;})
						else sourceFrom
					)
				];
		};
}
