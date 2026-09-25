{ appimageTools, fetchurl, lib, makeWrapper, symlinkJoin, cacert, writeShellScript
, hack-font, dejavu_fonts, liberation_ttf, freefont_ttf, noto-fonts }:

# AppImage oficial da Elegoo (mais recente). Nota: a janela de Preferências
# crasha em `libpangoft2::ensure_faces` — bug do combo AppImage do Elegoo +
# pango 1.57 do nixpkgs; edite `~/.config/ElegooSlicer/*.conf` diretamente
# se precisar mudar setting.
#
# A alternativa source-based (`../elegoo-slicer-source`) está bloqueada
# porque o repo público ELEGOO-3D/elegoo-link está atrasado em relação à
# versão embutida no slicer oficial.

let
  pname = "elegoo-slicer";
  version = "1.5.3.5";

  src = fetchurl {
    url = "https://github.com/elegooofficial/ElegooSlicer/releases/download/v${version}/ElegooSlicer_Linux_V${version}.AppImage";
    hash = "sha256-ezs/CODQ1Ru0cshYZdG+mwwoOFQj2rocsMOyJdAQGvw=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };

  runScript = writeShellScript "${pname}-run" ''
    mkdir -p "$HOME/.config/fontconfig"
    cat > "$HOME/.config/fontconfig/fonts.conf" <<EOF
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
      <dir>${hack-font}/share/fonts</dir>
      <dir>${dejavu_fonts}/share/fonts</dir>
      <dir>${liberation_ttf}/share/fonts</dir>
      <dir>${freefont_ttf}/share/fonts</dir>
      <dir>${noto-fonts}/share/fonts</dir>
    </fontconfig>
    EOF
    fc-cache -f >/dev/null 2>&1 || true
    export APPDIR=${appimageContents}
    export APPIMAGE_SILENT_INSTALL=1
    cd "$APPDIR"
    exec "$APPDIR/AppRun" "$@"
  '';

  wrapped = appimageTools.wrapAppImage {
    inherit pname version runScript;
    src = appimageContents;

    extraPkgs = pkgs: with pkgs; [
      webkitgtk_4_1
      libsoup_3
      cacert
      glib-networking
      gsettings-desktop-schemas
      # Loaders de imagem que o WebKit/GdkPixbuf usa (o AppImage não empacota).
      # Sem librsvg os ícones SVG do Home/Discovery/Device somem.
      gdk-pixbuf
      librsvg
      shared-mime-info
      # WebKit usa GStreamer para <video>/<audio> e alguns codecs de imagem.
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      hack-font
      dejavu_fonts
      liberation_ttf
      freefont_ttf
      noto-fonts
      hicolor-icon-theme
      adwaita-icon-theme
    ];

    extraInstallCommands = ''
      if [ -d ${appimageContents}/usr/share ]; then
        mkdir -p $out/share
        cp -r --no-preserve=mode,ownership ${appimageContents}/usr/share/. $out/share/
        chmod -R u+w $out/share
      fi

      for dt in $out/share/applications/*.desktop; do
        [ -f "$dt" ] || continue
        substituteInPlace "$dt" \
          --replace-warn 'Exec=AppRun' 'Exec=${pname}'
      done
    '';
  };
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ wrapped ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    rm $out/bin/${pname}
    makeWrapper ${wrapped}/bin/${pname} $out/bin/${pname} \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set NIX_SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set GIO_EXTRA_MODULES /usr/lib/gio/modules \
      --set GIO_MODULE_DIR /usr/lib/gio/modules \
      --set GSETTINGS_SCHEMA_DIR /usr/share/glib-2.0/schemas \
      --set XDG_DATA_DIRS /usr/share \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
      --set WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS 1
  '';

  meta = with lib; {
    description = "Slicer oficial Elegoo (fork OrcaSlicer) com SDCP para Centauri/Saturn/Mars";
    homepage = "https://github.com/elegooofficial/ElegooSlicer";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
