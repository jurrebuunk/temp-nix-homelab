{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/docker.nix
    ./modules/lxc.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixos-server";

    networkmanager = {
      enable = true;

      ensureProfiles.profiles.static-lan = {
        connection = {
          id = "static-lan";
          type = "ethernet";
          autoconnect = true;
          autoconnect-priority = 100;
        };

        ipv4 = {
          method = "manual";
          addresses = "192.168.2.31/24";
          gateway = "192.168.2.254";
          dns = "1.1.1.1";
        };

        ipv6.method = "auto";
      };
    };
  };

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

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    rsync
    unzip
    wget
  ];

  system.stateVersion = "26.05";
}
