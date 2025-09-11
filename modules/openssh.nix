{
	config,
	lib,
	...
}: {
	options.my.openssh = {
		enable = lib.mkEnableOption "OpenSSH server configuration.";
		hookPam = lib.mkEnableOption "using SSH authorization for PAM (and sudo).";
		keys =
			lib.mkOption {
				type = lib.types.listOf lib.types.singleLineStr;
				default = [];
				description = "A list of public keys to authorize for user login.";
			};
	};

	config =
		lib.mkIf config.my.openssh.enable {
			services.openssh = {
				enable = true;
				settings = {
					PermitRootLogin = "no";
					PasswordAuthentication = false;
					AllowUsers = [config.my.user.name];
				};
			};

			users.users.${config.my.user.name}.openssh.authorizedKeys.keys =
				config.my.openssh.keys;

			security.pam =
				lib.mkIf config.my.openssh.hookPam {
					sshAgentAuth.enable = true;
					services.sudo.sshAgentAuth = true;
				};
		};
}
