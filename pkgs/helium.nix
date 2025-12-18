{
	lib,
	stdenv,
	fetchurl,
	appimageTools,
}: let
	pname = "helium";
	version = "0.7.6.1";

	architectures."x86_64-linux" = {
		arch = "x86_64";
		hash = "sha256-SUpXcyQXUjZR57pNabVR/cSrGOMKvgzW0PSCLdB8d+E=";
	};

	src = let
		inherit (architectures.${stdenv.hostPlatform.system}) arch hash;
	in
		fetchurl {
			url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${arch}.AppImage";
			inherit hash;
		};
in
	appimageTools.wrapType2 rec {
		inherit pname version src;

		extraInstallCommands = let
			contents = appimageTools.extractType2 {inherit pname version src;};
		in ''
			mkdir -p "$out/share/applications"
			mkdir -p "$out/share/lib/helium"
			cp -r ${contents}/opt/helium/locales "$out/share/lib/helium"
			cp -r ${contents}/usr/share/* "$out/share"
			cp "${contents}/${pname}.desktop" "$out/share/applications/"
			substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram} --enable-features=AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,UseOzonePlatform --ozone-platform=wayland --ignore-gpu-blocklist --enable-zero-copy --ozone-platform-hint=wayland'
		'';

		meta = {
			description = "Private, fast, and honest web browser based on Chromium";
			homepage = "https://github.com/imputnet/helium-chromium";
			changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
			platforms = ["x86_64-linux" "aarch64-linux"];
			license = lib.licenses.gpl3;
			mainProgram = "helium";
		};
	}
