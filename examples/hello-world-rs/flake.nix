{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    overrides = (builtins.fromTOML (builtins.readFile ./rust-toolchain.toml));
    pkgs = nixpkgs.legacyPackages.x86_64-linux.pkgs;
  in {

    devShells.x86_64-linux.default = pkgs.mkShell {
      strictDeps = true;
      nativeBuildInputs = with pkgs; [
        rustup
        rustPlatform.bindgenHook
      ];
      # libraries here
      buildInputs =
        [
        ];
      RUSTC_VERSION = overrides.toolchain.channel;
      # https://github.com/rust-lang/rust-bindgen#environment-variables
      shellHook = ''
      export CARGO_HOME=/home/peter/emacs.d/examples/hello-world-rs/.cargo
      export RUSTUP_HOME=/home/peter/emacs.d/examples/hello-world-rs/.rustup/toolchains/$RUSTC_VERSION/bin

      export PATH="''${CARGO_HOME:-~/.cargo}/bin":"$PATH"
      export PATH="''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION/bin":"$PATH"
      '';
    };
  };
}
