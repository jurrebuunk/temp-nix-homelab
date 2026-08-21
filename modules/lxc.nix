{ pkgs, ... }:

{
  virtualisation.lxc = {
    enable = true;

    # Allows unprivileged LXC users to attach veth devices to br0.
    unprivilegedContainers = true;

    lxcfs.enable = true;

    bridgeConfig = ''
      USE_LXC_BRIDGE="false"
    '';

    defaultConfig = ''
      lxc.net.0.type = veth
      lxc.net.0.link = br0
      lxc.net.0.flags = up
      lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
      lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf
    '';

    usernetConfig = ''
      jurre veth br0 10
    '';
  };

  users.users.jurre = {
    extraGroups = [ "lxc-user" ];
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    gnutar
    lxc
    rsync
    xz
    zstd
  ];
}
