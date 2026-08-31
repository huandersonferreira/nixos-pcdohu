{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    package = pkgs.docker_29;
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    docker_29
    docker-compose
    docker-buildx
    distrobox
  ];
}