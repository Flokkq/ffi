{
  description = "A basic flake for git-cliff, Rust, and Zig development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          # Git tooling
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
        ];

        shellHook = ''
          echo "🚀 Welcome to your Rust & Zig dev environment!"
          echo "🔧 Rust version: $(rustc --version)"
          echo "⚡ Zig version: $(zig version)"
        '';
      };
    });
}
