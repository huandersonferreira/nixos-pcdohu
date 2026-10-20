{ pkgs, pkgsUnstable, lib, ... }:

# Backend de inferência local para o OpenJarvis (e qualquer outra coisa que
# fale a API HTTP do Ollama em localhost:11434).
#
# GPU: Radeon RX 6700 XT (gfx1031) — não está na lista oficial de GPUs
# suportadas pelo ROCm, mas funciona com o override HSA_OVERRIDE_GFX_VERSION
# para gfx1030 (passado via rocmOverrideGfx).
#
# Pacote vem do nixpkgs-unstable: o 0.21.1 do 25.11 tem um bug no fit
# algorithm que offloada "0/N layers to GPU" em RX 6xxx mesmo com VRAM
# sobrando. O 0.40+ corrige.
#
# Modelos ficam em /var/lib/ollama — adicionado em environment.persistence
# para sobreviver aos reboots (impermanence apaga tudo fora de /persist).

{
  services.ollama = {
    enable = true;
    package = pkgsUnstable.ollama-rocm;
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0";
  };

  # Ollama roda com DynamicUser via systemd, então o StateDirectory real é
  # /var/lib/private/ollama; /var/lib/ollama é só um symlink. Impermanence
  # precisa do path canônico, senão o bind mount falha com "not canonical
  # (contains a symlink)".
  environment.persistence."/persist".directories = [
    "/var/lib/private/ollama"
  ];

  # Systemd DynamicUser cria /var/lib/private com 0700 e recusa iniciar se
  # já existir com modo mais permissivo. Como impermanence e nossa criação
  # inicial deixaram 0755, forçar o modo correto via tmpfiles.
  systemd.tmpfiles.rules = [
    "d /var/lib/private 0700 root root - -"
  ];
}
