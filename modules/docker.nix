{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;

    enableOnBoot = true;

    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [
        "--all"
        "--filter=until=168h"
      ];
    };

    daemon.settings = {
      live-restore = true;

      log-driver = "json-file";

      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];
}
