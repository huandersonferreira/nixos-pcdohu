{ pkgs, ... }:

{
  imports = [
    ../modules/desktop/kde.nix
  ];

  # Ativa Ozone/Wayland nativo pros apps Chromium (o wrapper do google-chrome
  # do nixpkgs lê NIXOS_OZONE_WL e injeta --ozone-platform-hint=auto).
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    discord
    freecad-wayland
    # Rasterização Vulkan (Skia GaneshVulkan) é o que evita o GPU reset
    # do backend GL default na RX 6700 XT — sem ela o Chrome trava em
    # loop de pageflip no amdgpu. Mas Wayland nativo + GaneshVulkan é
    # incompatível no Chrome 149 (o próprio browser avisa: "wayland is
    # not compatible with Vulkan"): o compound backing das texturas de
    # vídeo não expõe representação Skia, e o <video> renderiza em
    # branco. Solução oficial recomendada pelo Chrome: rodar sob
    # XWayland via --ozone-platform=x11. KDE/KWin continuam Wayland
    # para o resto do sistema; apenas o Chrome usa a camada X11.
    (google-chrome.override {
      commandLineArgs = toString [
        "--enable-features=Vulkan"
        "--ozone-platform=x11"
        "--ignore-gpu-blocklist"
      ];
    })
    telegram-desktop
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