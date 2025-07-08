{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    alacritty
    chromium
    vesktop
    wl-clipboard
    clipman
    shotman
    twemoji-color-font
    nerd-fonts.fira-code
    fira-code-symbols
  ];

  home.sessionVariables = {BROWSER = "chromium";};

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

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name = "mochaDark";
      package = pkgs.catppuccin-cursors;
      size = 16;
    };
  };

  services.fnott.enable = true;
  services.lorri.enableNotifications = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["FiraCode Nerd Font"];
      emoji = ["Twitter Color Emoji"];
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "None";
        padding = {
          x = 20;
          y = 20;
        };
      };
      font = {
        size = 12;
        normal = {family = "FiraCode Nerd Font";};
      };
    };
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
      output = {
        "*" = {
          bg = "${pkgs.nixos-artwork.wallpapers.catppuccin-mocha.src} fill";
          # bg = "#000000 solid_color";
        };
      };
      gaps = {
        inner = 20;
      };
      keybindings = lib.mkOptionDefault {
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
  };

  xresources = {
    path = "$HOME/.Xdefaults";
    # TODO: colours
    properties = {};
  };
}
