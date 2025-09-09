{
	config,
	pkgs,
	lib,
	...
}: {
	imports = [
		./cmp.nix
		./lsp.nix
		./line.nix
	];

	options.my.neovim.enable = lib.mkEnableOption "a full neovim configuration.";

	config =
		lib.mkIf config.my.neovim.enable {
			programs.nixvim = {
				enable = true;
				viAlias = true;
				vimAlias = true;
				defaultEditor = true;

				globals.mapleader = " ";
				colorscheme = "catppuccin-mocha";
				colorschemes.catppuccin = {
					enable = true;
					settings = {
						transparent_background = true;
						integrations.notify = true;
					};
				};
				# colorschemes.base16 = {
				# 	enable = true;
				# 	colorscheme = "catppuccin-mocha";
				# };

				clipboard = {
					register = "unnamedplus";
					providers.wl-copy.enable = true;
				};

				highlightOverride = {
					LineNr = {
						fg = "#bac2de";
						bold = true;
					};
					LineNrAbove.fg = "#7f849c";
					LineNrBelow.fg = "#7f849c";
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
					colorizer.enable = true;
					telescope = {
						enable = true;
						extensions.fzf-native.enable = true;
					};
					treesitter = {
						enable = true;
						grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
							nix
							toml
							markdown
							markdown_inline
							nu
							typescript
							json
							yaml
							rust
							vim
							regex
							lua
							bash
						];
						settings.indent.enable = true;
					};
					nvim-autopairs.enable = true;
					notify.enable = true;
					todo-comments.enable = true;
					indent-blankline = {
						enable = true;
						settings = {
							indent.char = "▏";
							scope = {
								enabled = true;
								show_start = false;
								show_end = false;
							};
						};
					};
					mini = {
						enable = true;
						mockDevIcons = true;
						modules = {
							icons = {};
							surround = {};
						};
					};
					gitsigns = {
						enable = true;
						settings = {
							signcolumn = true;
							signs = {
								add = {text = "│";};
								change = {text = "│";};
								changedelete = {text = "~";};
								delete = {text = "_";};
								topdelete = {text = "‾";};
								untracked = {text = "┆";};
							};
							watch_gitdir = {follow_files = true;};
						};
					};
				};
			};
		};
}
