{
	config,
	pkgs,
	lib,
	...
}: {
	options.my.battery = lib.mkEnableOption "battery and power management tools.";

	config =
		lib.mkIf config.my.battery {
			environment.systemPackages = with pkgs; [
				acpi
				powertop
			];
			powerManagement.powertop.enable = true;

			services = {
				upower.enable = true;
				tlp.enable = true;
			};
		};
}
