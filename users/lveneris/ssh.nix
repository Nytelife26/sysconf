{pkgs, ...}: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_github";
      };
      "kludgecs.com" = {
        identityFile = "~/.ssh/id_rsa";
      };
    };
  };
}
