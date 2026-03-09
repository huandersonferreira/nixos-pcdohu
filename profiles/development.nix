{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    gh
    vscode

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