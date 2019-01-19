{ stdenv
, lib
, buildPythonPackage
, fetchFromGitHub
, sphinx
}:

buildPythonPackage rec {
  version = "0.1.5";
  pname = "sphinxcontrib-autoprogram";

  # pypi doesn't files necessary for tests (doc/cli.py)
  src = fetchFromGitHub {
    owner = "sphinx-contrib";
    repo = "autoprogram";
    rev = version;
    sha256 = "1ql2hvi1fby6j84ldjf96pyfh6drvcvyhshcp61s53d7x0ldvsv8";
  };

  propagatedBuildInputs = [
    sphinx
  ];

  meta = with lib; {
    description = "A Sphinx extension to document CLI programs";
    homepage = "https://github.com/sphinx-contrib/autoprogram";
    license = licenses.bsd2;
    maintainers = with maintainers; [ timokau ];
  };

}
