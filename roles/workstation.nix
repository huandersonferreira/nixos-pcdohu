{ ... }:

{
  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "startplasma-x11";
  };

  networking.firewall.allowedTCPPorts = [
    3389
  ];
}