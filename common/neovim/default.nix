{
	inputs,
	pkgs,
	...
}: {
	imports = [
		./cmp.nix
		./lsp.nix
		./line.nix
	];

	programs.nixvim = {
		enable = true;

		globals.mapleader = " ";
		colorscheme = "catppuccin-mocha";
		colorschemes.catppuccin.enable = true;
		# colorschemes.base16 = {
		# 	enable = true;
		# 	colorscheme = "catppuccin-mocha";
		# };

		clipboard = {
			register = "unnamedplus";
			providers.wl-copy.enable = true;
		};

		highlightOverride = {
			Normal.bg = "none";
			NormalNC.bg = "none";
			LineNr = {
				fg = "lightgrey";
				bold = true;
			};
			LineNrAbove.fg = "grey";
			LineNrBelow.fg = "grey";
		};

		keymaps = [
			{
				action = ":noh<LF>";
				key = "<Esc>";
				mode = "n";
				options.silent = true;
			}
			{
				action = "<Esc>";
				key = "jk";
				mode = "i";
			}
			{
				action = "<Nop>";
				key = "<Esc>";
				mode = "i";
			}
		];

		opts = {
			number = true;
			relativenumber = true;
			termguicolors = true;
			scrolloff = 10;

			smartindent = true;
			softtabstop = 4;
			shiftwidth = 4;
			tabstop = 4;
			expandtab = false;

			wrap = false;
			linebreak = false;

			autoread = true;
			lazyredraw = true;

			undofile = true;

			splitbelow = true;
			splitright = true;
		};

		performance.byteCompileLua = {
			enable = true;
			configs = true;
			plugins = true;
			nvimRuntime = true;
		};

		plugins = {
			coq-nvim.enable = true;
			colorizer.enable = true;
			nvim-autopairs.enable = true;
			telescope = {
				enable = true;
				extensions.fzf-native.enable = true;
			};
			treesitter.enable = true;
			web-devicons.enable = true;
		};
	};
}
