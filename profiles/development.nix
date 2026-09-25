{ pkgs, pkgsUnstable, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
    glab
    pkgsUnstable.vscode
    github-copilot-cli
    gemini-cli
    claude-code
    inputs.herdr-nix.packages.${pkgs.system}.default
    pkgsUnstable.dbeaver-bin
    pkgsUnstable.warp-terminal
    pkgsUnstable.ghostty
    termius
    postman

    gcc
    gnumake
    cmake

    curl
    wget

    nodejs
    python3
    go

    platformio-core

    bambu-studio
    (pkgs.callPackage ../pkgs/elegoo-slicer/package.nix { })
  ];

  services.udev.packages = [ pkgs.platformio-core.udev ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      libffi
      ncurses
      bzip2
      xz
      readline
      sqlite
      libuuid
    ];
  };

  programs.mtr.enable = true;

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0"; # RX 6750 XT (gfx1032) não reconhecida automaticamente; forçar RDNA2 resolve
  };
}