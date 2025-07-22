{pkgs, ...}: {
	imports = [
		../../common/hm/home.nix
		../../common/hm/cli.nix
		../../common/neovim
		../../common/stylix.nix
		../../common/hm/stylix.nix

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
