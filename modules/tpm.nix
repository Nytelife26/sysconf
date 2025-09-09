{
	config,
	lib,
	...
}: {
	options.my.tpm = lib.mkEnableOption "TPM configuration.";

	config =
		lib.mkIf config.my.tpm {
			boot.initrd = {
				availableKernelModules = ["tpm"];
				# NOTE: this is required for tpm2 prompt on boot
				systemd.enable = true;
			};
			security.tpm2.enable = true;
		};
}
