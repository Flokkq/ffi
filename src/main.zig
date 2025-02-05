const std = @import("std");

// Import Rust function
extern fn boop() void;

pub fn main() !void {
    std.debug.print("Beep");
    boop();
    std.debug.print("Beep");
}
