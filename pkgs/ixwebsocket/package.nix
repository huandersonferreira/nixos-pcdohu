{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openssl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ixwebsocket";
  version = "12.0.1";

  src = fetchFromGitHub {
    owner = "machinezone";
    repo = "IXWebSocket";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2QWIpLVIs2vGuMEhewDyihYdDQBz7SsOtfZ6pE67j2Q=";
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ openssl zlib ];

  cmakeFlags = [
    (lib.cmakeBool "USE_TLS" true)
    (lib.cmakeBool "USE_OPEN_SSL" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "BUILD_EXAMPLES" false)
    (lib.cmakeBool "BUILD_TESTS" false)
  ];

  meta = {
    description = "C++ WebSocket + HTTP library with TLS support";
    homepage = "https://github.com/machinezone/IXWebSocket";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
  };
})
