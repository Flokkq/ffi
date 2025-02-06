const std = @import("std");

extern fn add(a: i32, b: i32) i32;

pub fn main() !void {
    std.debug.print("Welcome in Zig Land\n", .{});
    std.debug.print("Rust Land wants to let you know that 2 + 4 = {}\n", .{add(2, 4)});
}
