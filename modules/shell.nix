{
	config,
	pkgs,
	lib,
	tools,
	...
}: let
	cfg = config.my.shell;
	shellOpts =
		if cfg.useNu
		then {
			shell = pkgs.nushell;
			name = "nushell";
			integration = "enableNushellIntegration";
			# TODO: factor settings out into separate modules?
			settings = {
				enable = true;
				settings = {
					buffer_editor = "nvim";
					show_banner = false;
				};
				environmentVariables =
					config.hm.home.sessionVariables
					// lib.optionalAttrs config.my.sshAgent {
						SSH_AUTH_SOCK =
							tools.hm.nushell.mkNushellInline
							''$"($env.XDG_RUNTIME_DIR)/ssh-agent"'';
					};
			};
		}
		else {
			shell = pkgs.bash;
			name = "bash";
			integration = "enableBashIntegration";
			settings = {
				enable = true;
				shellOptions = ["histappend" "nocasematch" "direxpand" "cmdhist" "lithist"];
			};
		};
in {
	options.my.shell = {
		enable = lib.mkEnableOption "a modern suite of CLI tools.";
		extended = lib.mkEnableOption "the full suite.";
		useNu = lib.mkEnableOption "Nu as the default shell.";
		useRadicle = lib.mkEnableOption "Radicle integration.";
	};

	config =
		lib.mkIf cfg.enable {
			my.git.signing =
				lib.optionalAttrs cfg.useRadicle {
					key = lib.mkDefault "/home/${config.my.user.name}/.radicle/keys/radicle";
				};
			users.users.${config.my.user.name}.shell = shellOpts.shell;

			hm = {
				home.packages = [pkgs.sd];

				services.lorri.enable = cfg.extended;

				programs = {
					${shellOpts.name} = shellOpts.settings;

					direnv =
						lib.mkIf cfg.extended {
							enable = true;
							${shellOpts.integration} = true;
							nix-direnv.enable = true;
							config.global.hide_env_diff = true;
						};
					delta = {
						enable = true;
						enableGitIntegration = true;
					};
					git = {
						enable = true;
						ignores = [
							".direnv"
							".envrc"
						];
					};
					radicle.enable = cfg.useRadicle;

					bottom.enable = true;
					ripgrep.enable = cfg.extended;
					fd.enable = cfg.extended;
					bat.enable = cfg.extended;
					fastfetch.enable = true;

					carapace =
						lib.mkIf cfg.extended {
							enable = true;
							${shellOpts.integration} = true;
							package = pkgs.carapace;
						};
					starship = {
						enable = true;
						${shellOpts.integration} = true;
						settings = {
							add_newline = false;
							format = "$username@\\[$hostname\\] $character$directory($git_branch$git_state )($git_status )";
							character = {
								error_symbol = "[»](bold red)";
								success_symbol = "[»](bold purple)";
							};
							directory.style = "bold blue";
							git_branch.format = "[$symbol$branch(:$remote_branch)]($style)";
							git_state = {
								format = "[\\($state( $progress_current/$progress_total)\\)]($style)";
								style = "bold cyan";
							};
							git_status.style = "bold yellow";
							hostname = {
								format = "[$hostname]($style)";
								style = "bold green";
								ssh_only = false;
							};
							username = {
								format = "[$user]($style)";
								style_root = "bold red";
								style_user = "bold white";
								show_always = true;
							};
						};
					};
				};
			};
		};
}
