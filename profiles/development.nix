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

    ollama-vulkan
  ];

  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };
}