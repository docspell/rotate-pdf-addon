{
  description = "A docspell addon for basic audio file support";

  inputs = {
    utils.url = "github:numtide/flake-utils";

    # Nixpkgs / NixOS version to use.
    nixpkgs.url = "nixpkgs/nixos-21.11";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [

          ];
        };
        name = "rotate-pdf-addon";
      in rec {
        packages.${name} = pkgs.callPackage ./nix/addon.nix {
          inherit name;
        };

        defaultPackage = packages.${name};

        apps.${name} = utils.lib.mkApp {
          inherit name;
          drv = packages.${name};
        };
        defaultApp = apps.${name};

        devShell = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.packages.${system};
          buildInputs =
            [ pkgs.guile
              pkgs.guile-json
              pkgs.qpdf
              pkgs.poppler_utils
            ];

          ADDON_DIR = self;
          TMPDIR = "/tmp";
          ITEM_DATA_JSON="test/item_data.json";
          ITEM_PDF_DIR="test/pdf";
          TMP_DIR="test/tmp";
          CACHE_DIR="test/tmp";
          OUTPUT_DIR="test/tmp";
          GUILE_WARN_DEPRECATED="detailed";
        };
      }
    );
}
