{
	lib,
	config,
	inputs,
	...
}: let
	cfg = config.my.conman.containers.caddy;
in {
	options.my.conman.containers.caddy = {
		# TODO: future plans to make cloudflare and secretsFile optional?
		# would be good to improve secrets handling in container modules
		enable = lib.mkEnableOption "Caddy for routing.";
		dataDir = {
			container =
				lib.mkOption {
					type = lib.types.path;
					default = config.services.caddy.dataDir;
				};
			hostPath =
				lib.mkOption {
					type = lib.types.path;
					default = cfg.dataDir.container;
				};
		};
		apex =
			lib.mkOption {
				type = lib.types.nonEmptyStr;
				default = "kludgecs.com";
				description = ''
					Apex of the target domain (e.g. example.com). This is used for determining
					default locations in enabled compatible services.
				'';
			};
		secretsFile =
			lib.mkOption {
				type = lib.types.path;
				default = ../../secrets/cf-api.age;
				description = ''
					An Age-encrypted {option}`services.caddy.environmentFile`.

					This must at least provide a 'CF_API_KEY'.
				'';
			};
		www =
			lib.mkOption {
				type = lib.types.nullOr lib.types.path;
				default = null;
				description = "Location of a `www` directory to mount for ease of use.";
			};
	};

	config.containers.caddy =
		lib.mkIf cfg.enable {
			bindMounts =
				{
					${cfg.dataDir.container} = {
						inherit (cfg.dataDir) hostPath;
						isReadOnly = false;
					};
					"/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
				}
				// lib.optionalAttrs (cfg.www != null) {${cfg.www}.isReadOnly = true;};
			forwardPorts = [
				{hostPort = 80;}
				{hostPort = 443;}
			];
			config = {
				config,
				pkgs,
				...
			}: {
				imports = [../age.nix inputs.age.nixosModules.age];

				age.secrets.caddy-env.file = cfg.secretsFile;

				services.caddy = {
					dataDir = cfg.dataDir.container;
					enable = true;
					package =
						pkgs.caddy.withPlugins {
							plugins = ["github.com/caddy-dns/cloudflare@v0.2.2"];
							hash = "sha256-ea8PC/+SlPRdEVVF/I3c1CBprlVp1nrumKM5cMwJJ3U=";
						};
					environmentFile = config.age.secrets.caddy-env.path;
					globalConfig = ''
						admin off
						ocsp_stapling off
						acme_dns cloudflare {$CF_API_KEY}
					'';
				};

				networking.firewall.allowedTCPPorts = [80 443];
			};
		};
}
