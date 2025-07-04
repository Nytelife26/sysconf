_: {
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
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
    bash = {
      enable = true;
      enableCompletion = true;

      historyControl = [
        "ignorespace"
        "erasedups"
      ];

      shellOptions = [
        "histappend"
        "cmdhist"
        "lithist"
        "histreedit"
        "histverify"
        "globstar"
        "direxpand"
        "cdspell"
        "checkwinsize"
        "dotglob"
        "extglob"
        "nocasematch"
      ];
    };
  };
}
