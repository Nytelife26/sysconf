{
  outputs,
  pkgs,
  ...
}: {
  programs.ssh = {
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [outputs.overlays.unstable-pkgs];
  };
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };
  };

  i18n.defaultLocale = "en_GB.UTF-8";
  time = {
    timeZone = "Europe/London";
    hardwareClockInLocalTime = true;
  };

  networking.networkmanager.enable = true;

  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  programs = {
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        commit.gpgSign = true;
        tag.gpgSign = true;
        gpg.format = "ssh";
      };
    };
    nano.enable = false;
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };

  environment.defaultPackages = [];
  environment.systemPackages = with pkgs; [
    vim
    neovim
    home-manager
  ];
  documentation.nixos.enable = false;
}
