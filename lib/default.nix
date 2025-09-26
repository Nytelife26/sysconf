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
