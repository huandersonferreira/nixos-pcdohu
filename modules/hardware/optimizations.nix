{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
}