{
	description = "nixos config yippee";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		lanzaboote = {
			url = "github:nix-community/lanzaboote/v1.0.0";
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
			url = "github:nix-community/nixvim/nixos-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		stylix = {
			url = "github:nix-community/stylix/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		swayalt = {
			url = "git+https://rad.kludgecs.com/z3GvbEBNDHEM6s8jZYWbrvYrvmBxk.git";
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
		...
	} @ inputs: rec {
		lib = nixpkgs.lib // home.lib // (import ./lib {inherit nixpkgs inputs self;});

		# `nixos-rebuild switch --flake .#hostname`
		nixosConfigurations = let
			user.name = "lveneris";
			git.user = {
				name = "lveneris";
				email = "tyler@kludgecs.com";
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
			lib.forAllSystems ({
					pkgs,
					system,
					...
				}: {
					pre-commit-check =
						hooks.lib.${system}.run {
							src = ./.;
							package = pkgs.prek;
							hooks =
								{
									statix = {
										enable = true;
										settings.ignore = ["/.direnv"];
									};
								}
								// lib.setMany {enable = true;} ["convco" "alejandra"];
						};
				});

		devShells =
			lib.forAllSystems ({
					pkgs,
					check,
					...
				}: {
					default =
						pkgs.mkShell {
							inherit (check) shellHook;
							buildInputs = check.enabledPackages ++ [pkgs.nil pkgs.nixd];
						};
				});

		formatter = lib.forAllSystems ({pkgs, ...}: pkgs.alejandra);
	};
}
