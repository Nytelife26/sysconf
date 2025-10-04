{
	config,
	lib,
	tools,
	...
}: {
	config.age = {
		identityPaths = ["${config.users.users.${config.my.user.name}.home}/.ssh/id_age"];
		secrets =
			lib.listToAttrs (
				map (path: {
						name = tools.pathName path;
						value.file = path;
					}) [tools.dirFiles ".age" ../secrets]
			);
	};
}
