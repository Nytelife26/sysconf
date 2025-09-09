{
	config,
	lib,
	...
}: {
	config =
		lib.mkIf config.my.neovim.enable {
			programs.nixvim.plugins.lualine = {
				enable = true;
				settings = {
					globalstatus = true;

					extensions = ["fzf"];
				};
			};
		};
}
