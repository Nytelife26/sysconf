_: {
	programs.nixvim.plugins = {
		cmp = {
			enable = true;
			settings = {
				autoEnableSources = true;
				experimental.ghost_text = true;
				snippet.expand = "luasnip";
				formatting.fields = ["kind" "abbr" "menu"];
				sources = [
					{name = "nvim_lsp";}
					{
						name = "buffer";
						keywordLength = 3;
					}
					{
						name = "path";
						keywordLength = 3;
					}
					{
						name = "luasnip";
						keywordLength = 3;
					}
				];
				window = {
					completion.border = "solid";
					documentation.border = "solid";
				};
			};
		};
		cmp-buffer.enable = true;
		cmp-cmdline.enable = true;
		cmp_luasnip.enable = true;
		cmp-nvim-lsp.enable = true;
		cmp-path.enable = true;
		luasnip.enable = true;
	};
}
