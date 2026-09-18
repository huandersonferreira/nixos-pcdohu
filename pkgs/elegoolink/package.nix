{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openssl,
  curl,
  paho-mqtt-cpp,
  paho-mqtt-c,
  ixwebsocket,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elegoolink";
  version = "1.0.6";

  # Existem DOIS repos "elegoo-link" da Elegoo (elegooofficial e ELEGOO-3D);
  # ambos apontam pro mesmo commit HEAD. Usamos rev específico pois v1.0.6
  # é apenas a versão no CMakeLists, sem tag no git.
  src = fetchFromGitHub {
    owner = "elegooofficial";
    repo = "elegoo-link";
    rev = "46c7b814e055cf9675d58482d79f43d0bd2280da";
    hash = "sha256-MEdRfpQ0pRzd0Mt1XI36cjvJt7JdgqOibPndpmgp4lE=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  # propagated: o elegoolink-config.cmake chama find_dependency(PahoMqttCpp, curl,
  # OpenSSL, ixwebsocket) — precisam estar disponíveis para o consumidor.
  propagatedBuildInputs = [
    openssl
    curl
    paho-mqtt-cpp
    paho-mqtt-c
    ixwebsocket
  ];

  # nixpkgs paho-mqtt-cpp exporta só target shared; elegoolink hardcoda -static.
  # Headers do elegoolink também dependem de includes transitivos que GCC de
  # outras distros oferece mas o do NixOS não; suplementamos os que faltam.
  postPatch = ''
    sed -i 's|paho-mqttpp3-static|paho-mqttpp3-shared|g' CMakeLists.txt
    for header in include/events/event_system.h; do
      [ -f "$header" ] && sed -i '1a #include <algorithm>' "$header"
    done
  '';

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXAMPLES" false)
    (lib.cmakeBool "BUILD_TESTS" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "ENABLE_CLOUD_FEATURES" true)
  ];

  # O elegoolink-config.cmake exige que exista $out/bin (ELEGOOLINK_BIN_DIR),
  # mesmo que nada seja instalado lá — sem isso o consumidor falha.
  postInstall = ''
    mkdir -p $out/bin
  '';

  meta = {
    description = "Elegoo Link SDK — SDCP protocol for Elegoo 3D printers (Centauri, Saturn, Mars)";
    homepage = "https://github.com/ELEGOO-3D/elegoo-link";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
})
