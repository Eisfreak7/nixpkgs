{ stdenv, fetchurl, pkgconfig, libxml2, glib, fetchpatch, gnome3 }:
let
  pname = "libcroco";
  version = "0.6.12";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "0q7qhi7z64i26zabg9dbs5706fa8pmzp1qhpa052id4zdiabbi6x";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2017-7960.patch";
      url = "https://git.gnome.org/browse/libcroco/patch/?id=898e3a8c8c0314d2e6b106809a8e3e93cf9d4394";
      sha256 = "1xjwdqijxf4b7mhdp3kkgnb6c14y0bn3b3gg79kyrm82x696d94l";
    })
    (fetchpatch {
      name = "CVE-2017-7961.patch";
      url = "https://git.gnome.org/browse/libcroco/patch/?id=9ad72875e9f08e4c519ef63d44cdbd94aa9504f7";
      sha256 = "0zakd72ynzjgzskwyvqglqiznsb93j1bkvc1lgyrzgv9rwrbwv9s";
    })
  ];

  outputs = [ "out" "dev" ];
  outputBin = "dev";

  configureFlags = stdenv.lib.optional stdenv.isDarwin "--disable-Bsymbolic";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libxml2 glib ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    description = "GNOME CSS2 parsing and manipulation toolkit";
    homepage = https://git.gnome.org/browse/libcroco;
    license = licenses.lgpl2;
    platforms = platforms.unix;
  };
}
