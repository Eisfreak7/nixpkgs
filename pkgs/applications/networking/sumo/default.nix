{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, pkgconfig
, fox_1_6
, xercesc
, proj
, gdal
, libX11
, mesa
, libGLU
, lzma
, libjpeg
, poppler
, qhull
, hdf5
, hdf4
, curl
, libtiff
, sqlite
, python2
, ffmpeg ? null
, withVideo ? true # ffmpeg for video output support
}:

stdenv.mkDerivation rec {
  name = "sumo-${version}";
  version = "1.0.1";

  # For reference: http://sumo.dlr.de/wiki/Installing/Linux_Build
  src = fetchFromGitHub {
    owner = "eclipse";
    repo = "sumo";
    rev = "v${ lib.replaceStrings [ "." ] [ "_" ] version }";
    sha256 = "0mdn88lnimhy8ydm2cbglxi08jafik3msndcg9ml3saz1v6858qf";
  };

  postPatch = ''
    patchShebangs .
  '';

  preBuild = ''
    export SUMO_HOME="$PWD"
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkgconfig # for some reason needed for autoreconf
  ];

  buildInputs = [
    fox_1_6
    xercesc
    proj
    gdal
    libX11
    ffmpeg
    mesa
    libGLU
    lzma
    libjpeg
    poppler
    qhull
    hdf4
    hdf5
    curl
    libtiff
    sqlite
    python2
  ] ++ lib.optionals withVideo [
    ffmpeg
  ];

  NIX_CFLAGS_COMPILE = "-fpermissive"; # invalid conversions to FX::FXObject

  enableParallelBuilding = true;

  # Tests need texttest, which is not packaged. See
  # https://github.com/eclipse/sumo/blob/master/tests/README_Tests.md
  # https://github.com/eclipse/sumo/blob/master/tests/runTests.sh
  doCheck = false;

  # sanity checks
  doInstallCheck = true;
  installCheckPhase = ''
    "$out/bin/sumo" --help || exit 1
    "$out/bin/sumo" --version | grep '${version}' || exit 1
  '';

  meta = with lib; {
    description = "Simulation of Urban MObility";
    homepage = http://sumo.dlr.de/;
    license = licenses.epl20;
    maintainers = with maintainers; [ timokau ];
    platforms = platforms.linux;
  };
}
