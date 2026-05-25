{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  programs.ssh.startAgent = true;

  networking.firewall.allowedTCPPorts = [
    22
  ];
}