{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/framework/13-inch/7040-amd"
      ./olly-fw/hardware-configuration.nix
      ./shared/common.nix
      ./shared/tailscale.nix
      ./shared/vms.nix
    ];

  services.fwupd.enable = true;

  networking.hostName = "olly-fw"; 

  services.fwupd.package = (import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/bb2009ca185d97813e75736c2b8d1d8bb81bde05.tar.gz";
    sha256 = "sha256:003qcrsq5g5lggfrpq31gcvj82lb065xvr7bpfa8ddsw8x4dnysk";
  }) {
    inherit (pkgs) system;
  }).fwupd;

  # Gestures
  environment.systemPackages = with pkgs; [
    touchegg
  ];

  services.touchegg.enable = true;

}
