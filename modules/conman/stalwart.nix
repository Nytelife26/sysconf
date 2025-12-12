{
	config,
	lib,
	inputs,
	...
}: let
	cfg = config.my.conman.containers.stalwart;
	inherit (config.my.conman) hostMap;
	inherit (config.my.conman) containers;
	apexDomain = containers.caddy.apex;
	# TODO: make this more robust - caddy also uses ZeroSSL, or other endpoints
	# see services.caddy.acmeCA
	certsPath = "${containers.caddy.dataDir.hostPath}/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
in {
	options.my.conman.containers.stalwart = {
		enable = lib.mkEnableOption "Stalwart for mail and collaboration.";

		dataDir = {
			container =
				lib.mkOption {
					type = lib.types.path;
					default = config.services.stalwart-mail.dataDir;
				};
			hostPath =
				lib.mkOption {
					type = lib.types.path;
					default = cfg.dataDir.container;
				};
		};

		secretsFile =
			lib.mkOption {
				type = lib.types.path;
				default = ../../secrets/mail-secrets.age;
			};

		targetDomain =
			lib.mkOption {
				type = lib.types.str;
				default = "mail.${apexDomain}";
			};
	};

	config =
		lib.mkIf cfg.enable {
			assertions = [
				{
					assertion = containers.caddy.enable;
					message = "The Stalwart container currently requires Caddy to function.";
				}
			];

			containers =
				{
					stalwart = {
						bindMounts = {
							${cfg.dataDir.container} = {
								inherit (cfg.dataDir) hostPath;
								isReadOnly = false;
							};
							"/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
							"/var/lib/certs/${cfg.targetDomain}".hostPath = "${certsPath}/${cfg.targetDomain}";
							"/var/lib/certs/autoconfig.${apexDomain}".hostPath = "${certsPath}/autoconfig.${apexDomain}";
							"/var/lib/certs/autodiscover.${apexDomain}".hostPath = "${certsPath}/autodiscover.${apexDomain}";
						};
						forwardPorts = [
							{hostPort = 25;}
							{hostPort = 465;}
							{hostPort = 993;}
						];
						config = {config, ...}: {
							imports = [../age.nix inputs.age.nixosModules.age];

							users = {
								groups.caddy.gid = config.ids.gids.caddy;
								users.caddy = {
									group = "caddy";
									uid = config.ids.uids.caddy;
									isSystemUser = true;
								};
							};

							age.secrets.mail-secrets.file = cfg.secretsFile;

							systemd.services.stalwart-mail.serviceConfig = {
								User = lib.mkForce "caddy";
								Group = lib.mkForce "caddy";
								EnvironmentFile = [config.age.secrets.mail-secrets.path];
							};

							services.stalwart-mail = {
								enable = true;
								dataDir = cfg.dataDir.container;
								settings = {
									server = {
										hostname = cfg.targetDomain;
										proxy.trusted-networks = builtins.attrValues hostMap.caddy;
										tls = {
											enable = true;
											implicit = false;
											certificate = "default";
										};
										listener = {
											smtp = {
												protocol = "smtp";
												bind = "[::]:25";
											};
											jmap = {
												protocol = "http";
												bind = "[::]:443";
												tls.implicit = true;
											};
											smtps = {
												protocol = "smtp";
												bind = "[::]:465";
												tls.implicit = true;
											};
											imaps = {
												protocol = "imap";
												bind = "[::]:993";
												tls.implicit = true;
											};
										};
									};
									certificate = {
										default = {
											cert = "%{file:/var/lib/certs/${cfg.targetDomain}/${cfg.targetDomain}.crt}%";
											private-key = "%{file:/var/lib/certs/${cfg.targetDomain}/${cfg.targetDomain}.key}%";
											default = true;
										};
										autoconfig = {
											cert = "%{file:/var/lib/certs/autoconfig.${apexDomain}/autoconfig.${apexDomain}.crt}%";
											private-key = "%{file:/var/lib/certs/autoconfig.${apexDomain}/autoconfig.${apexDomain}.key}%";
										};
										autodiscover = {
											cert = "%{file:/var/lib/certs/autodiscover.${apexDomain}/autodiscover.${apexDomain}.crt}%";
											private-key = "%{file:/var/lib/certs/autodiscover.${apexDomain}/autodiscover.${apexDomain}.key}%";
										};
									};
									authentication.fallback-admin = {
										user = "webadmin";
										secret = "%{env:FALLBACK_ADMIN}%";
									};
									form = {
										enable = true;
										max-size = 4096;
										validate-domain = true;
										rate-limit = "60/1h";
										deliver-to = ["contact@${apexDomain}"];
										email.field = "email";
										name.field = "name";
										honey-pot.field = "botcheck";
										subject = {
											field = "subject";
											default = "Enquiry";
										};
									};
								};
								credentials = {};
							};

							# NOTE: SMTP, HTTPS, SMTPS, IMAPS
							networking.firewall.allowedTCPPorts = [25 443 465 993 8080];
						};
					};
				}
				// lib.optionalAttrs containers.caddy.enable {
					caddy.config.services.caddy = {
						email = "admin@${cfg.targetDomain}";
						extraConfig = ''
							(stalwart-transport) {
								transport http {
									proxy_protocol v2
									tls_server_name ${cfg.targetDomain}
								}
							}
						'';
						virtualHosts = {
							${cfg.targetDomain}.extraConfig = ''
								@form {
									method POST
									path /form
								}

								reverse_proxy @form https://stalwart:443 {
									import stalwart-transport

									@pass status 200
									@fail status 4xx

									handle_response @pass {
									 	redir {query.redirect}
									}
									handle_response @fail {
										header +Location {query.redirect_err}
										copy_response 302
									}
								}

								reverse_proxy https://stalwart:443 {
									import stalwart-transport
								}
							'';
							"autoconfig.${apexDomain}" = {
								serverAliases = ["autodiscover.${apexDomain}"];
								extraConfig = ''
									@autoconfig {
										path /.well-known/mail-v1.xml
										path /.well-known/autoconfig/mail/config-v1.1.xml
										path /mail/config-v1.1.xml
										path /autodiscover/autodiscover.xml
										path /robots.txt
									}

									reverse_proxy @autoconfig https://stalwart:443 {
										import stalwart-transport
									}
								'';
							};
						};
					};
				};
		};
}
