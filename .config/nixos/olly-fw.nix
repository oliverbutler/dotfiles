{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./olly-fw/hardware-configuration.nix
      ./shared/common.nix
      ./shared/tailscale.nix
      ./shared/vms.nix
    ];


  networking.hostName = "olly-fw"; 

}
