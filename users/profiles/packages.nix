{
  inputs,
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
      alsa-lib
      alsa-plugins
      alsa-tools
      alsa-utils
      bandwhich
      bc
      blueberry
      btop
      bottom
      cairo
      cached-nix-shell
      cinnamon.nemo
      coreutils
      comma
      dconf
      droidcam
      findutils
      ffmpeg-full
      fzf
      flameshot
      glib
      glxinfo
      gnumake
      gnuplot
      gnused
      gnutls
      google-chrome
      grex
      hyperfine
      imagemagick
      inotify-tools
      keepassxc
      killall

      lazygit
      libappindicator
      libnotify
      libsecret
      # libreoffice-fresh
      lutris
      microsoft-edge
      netease-cloud-music-gtk
      nil
      nodejs
      obinskit
      openssl
      pamixer
      piper
      psmisc
      pavucontrol
      pulseaudio
      python3
      rsync
      todo
      tdrop
      thefuck
      trash-cli
      util-linux
      vscode
      wineWowPackages.fonts
      wineWowPackages.unstableFull
      winetricks
      wirelesstools
      xarchiver
      xclip
      xdg-utils
      xh
      xorg.xhost
      yesplaymusic
      yuzu-ea
      zoom-us
      gnome.zenity
      catimg
      duf
      du-dust
      fd
      file
      joshuto
      ranger
      ripgrep
      yt-dlp
    ]
    ++ (with pkgs.inur; [
      autohide-tdrop
      krabby
      leagueoflegends
    ])
    ++ (with pkgs.nur.repos; [
      xddxdd.wechat-uos
      xddxdd.baidupcs-go
    ]);

  programs = {
    exa.enable = true;

    fzf = {
      enable = false;
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;
    };

    mcfly = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    bat = {
      enable = true;
    };
  };
}
