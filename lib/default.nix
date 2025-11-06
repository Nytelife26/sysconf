{
	nixpkgs,
	inputs,
	...
}: let
	inherit (nixpkgs) lib;
in rec {
	setMany = attrs: keys:
		builtins.listToAttrs (builtins.map (name: lib.nameValuePair name attrs) keys);

	containersToHostMap = {
		containers,
		base4 ? "192.168.1.",
		base6 ? "fc80::",
		offset4 ? 10,
		offset6 ? 0,
	}:
		builtins.listToAttrs (lib.imap (idx: name: let
					final4 = builtins.toString (offset4 + idx);
					final6 = lib.toLower (lib.toHexString (offset6 + idx));
				in
					lib.nameValuePair name {
						localAddress = "${base4}${final4}";
						localAddress6 = "${base6}${final6}";
					})
			containers);
	hostMapToHosts = hostMap:
		lib.concatMapAttrs
		(host: addrs: {
				${addrs.localAddress} = ["${host}.local" host];
				${addrs.localAddress6} = ["${host}.local" host];
			})
		hostMap;

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
