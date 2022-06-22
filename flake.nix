{
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = inputs:
    let
      crossSystemAndroidPrebuilt = {
        config = "aarch64-unknown-linux-android";
        ndkVer = "21";
        sdkVer = "29";
        useAndroidPrebuilt = true;
      };

      crossSystemAndroidNonPrebuilt = {
        config = "aarch64-unknown-linux-android";
        sdkVer = "32";
        useAndroidPrebuilt = false;
        libc = "bionic";
        useLLVM = true;
        isStatic = true;
      };

      xNixpkgsPrebuilt = import inputs.nixpkgs {
        system = "x86_64-linux";
        crossSystem = crossSystemAndroidPrebuilt;
      };

      xNixpkgsNonPrebuilt = import inputs.nixpkgs {
        system = "x86_64-linux";
        crossSystem = crossSystemAndroidNonPrebuilt;
      };
      ss = xNixpkgsNonPrebuilt.pkgsStatic.stdenvAdapters.makeStaticBinaries xNixpkgsNonPrebuilt.stdenv;

      xHelloPrebuilt = xNixpkgsPrebuilt.callPackage ./hello.nix {};
      xHelloNonPrebuilt = xNixpkgsNonPrebuilt.callPackage ./hello.nix {
        stdenv = ss;
      };

      nonXNixpkgsNonPrebuilt = import inputs.nixpkgs {
        system = "aarch64-linux";
        crossSystem = crossSystemAndroidNonPrebuilt;
      };
      nonXHelloNonPrebuilt = xNixpkgsNonPrebuilt.callPackage ./hello.nix {
        stdenv =
            nonXNixpkgsNonPrebuilt.pkgsStatic.stdenvAdapters.makeStaticBinaries
            nonXNixpkgsNonPrebuilt.stdenv;
      };

    in {
      packages.x86_64-linux = {
        inherit xHelloNonPrebuilt xHelloPrebuilt;
        default = xHelloNonPrebuilt;
      };

      packages.aarch64-linux = {
        inherit nonXHelloNonPrebuilt;
        default = nonXHelloNonPrebuilt;
      };
    };
}
