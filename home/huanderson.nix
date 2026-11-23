{ config, pkgs, pkgsUnstable, inputs, ... }:

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.username = "huanderson";
  home.homeDirectory = "/home/huanderson";

  home.stateVersion = "25.11";

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
      iconTheme = "breeze-dark";
      cursor.theme = "breeze_cursors";
    };

    powerdevil = {
      AC = {
        powerProfile = "performance";
        # Nada automático: tela só apaga 30s depois do lock manual.
        # "never" literal não aceita idleTimeoutWhenLocked junto; 24h ~ nunca.
        turnOffDisplay.idleTimeout = 86400;
        turnOffDisplay.idleTimeoutWhenLocked = 30;
        autoSuspend.action = "nothing";
      };
    };

    kscreenlocker = {
      autoLock = false;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Huanderson C. Ferreira";
        email = "huandersonferreira7@gmail.com";
      };
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#pcdohu";
      nrt = "sudo nixos-rebuild test --flake /etc/nixos#pcdohu";
      nrb = "sudo nixos-rebuild boot --flake /etc/nixos#pcdohu";
      nrr = "sudo nixos-rebuild switch --rollback --flake /etc/nixos#pcdohu";
      nrd = "nixos-rebuild build --flake /etc/nixos#pcdohu && nix store diff-closures /run/current-system ./result";
      nfu = "sudo nix flake update --flake /etc/nixos";
      nru = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#pcdohu";
    };
    sessionVariables = {
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
      PRISMA_QUERY_ENGINE_BINARY  = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_FMT_BINARY           = "${pkgs.prisma-engines}/bin/prisma-fmt";
    };
  };

  programs.starship.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    bat
    eza
    fzf
    jq
    aspellDicts.pt_BR
    hunspellDicts.pt_BR
    yubioath-flutter
    yubikey-manager
    pam_u2f
    pkgsUnstable.winbox4
    anydesk
    bitwarden-desktop
    prisma-engines
    corepack_22
  ];

  systemd.user.services.krdpserver = {
    Unit = {
      Description = "KDE Plasma Wayland RDP server";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.kdePackages.krdp}/bin/krdpserver --plasma";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}