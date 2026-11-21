{ pkgs, ... }:

{
  # pcscd é obrigatório pro Yubico Authenticator conversar com o CCID
  # do YubiKey (OATH/PIV/OpenPGP). Sem ele o app aborta com
  # "failed to open connection, make sure pcscd is installed and running".
  services.pcscd.enable = true;

  # Regras udev pra permitir acesso ao device sem root (grupo plugdev/input
  # dependendo da regra). yubikey-personalization-gui empacota as regras
  # oficiais da Yubico.
  services.udev.packages = [ pkgs.yubikey-personalization ];
}
