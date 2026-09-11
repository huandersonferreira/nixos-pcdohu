{ inputs, ... }:

{
  imports = [ inputs.openlogi.nixosModules.openlogi ];

  programs.openlogi.enable = true;
}
