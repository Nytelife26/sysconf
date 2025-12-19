{
	lib,
	stdenv,
	fetchurl,
	alsa-lib,
	at-spi2-atk,
	autoPatchelfHook,
	cups,
	expat,
	gtk4,
	libxkbcommon,
	makeWrapper,
	nspr,
	nss,
	qt6,
	systemd,
	xorg,
	commandLineArgs ? "--enable-features=AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,UseOzonePlatform --ozone-platform=wayland --ignore-gpu-blocklist --enable-zero-copy --ozone-platform-hint=wayland",
}: let
	pname = "helium";
	version = "0.7.6.1";

	architectures = {
		x86_64-linux = {
			arch = "x86_64_linux";
			sha256 = "sha256-RL0MMsYmcboZt7aq2R/6onLX1bTxlEbhlwB7yBb84os=";
		};
		aarch64-linux = {
			arch = "arm64_linux";
			sha256 = "sha256-tkqUGCSBcUEpLrAlbJ9AtwjYSwcBchx/p5acBrp6Wrk=";
		};
	};

	src = let
		inherit (architectures.${stdenv.hostPlatform.system}) arch sha256;
	in
		fetchurl {
			url = "https://github.com/imputnet/helium-linux/releases/download/${version}/${pname}-${version}-${arch}.tar.xz";
			inherit sha256;
		};
in
	stdenv.mkDerivation {
		pname = "${pname}-bin";
		inherit version src;

		nativeBuildInputs = [
			autoPatchelfHook
			makeWrapper
		];

		buildInputs = [
			alsa-lib
			at-spi2-atk
			cups
			expat
			gtk4
			libxkbcommon
			nspr
			nss
			qt6.qtbase
			qt6.qtwayland
			stdenv.cc.cc.lib
			systemd
			xorg.libX11
			xorg.libXcomposite
			xorg.libXdamage
			xorg.libXext
			xorg.libXfixes
			xorg.libXrandr
			xorg.libxcb
		];

		autoPatchelfIgnoreMissingDeps = ["libQt5*.so.5"];
		dontWrapQtApps = true;

		buildPhase = ''
			runHook preBuild

			mkdir -p $out/{bin,libexec/helium,share/applications,share/icons/hicolor/256x256/apps}
			cp -r * $out/libexec/helium

			makeWrapper $out/libexec/helium/chrome $out/bin/helium \
				--add-flags ${lib.escapeShellArg commandLineArgs}
			ln -s $out/bin/helium $out/bin/chromium

			patchelf --add-needed libEGL.so.1 $out/libexec/helium/lib*GL*
			rm $out/libexec/helium/libvulkan.so.1
			patchelf --add-needed libvulkan.so.1 $out/libexec/helium/lib*GL*

			ln -s $out/libexec/helium/helium.desktop $out/share/applications/helium.desktop
			ln -s $out/libexec/helium/product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png

			runHook postBuild
		'';

		meta = {
			description = "Private, fast, and honest web browser based on Chromium";
			homepage = "https://helium.computer";
			changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
			platforms = ["x86_64-linux" "aarch64-linux"];
			license = lib.licenses.gpl3;
			mainProgram = "helium";
			sourceProvenance = [lib.sourceTypes.binaryNativeCode];
		};
	}
