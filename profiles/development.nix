{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
    vscode
    github-copilot-cli
    gemini-cli
    claude-code

    gcc
    gnumake
    cmake

    curl
    wget

    nodejs
    python3
    go
  ];
}