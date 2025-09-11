{
	lib,
	pkgs,
	...
}: {
	config = {
		programs.nano.enable = false;

		environment = {
			defaultPackages = lib.mkForce [];
			systemPackages = [
				# Replace as much GNU software as possible
				(lib.hiPrio pkgs.uutils-coreutils-noprefix)
				(lib.hiPrio pkgs.uutils-findutils)
				# Currently disabled - incomplete
				# (lib.hiPrio pkgs.uutils-diffutils)
			];
		};
		documentation = {
			nixos.enable = false;
			man.enable = false;
			doc.enable = false;
			info.enable = false;
		};

		system.stateVersion = "25.05";
	};
}
