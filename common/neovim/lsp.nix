{config, ...}: let
	inherit (config) lib;
in {
	programs.nixvim = {
		diagnostic.settings = {
			virtual_lines = true;
			severity_sort = true;
			float = {
				border = "rounded";
				source = "always";
			};
			signs.text = {
				ERROR = "";
				WARN = "";
				HINT = "󰌵";
				INFO = "";
			};
		};
		lsp = {
			luaConfig.pre = ''
				vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
					vim.lsp.handlers.hover,
					{ border = "rounded" }
				)

				vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
					vim.lsp.handlers.signature_help,
					{ border = "rounded" }
				)
			'';
			servers =
				builtins.listToAttrs (builtins.map (name: {
							inherit name;
							value = {
								enable = true;
								package = null;
							};
						}) [
						"basedpyright"
						"jsonls"
						"nil_ls"
						"nixd"
						"nushell"
						"ruff"
						"rust_analyzer"
						"statix"
						"taplo"
					]);
			keymaps = [
				# diagnostic
				{
					key = "<leader>E";
					action = lib.nixvim.mkRaw "function() vim.diagnostic.open_float() end";
				}
				{
					key = "[";
					action = lib.nixvim.mkRaw "function() vim.diagnostic.goto_prev() end";
				}
				{
					key = "]";
					action = lib.nixvim.mkRaw "function() vim.diagnostic.goto_next() end";
				}
				{
					key = "<leader>do";
					action = lib.nixvim.mkRaw "function() vim.diagnostic.setloclist() end";
				}
				# lspBuf
				{
					key = "K";
					lspBufAction = "hover";
				}
				{
					key = "gD";
					lspBufAction = "declaration";
				}
				{
					key = "gd";
					lspBufAction = "definition";
				}
				{
					key = "gr";
					lspBufAction = "references";
				}
				{
					key = "gI";
					lspBufAction = "implementation";
				}
				{
					key = "gy";
					lspBufAction = "type_definition";
				}
				{
					key = "<leader>ca";
					lspBufAction = "code_action";
				}
				{
					key = "<leader>cr";
					lspBufAction = "rename";
				}
			];
		};
		plugins = {
			lspconfig.enable = true;
			lsp-format.enable = true;
			lualine.settings.sections.lualine_x = ["lsp_status" "encoding" "filetype"];
			none-ls = {
				enable = true;
				enableLspFormat = true;

				sources = {
					code_actions = {
						gitsigns.enable = true;
						statix.enable = true;
					};
					diagnostics.statix.enable = true;
					formatting.alejandra.enable = true;
				};
			};
		};
	};
}
