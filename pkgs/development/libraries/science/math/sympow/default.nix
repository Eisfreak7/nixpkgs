{ stdenv
, fetchFromGitLab
, makeWrapper
, which
, autoconf
, help2man
, file
, pari
}:

stdenv.mkDerivation rec {
  version = "2.023.2";
  name = "sympow-${version}";

  # src = fetchurl {
  #   url = "https://gitlab.com/rezozer/forks/sympow/-/archive/v${version}/sympow-v${version}.tar.gz";
  #   sha256 = "04xi65141s7n1khppy8v4v9lryf7ccmsra4shw5w90pzj6c0aaap";
  # };

  src = fetchFromGitLab {
    owner = "rezozer/forks";
    repo = "sympow";
    rev = "v${version}";
    sha256 = "1askzb9lv79ci13xzamr38fq49bp6wam4fwspmjdplh4hdx4ybah";
  };

  postUnpack = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    makeWrapper
    which
    autoconf
    help2man
    file
    pari
  ];

  # installFlags = [
  #   "DESTDIR=$(out)"
  # ];
  configurePhase = ''
    runHook preConfigure
    export PREFIX="$out"
    export VARPREFIX="/tmp"
    mkdir -p "$VARPREFIX/cache/sympow/datafiles/le64"
    ./Configure # doesn't take any options
    runHook postConfigure
  '';

  postInstall = ''
    rm -rf $out/share/sympow/datafiles
    #mkdir -p "$out/bin"
    #for data in 1d0 2 2d0h 3d0 3d1 4; do
    #  "$out/bin/sympow" -new_data "$data"
    #done
  '';

  # some tests taken from the README
  # FIXME
  installCheck = ''
    "$out/bin/sympow" -sp 2p16 -curve "[1,2,3,4,5]"
  '';
  # installPhase = ''
  #   runHook preInstall
  #   install -D datafiles/* --target-directory "$out/share/sympow/datafiles/"
  #   install *.gp "$out/share/sympow/"
  #   install -Dm755 sympow "$out/share/sympow/sympow"
  #   install -D new_data "$out/bin/new_data"

  #   makeWrapper "$out/share/sympow/sympow" "$out/bin/sympow" \
  #     --run 'export SYMPOW_LOCAL="$HOME/.local/share/sympow"' \
  #     --run 'if [ ! -d "$SYMPOW_LOCAL" ]; then
  #       mkdir -p "$SYMPOW_LOCAL"
  #       cp -r @out@/share/sympow/* "$SYMPOW_LOCAL"
  #       chmod -R +xw "$SYMPOW_LOCAL"
  #   fi' \
  #     --run 'cd "$SYMPOW_LOCAL"'
  #   substituteInPlace $out/bin/sympow --subst-var out

  #   runHook postInstall
  # '';

  meta = with stdenv.lib; {
    description = "A package to compute special values of symmetric power elliptic curve L-functions";
    license = {
      shortName = "sympow";
      fullName = "Custom, BSD-like. See COPYING file.";
      free = true;
    };
    maintainers = with maintainers; [ timokau ];
    platforms = platforms.all;
  };
}
