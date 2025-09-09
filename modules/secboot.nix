{
	config,
	pkgs,
	lib,
	...
}: {
	options.my.secboot = lib.mkEnableOption "secure boot configuration";

	config =
		lib.mkIf config.my.secboot {
			environment.systemPackages = [pkgs.sbctl];
			boot = {
				lanzaboote = {
					enable = true;
					pkiBundle = "/var/lib/sbctl";
				};
				# NOTE: lanzaboote replaces systemd-boot for now (as of 0.4.2), review later
				loader = {
					systemd-boot.enable = false;
					efi.canTouchEfiVariables = true;
				};
			};
		};
}
