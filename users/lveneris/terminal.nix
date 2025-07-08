{pkgs, ...}: {
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      _1password-cli
      ;
  };
  programs = {
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    git = {
      userName = "Nytelife26";
      userEmail = "xtylerjrx@gmail.com";
      signing = {
        key = "~/.ssh/id_github";
        format = "ssh";
        signByDefault = true;
      };

      extraConfig = {
        color.ui = "auto";
        pull.rebase = true;
      };

      delta.enable = true;
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    gpg.enable = true;
  };
}
