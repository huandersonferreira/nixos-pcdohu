{ ... }:

# NVMe secundário Samsung 990 PRO 2TB (nvme1n1p1) dedicado a dados grandes:
#   /mnt/storage/project-nomad  (ZIMs, modelos NOMAD, mapas, notes, etc.)
#   /mnt/storage/ollama         (home do daemon Ollama + modelos locais)
#
# btrfs com compressão zstd:3 (bom tradeoff pra JSON/HTML dos ZIMs) e noatime.
# Subvolumes @project-nomad e @ollama existem no root do FS; a UI do NOMAD
# precisa de paths reais no host (sem subvol=), então montamos o top-level.

{
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
    options = [ "compress=zstd:3" "noatime" ];
  };
}
