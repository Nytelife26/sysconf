{lib, ...}: {
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
	};
}
