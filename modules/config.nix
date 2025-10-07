{
	lib,
	pkgs,
	config,
	inputs,
	tools,
	...
}: {
	imports = [./minsys.nix];

	options.my = {
		host = {
			name =
				lib.mkOption {
					type = lib.types.str;
					description = "Hostname of the system.";
				};
			arch =
				lib.mkOption {
					type = lib.types.enum tools.supportedSystems;
					default = "x86_64-linux";
					description = "Architecture of the system.";
				};
		};
		user = {
			name =
				lib.mkOption {
					type = lib.types.str;
					description = "Username for host configuration.";
				};
			extraGroups =
				lib.mkOption {
					type = lib.types.listOf lib.types.str;
					default = ["wheel"];
					description = "Groups to assign to the user.";
				};
		};
		git = {
			userName =
				lib.mkOption {
					type = lib.types.str;
					default = "Username";
					description = "Username for git.";
				};
			userEmail =
				lib.mkOption {
					type = lib.types.str;
					default = "at@noreply.me";
					description = "Email address for git.";
				};
			signing = {
				enable = lib.mkEnableOption "Git signing via GPG with SSH.";
				key =
					lib.mkOption {
						type = lib.types.path;
						default = "/home/${config.my.user.name}/.ssh/id_git";
						description = "Path to the signing key to use.";
					};
			};
		};
		sshAgent = lib.mkEnableOption "the SSH agent.";
		gh = lib.mkEnableOption "the GitHub CLI.";
	};

	config = {
		nixpkgs = {
			hostPlatform = config.my.host.arch;
			config = {
				allowUnfree = true;
				allowUnfreePredicate = _: true;
			};
		};
		nix = {
			channel.enable = false;
			settings = {
				experimental-features = "nix-command flakes";
				auto-optimise-store = true;
			};
		};

		i18n.defaultLocale = "en_GB.UTF-8";
		time.timeZone = "Europe/London";

		networking.hostName = config.my.host.name;

		console = {
			earlySetup = true;
			font = "Lat2-Terminus16";
			keyMap = "uk";
		};

		programs = {
			git = {
				enable = true;
				config =
					lib.mkMerge [
						{init.defaultBranch = "main";}
						(lib.mkIf config.my.git.signing.enable {
								commit.gpgSign = true;
								tag.gpgSign = true;
								gpg.format = "ssh";
							})
					];
			};
			nh = {
				enable = true;
				clean = {
					enable = true;
					extraArgs = "--keep-since 7d --keep 5";
				};
			};
			ssh =
				lib.mkIf config.my.sshAgent {
					startAgent = true;
					extraConfig = ''
						AddKeysToAgent yes
					'';
				};
		};

		users.users.${config.my.user.name} = {
			uid = 1000;
			home = "/home/${config.my.user.name}";

			isNormalUser = true;
			initialPassword = "changeme";

			inherit (config.my.user) extraGroups;
		};

		environment.systemPackages =
			[pkgs.brightnessctl inputs.age.packages.${config.my.host.arch}.default]
			++ lib.optional (!config.my.neovim.enable) pkgs.neovim;

		hm = {
			manual.manpages.enable = false;
			programs = {
				home-manager.enable = true;
				man.enable = false;
				git = {
					enable = true;
					inherit (config.my.git) userName userEmail;
					signing =
						lib.mkIf config.my.git.signing.enable {
							inherit (config.my.git.signing) key;
							format = "ssh";
							signByDefault = true;
						};
					extraConfig = {
						color.ui = "auto";
						pull.rebase = true;
					};

					delta.enable = true;
				};
				gh =
					lib.mkIf config.my.gh {
						enable = true;
						settings.git_protocol = lib.mkIf config.my.sshAgent "ssh";
					};
				gpg.enable = config.my.git.signing.enable;
			};

			home = {
				homeDirectory = "/home/${config.my.user.name}";

				sessionVariables = {
					EDITOR = "nvim";
					MANPAGER = "nvim +Man!";
				};
			};
		};
	};
}
