{ stdenv
, lib
, fetchurl
, autoreconfHook
, tcl
, tk
, jre
, bison
, flex
, perl
, which
, xdg_utils
, logger
, python2
, libxml2
}:

stdenv.mkDerivation rec {
  pname = "omnetpp";
  version = "5.4.1";
  name = "${pname}-${version}";

  # Distributed via ipfs. Since the current `fetchipfs` doesn't support ipns,
  # we use the official http gateway with `fetchurl` instead.
  src = fetchurl {
    # url = "https://ipfs.omnetpp.org/release/omnetpp-${version}-src-linux.tgz";
    url = "https://ipfs.omnetpp.org/release/omnetpp-${version}-src-core.tgz";
    sha256 = "1bakrhzr4s25a8yxcfkwgf23n34ykpw02zkjccrnwwmz7a5izp6n";
  };

  # should really be postUnpack, but by that time we haven't cd'd into the unpacked directory yet
  # build in $out since there is no `make install` and the build process will leave references to the path it was built in
  preAutoreconf = ''
    mkdir -p "$out"
    cp -r * "$out"
    cd "$out" # since there is no `make install`, build at the target
  '';

  # for reference: https://omnetpp.org/doc/omnetpp/InstallGuide.pdf
  preConfigure = ''
    source setenv -f # set needed environment variables

    mkdir home
    export HOME="$PWD/home"

    export LIBXML_LIBS='-L${libxml2.dev}/lib -lxml2'
    export LIBXML_CFLAGS='-I${libxml2.dev}/include/libxml2'
  '';

  buildFlags = [
     # "cleanall" # force rebuild
     # Build shared library. This isn't done by default since it is distributed in binary form for convenience. We re-build it.
    # "ui"
    "all"
  ];

  # https://groups.google.com/forum/#!topic/omnetpp/vezyKEe8Qek
  postFixup = ''
    echo 'echo "The omnet++ IDE is currently not packaged for Nix."'
  '';

  doCheck = true; # although no acutal checks are present

  patches = [
    # configure checks for perl to be in /usr/bin/perl because that is needed for shebangs to work
    # since we patch shebangs, that is not necessary
    ./patches/0001-Don-t-check-for-perl-in-a-specific-location.patch
    # ./patches/0002-Debug.patch # FIXME
  ];

  postPatch = ''
    substituteInPlace configure.user --replace 'WITH_QTENV=yes' 'WITH_QTENV=no' # FIXME
    substituteInPlace configure.user --replace 'WITH_OSG=yes' 'WITH_OSG=no' # FIXME
    substituteInPlace configure.user --replace 'WITH_OSGEARTH=yes' 'WITH_OSG=no' # FIXME

    # replace error.log file (not writeable) with syslog
    for file in src/utils/omnest src/utils/omnetpp; do
      substituteInPlace "$file" \
        --replace '2>$IDEDIR/error.log' '2>&1 >/dev/null | ${logger}/bin/logger -p user.err -t omnetpp'
    done
    mkdir -p "$out/ide"
    echo 'This is a stub. See the syslog (tag omnetpp) for the logs.' > "$out/ide/error.log"

    substituteInPlace src/utils/omnest --replace 'WITH_OSGEARTH=yes' 'WITH_OSG=no' # FIXME
    echo 'ARFLAG_OUT="-r "' >> configure.user
    patchShebangs .
  '';

  # make install-menu-item
  # make install-desktop-icon

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    tcl
    tk
    jre
    bison
    flex
    perl
    which
    xdg_utils # for make install-desktop-icon
    python2
    libxml2
  ];

  checkPhase = ''
    export PATH="$out/bin:$PATH"
    cd "$out/test"
    # only test core functionality since IDE is not built
    make test_core
  '';

  installPhase = ''
    # actual "installation" happens during build since there is no `make install`
    rm -r $out/test # not necessary
    echo '#! /bin/sh' > "$out/bin/omnetpp" # override default executable that isn't working
    echo ' echo "The omnet++ IDE is not currently packaged for Nix."' >> "$out/bin/omnetpp"
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = ""; # FIXME
    license = {
      # free for non-commercial simulations like at academic institutions and for teaching
      fullName = "Academic Public License";
      url = https://omnetpp.org/intro/license;
    };
    maintainers = with maintainers; [ timokau ];
    platforms = platforms.linux;
  };
}
