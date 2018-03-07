{stdenv, fetchFromGitHub, automake, autoconf, libtool, autoreconfHook, gmpxx}:
stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "givaro";
  version = "4.0.4";
  src = fetchFromGitHub {
    owner = "linbox-team";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "199p8wyj5i63jbnk7j8qbdbfp5rm2lpmcxyk3mdjy9bz7ygx3hhy";
  };
  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [autoconf automake libtool gmpxx];
  meta = {
    inherit version;
    description = ''A C++ library for arithmetic and algebraic computations'';
    license = stdenv.lib.licenses.cecill-b;
    maintainers = [stdenv.lib.maintainers.raskin];
    platforms = stdenv.lib.platforms.linux;
  };
}
