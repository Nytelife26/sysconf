{
	programs.ssh = {
		enable = true;
		enableDefaultConfig = false;
		matchBlocks = {
			"*" = {
				forwardAgent = false;
				addKeysToAgent = "yes";
			};
			"github.com".identityFile = "~/.ssh/id_git";
			"*.kludgecs.com" = {
				identityFile = "~/.ssh/id_kcs";
				forwardAgent = true;
			};
		};
	};
}
