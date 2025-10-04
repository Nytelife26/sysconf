{
	nixpkgs,
	inputs,
	...
}: let
	inherit (nixpkgs) lib;
in rec {
	setMany = attrs: keys:
		builtins.listToAttrs (builtins.map (name: {
					inherit name;
					value = attrs;
				})
			keys);

	enumerate = list: lib.zipLists (lib.range 1 (builtins.length list)) list;
	namedOffsets = list:
		builtins.listToAttrs (builtins.map (elem: {
					name = elem.snd;
					value = elem.fst;
				}) (enumerate list));
	containersToHostMap = containers:
		builtins.mapAttrs (_: value: let
				final4 = builtins.toString (10 + value);
				final6 = lib.toLower (lib.toHexString value);
			in {
				localAddress = "192.168.1.${final4}";
				localAddress6 = "fc00::${final6}";
			}) (namedOffsets containers);

	hostMapToHosts = hostMap:
		builtins.listToAttrs
		(builtins.concatMap
			(
				host:
					builtins.map
					(ip: {
							name = ip;
							value = [host.name];
						})
					(builtins.attrValues host.value)
			)
			(lib.attrsToList hostMap));

	pathName = path: lib.last (builtins.split "/" (toString path));
	dirFiles = type: dir: lib.filter (lib.hasSuffix type) (lib.filesystem.listFilesRecursive dir);

	mkHost = {
		extraOpts ? {},
		extraModules ? [],
		extraSpecialArgs ? {},
		system ? "x86_64-linux",
	}:
		lib.nixosSystem {
			inherit system;
			specialArgs = {inherit inputs;} // extraSpecialArgs;

			modules =
				[
					../modules/config.nix
					{
						my = extraOpts;
						nixpkgs.overlays = import ../overlays {inherit inputs;};
						system.stateVersion = "25.05";
					}

					../systems/${extraOpts.host.name}/host.nix
					../systems/${extraOpts.host.name}/hardware.nix

					inputs.age.nixosModules.age
					inputs.home.nixosModules.home-manager
					{
						home-manager = {
							useGlobalPkgs = true;
							useUserPackages = true;
							users.${extraOpts.user.name} = {
								home.stateVersion = "25.05";
								imports = [../systems/${extraOpts.host.name}/home.nix];
							};
						};
					}

					(lib.mkAliasOptionModule ["hm"] ["home-manager" "users" extraOpts.user.name])
				]
				++ extraModules;
		};

	supportedSystems = [
		"aarch64-linux"
		"x86_64-linux"
	];
	forAllSystems = lib.genAttrs supportedSystems;
}
