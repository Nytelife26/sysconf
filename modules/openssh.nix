{
	config,
	lib,
	...
}: {
	options.my.openssh = {
		enable = lib.mkEnableOption "OpenSSH server configuration.";
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
		};
}
