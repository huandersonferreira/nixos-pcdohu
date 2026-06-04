{ pkgs, pkgsUnstable, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
    glab
    pkgsUnstable.vscode
    github-copilot-cli
    gemini-cli
    claude-code
    pkgsUnstable.dbeaver-bin
    pkgsUnstable.warp-terminal
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
  ];

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0"; # RX 6750 XT (gfx1032) não reconhecida automaticamente; forçar RDNA2 resolve
  };
}