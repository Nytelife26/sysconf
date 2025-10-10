{
	config,
	pkgs,
	lib,
	...
}: {
	options.my.wm = {
		enable = lib.mkEnableOption "window manager configuration.";
		notify = lib.mkEnableOption "notifications.";
		portals = {
			enable = lib.mkEnableOption "XDG portals.";
			# extraPortals = {
			# 	type = lib.types.listOf lib.types.package;
			# 	default = with pkgs; [
			# 		xdg-desktop-portal-gtk
			# 		xdg-desktop-portal-wlr
			# 	];
			# 	description = "XDG portals to use.";
			# };
		};
	};

	config =
		lib.mkIf config.my.wm.enable {
			security.polkit.enable = true;

			programs.dconf.enable = true;

			services.libinput.enable = true;

			hardware.graphics.enable = true;

			hm = {
				home = {
					packages = with pkgs; [
						wl-clipboard
						clipman
						shotman
						fira-code-symbols
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

					portal = let
						extraPortals = with pkgs; [
							xdg-desktop-portal-gtk
							xdg-desktop-portal-wlr
						];
					in
						lib.mkIf config.my.wm.portals.enable {
							enable = true;
							xdgOpenUsePortal = true;

							inherit extraPortals;
							configPackages = [pkgs.xdg-desktop-portal] ++ extraPortals;
						};
				};

				services =
					lib.mkIf config.my.wm.notify {
						fnott.enable = true;
						lorri.enableNotifications = true;
					};

				programs = {
					alacritty = {
						enable = true;
						settings.window = {
							decorations = "None";
							padding = {
								x = 20;
								y = 20;
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
						terminal = "! (alacritty msg create-window) && alacritty";
						input."*" = {
							xkb_layout = "gb";
							tap = "enabled";
							natural_scroll = "enabled";
						};
						seat."*".hide_cursor = "1000";
						gaps.inner = 20;
						startup = [{command = "--no-startup-id ${pkgs.swayalt}/bin/swayalt";}];
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
			};
		};
}
