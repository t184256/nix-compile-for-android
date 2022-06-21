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
        ndkVer = "21";
        sdkVer = "30";
        useAndroidPrebuilt = false;
        libc = "bionic";
        useLLVM = true;
      };

      xNixpkgsPrebuilt = import inputs.nixpkgs {
        system = "x86_64-linux";
        crossSystem = crossSystemAndroidPrebuilt;
      };

      xNixpkgsNonPrebuilt = import inputs.nixpkgs {
        system = "x86_64-linux";
        crossSystem = crossSystemAndroidNonPrebuilt;
      };

      xHelloPrebuilt = xNixpkgsPrebuilt.callPackage ./hello.nix {};
      xHelloNonPrebuilt = xNixpkgsNonPrebuilt.callPackage ./hello.nix {};

    in {
      packages.x86_64-linux = {
        inherit xHelloNonPrebuilt xHelloPrebuilt;
        default = xHelloNonPrebuilt;
      };
    };
}
