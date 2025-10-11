{
	inputs,
	homePath,
	...
}: {
	additionalCapabilities = ["CAP_NET_ADMIN"];

	forwardPorts = [
		{
			hostPort = 25;
			containerPort = 25;
		}
		{
			hostPort = 587;
			containerPort = 587;
		}
	];

	bindMounts = {
		"/etc/ssh/ssh_host_ed25519_key".hostPath = "/etc/ssh/ssh_host_ed25519_key";
		"/var/lib/matrix-postmoogle" = {
			hostPath = "${homePath}/mail/data";
			isReadOnly = false;
		};
		"/var/lib/certs".hostPath = "${homePath}/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
	};

	config = {config, ...}: {
		imports = [../modules/postmoogle.nix ../modules/age.nix inputs.age.nixosModules.age];

		age.secrets.mail-secrets.file = ../secrets/mail-secrets.age;

		users.users.caddy = {
			group = "caddy";
			uid = config.ids.uids.caddy;
			isSystemUser = true;
		};
		users.groups.caddy.gid = config.ids.gids.caddy;

		services = {
			matrix-postmoogle = {
				enable = true;
				user = "caddy";
				group = "caddy";
				environmentFiles = [config.age.secrets.mail-secrets.path];
				environment = {
					POSTMOOGLE_HOMESERVER = "https://matrix.kludgecs.com";
					POSTMOOGLE_LOGIN = "postmoogle";
					POSTMOOGLE_DOMAINS = "kludgecs.com";

					POSTMOOGLE_TLS_REQUIRED = "1";
					POSTMOOGLE_TLS_CERT = "/var/lib/certs/matrix.kludgecs.com/matrix.kludgecs.com.crt";
					POSTMOOGLE_TLS_KEY = "/var/lib/certs/matrix.kludgecs.com/matrix.kludgecs.com.key";

					POSTMOOGLE_MAILBOXES_ACTIVATION = "notify";
					POSTMOOGLE_ADMINS = "@lveneris:kludgecs.com";
				};
			};
		};

		networking = {
			firewall.allowedTCPPorts = [25 587];
		};
	};
}
