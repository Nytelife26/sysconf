{
	inputs,
	homePath,
	hostMap,
	...
}: {
	bindMounts."/var/lib/continuwuity" = {
		hostPath = "${homePath}/continuwuity/data";
		isReadOnly = false;
	};

	config = {pkgs, ...}: {
		nixpkgs.overlays = import ../overlays {inherit inputs;};

		services = {
			matrix-continuwuity = {
				enable = true;
				package = pkgs.unstable.matrix-continuwuity;
				settings.global = {
					server_name = "kludgecs.com";
					allow_registration = false;
					allow_encryption = true;
					allow_federation = true;
					trusted_servers = ["matrix.org" "techncs.de" "maunium.net"];
					address = builtins.attrValues hostMap.matrix;
				};
			};
		};

		networking = {
			firewall.allowedTCPPorts = [6167];
		};
	};
}
