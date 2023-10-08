{
  lib,
  mkDerivation,
  cmake,
  extra-cmake-modules,
  qtx11extras,
  plasma-framework,
  kdecoration,
  qtbase,
  qtdeclarative,
  kirigami2,
  xrandr,
  libSM,
  plasma-workspace,
  unstableGitUpdater,
  sources,
}: let
  inherit (sources.plasma5-applets-window-appmenu) pname src version;
in
  mkDerivation {
    inherit pname src version;

    nativeBuildInputs = [cmake extra-cmake-modules];

    buildInputs = [
      qtx11extras
      plasma-framework
      kdecoration
      qtbase
      qtdeclarative
      kirigami2
      xrandr
      libSM
      plasma-workspace
    ];

    passthru = {
      updateScript = unstableGitUpdater {};
    };

    meta = with lib; {
      description = "Plasma 5 applet in order to show the window appmenu";
      homepage = "https://github.com/psifidotos/applet-window-appmenu";
      license = licenses.gpl2;
    };
  }
