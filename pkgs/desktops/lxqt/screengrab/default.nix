{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  autoPatchelfHook,
  gitUpdater,
  kwindowsystem,
  libXdmcp,
  libpthreadstubs,
  libqtxdg,
  perl,
  pkg-config,
  qtbase,
  qtsvg,
  qttools,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "screengrab";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = pname;
    rev = version;
    hash = "sha256-cTDGVNnnjgIiCS/KzEVmTagJvNwDKAP2UrWKwdn3WmE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    perl # needed by LXQtTranslateDesktop.cmake
    qttools
    autoPatchelfHook # fix libuploader.so and libextedit.so not found
    wrapQtAppsHook
  ];

  buildInputs = [
    kwindowsystem
    libXdmcp
    libpthreadstubs
    libqtxdg
    qtbase
    qtsvg
  ];

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    homepage = "https://github.com/lxqt/screengrab";
    description = "Crossplatform tool for fast making screenshots";
    mainProgram = "screengrab";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    teams = [ teams.lxqt ];
  };
}
