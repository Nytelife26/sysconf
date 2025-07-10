{
	lib,
	pkgs,
	...
}: {
	home.packages = with pkgs; [sd unzip];
	services.lorri.enable = true;
	programs = {
		direnv = {
			enable = true;
			enableNushellIntegration = true;
			nix-direnv.enable = true;
			config.global.hide_env_diff = true;
		};

		git = {
			enable = true;
			ignores = [
				".direnv"
			];
		};

		bottom.enable = true;
		ripgrep.enable = true;
		fd.enable = true;
		bat.enable = true;
		fastfetch.enable = true;

		carapace = {
			enable = true;
			enableNushellIntegration = true;
		};
		nushell = {
			enable = true;
			settings = {
				buffer_editor = "nvim";
				show_banner = false;
			};
			environmentVariables = {
				# TODO: read this and other entries from `environment.extraInit`
				# this is currently dependent on the value set by `programs.ssh.startAgent`
				SSH_AUTH_SOCK =
					lib.hm.nushell.mkNushellInline
					''$"($env.XDG_RUNTIME_DIR)/ssh-agent"'';
			};
		};
		starship = {
			enable = true;
			enableNushellIntegration = true;
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
}
