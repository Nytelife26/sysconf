{
	inputs,
	homePath,
	...
}: {
	autoStart = true;

	bindMounts = {
		"/var/www".hostPath = "${homePath}/www";
		"/var/lib/caddy" = {
			hostPath = "${homePath}/caddy";
			isReadOnly = false;
		};
		"/etc/ssh/ssh_host_ed25519_key".hostPath = "/etc/ssh/ssh_host_ed25519_key";
	};

	config = {
		config,
		pkgs,
		...
	}: {
		imports = [../modules/minsys.nix ../modules/age.nix inputs.age.nixosModules.age];

		age.secrets."cf-api".file = ../secrets/cf-api.age;

		services.caddy = {
			enable = true;
			package =
				pkgs.caddy.withPlugins {
					plugins = ["github.com/caddy-dns/cloudflare@v0.2.1"];
					hash = "sha256-p9AIi6MSWm0umUB83HPQoU8SyPkX5pMx989zAi8d/74=";
				};
			configFile = ./Caddyfile;
			environmentFile = config.age.secrets.cf-api.path;
		};

		networking.firewall.allowedTCPPorts = [80 443];
	};
}
