{
	pkgs,
	lib,
	...
}: {
	home = {
		packages = with pkgs; [
			vesktop
			wl-clipboard
			clipman
			shotman
			fira-code-symbols
			qimgv
		];
		sessionVariables = {
			BROWSER = "chromium";
			NIXOS_OZONE_WL = 1;
		};
	};

	xdg = {
		enable = true;

		userDirs = {
			enable = true;

			documents = "$HOME/doc";
			download = "$HOME/dls";
			music = "$HOME/aud";
			pictures = "$HOME/img";
			videos = "$HOME/vid";
		};

		portal = {
			enable = true;
			xdgOpenUsePortal = true;

			extraPortals = with pkgs; [
				xdg-desktop-portal-gtk
				xdg-desktop-portal-wlr
			];

			configPackages = with pkgs; [
				xdg-desktop-portal-gtk
				xdg-desktop-portal-wlr
				xdg-desktop-portal
			];
		};
	};

	services = {
		fnott.enable = true;
		lorri.enableNotifications = true;
		unclutter.enable = true;
	};

	# dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

	programs = {
		alacritty = {
			enable = true;
			settings = {
				window = {
					decorations = "None";
					padding = {
						x = 20;
						y = 20;
					};
				};
			};
		};
		chromium.enable = true;
	};

	wayland.windowManager.sway = {
		enable = true;
		systemd.enable = true;
		package = pkgs.swayfx;
		checkConfig = false;
		config = rec {
			bars = [];
			window = {
				border = 0;
				titlebar = false;
			};
			modifier = "Mod1";
			terminal = "alacritty";
			input = {
				"*" = {
					xkb_layout = "gb";
					tap = "enabled";
					natural_scroll = "enabled";
				};
			};
			gaps = {
				inner = 20;
			};
			keybindings =
				lib.mkOptionDefault {
					# Brightness
					"XF86MonBrightnessDown" = "exec 'brightnessctl s 5%-'";
					"XF86MonBrightnessUp" = "exec 'brightnessctl s 5%+'";
					# Audio
					"XF86AudioRaiseVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ +2%'";
					"XF86AudioLowerVolume" = "exec 'pactl set-sink-volume @DEFAULT_SINK@ -2%'";
					"XF86AudioMute" = "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
					# Misc
					"${modifier}+Shift+e" = "exec 'swaymsg exit'";
				};
		};
		extraConfig = ''
			default_dim_inactive 0.2
			corner_radius 15
		'';
	};

	# xresources = {
	# 	path = "$HOME/.Xdefaults";
	# 	# TODO: colours
	# 	properties = {};
	# };
}
