{
  description = "Unsure is used to calculate with numbers you're not sure about";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: with nixpkgs; {
        packages.unsure = nixpkgs.outputs.legacyPackages.${system}.buildDartApplication rec {
          pname = "unsure";
          name = pname;
          version = "0.4.0";

          src = ./.;

          # Convert lockfile with `yq . pubspec.lock >"pubspec.lock.json"`
          pubspecLock = lib.importJSON ./pubspec.lock.json;
        };
        devShells.default = mkShell {
          buildInputs = [
            dart
            yq # To convert the lockfile to json
          ];
        };
      }
    );
}
