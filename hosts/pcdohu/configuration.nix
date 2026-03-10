{ config, pkgs, ... }:

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

  system.stateVersion = "25.11";
}