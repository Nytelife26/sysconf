{
	config,
	pkgs,
	lib,
	...
}: {
	options.my.style = lib.mkEnableOption "theme configuration.";

	config =
		lib.mkIf config.my.style {
			stylix = {
				autoEnable = true;
				enable = true;
				base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
				image = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.src;
				fonts = {
					sizes.applications = 11;
					serif = {
						package = pkgs.source-serif;
						name = "Source Serif";
					};
					sansSerif = {
						package = pkgs.fira-math;
						name = "Fira Math";
					};
					monospace = {
						package = pkgs.nerd-fonts.fira-code;
						name = "FiraCode Nerd Font";
					};
					emoji = {
						package = pkgs.twitter-color-emoji;
						name = "Twitter Color Emoji";
					};
				};
				opacity.terminal = 0.9;
				targets.nixvim.enable = false;
				polarity = "dark";
				cursor = {
					name = "catppuccin-mocha-pink-cursors";
					package = pkgs.catppuccin-cursors.mochaPink;
					size = 20;
				};
			};
			hm.stylix.targets.kde.enable = false;
		};
}
