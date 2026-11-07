{ pkgs, pkgsUnstable, lib, ... }:

# Backend de inferência local para o OpenJarvis, Project NOMAD e qualquer
# coisa que fale a API HTTP do Ollama.
#
# GPU: Radeon RX 6700 XT (gfx1031) — não está na lista oficial de GPUs
# suportadas pelo ROCm, mas funciona com o override HSA_OVERRIDE_GFX_VERSION
# para gfx1030 (passado via rocmOverrideGfx).
#
# Pacote vem do nixpkgs-unstable: o 0.21.1 do 25.11 tem um bug no fit
# algorithm que offloada "0/N layers to GPU" em RX 6xxx mesmo com VRAM
# sobrando. O 0.40+ corrige.
#
# host = "0.0.0.0": necessário pra containers Docker (ex.: Project NOMAD)
# alcançarem a API via host.docker.internal. Expõe 11434 na LAN;
# restringir via firewall se o ambiente não for confiável.
#
# Storage em /mnt/storage/ollama (btrfs no NVMe secundário) via user fixo
# ollama — DynamicUser do systemd + home em disco externo é dor de cabeça
# (ownership efêmero, bind mounts, impermanence no /var/lib/private). Com
# user fixo, home e modelos ficam direto no path do subvolume.

{
  users.groups.ollama = {};
  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    home = "/mnt/storage/ollama";
  };

  services.ollama = {
    enable = true;
    package = pkgsUnstable.ollama-rocm;
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0";
    host = "0.0.0.0";
    user = "ollama";
    group = "ollama";
    home = "/mnt/storage/ollama";
    models = "/mnt/storage/ollama/models";
  };

  # Libera 11434 no firewall pra que containers Docker em bridges custom
  # (ex.: project-nomad em 172.24.0.0/16) alcancem a API via
  # host.docker.internal.
  networking.firewall.allowedTCPPorts = [ 11434 ];

  # Garante que o home existe com ownership certo antes do serviço subir.
  # A regra do /var/lib/private vem do módulo anterior e segue valendo para
  # qualquer outro serviço que use DynamicUser em cima de impermanence.
  systemd.tmpfiles.rules = [
    "d /var/lib/private            0700 root   root   - -"
    "d /mnt/storage/ollama         0755 ollama ollama - -"
    "d /mnt/storage/ollama/models  0755 ollama ollama - -"
  ];
}
