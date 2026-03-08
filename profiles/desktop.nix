{ pkgs, ... }:

{
  imports = [
    ../modules/desktop/kde.nix
  ];

  environment.systemPackages = with pkgs; [
    discord
    google-chrome
  ];
}