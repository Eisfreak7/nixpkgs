{ stdenv
, fetchpatch
, python
, buildPythonPackage
, fetchFromGitHub
, mathjax
, twisted
, flask
, flask-oldsessions
, flask-openid
, flask-autoindex
, flask-babel
}:

# Has a cyclic dependency with sage (not expressed here) and is not useful outside of sage.
# Deprecated, hopefully soon to be removed. See
# https://trac.sagemath.org/ticket/25837

buildPythonPackage rec {
  pname = "sagenb";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "sagemath";
    repo = "sagenb";
    rev = version;
    sha256 = "0bxvhr03qh2nsjdfc4pyfiqrn9jhp3vf7irsc9gqx0185jlblbxs";
  };

  propagatedBuildInputs = [
    twisted
    flask
    flask-oldsessions
    flask-openid
    flask-autoindex
    flask-babel
  ];

  # tests depend on sage
  doCheck = false;

  # patches = [
  #   # work with latest flask-babel
  #   (fetchpatch {
  #     url = "https://github.com/sagemath/sagenb/commit/ba065eca63dd34a383e4c7ba7561430a90fcd087.patch";
  #     sha256 = "1lamzsrgymdd618imrasjp6ivhw2aynh83gkybsd7pm1rzjcq4x8";
  #   })
  # ];

  meta = with stdenv.lib; {
    description = "Sage Notebook";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ timokau ];
  };

  # let sagenb use mathjax
  postInstall = ''
    mkdir -p "$out/${python.sitePackages}/sagenb/data"
    ln -s ${mathjax}/lib/node_modules/mathjax "$out/${python.sitePackages}/sagenb/data/mathjax"
  '';
}
