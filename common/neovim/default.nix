{
	inputs,
	pkgs,
	...
}: {
	imports = [];

	programs.nixvim = {
		enable = true;

		globals.mapleader = " ";
		colorscheme = "catppuccin-mocha";
		colorschemes.catppuccin.enable = true;

		opts = {
			number = true;
			relativenumber = true;
			termguicolors = true;

			smartindent = true;
			softtabstop = 4;
			shiftwidth = 4;
			tabstop = 4;
			expandtab = false;

			wrap = false;
			linebreak = false;
		};
	};
}
