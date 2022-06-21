{ stdenv }:

stdenv.mkDerivation {
  pname = "hello";
  version = "0";

  src = ./src;

  buildPhase = "make hello";

  installPhase = ''
    install -D -m 0755 hello $out
  '';
}
