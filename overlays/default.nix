{inputs, ...}: [
	(final: _: {
			unstable =
				import inputs.nixpkgs-unstable {
					inherit (final.stdenv.hostPlatform) system;
					config.allowUnfree = true;
				};
		})
	(final: _: {
			swayalt = inputs.swayalt.packages.${final.stdenv.hostPlatform.system}.default;
		})
]
