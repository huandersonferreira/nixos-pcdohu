{
  stdenv,
  lib,
  binutils,
  fetchFromGitHub,
  fetchurl,
  appimageTools,
  cmake,
  pkg-config,
  wrapGAppsHook3,
  boost187,
  cereal,
  cgal_5,
  curl,
  dbus,
  draco,
  eigen,
  expat,
  ffmpeg,
  gcc-unwrapped,
  glew,
  glfw,
  glib,
  glib-networking,
  gmp,
  gst_all_1,
  gtest,
  gtk3,
  gspell,
  hicolor-icon-theme,
  libxkbcommon,
  pcre2,
  libsecret,
  libnotify,
  libpng,
  mpfr,
  nlopt,
  opencascade-occt_7_6,
  openvdb,
  opencv,
  pcre,
  systemd,
  onetbb,
  webkitgtk_4_1,
  xorg,
  libnoise,
  sentry-native,
  callPackage,
  withSystemd ? stdenv.hostPlatform.isLinux,
}:
let
  # Fork do wxWidgets 3.3.2 mantido pelo time do OrcaSlicer, com patches
  # e opções (wxUSE_PRIVATE_FONTS, WebView próprio, etc) que fazem a Home
  # renderizar. wxGTK33 do nixpkgs é upstream 3.3.1 sem esses patches.
  wxGTK' = callPackage ../wxwidgets-orca/package.nix { };
  ixwebsocket' = callPackage ../ixwebsocket/package.nix { };
  elegoolink = callPackage ../elegoolink/package.nix { ixwebsocket = ixwebsocket'; };

  # libagora_rtm_sdk.so e libaosl.so são libs proprietárias do Agora RTM SDK,
  # não open source. Extraímos do próprio AppImage oficial da Elegoo.
  appimageSrc = fetchurl {
    url = "https://github.com/elegooofficial/ElegooSlicer/releases/download/v1.5.3.5/ElegooSlicer_Linux_V1.5.3.5.AppImage";
    hash = "sha256-ezs/CODQ1Ru0cshYZdG+mwwoOFQj2rocsMOyJdAQGvw=";
  };
  agoraLibs = appimageTools.extractType2 {
    pname = "elegoo-slicer-agora-libs";
    version = "1.5.3.5";
    src = appimageSrc;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "elegoo-slicer";
  version = "1.5.3.5";

  src = fetchFromGitHub {
    owner = "elegooofficial";
    repo = "ElegooSlicer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6Ss6zpLFdaPSavOspDsvY3p8MkTOD6njrPsJ3+92Txg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    wxGTK'
  ];

  buildInputs = [
    binutils
    (boost187.override {
      enableShared = true;
      enableStatic = false;
      extraFeatures = [
        "log"
        "thread"
        "filesystem"
      ];
    })
    boost187.dev
    cereal
    cgal_5
    curl
    dbus
    draco
    eigen
    expat
    ffmpeg
    gcc-unwrapped
    glew
    glfw
    glib
    glib-networking
    gmp
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-good
    gtk3
    gspell
    hicolor-icon-theme
    libxkbcommon
    pcre2
    libsecret
    libnotify
    libpng
    mpfr
    nlopt
    opencascade-occt_7_6
    openvdb
    pcre
    onetbb
    webkitgtk_4_1
    wxGTK'
    xorg.libX11
    opencv.cxxdev
    libnoise
    sentry-native
    elegoolink
  ]
  ++ lib.optionals withSystemd [ systemd ];

  # Reaproveitamos os patches genéricos do orca-slicer.
  # Se algum não aplicar, remover; se faltar, adicionar Elegoo-específico.
  patches = [
    ./patches/0001-not-for-upstream-CMakeLists-Link-against-webkit2gtk-.patch
    ./patches/dont-link-opencv-world-orca.patch
    ./patches/no-ilmbase.patch
  ];

  separateDebugInfo = true;

  NLOPT = nlopt;

  NIX_CFLAGS_COMPILE = toString (
    [
      # wxWidgets do fork Orca é buildado com wxBUILD_DEBUG_LEVEL=0
      # (sem asserts), então wxTheAssertHandler não existe. Precisamos que
      # o Elegoo também compile com wxDEBUG_LEVEL=0 para os macros wxASSERT
      # expandirem pra no-op ao invés de referenciar o handler ausente.
      "-DwxDEBUG_LEVEL=0"
      "-Wno-ignored-attributes"
      "-I${opencv.out}/include/opencv4"
      "-Wno-error=incompatible-pointer-types"
      "-Wno-template-id-cdtor"
      "-Wno-uninitialized"
      "-Wno-unused-result"
      "-Wno-deprecated-declarations"
      "-Wno-use-after-free"
      "-Wno-format-overflow"
      "-Wno-stringop-overflow"
      "-DBOOST_ALLOW_DEPRECATED_HEADERS"
      "-DBOOST_MATH_DISABLE_STD_FPCLASSIFY"
      "-DBOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS"
      "-DBOOST_MATH_DISABLE_FLOAT128"
      "-DBOOST_MATH_NO_QUAD_SUPPORT"
      "-DBOOST_MATH_MAX_FLOAT128_DIGITS=0"
      "-DBOOST_CSTDFLOAT_NO_LIBQUADMATH_SUPPORT"
      "-DBOOST_MATH_DISABLE_FLOAT128_BUILTIN_FPCLASSIFY"
    ]
    ++ lib.optionals (stdenv.cc.isGNU && lib.versionAtLeast stdenv.cc.version "14") [
      "-Wno-error=template-id-cdtor"
    ]
  );

  NIX_LDFLAGS = toString [
    (lib.optionalString withSystemd "-ludev")
    "-L${boost187}/lib"
    "-lboost_log"
    "-lboost_log_setup"
  ];

  prePatch = ''
    sed -i 's|nlopt_cxx|nlopt|g' cmake/modules/FindNLopt.cmake
    if [ -f src/libslic3r/PerimeterGenerator.cpp ]; then
      sed -i 's|"libnoise/noise.h"|"noise/noise.h"|' src/libslic3r/PerimeterGenerator.cpp
    fi
    if [ -f src/libslic3r/Feature/FuzzySkin/FuzzySkin.cpp ]; then
      sed -i 's|"libnoise/noise.h"|"noise/noise.h"|' src/libslic3r/Feature/FuzzySkin/FuzzySkin.cpp
    fi
    # ElegooSlicer pede Eigen3 5.0.1 (versão que não existe upstream).
    # A do nixpkgs é 3.4.x e é compatível na prática.
    sed -i 's|find_package(Eigen3 5.0.1 REQUIRED)|find_package(Eigen3 REQUIRED)|' CMakeLists.txt
    # Copia libs proprietárias do Agora RTM SDK do AppImage extraído.
    mkdir -p thirdparty/agora/linux
    cp ${agoraLibs}/bin/libagora_rtm_sdk.so thirdparty/agora/linux/
    cp ${agoraLibs}/bin/libaosl.so         thirdparty/agora/linux/
    chmod -R u+w thirdparty/agora
    # CMake do slicer assume libs Agora em $CMAKE_PREFIX_PATH/bin (do build
    # de deps upstream); redirecionamos para nossa thirdparty local.
    sed -i 's|"''${CMAKE_PREFIX_PATH}/bin/libaosl.so"|"''${CMAKE_SOURCE_DIR}/thirdparty/agora/linux/libaosl.so"|g' src/CMakeLists.txt
    sed -i 's|"''${CMAKE_PREFIX_PATH}/bin/libagora_rtm_sdk.so"|"''${CMAKE_SOURCE_DIR}/thirdparty/agora/linux/libagora_rtm_sdk.so"|g' src/CMakeLists.txt
    # Boost 1.87 removeu boost::asio::io_service (alias antigo de io_context).
    # Substituição global segura — io_service era alias exato de io_context.
    find src -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) \
      -exec sed -i 's|io_service|io_context|g' {} +
    # Bonjour.cpp chama io_context->post() que foi removido — precisa da forma
    # livre boost::asio::post(*io_context, handler).
    sed -i 's|io_context->post(|boost::asio::post(*io_context, |' src/slic3r/Utils/Bonjour.cpp
    # Boost 1.87: resolver retorna results (não iterator) — endpoints->endpoint()
    # precisa virar endpoints.begin()->endpoint().
    sed -i 's|endpoints->endpoint()|endpoints.begin()->endpoint()|' src/slic3r/Utils/TCPConsole.cpp
    # Força modo CONFIG do find_package(wxWidgets): nosso fork Orca é
    # buildado via CMake e expõe lib/cmake/wxWidgets-3.3/ mas sem wx-config
    # (que é o que a busca legacy do CMake procura no Linux).
    sed -i 's|find_package(wxWidgets 3.3 REQUIRED COMPONENTS|find_package(wxWidgets 3.3 CONFIG REQUIRED COMPONENTS|' src/CMakeLists.txt
    # HomeView depende de wxEVT_SHOW do MainFrame para inicializar o
    # WebView de navegação (via CallAfter). Em Wayland esse evento não
    # dispara consistente, deixando a Home vazia. Forçamos:
    # 1) chamar initializeNavigationWebView em qualquer Show
    # 2) fazer o initUI já disparar a inicialização (CallAfter para depois
    #    do event loop rodar uma vez, garantindo que wxWebView tá pronto).
    sed -i 's|if (show \&\& mResetNavigationOnShow)|if (show \&\& !mNavigationWebViewInitialized)|' \
      src/slic3r/GUI/Elegoo/HomeView.cpp
    sed -i 's|mResetNavigationOnShow = wxGetApp().is_recreating_gui();|mResetNavigationOnShow = wxGetApp().is_recreating_gui();\n    CallAfter([this]{ initializeNavigationWebView(); });|' \
      src/slic3r/GUI/Elegoo/HomeView.cpp
  '';

  cmakeFlags = [
    (lib.cmakeBool "SLIC3R_STATIC" false)
    (lib.cmakeBool "SLIC3R_FHS" true)
    (lib.cmakeFeature "SLIC3R_GTK" "3")
    (lib.cmakeBool "BBL_RELEASE_TO_PUBLIC" true)
    (lib.cmakeBool "BBL_INTERNAL_TESTING" false)
    (lib.cmakeFeature "ELEGOO_INTERNAL_TESTING" "0")
    (lib.cmakeBool "SLIC3R_BUILD_TESTS" false)
    (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-DGL_SILENCE_DEPRECATION")
    (lib.cmakeFeature "CMAKE_EXE_LINKER_FLAGS" "-Wl,--no-as-needed")
    (lib.cmakeFeature "LIBNOISE_INCLUDE_DIR" "${libnoise}/include")
    (lib.cmakeFeature "LIBNOISE_LIBRARY_RELEASE" "${libnoise}/lib/libnoise-static.a")
    "-Wno-dev"
  ];

  postBuild = ''
    if [ -f ../scripts/run_gettext.sh ]; then
      ( cd .. && ./scripts/run_gettext.sh ) || true
    fi
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/bin:$out/lib:${lib.makeLibraryPath [ glew ]}"
      # WebKit em Wayland: compositing GPU causa tela branca em WebView.
      # Sandbox mantém-se habilitado (build nativo, não precisa desabilitar).
      # DMABUF renderer removido — desabilitá-lo com AMD RDNA2 zera a Home.
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
      # ElegooSlicer usa flags de sizer inválidas em vários lugares; sem esta
      # var, wxGTK 3.3 do nixpkgs aborta com assertion fatal na inicialização.
      --set WXSUPPRESS_SIZER_FLAGS_CHECK 1
    )
  '';

  postInstall = ''
    rm -f $out/LICENSE.txt
    # Recursos web dos plugins (elegoolink cloud_service_web / lan_service_web)
    # não estão no repo do source — o build oficial baixa via CMake fetch.
    # Copiamos do AppImage extraído; path final tem que ser
    # $resources_dir/plugins/elegoolink/web/... (resources_dir = share/ElegooSlicer).
    if [ -d ${agoraLibs}/resources/plugins ]; then
      cp -r --no-preserve=mode,ownership ${agoraLibs}/resources/plugins \
            $out/share/ElegooSlicer/plugins
      chmod -R u+w $out/share/ElegooSlicer/plugins
    fi
  '';

  meta = {
    description = "Slicer oficial Elegoo (fork OrcaSlicer) com SDCP nativo para Centauri/Saturn/Mars";
    homepage = "https://github.com/elegooofficial/ElegooSlicer";
    changelog = "https://github.com/elegooofficial/ElegooSlicer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "elegoo-slicer";
    platforms = lib.platforms.linux;
  };
})
