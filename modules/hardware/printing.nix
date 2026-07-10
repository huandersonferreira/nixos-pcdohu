{ pkgs, ... }:

{
  # Servidor de impressão CUPS com drivers HP (inclui plugin proprietário)
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplipWithPlugin
      gutenprint
      gutenprintBin
    ];
  };

  # Descoberta de impressoras/scanners na rede via mDNS (Wi-Fi)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Suporte a scanner (multifuncional HP)
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  users.users.huanderson.extraGroups = [ "scanner" "lp" ];

  # Persistência do estado do CUPS (impressoras cadastradas sobrevivem ao reboot)
  environment.persistence."/persist".directories = [
    "/var/lib/cups"
  ];

  environment.systemPackages = with pkgs; [
    system-config-printer
    simple-scan
  ];
}
