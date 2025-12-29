{
	config,
	pkgs,
	lib,
	tools,
	...
}: let
	cfg = config.my.wm;
	createHeliumExtension = tools.createChromiumExtensionFor (lib.versions.major pkgs.my.helium.chromiumVersion);
in {
	options.my.wm = {
		enable = lib.mkEnableOption "window manager configuration.";
		notify = lib.mkEnableOption "notifications.";
		portals = {
			enable = lib.mkEnableOption "XDG portals.";
			extraPortals =
				lib.mkOption {
					type = lib.types.listOf lib.types.package;
					default = with pkgs; [
						xdg-desktop-portal-gtk
						xdg-desktop-portal-wlr
					];
					description = "XDG portals to use.";
				};
		};
	};

	config =
		lib.mkIf cfg.enable {
			security.polkit.enable = true;

			programs.dconf.enable = true;

			services.libinput.enable = true;

			hardware.graphics.enable = true;

			environment.pathsToLink = lib.optionals cfg.portals.enable ["/share/xdg-desktop-portal" "/share/applications"];

			hm = {
				home = {
					packages = with pkgs;
						[
							wl-clipboard
							clipman
							shotman
							fira-code-symbols
						]
						++ lib.optional cfg.notify pkgs.libnotify;
					sessionVariables = {
						BROWSER = lib.getExe pkgs.my.helium;
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

					portal =
						lib.mkIf cfg.portals.enable {
							enable = true;
							xdgOpenUsePortal = true;

							inherit (cfg.portals) extraPortals;
							configPackages = [pkgs.xdg-desktop-portal] ++ cfg.portals.extraPortals;
						};
				};

				services =
					lib.mkIf cfg.notify {
						fnott = {
							enable = true;
							settings.main = {
								max-timeout = 3;
								idle-timeout = 10;
							};
						};
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
					chromium = {
						enable = true;
						package = pkgs.my.helium;
						# TODO: the following does not yet work for helium

						# extensions = [
						# 	(createHeliumExtension {
						# 		# Bitwarden
						# 		id = "nngceckbapebfimnlniiiahkandclblb";
						# 		sha256 = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=";
						# 		version = "2025.12.0";
						# 	})
						# ];
					};
				};

				wayland.windowManager.sway = {
					enable = true;
					systemd.enable = true;
					xwayland = false;
					package = pkgs.swayfx;
					checkConfig = false;
					config = rec {
						bars = [];
						window = {
							border = 0;
							titlebar = false;
						};
						modifier = "Mod1";
						terminal = let
							alacritty = lib.getExe pkgs.alacritty;
						in "! (${alacritty} msg create-window) && alacritty";
						input."*" = {
							xkb_layout = "gb";
							tap = "enabled";
							natural_scroll = "enabled";
						};
						seat."*".hide_cursor = "1000";
						gaps.inner = 20;
						startup = [{command = "--no-startup-id '${lib.getExe pkgs.swayalt}'";}];
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
								"${modifier}+d" = "exec '${lib.getExe' pkgs.wmenu "wmenu-run"}'";
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
