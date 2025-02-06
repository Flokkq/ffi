{
  description = "A basic flake for rust, and zig development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          git-cliff
          gnupg
          pre-commit

          rustc
          cargo
          rust-analyzer
          clippy
          rustfmt

          zig
          zls

          SDL2
          SDL2.dev
          SDL2_ttf
          SDL2_gfx
          SDL2_image

          # Extra tools for cross-compilation or debugging
          pkg-config
          llvmPackages.bintools
          lldb
        ];

        # https://github.com/ziglang/zig/issues/18998
        shellHook = ''
          unset NIX_CFLAGS_COMPILE
          unset NIX_LDFLAGS
        '';
      };
    });
}
