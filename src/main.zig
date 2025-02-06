const std = @import("std");

// Import Rust function
extern fn boop() void;

pub fn main() !void {
    std.debug.print("Zig\n", .{});
    boop();
    std.debug.print("Zig\n", .{});
}
