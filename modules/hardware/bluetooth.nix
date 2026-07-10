{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
      };
    };
  };

  hardware.xpadneo.enable = true;

  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=1
  '';

  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];
}
