{
	config,
	lib,
	pkgs,
	...
}: {
	options.my.audio = lib.mkEnableOption "audio configuration.";

	config =
		lib.mkIf config.my.audio {
			security.rtkit.enable = true;
			services.pipewire = {
				enable = true;
				alsa.enable = true;
				pulse.enable = true;
			};
			environment.systemPackages = [pkgs.pulseaudio];
		};
}
