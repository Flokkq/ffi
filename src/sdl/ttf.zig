const std = @import("std");
const c = @import("raw.zig");
const sdl = @import("sdl2.zig");

/// Initialize the SDL_ttf library.
pub fn init() i32 {
    return c.TTF_Init();
}

/// Clean up the SDL_ttf library.
pub fn cleanup() void {
    c.TTF_Quit();
}

pub const Error = error{
    FontLoadFailed,
    TextRenderingFailed,
};

/// A wrapper around SDL_ttf's font type.
pub const Font = struct {
    inner: *c.TTF_Font,
    alloc: std.mem.Allocator,

    /// Open a font at the given path with the specified point size.
    pub fn open(allocator: std.mem.Allocator, path: []const u8, ptsize: i32) !*Font {
        const font_ptr = c.TTF_OpenFont(path.ptr, ptsize) orelse return Error.FontLoadFailed;
        const font = try allocator.create(Font);
        font.* = Font{
            .inner = font_ptr,
            .alloc = allocator,
        };
        return font;
    }

    /// Close the font and free its wrapper.
    pub fn close(self: *Font) void {
        c.TTF_CloseFont(self.inner);
        self.alloc.destroy(self);
    }

    /// Render the given text using solid rendering.
    /// Returns a pointer to an SDL_Surface;
    pub fn renderTextSolid(self: *Font, text: []const u8, color: c.SDL_Color) !*sdl.Surface {
        const surface_ptr = c.TTF_RenderText_Solid(self.inner, text.ptr, color) orelse return Error.TextRenderingFailed;
        const wrapped = try self.alloc.create(sdl.Surface);
        wrapped.* = sdl.Surface{ .inner = surface_ptr };
        return wrapped;
    }
};
