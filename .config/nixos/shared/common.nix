{ config, pkgs, lib, ... }:


let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config = config.nixpkgs.config;
  };
in

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  users.users.olly = {
    isNormalUser = true;
    description = "Oliver Butler";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
    openssh = {
      authorizedKeys = {
        keys = [
           "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEu6Iqvohxzm8FBBXznE/ZmHkry9nHHHM8PrtbNeXg0X" # Olly Key
	];
      };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };


  # Enable networking
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.fish.enable = true;

  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  services.blueman.enable = true;

  virtualisation.docker.enable = true;

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  environment.systemPackages = with pkgs; [
    kitty
    gh
    # Build stuff
    gnumake
    bruno
    openssl
    parted
    gccgo
    unzip
    influxdb
    nvtopPackages.full
    btop
    vulkan-tools
    starship
    zoxide
    delta
    vim 
    unstable.neovim
    easyeffects
    stylua
    prismlauncher
    nodejs_22
    go
    air
    gopls
    gofumpt
    gparted 
    ansel
    darktable
    sqlite
    caligula
    lsof
    wget
    ethtool
    spotify
    kdePackages.kimageformats

    # Keyboard
    qmk

    # Lua
    lua54Packages.busted
    lua

    # Python
    python312Full
    python312Packages.pip

    # LSPs
    lua-language-server
    stylua
    prettierd
    tailwindcss-language-server

    audacity
    mullvad-vpn
    neofetch
    wezterm
    nmap
    nextcloud-client
    prusa-slicer
    lazygit
    lazydocker
    discord
    git
    htop
    mangohud
    protonup
    yadm
    tmux
    ripgrep
    obsidian
    kubectl
    talosctl
    k9s
    lens
    flux
    sshfs
    beekeeper-studio
    unstable.immich-cli
    bun
    wakeonlan
    remmina
  ];

  services.flatpak.enable = true;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "olly" ];
  };


  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;


  environment.sessionVariables = {
    # this is so we can run "protonup" and not need to specify a path
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/olly/.steam/root/compatibilitytools.d";
  };


  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  fileSystems."/mnt/unraid-photos" = {
    device = "10.0.0.40:/mnt/user/Photos";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };


  fileSystems."/mnt/unraid" = {
    device = "root@10.0.0.40:/mnt/user";
    fsType = "fuse.sshfs";
    options = [
      "identityfile=/home/olly/.ssh/id_ed25519"
      "idmap=user"
      "x-systemd.automount"
      "allow_other"
      "user"
      "_netdev"
    ];  
  };

  boot.supportedFilesystems = [ "fuse" "sshfs" ];


  system.stateVersion = "24.11"; 
}
