{ lib, pkgs, inputs, ... }:

{
  imports = [ inputs.openlogi.nixosModules.openlogi ];

  programs.openlogi.enable = true;

  # Upstream (packaging/linux/package.nix) esqueceu `zstd` em buildInputs mas
  # alguma dep do GPUI puxou `zstd-sys` no Cargo.lock — build quebra com
  # "libzstd was not found in the pkg-config search path". Override local
  # até arrumarem lá.
  programs.openlogi.package =
    inputs.openlogi.packages.${pkgs.stdenv.hostPlatform.system}.openlogi.overrideAttrs
      (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.zstd ];
      });

  # O openlogi-agent faz dlopen de libwayland/libGL/etc. em runtime, mas a
  # derivation upstream só wrappeia openlogi-gui com LD_LIBRARY_PATH — o agent
  # sobe sem rpath nem wrapper, panics com `NoWaylandLib` e os uinputs do helper
  # vazam, aparecendo como "mouse duplicado" na UI.
  systemd.user.services.openlogi-agent.environment.LD_LIBRARY_PATH =
    lib.makeLibraryPath (with pkgs; [
      wayland
      libxkbcommon
      libGL
      libxcb
      vulkan-loader
    ]);
}
