# Modulo NixOS: dois containers isolados pra rodar S4MP.
#
# Como usar:
#   1. Copie este arquivo pra /etc/nixos/ (ou onde estao seus modulos)
#   2. No configuration.nix adicione: imports = [ ./sims4-containers.nix ];
#   3. sudo nixos-rebuild switch
#   4. sudo nixos-container start s4host
#   5. sudo nixos-container start s4client
#   6. rode ~/sims4-container-launcher.sh conforme o guia
{ config, pkgs, lib, ... }:

let
  # Config comum entre os dois containers
  commonContainerConfig = { pkgs, ... }: {
    system.stateVersion = "25.11";

    nixpkgs.config.allowUnfree = true;

    # User espelhando o do host (UID/GID = 1000)
    users.users.huanderson = {
      isNormalUser = true;
      uid = 1000;
      group = "users";
      extraGroups = [ "video" "render" "audio" "wheel" ];
      # Sem senha; entra via machinectl/nsenter
      hashedPassword = "";
    };
    users.groups.users.gid = 100;
    users.groups.video.gid = 26;
    users.groups.render.gid = 303;
    users.groups.audio.gid = 17;

    # Steam-run + libs necessarias pra Wine/Proton
    environment.systemPackages = with pkgs; [
      steam-run
      # Opcional: wine winetricks pra debug
    ];

    # OpenGL/Vulkan (necessario pra Wine+DXVK ver a GPU)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # PulseAudio via socket bind-mount do host
    services.pulseaudio.enable = false;
    services.pipewire.enable = false;
    # (o container usa o socket do host via bind mount)

    # Sem firewall pra nao atrapalhar S4MP
    networking.firewall.enable = false;

    # Locale / timezone iguais ao host
    time.timeZone = "America/Maceio";
    i18n.defaultLocale = "pt_BR.UTF-8";
  };

  # Bind mounts comuns
  commonBindMounts = {
    # GPU (nao read-only, Wine escreve em GBM)
    "/dev/dri" = { hostPath = "/dev/dri"; isReadOnly = false; };

    # Nix store compartilhada (read-only) - traz proton, steam-run, etc.
    "/nix/store" = { hostPath = "/nix/store"; isReadOnly = true; };

    # Home do usuario - contem prefixes, Sims 4 install (via ~/.steam), Downloads
    "/home/huanderson" = { hostPath = "/home/huanderson"; isReadOnly = false; };

    # X11 socket
    "/tmp/.X11-unix" = { hostPath = "/tmp/.X11-unix"; isReadOnly = false; };

    # XDG_RUNTIME_DIR do host - contem wayland-0, pulseaudio, dbus
    "/run/user/1000" = { hostPath = "/run/user/1000"; isReadOnly = false; };
  };
in
{
  # HOST container - roda instancia 1 do Sims (host do S4MP)
  containers.s4host = {
    autoStart = false;
    privateNetwork = true;
    hostAddress = "10.200.0.1";
    localAddress = "10.200.0.10";

    bindMounts = commonBindMounts;
    config = commonContainerConfig;
  };

  # CLIENT container - roda instancia 2 do Sims (client do S4MP)
  containers.s4client = {
    autoStart = false;
    privateNetwork = true;
    hostAddress = "10.200.0.2";
    localAddress = "10.200.0.20";

    bindMounts = commonBindMounts;
    config = commonContainerConfig;
  };

  # Firewall do host: liberar veth-containers (privateNetwork cria ve-*)
  networking.firewall.trustedInterfaces = [ "ve-s4host" "ve-s4client" ];

  # Habilitar IP forwarding (pros containers falarem entre si via host)
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # NAT entre os dois containers (10.200.0.10 <-> 10.200.0.20 via host)
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-s4host" "ve-s4client" ];
    # Opcional: externalInterface = "enp8s0" se quiser dar internet aos containers
  };
}
