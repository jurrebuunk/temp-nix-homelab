{ lib, ... }:

{
  networking = {
    useDHCP = false;
    useNetworkd = true;

    # NetworkManager does not manage Linux bridges as predictably as networkd
    # for this headless server setup.
    networkmanager.enable = lib.mkForce false;

    nameservers = [
      "192.168.2.254"
      "1.1.1.1"
    ];
  };

  systemd.network = {
    enable = true;

    netdevs."10-br0".netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };

    # Attach the physical LAN interface to br0. Match both predictable Ethernet
    # names (eno1/enp*/enx*) and legacy names (eth0).
    networks."10-lan-uplink" = {
      matchConfig.Name = "en* eth*";
      networkConfig = {
        Bridge = "br0";
        LinkLocalAddressing = "no";
      };
    };

    networks."20-br0" = {
      matchConfig.Name = "br0";
      address = [ "192.168.2.31/24" ];
      gateway = [ "192.168.2.254" ];
      dns = [
        "192.168.2.254"
        "1.1.1.1"
      ];
      networkConfig.IPv6AcceptRA = true;
    };
  };
}
