{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  curl,
  expat,
  gspell,
  gst_all_1,
  gtk3,
  libGL,
  libGLU,
  libSM,
  libXinerama,
  libXtst,
  libXxf86vm,
  libjpeg_turbo,
  libnotify,
  libpng,
  libsecret,
  libtiff,
  libxkbcommon,
  pcre2,
  webkitgtk_4_1,
  wayland,
  wayland-scanner,
  wayland-protocols,
  xorgproto,
  zlib,
}:

# Fork do wxWidgets 3.3 mantido pelo time do OrcaSlicer, com patches
# necessários para o WebView renderizar corretamente no Elegoo Slicer.
# O wxWidgets 3.3.1 upstream do nixpkgs faz a Home ficar branca.
stdenv.mkDerivation (finalAttrs: {
  pname = "wxwidgets-orca";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "SoftFever";
    repo = "Orca-deps-wxWidgets";
    # v3.3.2 é um branch (não tag) — usamos o SHA do HEAD dele.
    rev = "88f3483ca546fbf4ad732e1acd94cc930935077a";
    fetchSubmodules = true;
    hash = "sha256-AFIR62QHGk5+V3O7JInCzHFmGwh+EsTDZbP06GCNxu0=";
  };

  nativeBuildInputs = [ cmake pkg-config wayland-scanner ];

  # Mesma lista de deps do wxGTK padrão do nixpkgs (Linux).
  buildInputs = [
    curl
    expat
    gspell
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    gtk3
    libGL
    libGLU
    libSM
    libXinerama
    libXtst
    libXxf86vm
    libjpeg_turbo
    libnotify
    libpng
    libsecret
    libtiff
    libxkbcommon
    pcre2
    webkitgtk_4_1
    wayland
    wayland-protocols
    xorgproto
    zlib
  ];

  # Opções idênticas às do build oficial da Elegoo/Orca
  # (deps/wxWidgets/wxWidgets.cmake no repo do ElegooSlicer).
  # Todas via cmakeFeature "ON"/"OFF" — algumas aceitam só strings específicas
  # (sys/builtin/OFF), então usar cmakeBool com true/false quebra o wx CMake.
  cmakeFlags = [
    (lib.cmakeFeature "wxBUILD_SHARED" "ON")
    (lib.cmakeFeature "wxBUILD_TOOLKIT" "gtk3")
    (lib.cmakeFeature "wxBUILD_PRECOMP" "ON")
    (lib.cmakeFeature "wxBUILD_SAMPLES" "OFF")
    (lib.cmakeFeature "wxBUILD_DEBUG_LEVEL" "0")
    (lib.cmakeFeature "wxUSE_MEDIACTRL" "ON")
    (lib.cmakeFeature "wxUSE_DETECT_SM" "OFF")
    (lib.cmakeFeature "wxUSE_PRIVATE_FONTS" "ON")
    (lib.cmakeFeature "wxUSE_OPENGL" "ON")
    (lib.cmakeFeature "wxUSE_GLCANVAS_EGL" "ON")
    (lib.cmakeFeature "wxUSE_WEBREQUEST" "ON")
    (lib.cmakeFeature "wxUSE_WEBVIEW" "ON")
    (lib.cmakeFeature "wxUSE_WEBVIEW_EDGE" "OFF")
    (lib.cmakeFeature "wxUSE_WEBVIEW_IE" "OFF")
    (lib.cmakeFeature "wxUSE_REGEX" "builtin")
    (lib.cmakeFeature "wxUSE_LIBSDL" "OFF")
    (lib.cmakeFeature "wxUSE_XTEST" "OFF")
    (lib.cmakeFeature "wxUSE_STC" "OFF")
    (lib.cmakeFeature "wxUSE_AUI" "ON")
    (lib.cmakeFeature "wxUSE_LIBPNG" "sys")
    (lib.cmakeFeature "wxUSE_ZLIB" "sys")
    (lib.cmakeFeature "wxUSE_LIBJPEG" "sys")
    (lib.cmakeFeature "wxUSE_LIBTIFF" "OFF")
    (lib.cmakeFeature "wxUSE_LIBWEBP" "builtin")
    (lib.cmakeFeature "wxUSE_EXPAT" "sys")
    (lib.cmakeFeature "wxUSE_NANOSVG" "OFF")
    (lib.cmakeFeature "wxUSE_SECRETSTORE" "ON")
  ];

  meta = {
    description = "OrcaSlicer fork do wxWidgets 3.3 com patches para WebView";
    homepage = "https://github.com/SoftFever/Orca-deps-wxWidgets";
    license = lib.licenses.lgpl2Plus;  # wxWindows Licence é LGPL2+ com exception
    platforms = lib.platforms.linux;
  };
})
