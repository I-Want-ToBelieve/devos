{
  lib,
  pkgs,
  ...
}: {
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";

    extraLocaleSettings = {
      LC_TIME = lib.mkDefault "en_US.UTF-8";
    };

    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];

    inputMethod = {
      enabled = "fcitx5";
      fcitx5.enableRimeData = true;
      fcitx5.addons = with pkgs;
      with inur; [
        fcitx5-rime
        fcitx5-gtk
        fcitx5-chinese-addons
        libsForQt5.fcitx5-qt
        rime-cloverpinyin
        fcitx5-theme-catppuccin
      ];
    };
  };

  time = {
    timeZone = lib.mkDefault "Asia/Shanghai";
    hardwareClockInLocalTime = true;
  };
}
