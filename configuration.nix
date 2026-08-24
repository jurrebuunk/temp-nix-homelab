{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/docker.nix
    ./modules/lan-bridge.nix
    ./modules/lxc.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-server";

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    keyMap = "us";
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      auto-optimise-store = true;
    };

    # Remove old generations and unused packages weekly.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  users.users.jurre = {
    isNormalUser = true;
    description = "Jurre";

    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  security.sudo.wheelNeedsPassword = true;

  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };

    openFirewall = true;
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:JurreBuunk/temp-nix-homelab/main#server";
    operation = "switch";
    dates = "*:0/5";
    randomizedDelaySec = "0";
    allowReboot = false;
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    rsync
    unzip
    wget
    vim
  ];

  system.stateVersion = "26.05";
}
