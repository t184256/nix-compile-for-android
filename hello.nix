{ stdenv }:

stdenv.mkDerivation {
  pname = "hello";
  version = "0";

  src = ./src;

  buildPhase = "make CFLAGS=-static hello";

  installPhase = ''
    install -D -m 0755 hello $out
  '';
}
