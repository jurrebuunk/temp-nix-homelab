{ ... }:

{
  # Host storage used by services/gonic/compose.yml.
  systemd.tmpfiles.rules = [
    "d /srv/gonic 0755 root root -"
    "d /srv/gonic/data 0755 1000 1000 -"
    "d /srv/gonic/cache 0755 1000 1000 -"
    "d /srv/gonic/music 0775 1000 1000 -"
    "d /srv/gonic/podcasts 0775 1000 1000 -"
  ];

  # The NFS server runs in Docker but still uses the host nfsd kernel module.
  boot.kernelModules = [ "nfsd" ];

  networking.firewall.allowedTCPPorts = [
    4747
    2049
  ];
}
