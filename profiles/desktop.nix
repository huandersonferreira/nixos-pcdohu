{ pkgs, ... }:

{
  imports = [
    ../modules/desktop/kde.nix
  ];

  environment.sessionVariables = {
    CHROMIUM_FLAGS = "--disable-gpu-sandbox --use-gl=swiftshader";
  };

  environment.systemPackages = with pkgs; [
    discord
    freecad-wayland
    google-chrome
    vlc
  ];

  fonts.packages = with pkgs; [
    hack-font
    # Fontes de cobertura ampla; Elegoo Slicer (e outros apps com dropdown
    # de idiomas) crasha em pangoft2 ao renderizar CJK/RTL sem elas.
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    liberation_ttf
    dejavu_fonts
    unifont  # fallback universal para qualquer glyph Unicode
  ];

  # Sem esses fallbacks, fc-match "sans-serif":lang=zh-cn cai em Noto Sans
  # comum (sem CJK) e o Pango crasha em ensure_faces ao renderizar
  # caracteres CJK (ex.: nomes de idiomas no dropdown do Elegoo Slicer).
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" "Noto Sans CJK SC" "Noto Sans CJK JP" "Noto Sans CJK KR" ];
    serif = [ "Noto Serif" "Noto Serif CJK SC" "Noto Serif CJK JP" "Noto Serif CJK KR" ];
    monospace = [ "Hack" "Noto Sans Mono" "Noto Sans Mono CJK SC" ];
    emoji = [ "Noto Color Emoji" ];
  };
}