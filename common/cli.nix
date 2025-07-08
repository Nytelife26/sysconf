_: {
  services.lorri.enable = true;
  programs = {
    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      ignores = [
        ".direnv"
      ];
    };

    bottom.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    bat.enable = true;
    fastfetch.enable = true;

    nushell = {
      enable = true;
      settings = {
        buffer_editor = "nvim";
        show_banner = false;
      };
    };
  };
}
