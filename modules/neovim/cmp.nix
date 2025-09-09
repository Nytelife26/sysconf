{
	config,
	lib,
	...
}: {
	config =
		lib.mkIf config.my.neovim.enable {
			programs.nixvim.plugins = {
				cmp = {
					enable = true;
					settings = {
						autoEnableSources = true;
						experimental.ghost_text = true;
						snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
						formatting.fields = ["abbr" "kind" "menu"];
						sources = [
							{name = "nvim_lsp";}
							{
								name = "buffer";
								keywordLength = 3;
							}
							{name = "path";}
							{name = "luasnip";}
						];
						window = {
							completion = {
								border = "rounded";
								winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None";
								zindex = 1001;
								scrolloff = 0;
								colOffset = 0;
								sidePadding = 1;
								scrollbar = true;
							};
							documentation = {
								border = "rounded";
								winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None";
								zindex = 1001;
								maxHeight = 20;
								scrollbar = true;
							};
						};
						mapping = {
							"<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
							"<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
							"<C-e>" = "cmp.mapping.abort()";
							"<C-b>" = "cmp.mapping.scroll_docs(-4)";
							"<C-f>" = "cmp.mapping.scroll_docs(4)";
							"<C-Space>" = "cmp.mapping.complete()";
							"<CR>" = "cmp.mapping.confirm({ select = true })";
							"<S-CR>" = "cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })";
						};
					};
				};
				cmp-buffer.enable = true;
				cmp-cmdline.enable = true;
				cmp-nvim-lsp.enable = true;
				cmp-path.enable = true;
				lspkind = {
					enable = true;
					cmp = {
						enable = true;
						ellipsisChar = "…";
						maxWidth = 15;
						menu = {
							nvim_lsp = "[Lang]";
							path = "[Path]";
							buffer = "[Buff]";
							luasnip = "[Snip]";
						};
					};
				};
				luasnip.enable = true;
			};
		};
}
