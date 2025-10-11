{
	inputs,
	homePath,
	...
}: {
	bindMounts = {
		"/etc/ssh/ssh_host_ed25519_key".hostPath = "/etc/ssh/ssh_host_ed25519_key";
		"/var/lib/matrix-ooye" = {
			hostPath = "${homePath}/ooye";
			isReadOnly = false;
		};
	};

	config = {config, ...}: {
		imports = [../modules/age.nix inputs.ooye.modules.default inputs.age.nixosModules.age];

		age.secrets = {
			ooye-token.file = ../secrets/ooye-token.age;
			ooye-secret.file = ../secrets/ooye-secret.age;
		};

		services = {
			matrix-ooye = {
				enable = true;
				homeserver = "https://matrix.kludgecs.com";
				homeserverName = "kludgecs.com";
				discordTokenPath = config.age.secrets.ooye-token.path;
				discordClientSecretPath = config.age.secrets.ooye-secret.path;
				bridgeOrigin = "https://ooye.kludgecs.com";
			};
		};

		networking = {
			firewall.allowedTCPPorts = [6693];
		};
	};
}
