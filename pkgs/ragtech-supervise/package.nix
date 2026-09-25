{ stdenv, lib, fetchurl, autoPatchelfHook, unzip, dpkg
, sqlite, libGL, libpng, harfbuzz, fontconfig, xorg, systemdLibs }:

# Ragtech Supervise 8 (versão nova, ex-"beta" no site). Substitui o PoC
# antigo baseado em Supervise Personal 6.3, que não conhecia o OneUp Nitro
# (upstype.cfg revisão J era de 2018; Nitro é posterior). O 8 tem devices.xml
# com <device family="7" name="SENIUM/ONEUP"> e <family=10 name="NEP/TORO/
# INNERGIE/ONEUP">, então cobre a linha OneUp nativamente.
#
# Distribuição oficial é um .deb dentro de um .zip. O bundle é 100%
# self-contained: leva o próprio Qt5 (5.9.5), ncurses5, libX*, etc. em
# opt/supervise/lib/. autoPatchelfHook só precisa acertar o interpreter da
# glibc e apontar a search path pra esse lib/.
#
# Interface web em http://localhost:4470 (servida pelo supsvc).

stdenv.mkDerivation rec {
  pname = "ragtech-supervise";
  version = "8.10";

  src = fetchurl {
    url = "https://ragtech.com.br/downloads/softwares-supervise-beta/?id=7241&tsd=1";
    name = "supervise-${version}-0.x86_64.zip";
    hash = "sha256-doAdCDoUt+kLO7kLOBVUffIwqFOLi/4Lg1Q6ziD+rJc=";
  };

  nativeBuildInputs = [ autoPatchelfHook unzip dpkg ];

  # Só libc/libstdc++/libgcc_s vêm de fora — Qt5 e o resto estão bundled.
  # sqlite é necessário pro plugin Qt5Sql (monit.so grava histórico local).
  buildInputs = [
    stdenv.cc.cc.lib
    sqlite
    libGL       # Qt5Gui bundled linka contra
    libpng
    harfbuzz
    fontconfig  # Qt5XcbQpa
    xorg.libXfixes  # libXcursor bundled
    systemdLibs # libudev, para libusb
  ];

  # Plugins Qt bundled que a gente NÃO usa em modo headless (VNC, GTK theme,
  # printing) exigem libs que não temos e não valem a pena empacotar.
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Network.so.5"      # só o plugin VNC pede
    "libQt5PrintSupport.so.5" # só o plugin de printing pede
    "libcups.so.2"
    "libgtk-3.so.0" "libgdk-3.so.0" "libpango-1.0.so.0"
    "libgobject-2.0.so.0" "libglib-2.0.so.0"
    "libX11.so.6" "libfreetype.so.6"
    # appindicator (usado só pelo notifygui/systray; headless não precisa)
    "libindicator3.so.7" "libdbusmenu-gtk3.so.4" "libdbusmenu-glib.so.4"
    # gdk-pixbuf usado pelo libnotify (desktop notifications) — headless não precisa
    "libgdk_pixbuf-2.0.so.0"
    # Plugins EGL/KMS/framebuffer/touchscreen pra display embarcado (sem uso em desktop)
    "libQt5EglFSDeviceIntegration.so.5" "libQt5EglFsKmsSupport.so.5" "libdrm.so.2"
    "libgbm.so.1" "libmtdev.so.1" "libinput.so.10"
    # plugin JPEG do Qt exige libjpeg.so.8 (nixpkgs só tem libjpeg-turbo com
    # soname .62); web UI serve JPEGs como estáticos, não decodifica pelo Qt
    "libjpeg.so.8"
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    unzip -q $src
    dpkg-deb -x supervise-*.deb payload
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -a payload/opt $out/

    mkdir -p $out/bin
    for b in supsvc notifysvc shutsvc cloudsvc notifygui; do
      ln -s $out/opt/supervise/$b $out/bin/$b
    done

    # Guarda .desktop e web/ pra o módulo referenciar se quiser.
    mkdir -p $out/share
    cp -r payload/usr/share/applications $out/share/ 2>/dev/null || true

    runHook postInstall
  '';

  # Bundled Qt5 e amigos em opt/supervise/lib — autoPatchelf resolve tudo dali.
  preFixup = ''
    addAutoPatchelfSearchPath $out/opt/supervise/lib
    addAutoPatchelfSearchPath $out/opt/supervise
  '';

  meta = with lib; {
    description = "Ragtech Supervise 8 (monitoramento de nobreaks; UI web em localhost:4470)";
    homepage = "https://ragtech.com.br/downloads/categoria/softwares/supervise-beta/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "supsvc";
  };
}
