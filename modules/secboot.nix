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
					autoGenerateKeys.enable = true;
					autoEnrollKeys = {
						enable = true;
						autoReboot = true;
					};
				};
				# NOTE: lanzaboote replaces systemd-boot for now (as of 1.0.0), review later
				loader = {
					systemd-boot.enable = lib.mkForce false;
					efi.canTouchEfiVariables = true;
				};
			};
		};
}
