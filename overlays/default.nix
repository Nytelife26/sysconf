{inputs, ...}: {
	unstable-pkgs = final: _: {
		unstable =
			import inputs.nixpkgs-unstable {
				inherit (final) system;
				config.allowUnfree = true;
			};
	};
	swayalt = final: _: {
		swayalt = inputs.swayalt.packages.${final.system}.default;
	};
}
