{pkgs, ...}: {
	imports = [
		../../common/hm/home.nix
		../../common/hm/cli.nix
		../../common/neovim

		./terminal.nix
		./ssh.nix
		./desktop.nix
	];

	home = let
		username = "lveneris";
	in {
		inherit username;
		homeDirectory = "/home/${username}";
	};
}
