{
	imports = [
		../../modules/neovim
		../../modules/style.nix

		../../modules/network.nix
		../../modules/bat.nix
		../../modules/tpm.nix
		../../modules/secboot.nix

		../../modules/shell.nix
		../../modules/audio.nix
		../../modules/wm.nix
	];

	my = {
		neovim.enable = true;

		audio = true;
		battery = true;
		networking = true;
		secboot = true;
		shell = {
			enable = true;
			extended = true;
			useNu = true;
		};
		style = true;
		tpm = true;
		wm = {
			enable = true;
			notify = true;
			portals.enable = true;
		};
	};
}
