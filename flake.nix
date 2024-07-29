{
  description = "warashi.dev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    theme = {
      url = "github:jnjosh/internet-weblog";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    theme,
    ...
  } @ inputs: let
    baseURL = "https://times.warashi.dev/";
  in
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [hugo nodejs go];
        };
        packages = pkgs.callPackage ./build.nix {
          inherit theme baseURL;
        };
      }
    );
}
