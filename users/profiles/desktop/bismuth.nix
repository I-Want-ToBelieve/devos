{pkgs, ...}: {
  home.packages = with pkgs; [
    # @see https://ryantm.github.io/nixpkgs/stdenv/stdenv/#:~:text=As%20described%20in%20the%20Nix%20manual%2C%20almost%20any,so%20that%20certain%20other%20setup%20can%20take%20place.
    # @see https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/desktops/plasma-5/3rdparty/addons/bismuth/default.nix#L43
    # @see https://ryantm.github.io/nixpkgs/using/overrides/#sec-pkg-overrideAttrs
    # @see https://github.com/Bismuth-Forge/bismuth/issues/474
    # @see https://github.com/Bismuth-Forge/bismuth/blob/ef69afe69f615149ab347e4402862ee900452a65/src/kdecoration/decoration.cpp#L63-L64
    # @see https://discourse.nixos.org/t/how-to-patch-in-an-overlay/3678
    # @see https://stackoverflow.com/a/28484585
    (libsForQt5.bismuth.overrideAttrs
      (finalAttrs: previousAttrs: {
        src = /home/i.want.to.believe/git.workspaces/any.workspaces/bismuth/.;
        version = "5.0.6";
      }))
  ];
}
