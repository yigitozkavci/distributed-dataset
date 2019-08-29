let
sources = import ./nix/sources.nix;
in

{ pkgs ? import sources.nixpkgs { config.allowBroken = true; }
}:

let
gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];

overlays = se: su: {
  "distributed-dataset" =
    se.callCabal2nix
      "distributed-dataset"
      (gitignore ./distributed-dataset)
      {};

  "distributed-dataset-aws" =
    let orig = se.callCabal2nix
                 "distributed-dataset-aws"
                 (gitignore ./distributed-dataset-aws)
                 {};
    in  pkgs.haskell.lib.overrideCabal orig (_: {
          extraLibraries = with pkgs; [
            glibc glibc.static zlib.static
            (libffi.override { stdenv = makeStaticLibraries stdenv; })
            (gmp.override { withStatic = true; })
          ];
    });

  "distributed-dataset-opendatasets" =
    se.callCabal2nix
      "distributed-dataset-opendatasets"
      (gitignore ./distributed-dataset-opendatasets)
      {};

  "example-gh" =
    let orig = se.callCabal2nix
                 "example-gh"
                 (gitignore ./examples/gh)
                 {};
    in  pkgs.haskell.lib.overrideCabal orig (_: {
          extraLibraries = with pkgs; [
            glibc glibc.static zlib.static
            (libffi.override { stdenv = makeStaticLibraries stdenv; })
            (gmp.override { withStatic = true; })
          ];
    });

  # not on Hackage yet
  ormolu = se.callCabal2nix "ormolu" sources.ormolu {};

  amazonka-core =
    pkgs.haskell.lib.doJailbreak su.amazonka-core;

  amazonka =
    pkgs.haskell.lib.doJailbreak su.amazonka;
};

haskellPackages = pkgs.haskell.packages.ghc865.override {
  overrides = overlays;
};

in rec
{
  "distributed-dataset" = haskellPackages.distributed-dataset;
  "distributed-dataset-aws" = haskellPackages.distributed-dataset-aws;
  "distributed-dataset-opendatasets" = haskellPackages.distributed-dataset-opendatasets;
  "example-gh" = haskellPackages.example-gh;

  inherit haskellPackages;

  docs = pkgs.runCommand "distributed-dataset-docs" {
    buildInputs =
      [ (haskellPackages.ghcWithPackages (hp: with hp;
          [ distributed-dataset distributed-dataset-aws distributed-dataset-opendatasets ]))
        haskellPackages.standalone-haddock
      ];
  } ''
    mkdir "$out"
    standalone-haddock \
      --dist-dir "$(mktemp -d)" \
      -o "$out" \
      ${distributed-dataset.src} \
      ${distributed-dataset-aws.src} \
      ${distributed-dataset-opendatasets.src}
  '';

  shell = haskellPackages.shellFor {
    packages = p: with p; [
      distributed-dataset
      distributed-dataset-aws
      distributed-dataset-opendatasets
      example-gh
    ];
    buildInputs = with haskellPackages; [
      cabal-install
      ghcid
      ormolu
    ];
    withHoogle = true;
  };
}
