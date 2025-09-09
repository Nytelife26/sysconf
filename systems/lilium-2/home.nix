{
	programs.ssh = {
		enable = true;
		matchBlocks = {
			"github.com".identityFile = "~/.ssh/id_git";
			"kludgecs.com".identityFile = "~/.ssh/id_rsa";
		};
	};
}
