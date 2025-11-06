{
	config,
	pkgs,
	lib,
	...
}: let
	cfg = config.my.style;
	themes = {
		catppuccin-mocha = {
			base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
			image = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.src;
		};
		catppuccin-mocha-oled = {
			base16Scheme = {
				system = "base16";
				name = "Catppuccin Mocha OLED";
				author = "https://catppuccin.com";
				variant = "dark";
				palette = {
					base00 = "#000000"; # base
					base01 = "#010101"; # mantle
					base02 = "#313244"; # surface0
					base03 = "#45475a"; # surface1
					base04 = "#585b70"; # surface2
					base05 = "#cdd6f4"; # text
					base06 = "#f5e0dc"; # rosewater
					base07 = "#b4befe"; # lavender
					base08 = "#f38ba8"; # red
					base09 = "#fab387"; # peach
					base0A = "#f9e2af"; # yellow
					base0B = "#a6e3a1"; # green
					base0C = "#94e2d5"; # teal
					base0D = "#89b4fa"; # blue
					base0E = "#cba6f7"; # mauve
					base0F = "#f2cdcd"; # flamingo
				};
			};
			image =
				pkgs.fetchurl {
					url = "https://raw.githubusercontent.com/gytis-ivaskevicius/high-quality-nix-content/174f162cf06a02f7090986e19720487c19f39416/wallpapers/nix-glow-black.png";
					hash = "sha256-3AG1n3BrjR/iJVqiSZbj/ZeAZG+SB1zpGsTmY/SDFMk=";
				};
		};
	};
in {
	options.my.style = {
		enable = lib.mkEnableOption "theme configuration.";
		theme =
			lib.mkOption {
				description = "Name of the theme to use.";
				type = lib.types.enum ["catppuccin-mocha" "catppuccin-mocha-oled"];
				default = "catppuccin-mocha-oled";
			};
	};

	config =
		lib.mkIf cfg.enable {
			stylix = {
				autoEnable = true;
				enable = true;
				inherit (themes.${cfg.theme}) base16Scheme image;
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
