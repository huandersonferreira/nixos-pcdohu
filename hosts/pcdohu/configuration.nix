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

  system.stateVersion = "25.11";
}