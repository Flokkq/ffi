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

          # Extra tools for cross-compilation or debugging
          pkg-config
          llvmPackages.bintools
          lldb
          llvmPackages_19.clangUseLLVM
          libiconv
        ];

        # https://github.com/ziglang/zig/issues/18998
        shellHook = ''
          unset NIX_CFLAGS_COMPILE
          unset NIX_LDFLAGS
        '';
      };
    });
}
