const std = @import("std");
const c = @import("raw.zig");

/// Initialize the SDL library.
pub fn init() i32 {
    return c.SDL_Init(c.SDL_INIT_VIDEO);
}

/// Clean up all initialized subsystems.
pub fn cleanup() void {
    c.SDL_Quit();
}

pub const Window = struct {
    inner: *c.SDL_Window,
    alloc: std.mem.Allocator,

    /// Creates an SDL window and stores the allocator.
    pub fn create(allocator: std.mem.Allocator, title: []const u8, width: i32, height: i32) !*Window {
        const win = c.SDL_CreateWindow(
            title.ptr,
            c.SDL_WINDOWPOS_CENTERED,
            c.SDL_WINDOWPOS_CENTERED,
            width,
            height,
            c.SDL_WINDOW_SHOWN,
        ) orelse return error.WindowCreationFailed;

        const window = try allocator.create(Window);
        window.* = Window{ .inner = win, .alloc = allocator };

        return window;
    }

    /// Properly destroys the SDL window and frees memory.
    pub fn destroy(self: *const Window) void {
        c.SDL_DestroyWindow(self.inner);
        self.alloc.destroy(self);
    }
};

pub const Renderer = struct {
    inner: *c.SDL_Renderer,
    alloc: std.mem.Allocator,

    /// Create a new SDL_Renderer for a given window.
    pub fn create(allocator: std.mem.Allocator, window: *Window) !*Renderer {
        const rnd = c.SDL_CreateRenderer(window.inner, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse {
            return error.RenderCreationFailed;
        };

        const renderer = try allocator.create(Renderer);
        renderer.* = Renderer{ .inner = rnd, .alloc = allocator };

        return renderer;
    }

    /// Destroy the renderer and free allocated memory.
    pub fn destroy(self: *const Renderer) void {
        c.SDL_DestroyRenderer(self.inner);
        self.alloc.destroy(self);
    }

    /// Clear the screen.
    pub fn clear(self: *Renderer) void {
        _ = c.SDL_RenderClear(self.inner);
    }

    /// Set the drawing color.
    pub fn set_draw_color(self: *Renderer, r: u8, g: u8, b: u8, a: u8) void {
        _ = c.SDL_SetRenderDrawColor(self.inner, r, g, b, a);
    }

    /// Render a texture.
    pub fn render(self: *Renderer, texture: *const Texture, rect: *const Rect) void {
        _ = c.SDL_RenderCopy(self.inner, texture.inner, null, &rect.inner);
    }

    /// Swap buffers.
    pub fn present(self: *Renderer) void {
        c.SDL_RenderPresent(self.inner);
    }
};

pub const Texture = struct {
    inner: *c.SDL_Texture,
    alloc: std.mem.Allocator,

    /// Create a Texture from a surface.
    pub fn create_from_surface(allocator: std.mem.Allocator, renderer: *Renderer, surface: *Surface) !*Texture {
        const tex = c.SDL_CreateTextureFromSurface(renderer.inner, surface.inner) orelse {
            return error.TextureCreationFailed;
        };

        const texture = try allocator.create(Texture);
        texture.* = Texture{ .inner = tex, .alloc = allocator };
        return texture;
    }

    /// Destroy the texture and free allocated memory.
    pub fn destroy(self: *Texture) void {
        c.SDL_DestroyTexture(self.inner);
        self.alloc.destroy(self);
    }

    /// Access the raw SDL_Texture pointer.
    pub fn raw(self: *Texture) *c.SDL_Texture {
        return self.inner;
    }
};

pub const Rect = struct {
    inner: c.SDL_Rect,

    /// Create a new Rect with specified position and size.
    pub fn create(x: i32, y: i32, w: i32, h: i32) Rect {
        return Rect{ .inner = c.SDL_Rect{ .x = x, .y = y, .w = w, .h = h } };
    }

    /// Set the position of the rectangle.
    pub fn set_position(self: *Rect, x: i32, y: i32) void {
        self.inner.x = x;
        self.inner.y = y;
    }

    /// Set the size of the rectangle.
    pub fn set_size(self: *Rect, w: i32, h: i32) void {
        self.inner.w = w;
        self.inner.h = h;
    }

    /// Get the width of the rectangle.
    pub fn width(self: *Rect) i32 {
        return self.inner.w;
    }

    /// Get the height of the rectangle.
    pub fn height(self: *Rect) i32 {
        return self.inner.h;
    }

    /// Access the raw SDL_Rect pointer.
    pub fn raw(self: *Rect) *c.SDL_Rect {
        return &self.inner;
    }
};

pub const Surface = struct {
    inner: *c.SDL_Surface,

    /// Wraps an existing SDL_Surface pointer.
    pub fn fromRaw(surface: *c.SDL_Surface) Surface {
        return Surface{ .inner = surface };
    }

    /// Frees the underlying SDL_Surface.
    pub fn destroy(self: *Surface) void {
        c.SDL_FreeSurface(self.inner);
    }
};
