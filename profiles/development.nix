{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      vscode = (import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      }).vscode;
      dbeaver-bin = (import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      }).dbeaver-bin;
      warp-terminal = (import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      }).warp-terminal;
    })
  ];

  environment.systemPackages = with pkgs; [
    git
    gh
    glab
    vscode
    github-copilot-cli
    gemini-cli
    claude-code
    dbeaver-bin
    warp-terminal

    gcc
    gnumake
    cmake

    curl
    wget

    nodejs
    python3
    go

    ollama
    ollama-vulkan
  ];

  services.ollama = {
    enable = true;
  };
}