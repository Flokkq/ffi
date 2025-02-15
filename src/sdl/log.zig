const std = @import("std");
const c = @import("raw.zig");

/// Logs a **normal message** to the SDL log system.
pub fn trace(message: []const u8) void {
    c.SDL_Log("%s", message.ptr);
}

pub const SdlErrorType = enum {
    Default,
    Ttf,
};

/// Logs an **error message** with the error source from the specified SDL subsystem.
pub fn err(error_type: SdlErrorType, message: []const u8) void {
    const sdl_err: [*c]const u8 = switch (error_type) {
        .Default => c.SDL_GetError(),
        .Ttf => c.TTF_GetError(),
    };
    c.SDL_LogError(c.SDL_LOG_CATEGORY_APPLICATION, "%s\n\nCaused by: %s", message.ptr, sdl_err);
}
