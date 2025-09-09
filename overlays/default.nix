{inputs, ...}: [
	(final: _: {
			unstable =
				import inputs.nixpkgs-unstable {
					inherit (final) system;
					config.allowUnfree = true;
				};
		})
	(final: _: {
			swayalt = inputs.swayalt.packages.${final.system}.default;
		})
]
