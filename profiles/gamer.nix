{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    protontricks.enable = true;

    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];

    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  hardware.steam-hardware.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protontricks
    winetricks
  ];
}
