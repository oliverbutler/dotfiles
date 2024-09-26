
{ config, pkgs, lib, ... }:

{

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    spice 
    spice-gtk
    spice-protocol
    win-spice
  ];

  users.users.olly.extraGroups = [ "libvirtd" ];

}
