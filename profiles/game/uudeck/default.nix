{pkgs, ...}: {
  environment.etc = {
    "uu/uuplugin_monitor.config".source = ./uuplugin_monitor.config;
    "uu/uuplugin_monitor.sh".source = ./uuplugin_monitor.sh;
    "uu/uninstall.sh".source = ./uninstall.sh;
  };

  systemd.services.uuplugin = {
    description = "UU Plugin";
    path = with pkgs; [coreutils curl wget gawk procps iproute2];
    wants = ["network-online.target"];
    after = ["network.target" "network-online.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "/etc/uu/uuplugin_monitor.sh";
    };
  };
}
