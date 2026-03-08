{ config, pkgs, ... }:

{
  home.username = "huanderson";
  home.homeDirectory = "/home/huanderson";

  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    userName = "Huanderson C. Ferreira";
    userEmail = "huandersonferreira7@gmail.com";
  };

  programs.zsh.enable = true;

  programs.starship.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    bat
    eza
    fzf
    jq
  ];
}