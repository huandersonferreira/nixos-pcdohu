{ pkgs, ... }:

{
  # Placa ASUS reserva as portas do Super I/O via ACPI; "lax" libera o acesso ao nct6775.
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  # nct6775 → NCT6798D (fans/temperaturas da placa)
  # i2c-dev → acesso a barramentos SMBus/I2C (necessário para o OpenRGB)
  boot.kernelModules = [
    "nct6775"
    "i2c-dev"
  ];

  # RGB da placa (ASUS Aura LED Controller USB 0b05:19af e headers ARGB via SMBus)
  services.hardware.openrgb.enable = true;

  # Daemon + GUI para curvas de ventoinha (equivalente ao Armoury Crate/AI Suite)
  programs.coolercontrol.enable = true;

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
}
