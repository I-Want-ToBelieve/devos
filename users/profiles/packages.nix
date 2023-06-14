{
  inputs,
  pkgs,
  config,
  ...
}: let
  mpv-unwrapped = pkgs.mpv-unwrapped.overrideAttrs (o: {
    src = pkgs.fetchFromGitHub {
      owner = "mpv-player";
      repo = "mpv";
      rev = "48ad2278c7a1fc2a9f5520371188911ef044b32c";
      sha256 = "sha256-6qbv34ysNQbI/zff6rAnVW4z6yfm2t/XL/PF7D/tjv4=";
    };
  });
in {
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
      mpv-unwrapped
      netease-cloud-music-gtk
      nil
      nodejs
      obinskit
      pamixer
      piper
      psmisc
      pavucontrol
      pulseaudio
      python3
      rsync
      todo
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
      zoom-us
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
      enable = true;
      enableBashIntegration = true;
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
