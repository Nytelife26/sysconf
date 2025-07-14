{
	description = "nixos config yippee";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		hardware.url = "github:NixOS/nixos-hardware";
		hooks.url = "github:cachix/git-hooks.nix";

		home-manager = {
			url = "github:nix-community/home-manager/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		lanzaboote = {
			url = "github:nix-community/lanzaboote/v0.4.2";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		disko = {
			url = "github:nix-community/disko/v1.11.0";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		vim = {
			url = "github:nix-community/nixvim/nixos-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		stylix = {
			url = "github:nix-community/stylix/release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = {
		self,
		disko,
		hardware,
		home-manager,
		hooks,
		lanzaboote,
		vim,
		stylix,
		nixpkgs,
		nixpkgs-unstable,
		...
	} @ inputs: let
		lib = nixpkgs.lib // home-manager.lib;
		inherit (self) outputs;

		systems = [
			"aarch64-linux"
			"x86_64-linux"
		];

		forAllSystems = lib.genAttrs systems;

		mkSystem = host: system: extraModules:
			lib.nixosSystem {
				inherit system;
				specialArgs = {inherit inputs outputs;};
				modules = extraModules ++ [./hosts/${host}];
			};

		mkHome = user: system: extraModules:
			lib.homeManagerConfiguration {
				pkgs = nixpkgs.legacyPackages.${system};
				extraSpecialArgs = {inherit inputs outputs;};
				modules = extraModules ++ [./users/${user}];
			};
	in {
		overlays = import ./overlays {inherit inputs;};

		# `nixos-rebuild switch --flake .#hostname`
		nixosConfigurations = {
			lilium-2 =
				mkSystem "lilium-2" "x86_64-linux"
				[
					disko.nixosModules.disko
					lanzaboote.nixosModules.lanzaboote
					# This is required because Chromium cannot be configured by home-manager
					stylix.nixosModules.stylix
					hardware.nixosModules.common-pc-laptop
					hardware.nixosModules.common-cpu-intel
					hardware.nixosModules.common-pc-ssd
					hardware.nixosModules.asus-battery
				];
		};

		# `home-manager switch --flake .#username@hostname`
		homeConfigurations = {
			"lveneris@lilium-2" =
				mkHome "lveneris" "x86_64-linux"
				[
					vim.homeManagerModules.nixvim
					stylix.homeModules.stylix
				];
		};

		checks =
			forAllSystems (system: let
					lib = hooks.lib.${system};
				in {
					pre-commit-check =
						lib.run {
							src = ./.;
							hooks = {
								convco.enable = true;
								alejandra = {
									enable = true;
									package = nixpkgs.legacyPackages.${system}.alejandra;
								};
								statix = {
									enable = true;
									settings.ignore = ["/.direnv"];
								};
							};
						};
				});

		devShells =
			forAllSystems (system: let
					check = self.checks.${system}.pre-commit-check;
				in {
					default =
						nixpkgs.legacyPackages.${system}.mkShell {
							inherit (check) shellHook;
							buildInputs = check.enabledPackages;
						};
				});
	};
}
