{
  config,
  pkgs,
  lib,
  ...
}: {
  networking = {
    networkmanager = {
      enable = true;
      unmanaged = ["docker0" "rndis0"];
      wifi.macAddress = "random";
    };

    firewall = {
      enable = false;
      allowPing = true;
      logReversePathDrops = true;
      allowedUDPPortRanges = [
        # warframe
        {
          from = 4990;
          to = 4995;
        }
      ];
    };
  };

  # slows down boot time
  systemd.services.NetworkManager-wait-online.enable = false;
}
