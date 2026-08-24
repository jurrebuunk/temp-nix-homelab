{ lib, pkgs, ... }:

let
  servicesRoot = ../services;

  entries = builtins.readDir servicesRoot;

  hasComposeFile = name:
    builtins.pathExists (servicesRoot + "/${name}/compose.yml")
    || builtins.pathExists (servicesRoot + "/${name}/compose.yaml");

  composeFileName = name:
    if builtins.pathExists (servicesRoot + "/${name}/compose.yml")
    then "compose.yml"
    else "compose.yaml";

  stackNames = lib.filter (
    name: entries.${name} == "directory" && hasComposeFile name
  ) (builtins.attrNames entries);

  stackDir = name: builtins.path {
    path = servicesRoot + "/${name}";
    name = "compose-stack-${name}";
  };

  composeBin = "${pkgs.docker-compose}/bin/docker-compose";

  composeUpScript = name:
    let
      dir = stackDir name;
      file = "${dir}/${composeFileName name}";
      project = lib.escapeShellArg name;
    in pkgs.writeShellScript "compose-${name}-up" ''
      set -euo pipefail

      ${composeBin} --project-name ${project} --file ${file} pull
      ${composeBin} --project-name ${project} --file ${file} up -d --remove-orphans
    '';

  composeDownScript = name:
    let
      dir = stackDir name;
      file = "${dir}/${composeFileName name}";
      project = lib.escapeShellArg name;
    in pkgs.writeShellScript "compose-${name}-down" ''
      set -euo pipefail

      ${composeBin} --project-name ${project} --file ${file} down
    '';
in
{
  assertions = [
    {
      assertion = lib.all (name: builtins.match "[A-Za-z0-9_-]+" name != null) stackNames;
      message = "Docker Compose service directory names under services/ may only contain letters, numbers, '_' and '-'.";
    }
  ];

  systemd.tmpfiles.rules = [
    "d /etc/compose 0750 root root -"
  ];

  systemd.services = lib.listToAttrs (map (name: {
    name = "compose-${name}";
    value = {
      description = "Docker Compose stack ${name}";

      wantedBy = [ "multi-user.target" ];
      wants = [
        "docker.service"
        "network-online.target"
      ];
      after = [
        "docker.service"
        "docker.socket"
        "network-online.target"
      ];

      # If the compose directory changes in Git, nixos-rebuild switch reloads this
      # oneshot unit and runs pull/up again instead of tearing containers down first.
      reloadIfChanged = true;
      restartTriggers = [ (stackDir name) ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        EnvironmentFile = "-/etc/compose/${name}.env";
        ExecStart = "${composeUpScript name}";
        ExecReload = "${composeUpScript name}";
        ExecStop = "${composeDownScript name}";
        TimeoutStartSec = "15min";
        TimeoutStopSec = "5min";
      };
    };
  }) stackNames);
}
