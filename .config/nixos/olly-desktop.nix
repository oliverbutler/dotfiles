{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./olly-desktop/hardware-configuration.nix
      ./olly-desktop/nvidia.nix
      ./shared/common.nix
      ./shared/tailscale.nix
      ./shared/vms.nix
    ];


  networking.hostName = "olly-desktop"; 

}
