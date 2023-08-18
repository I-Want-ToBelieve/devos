final: prev: {
  # keep sources this first
  sources = prev.callPackage (import ./_sources/generated.nix) {};
  # then, call packages with `final.callPackage`
  swhkd = prev.callPackage ./applications/window-managers/swhkd {};
  aliyunpan = prev.callPackage ./applications/cloud-drive/aliyunpan {};
  mpv-iptvplus = prev.callPackage ./applications/video/mpv/scripts/mpv-iptvplus.nix {};
}
