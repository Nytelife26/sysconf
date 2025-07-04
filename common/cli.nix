_: {
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

    ripgrep.enable = true;
    fd.enable = true;
    bat.enable = true;
    fastfetch.enable = true;

    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    nushell = {
      enable = true;
    };
  };
}
