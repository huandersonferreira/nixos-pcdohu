{ ... }:

# Project NOMAD roda via Docker Compose em /opt/project-nomad (fora do Nix
# porque o updater do próprio NOMAD precisa escrever no compose.yml, o que
# não funciona num path read-only do /nix/store).
#
# Este módulo só cuida do firewall pra expor a UI na LAN.
#
# Portas:
#   8080       → Command Center (UI principal, sem autenticação)
#   8090-8500  → apps do Supply Depot (Kiwix, CyberChef, FlatNotes, Kolibri,
#                nomad-translate, Jellyfin, Vaultwarden, etc.) — NOMAD atribui
#                cada app a uma porta nesse range por convenção.
#   9999       → Dozzle (visualizador de logs dos containers)

{
  networking.firewall.allowedTCPPorts = [
    8080
    9999
  ];

  networking.firewall.allowedTCPPortRanges = [
    { from = 8090; to = 8500; }
  ];
}
