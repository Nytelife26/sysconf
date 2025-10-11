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
			};
		hosts = {
			withHost = {
				hostAddress =
					lib.mkOption {
						type = lib.types.nullOr lib.types.str;
						default = null;
					};
				hostAddress6 =
					lib.mkOption {
						type = lib.types.nullOr lib.types.str;
						default = null;
					};
			};
			containers =
				lib.mkOption {
					type = lib.types.listOf lib.types.str;
					default = [];
				};
			offset4 =
				lib.mkOption {
					type = lib.types.ints.unsigned;
					default = 0;
				};
			offset6 =
				lib.mkOption {
					type = lib.types.ints.unsigned;
					default = 0;
				};
			applyTo =
				lib.mkOption {
					type = lib.types.listOf lib.types.str;
					default = [];
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
