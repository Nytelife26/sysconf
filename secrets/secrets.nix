let
	fetchKeys = {
		url,
		sha256,
	} @ urlObject:
		builtins.filter
		(line: builtins.isString line && builtins.stringLength line != 0)
		(builtins.split "\n" (builtins.readFile (builtins.fetchurl urlObject)));
	# NOTE: lib.flatten re-implemented here because this file cannot be a function
	flatten = x:
		if builtins.isList x
		then builtins.concatMap flatten x
		else [x];

	users = {
		lveneris =
			fetchKeys {
				url = "https://github.com/Nytelife26.keys";
				sha256 = "sha256-wPUS57yzLypDrGYPTW/ZnV8KERUDsOmDfriGqXJjHFU=";
			};
	};

	systems = {
		lilium-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEgXqRYijIASVNddVHKGG89WAjmw3mvHwrHl8Cy0Zv2Q";
		sludge = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLd2/iC2Ppoz+Q8pRGnSgaQUeFfg3lJ39bbugGAMUzi";
	};
	allUsers = flatten (builtins.attrValues users);
	allSystems = builtins.attrValues systems;
in {
	"cf-api.age".publicKeys = allUsers ++ [systems.sludge];
	"mail-secrets.age".publicKeys = allUsers ++ [systems.sludge];
	"lvpass.age".publicKeys = allUsers ++ allSystems;
	"ooye-token.age".publicKeys = allUsers ++ [systems.sludge];
	"ooye-secret.age".publicKeys = allUsers ++ [systems.sludge];
}
