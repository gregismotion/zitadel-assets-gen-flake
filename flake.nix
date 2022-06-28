{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix.url = "github:tweag/gomod2nix";
    zitadel-src = {
      type = "git";
      flake = false;
      url = "https://github.com/zitadel/zitadel";
      ref = "refs/tags/v1.84.5";
    };
  };

  outputs =
    { self, nixpkgs, flake-utils, gomod2nix, zitadel-src }:
    let
      overlays = [ gomod2nix.overlays.default ];
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      rec {
        packages = flake-utils.lib.flattenTree
        { 
          zitadel-assets-gen = pkgs.buildGoApplication {
              name = "zitadel-assets-gen";
              src = "${zitadel-src}";
              modules = ./gomod2nix.toml;
              subPackages = [ 
                "internal/api/assets/generator" 
              ];
              go = pkgs.go_1_17;
          };
        };
        
        defaultPackage = packages.zitadel-assets-gen;

        apps.zitadel-assets-gen = flake-utils.lib.mkApp { name = "zitadel-assets-gen"; drv = packages.zitadel-assets-gen; };
      });
}

