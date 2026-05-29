{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  programs.ssh.startAgent = true;

  networking.firewall.allowedTCPPorts = [
    22
  ];
}