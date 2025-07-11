_: {
	programs.nixvim.plugins = {
		lsp = {
			servers = {
				bacon_ls.enable = true;
				basedpyright.enable = true;
				nil_ls.enable = true;
				ruff.enable = true;
				rust_analyzer = {
					enable = true;

					installRustc = false;
					installCargo = false;
				};
				statix.enable = true;
				taplo.enable = true;
			};
		};
		lspconfig.enable = true;
		lsp-format.enable = true;
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
}
