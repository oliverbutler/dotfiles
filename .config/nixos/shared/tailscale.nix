

{ config, pkgs, lib, ... }:

{

  # Tailscale
  services.tailscale = {
    enable = true;
  };
}
