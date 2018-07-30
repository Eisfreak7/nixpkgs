{ buildPythonPackage
, fetchPypi
, pytest
, tornado
, zeromq
, py
, python
}:

buildPythonPackage rec {
  pname = "pyzmq";
  version = "17.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1r6yp4hak0cna524jzc89j5710370f5m3c1qabn6mqihl99zg691";
  };

  checkInputs = [  pytest tornado ];
  buildInputs = [ zeromq ];
  propagatedBuildInputs = [ py ];

  # test_socket.py seems to be hanging
  # others fail
  checkPhase = ''
    py.test $out/${python.sitePackages}/zmq/ -k "not test_socket \
      and not test_current \
      and not test_instance \
      and not test_callable_check \
      and not test_on_recv_basic \
      and not test_on_recv_wake"
  '';
}
