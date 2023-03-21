{pkgs, ...}: {
  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";

  environment.systemPackages = [
    pkgs.libsForQt5.bismuth
  ];
}
