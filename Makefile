ZIG_SRC = src/zig/lib.zig
ZIG_LIB = libzigmath.so
RUST_TARGET = target/debug/my_rust_project

all: zig run

zig:
	zig build-lib $(ZIG_SRC) -dynamic -fPIC -femit-bin=$(ZIG_LIB)

run:
	RUSTFLAGS="-L . -lzigmath" cargo run

# Clean up build files
clean:
	rm -f $(ZIG_LIB)
	cargo clean
