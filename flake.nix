{
	description = "nixos config yippee";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
		hardware.url = "github:NixOS/nixos-hardware";

		age = {
			url = "github:ryantm/agenix";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.home-manager.follows = "home";
		};

		hooks = {
			url = "github:cachix/git-hooks.nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home = {
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

		ooye = {
			url = "git+https://cgit.rory.gay/nix/OOYE-module.git";
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

		swayalt = {
			url = "github:nytelife26/swayalt-rs";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.hooks.follows = "hooks";
		};
	};

	outputs = {
		self,
		disko,
		hardware,
		home,
		hooks,
		lanzaboote,
		vim,
		stylix,
		nixpkgs,
		nixpkgs-unstable,
		...
	} @ inputs: rec {
		lib = nixpkgs.lib // home.lib // (import ./lib {inherit nixpkgs inputs;});

		# `nixos-rebuild switch --flake .#hostname`
		nixosConfigurations = let
			user.name = "lveneris";
			git = {
				userName = "nytelife26";
				userEmail = "xtylerjrx@gmail.com";
			};
			extraSpecialArgs.tools = lib;
		in {
			lilium-2 =
				lib.mkHost {
					extraModules = [
						disko.nixosModules.disko
						lanzaboote.nixosModules.lanzaboote
						stylix.nixosModules.stylix
						vim.nixosModules.nixvim
						hardware.nixosModules.common-pc-laptop
						hardware.nixosModules.common-cpu-intel
						hardware.nixosModules.common-pc-ssd
						hardware.nixosModules.asus-battery
					];
					extraOpts = {
						host.name = "lilium-2";
						user =
							user
							// {
								extraGroups = ["wheel" "audio" "video" "networkmanager"];
							};
						git = git // {signing.enable = true;};
						gh = true;
						sshAgent = true;
					};
					inherit extraSpecialArgs;
				};
			sludge =
				lib.mkHost {
					extraModules = [
						disko.nixosModules.disko
						vim.nixosModules.nixvim
						hardware.nixosModules.common-pc
						hardware.nixosModules.common-cpu-amd
					];
					extraOpts = {
						host.name = "sludge";
						inherit user git;
					};
					inherit extraSpecialArgs;
				};
		};

		checks =
			lib.forAllSystems (system: let
					hooksLib = hooks.lib.${system};
				in {
					pre-commit-check =
						hooksLib.run {
							src = ./.;
							hooks = {
								convco.enable = true;
								alejandra.enable = true;
								statix = {
									enable = true;
									settings.ignore = ["/.direnv"];
								};
							};
						};
				});

		devShells =
			lib.forAllSystems (system: let
					check = self.checks.${system}.pre-commit-check;
					pkgs = nixpkgs.legacyPackages.${system};
				in {
					default =
						pkgs.mkShell {
							inherit (check) shellHook;
							buildInputs = check.enabledPackages ++ [pkgs.nil];
						};
				});

		formatter =
			lib.forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
	};
}
