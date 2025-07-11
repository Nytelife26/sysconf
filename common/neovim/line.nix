_: {
	programs.nixvim.plugins.lualine = {
		enable = true;
		settings = {
			globalstatus = true;

			extensions = ["fzf"];
		};
	};
}
