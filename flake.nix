{
  description = "Sample Nix ts-node build";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        {
          packages.default = pkgs.buildNpmPackage rec {
            pname = "momme.world-cli";
            version = "1.0.0";
            buildInputs = [
              pkgs.nodejs-18_x
            ];

            src = ./.;

            installPhase = ''
              mkdir $out
              npm run build
              cp -r dist/* $out
            '';

            npmDepsHash = "sha256-hFskq3BgBtp5MdSi0hoEp9TeoAnDEL3N61xEm9LK6/o=";

            meta = {
              description = "A printable calendar generator for the Flatshares";
              homepage = "https://momme.world";
              maintainers = with pkgs.lib.maintainers; [ supermomme ];
            };
          };
          devShells.default = pkgs.mkShell {
            packages = [
              self.packages."${system}".default
            ];
          };
        }
      );
}