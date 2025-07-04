{pkgs, ...}: {
  imports = [
    ../../common/home.nix
    ../../common/cli.nix
    ../../common/neovim

    ./terminal.nix
    ./ssh.nix
    ./desktop.nix
  ];

  home = let
    username = "lveneris";
  in {
    inherit username;
    homeDirectory = "/home/${username}";
    packages = builtins.attrValues {
      inherit
        (pkgs)
        pulseaudio
        qimgv
        sd
        unzip
        man-pages-posix
        man-pages
        ;
    };
  };
}
