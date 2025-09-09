{
	config,
	lib,
	...
}: {
	options.my.networking = lib.mkEnableOption "network configuration";

	config.networking.networkmanager.enable = config.my.networking;
}
