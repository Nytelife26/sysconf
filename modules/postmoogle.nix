{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.services.matrix-postmoogle;
	defaultUser = "postmoogle";
	defaultGroup = "postmoogle";
in {
	options.services.matrix-postmoogle = {
		enable = lib.mkEnableOption "Postmoogle - a 1-to-1 email over Matrix bridge.";
		package = lib.mkPackageOption pkgs "postmoogle" {};
		user =
			lib.mkOption {
				type = lib.types.nonEmptyStr;
				description = "The user {command}`postmoogle` is run as.";
				default = defaultUser;
			};
		group =
			lib.mkOption {
				type = lib.types.nonEmptyStr;
				description = "The group {command}`postmoogle` is run as.";
				default = defaultGroup;
			};
		environment =
			lib.mkOption {
				type = lib.types.attrsOf lib.types.str;
				description = ''
					Environment variables to set for the service. Secrets should be specified
					using {option}`environmentFiles`.
					Refer to
					<https://github.com/etkecc/postmoogle?tab=readme-ov-file#1-bot-mandatory>
					for available options.
				'';
				default = {};
			};
		environmentFiles =
			lib.mkOption {
				type = lib.types.listOf lib.types.path;
				description = ''
					Files to load envirnoment variables from. Loaded variables override values
					set in {option}`environment`.
				'';
				default = [];
			};
	};

	config =
		lib.mkIf cfg.enable {
			assertions = [
				{
					assertion = cfg.user != defaultUser -> config ? users.users.${cfg.user};
					message = "If `services.matrix-postmoogle.user` is changed, the configured user must already exist.";
				}
				{
					assertion = cfg.group != defaultGroup -> config ? users.groups.${cfg.group};
					message = "If `services.matrix-postmoogle.user` is changed, the configured user must already exist.";
				}
			];

			users = {
				users =
					lib.mkIf (cfg.user == defaultUser) {
						${defaultUser} = {
							inherit (cfg) group;
							isSystemUser = true;
						};
					};
				groups =
					lib.mkIf (cfg.group == defaultGroup) {
						${defaultGroup} = {};
					};
			};

			environment.systemPackages = [cfg.package];

			systemd.services.matrix-postmoogle = {
				description = "Postmoogle - a 1-to-1 email over Matrix bridge.";
				wantedBy = ["multi-user.target"];
				wants = [
					"network-online.target"
					"matrix-synapse.service"
					"conduit.service"
					"dendrite.service"
				];
				after = ["network-online.target"];

				inherit (cfg) environment;
				serviceConfig = {
					DynamicUser = true;
					User = cfg.user;
					Group = cfg.group;

					EnvironmentFile = cfg.environmentFiles;
					AmbientCapabilities = "CAP_NET_BIND_SERVICE";

					WorkingDirectory = "/var/lib/matrix-postmoogle";
					StateDirectory = "matrix-postmoogle";
					StateDirectoryMode = "0760";

					ExecStart = lib.getExe cfg.package;
					Restart = "on-failure";
					RestartSec = 10;
				};
			};
		};
}
