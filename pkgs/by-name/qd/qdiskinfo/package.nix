{
  lib,
  stdenv,
  smartmontools,
  fetchFromGitHub,
  fetchzip,
  cmake,
  qt6,
  qdiskinfo,
  themeBundle ? null,
  unstableGitUpdater,
}:

let
  isThemed = themeBundle != null && themeBundle != { };
  themeBundle' =
    if isThemed then
      {
        rightCharacter = false;
      }
      // themeBundle
    else
      { rightCharacter = false; };
in

# check theme bundle
assert
  isThemed
  -> (
    themeBundle' ? src
    && themeBundle' ? paths.bgDark
    && themeBundle' ? paths.bgLight
    && themeBundle' ? paths.status
    && themeBundle' ? rightCharacter
  );

stdenv.mkDerivation {
  pname = "qdiskinfo";
  version = "0.3-unstable-2025-05-08";

  src = fetchFromGitHub {
    owner = "edisionnano";
    repo = "QDiskInfo";
    rev = "3416cc7ac19b25bb78eab135cf5e0b281e506de0";
    hash = "sha256-loL6fzOSoZyCmrs7joHQCsCStLGgKxmMuqFmtADWTW0=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    smartmontools
  ];

  cmakeBuildType = "MinSizeRel";

  cmakeFlags =
    [
      "-DQT_VERSION_MAJOR=6"
    ]
    ++ lib.optionals isThemed [ "-DINCLUDE_OPTIONAL_RESOURCES=ON" ]
    ++ (
      if themeBundle'.rightCharacter then
        [ "-DCHARACTER_IS_RIGHT=ON" ]
      else
        [ "-DCHARACTER_IS_RIGHT=OFF" ]
    );

  postUnpack = ''
    cp -r $sourceRoot $TMPDIR/src
    sourceRoot=$TMPDIR/src
  '';
  patchPhase = lib.optionalString isThemed ''
    export SRCPATH=${themeBundle'.src}/CdiResource/themes/
    export DESTPATH=$sourceRoot/dist/theme/
    mkdir -p $DESTPATH
    if [ -n "${themeBundle'.paths.bgDark}" ]; then
      cp $SRCPATH/${themeBundle'.paths.bgDark} $DESTPATH/bg_dark.png
    fi
    if  [ -n "${themeBundle'.paths.bgLight}" ]; then
      cp $SRCPATH/${themeBundle'.paths.bgLight} $DESTPATH/bg_light.png
    fi
    cp $SRCPATH/${themeBundle'.paths.status}/SDdiskStatusBad-300.png $DESTPATH/bad.png
    cp $SRCPATH/${themeBundle'.paths.status}/SDdiskStatusCaution-300.png $DESTPATH/caution.png
    cp $SRCPATH/${themeBundle'.paths.status}/SDdiskStatusGood-300.png $DESTPATH/good.png
    cp $SRCPATH/${themeBundle'.paths.status}/SDdiskStatusUnknown-300.png $DESTPATH/unknown.png
  '';
  postInstall = ''
    wrapProgram $out/bin/QDiskInfo \
      --suffix PATH : ${smartmontools}/bin
  '';

  passthru =
    let
      themeSources = import ./sources.nix { inherit fetchzip; };
    in
    rec {
      themeBundles = import ./themes.nix { inherit themeSources; };
      tests = lib.flip lib.mapAttrs themeBundles (
        themeName: themeBundle:
        (qdiskinfo.override { inherit themeBundle; }).overrideAttrs { pname = "qdiskinfo-${themeName}"; }
      );
      updateScript = unstableGitUpdater { };
    };

  meta = {
    description = "CrystalDiskInfo alternative for Linux";
    homepage = "https://github.com/edisionnano/QDiskInfo";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      roydubnium
      ryand56
    ];
    platforms = lib.platforms.linux;
    mainProgram = "QDiskInfo";
  };
}
