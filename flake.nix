{
  description = "Unsure is used to calculate with numbers you're not sure about";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system:
        with nixpkgs; let
          pkgs = import nixpkgs {
            inherit system;
          };
          unsure = nixpkgs.outputs.legacyPackages.${system}.buildDartApplication rec {
            pname = "unsure";
            name = pname;
            version = "0.4.0";

            src = ./.;

            # Convert lockfile with `yq . pubspec.lock >"pubspec.lock.json"`
            pubspecLock = lib.importJSON ./pubspec.lock.json;
          };
        in {
          packages = {
            default = unsure;
            unsure = unsure;
          };
          apps = rec {
            unsure = flake-utils.lib.mkApp {
              drv = self.packages.${system}.unsure;
            };
            default = unsure;
          };
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              dart
              yq # To convert the lockfile to json
            ];
          };
        }
    );
}
