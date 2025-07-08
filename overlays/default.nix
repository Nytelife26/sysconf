{inputs, ...}: {
	unstable-pkgs = final: _: {
		unstable =
			import inputs.nixpkgs-unstable {
				inherit (final) system;
				config.allowUnfree = true;
			};
	};
}
