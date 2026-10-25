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
    # Chrome 149 descarta VAAPI em GPUs AMD por "driver check" interno;
    # VaapiIgnoreDriverChecks + habilitação explícita do pipeline VAAPI
    # manda o decode do vídeo pro VCN da Navi 22 em vez da CPU.
    # Combina com rasterização Vulkan (ligada em chrome://flags), que
    # mitiga o GPU reset do backend GL default.
    (google-chrome.override {
      commandLineArgs = toString [
        # VAAPI acelera decode de vídeo pelo VCN da Navi 22. Em Wayland
        # nativo, Vulkan Ganesh conflita com o VaapiVideoDecoder (toda
        # config é rejeitada como kUnsupportedConfig), por isso Vulkan
        # tem que ficar desligado em chrome://flags. Trade-off: sem o
        # backend Vulkan de rasterização o Chrome volta pro path GL
        # default, que historicamente causou GPU reset na RX 6700 XT —
        # se voltar a travar, religar Vulkan e aceitar decode em CPU.
        "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks,VaapiVideoDecodeLinuxGL"
        "--ignore-gpu-blocklist"
      ];
    })
    libva-utils
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