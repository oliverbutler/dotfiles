{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.olly = {
    home.stateVersion = "18.09";

    programs.git = {
      enable = true;
      userName  = "oliverbutler";
      userEmail = "dev@oliverbutler.uk";
    };

    programs.kitty.enable = true;
  };

  home-manager.backupFileExtension = "backup";
   
}
