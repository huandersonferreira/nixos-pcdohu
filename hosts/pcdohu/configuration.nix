{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../profiles/base.nix
    ../../profiles/desktop.nix
    ../../profiles/development.nix
    ../../profiles/gamer.nix

    ../../roles/workstation.nix
    ../../roles/docker-host.nix
    ../../roles/virtualization.nix
  ];

  networking.hostName = "PCdoHU";

  time.timeZone = "America/Maceio";

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Define o idioma principal do sistema
  i18n.defaultLocale = "pt_BR.UTF-8";

  # Configurações extras (moeda, medidas, data) para o padrão brasileiro
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configura o teclado no console (TTY)
  console.keyMap = "br-abnt2";

  # Configura o teclado no ambiente gráfico (X11/Wayland/Plasma)
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  users.users = {
    huanderson = {
      isNormalUser = true;
      description = "Huanderson Ferreira";
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "libvirt"
        "wireshark"
      ];
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "huanderson" ];
  };

  nixpkgs.config.allowUnfree = true;

  services.snapper = {
    configs.root = {
      SUBVOLUME = "/";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/var/lib/bluetooth"
      "/var/lib/systemd"
      "/var/lib/nixos"
    ];

    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /btrfs_tmp
    mount -o subvolid=5 /dev/nvme2n1p2 /btrfs_tmp

    if [ -e /btrfs_tmp/@root ]; then
      btrfs subvolume delete /btrfs_tmp/@root
    fi

    btrfs subvolume snapshot /btrfs_tmp/@root-base /btrfs_tmp/@root

    umount /btrfs_tmp
  '';

  system.activationScripts.updateRootBase = lib.mkAfter ''
    echo "Updating BTRFS root-base snapshot..."

    mkdir -p /btrfs_tmp
    mount -o subvolid=5 /dev/nvme2n1p2 /btrfs_tmp

    if [ -e /btrfs_tmp/@root-base ]; then
      ${pkgs.btrfs-progs}/bin/btrfs subvolume delete /btrfs_tmp/@root-base
    fi

    ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot /btrfs_tmp/@root /btrfs_tmp/@root-base

    umount /btrfs_tmp
  '';

  system.stateVersion = "25.11";
}