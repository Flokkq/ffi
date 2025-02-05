const std = @import("std");

// Import Rust function
extern fn calculate(expression: [*c]const u8) c_int;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    var buf: [100]u8 = undefined; // Buffer for user input
    var fbs = std.io.fixedBufferStream(&buf);

    while (true) {
        try stdout.print("Enter calculation (e.g., 5+2) or 'exit': ", .{});

        // Reset the FixedBufferStream before each use
        fbs.reset();

        // Read from stdin until newline character
        try stdin.streamUntilDelimiter(fbs.writer(), '\n', null);

        const expression = fbs.getWritten();

        if (std.mem.eql(u8, expression, "exit")) {
            break;
        }

        const result = calculate(expression.ptr);

        try stdout.print("Result: {}\n", .{result});
    }
}
