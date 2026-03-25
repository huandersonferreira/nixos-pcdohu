{ pkgs, ... }:

{
  imports = [
    ../modules/desktop/kde.nix
  ];

  environment.sessionVariables = {
    CHROMIUM_FLAGS = "--disable-gpu-sandbox --use-gl=swiftshader";
  };

  environment.systemPackages = with pkgs; [
    discord
    google-chrome
  ];
}