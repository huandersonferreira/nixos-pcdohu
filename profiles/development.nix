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

    bambu-studio
    (pkgs.callPackage ../pkgs/elegoo-slicer-source/package.nix {
      sentry-native = pkgsUnstable.sentry-native;
    })
  ];

  programs.mtr.enable = true;

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0"; # RX 6750 XT (gfx1032) não reconhecida automaticamente; forçar RDNA2 resolve
  };
}