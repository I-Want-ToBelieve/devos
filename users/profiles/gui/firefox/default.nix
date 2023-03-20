{
  config,
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;

    package = pkgs.firefox-wayland;

    profiles = {
      "i.want.to.believe" = {
        id = 0;
        settings = {
          "general.smoothScroll" = true;
        };

        # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        #   adnauseam
        #   enhanced-github
        #   enhancer-for-youtube
        #   octotree
        #   refined-github
        #   stylus
        #   ublock-origin
        # ];
        extensions = [];

        userChrome = import ./userChrome-css.nix;
        userContent = import ./userContent-css.nix;

        extraConfig = ''
          user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
          user_pref("full-screen-api.ignore-widgets", true);
          user_pref("media.ffmpeg.vaapi.enabled", true);
          user_pref("media.rdd-vpx.enabled", true);
        '';
      };
    };
  };
}
