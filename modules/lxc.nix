{ pkgs, ... }:

{
  virtualisation.lxc = {
    enable = true;

    # Also enables the upstream lxc-net service, which creates a NATed
    # bridge at lxcbr0 for simple test containers.
    unprivilegedContainers = true;

    lxcfs.enable = true;

    bridgeConfig = ''
      USE_LXC_BRIDGE="true"
      LXC_BRIDGE="lxcbr0"
      LXC_ADDR="10.0.3.1"
      LXC_NETMASK="255.255.255.0"
      LXC_NETWORK="10.0.3.0/24"
      LXC_DHCP_RANGE="10.0.3.2,10.0.3.254"
      LXC_DHCP_MAX="253"
    '';

    defaultConfig = ''
      lxc.net.0.type = veth
      lxc.net.0.link = lxcbr0
      lxc.net.0.flags = up
      lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
      lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf
    '';

    usernetConfig = ''
      jurre veth lxcbr0 10
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
