{ lib, pkgs, inputs, ... }:

{
  imports = [ inputs.openlogi.nixosModules.openlogi ];

  programs.openlogi.enable = true;

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
