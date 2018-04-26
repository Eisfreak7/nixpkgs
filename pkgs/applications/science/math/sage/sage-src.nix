{ pkgs
, fetchFromGitHub
, fetchpatch
, stdenv
}:
pkgs.stdenv.mkDerivation rec {
  version = "8.1"; # TODO
  name = "sage-src-${version}";

  src = fetchFromGitHub {
    owner = "sagemath";
    repo = "sage";
    rev = "8.1";
    sha256 = "035qvag43bmcwr9yq4qywx7pphzldlb6a0bwldr01qbgv3ny5j40";
  };

  patches = [
    # Make pkgconfig return lists instead of sets
    # FIXME still necessary?
    ./patches/pkgconfig-set.patch
    ./patches/spkg-paths.patch
    # FIXME
    ./patches/no-jupyter-kernel.patch
    ./patches/maxima-absolute-paths.patch
    # Tests in nix unnecessary behaviour
    ./patches/disable-refusing-doctests-test.patch
    ./patches/remove-python-workarounds.patch
    ./patches/python3-syntax-warning-lenient.patch
    ./patches/remove-sage-started.patch
    ./patches/qepcad-config-optional.patch
    ./patches/respect-jupyter-path.patch
    ./patches/python-5755-hotpatch.patch
    ./patches/add-cysignals-include.patch
    ./patches/find_library.patch
    ./patches/no-python3-syntax-test.patch
    # FIXME this is a *temporary* fix for the timeout which is caused by PYTHONPATH being slow
    # and adding *significant* (~2s) overhead to python startup
    ./patches/increase_timeout.patch
    ./patches/doctests_optional.patch

    # Update linbox, fixed in sage-8.2
    # https://git.sagemath.org/sage.git/commit?id=dac963f5985bf6b9c40b1aad619946b5a1f917d7
    (fetchpatch {
      url = "https://git.sagemath.org/sage.git/patch/?id=dac963f5985bf6b9c40b1aad619946b5a1f917d7";
      sha256 = "0m8s225p0i8cvj04n0wbk12az6193gf7hp0y3cbnhi47mg99d2xb";
    })
    # More for the linbox update
    (fetchpatch {
      url = "https://git.sagemath.org/sage.git/patch/?id=4c1474a6c04ddfab86c79b2ab6809ebfdfba3d49";
      sha256 = "1nkhdrwqj9bidy57nh2rwhrb1aib8a9ra3rc613prci50883cl35";
    })

    # Patch the giac true symbol to be compatible with giac >= 1.2.3-57 (included in 8.2)
    (fetchpatch {
      url = "https://git.sagemath.org/sage.git/patch/?id=9141f652ae719f1db96f33eaa096ad5ab4e545c3";
      sha256 = "0yi2bxl58q2i1i261p9brpgynhf27nq8mh4fk8a25sdvixb36f2v";
    })

    # sphinx 1.6 -> 1.7 upgrade (should be included in 8.2)
    # this is https://git.sagemath.org/sage.git/patch?id=676a1d533bb97c7006651f353a26dd20ab001ae1 stripped of all build/pkgs patches, since those are not applicable to the sage 8.1 source
    ./patches/sphinx-1.7.patch

    # Update singular to 4.1.1 (not yet upstreamed, might not land in sage 8.2)
    # See https://groups.google.com/forum/#!topic/sage-packaging/cS3v05Q0zso
    # TODO
    # (fetchpatch {
    #   url = "https://git.archlinux.org/svntogit/community.git/plain/trunk/sagemath-singular-4.1.1.patch?h=packages/sagemath";
    #   sha256 = "1adz6lrpvywqk1aym8pfsvadly8r476a0isyqlpzyg9dpyn2mspa";
    # })

    # Ignore pari stack warnings in doctests (upstream patches pari instead)
    (fetchpatch {
      url = "https://sources.debian.org/data/main/s/sagemath/8.1-7/debian/patches/u2-pari-stackwarn.patch";
      sha256 = "0m8vr5v0lwq0d3iar3qc82wdsw81n0c0qqdifijqbrqiyqskchd1";
      stripLen = 1;
    })

    # Adapt to new ipython (5.5) prompt -- included in 8.2
    (fetchpatch {
      url = "https://git.sagemath.org/sage.git/patch/?id=9c8ee44821b82c0d861990ad37bfcb28521e4238";
      sha256 = "0vxdyavwndk1y3g30nm1kfrxahppf86b49fwdrn6ra9c4zik58yg";
    })

    ./patches/zero_division_error_formatting.patch

    # update matplotlib to 2.1 (included in 8.2)
    # unfortunately this can't be fetched as one patch, since there are rebases and merges included
    (fetchpatch {
      url = "https://sources.debian.org/data/main/s/sagemath/8.1-7/debian/patches/u0-version-matplotlib-2.1.0.patch";
      sha256 = "1a08zhwbms3pwl6sildp57llhz6qhs09p6iwcrpq07708j0g3g7n";
      stripLen = 1;
    })

    # fix speed regression with matplotlib update (included in 8.2)
    (fetchpatch {
      url = "https://git.sagemath.org/sage.git/patch/?h=4d17a73d3e0b7f7151acc4e29146c3992f3ac43c";
      sha256 = "0nx68axixjkqqib5grmgarx6rfva1zpkyiilnciv1lnvwb3b7rka";
    })

    # Adapt hashes to new boost version
    (fetchpatch {
      url = "https://sources.debian.org/data/main/s/sagemath/8.1-7/debian/patches/u1-version-pbori-boost1.62-hashes.patch";
      sha256 = "02hkvlf6djzfsf2nrazra5vfwvc4s8qmlaqfywzkcpnavj6s9ng8";
      stripLen = 1;
    })

    # New glpk version has new warnings, filter those out until upstream sage has found a solution
    (fetchpatch {
      url = "https://sources.debian.org/data/main/s/sagemath/8.1-7/debian/patches/dt-version-glpk-4.65-ignore-warnings.patch";
      sha256 = "0b9293v73wb4x13wv5zwyjgclc01zn16msccfzzi6znswklgvddp";
      stripLen = 1;
    })

    # doctest checks for exact glpk version
    ./patches/glpk-update.patch

    # threejs paths
    (fetchpatch {
      url = "https://sources.debian.org/data/main/s/sagemath/8.1-7/debian/patches/d0-threejs-offline-paths.patch";
      sha256 = "1qpfv678cs152sfp1jrafk0lkdd0jd0mp0n23dsz98yhvh1kfikz";
      stripLen = 1;
    })

    # Maxima version 5.39.0 is hardcoded in the doctests -- change that
    ./patches/maxima-version-hardcode.patch

    # Maxima version 5.41.0 breaks some doctests (the new results are still valid)
    ./patches/maxima-5.41.0-doctests.patch

    # update to ipywidgets 7 (https://trac.sagemath.org/ticket/23177, sage-8.2)
    # the first patch is not part of that update, but otherwise the following patches don't apply
    (fetchpatch {
      url = "https://git.sagemath.org/sage.git/patch/?id=7a0d5ab956fc38a775069521c2f3c6b51187611f";
      sha256 = "0437mf3ca2g4n735ng1r80db8yggxd8bspk3ckflwrqgpj9dnyfb";
    })
    (fetchpatch {
      url = "https://git.sagemath.org/sage.git/patch/?id=e64c034e0ae46dc08ff444bb8a6b85430d2b1c26";
      sha256 = "0f4j8n2gmfqsy1b9fg89qsl86sp4s0wc4dhi5ymlc613w097x9kb";
    })
    (fetchpatch {
      url = "https://git.sagemath.org/sage.git/patch/?id=e1c1fa74803213b4d596a83edd198d66ff02211b";
      sha256 = "0p5qvr2m1ai3kl34dlwpqasmdz8aqawmaq590czasg236abz5k90";
    })

    ./patches/zn_poly_version.patch

    # update cddlib from 0.94g to 0.94h
    (fetchpatch {
      url = "https://sources.debian.org/data/main/s/sagemath/8.1-7/debian/patches/u2-version-cddlib-094h.patch";
      sha256 = "0fmw7pzbaxs2dshky6iw9pr8i23p9ih2y2lw661qypdrxh5xw03k";
      stripLen = 1;
    })

    # This didn't work in cddlib < 0.94g, worked in 0.94g but doesn't work again in >0.94g
    # https://trac.sagemath.org/ticket/14479
    ./patches/revert-269c1e1551285.patch

    # FIXME
    # (fetchpatch {
    #   name = "sagemath-cython-source.patch";
    #   url = "https://github.com/sagemath/sage/commit/fccaf230.patch";
    #   sha256 = "0jyxzghgfsp3snnpp7l2di930hafvf7zyngc87zqw58rwrz22lfy";
    # })
    # (fetchpatch {
    #   name = "sagemath-cython-0.28a.patch";
    #   url = "https://github.com/sagemath/sage/commit/348432f7.patch";
    #   sha256 = "0g20zg0r67kvl16ycq69zm0y08918c9qx14ydkmhkq2b6wfic0ww";
    # })
    # (fetchpatch {
    #   name = "sagemath-cython-0.28b.patch";
    #   url = "https://github.com/sagemath/sage/commit/609a04de.patch";
    #   sha256 = "06fzbsni84y8abnsm7r46fhyi8gg4m4gl8c1gxiaxxfc04r5i4mc";
    # })
    # (fetchpatch {
    #   name = "sagemath-cython-0.28c.patch";
    #   url = "https://git.archlinux.org/svntogit/community.git/plain/trunk/sagemath-cython-0.28c.patch?h=packages/sagemath&id=434435a400fa9f6078ad4e3078dceb2a1d1f7591";
    #   sha256 = "0arqv0hp5q5061q6a5lhilms0v98f04yns33lqagbl6y2k97nrmv";
    # })
    # (fetchpatch {
    #   name = "sagemath-cython-0.28d.patch";
    #   url = "https://github.com/sagemath/sage/commit/c331d9bb.patch";
    #   sha256 = "0shac7inz08wcqd9vmsqvigb6gw1vqdnfry6vqmxc0qsq69rjafi";
    # })
  ];

  configurePhase = "true";

  buildPhase = "true";

  installPhase = ''
    cp -r . "$out"
  '';
}
