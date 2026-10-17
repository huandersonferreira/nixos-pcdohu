{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Desliga PCIe ASPM na GPU: evita que o DP perca link training silenciosamente
  # quando o monitor sai de DPMS/power-save (sintoma: monitor fica preto até
  # reconectar o cabo). Custo ~5W a mais em idle.
  boot.kernelParams = [ "amdgpu.aspm=0" ];

  services.fstrim.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  services.thermald.enable = true;

  hardware.enableRedistributableFirmware = true;

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
  '';

  nix.settings = {
    max-jobs = "auto";
    cores = 0;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # Não bloqueia o boot esperando conectividade.
  systemd.services.NetworkManager-wait-online.enable = false;

  hardware.graphics = {
    extraPackages = [ ];
  };
}