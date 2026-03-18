{ config, pkgs, inputs, ... }:

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
        turnOffDisplay.idleTimeout = 1800;
        autoSuspend.action = "nothing";
      };
    };

    kscreenlocker = {
      autoLock = true;
      timeout = 10;
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

  programs.zsh.enable = true;

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
    winbox4
  ];
}