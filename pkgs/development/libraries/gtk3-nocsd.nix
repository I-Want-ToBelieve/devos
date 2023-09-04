{
  stdenv,
  pkgconfig,
  gtk3,
  gobject-introspection,
  sources,
}: let
  inherit (sources.gtk3-nocsd) pname src version;
in
  stdenv.mkDerivation {
    inherit pname src version;

    buildInputs = [
      gtk3
      gobject-introspection
    ];

    nativeBuildInputs = [
      pkgconfig
    ];

    makeFlags = [
      "prefix=${placeholder "out"}"
    ];
  }
