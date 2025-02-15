const std = @import("std");
const sdl = @import("sdl/sdl2.zig");
const sdl_ttf = @import("sdl/ttf.zig");
const sdl_log = @import("sdl/log.zig");
const c = @import("sdl/raw.zig");

extern fn add(a: i32, b: i32) i32;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    if (sdl.init() != 0) {
        sdl_log.err(.Default, "Unable to initialize SDL");
        return error.SDLInitializationFailed;
    }
    defer sdl.cleanup();

    if (sdl_ttf.init() != 0) {
        sdl_log.err(.Ttf, "Unable to initialize SDL_ttf");
        return error.SDLTTFInitializationFailed;
    }
    defer sdl_ttf.cleanup();

    sdl_log.trace("Application initialized successfully.");

    var screen = try sdl.Window.create(allocator, "My Game Window", 400, 140);
    defer screen.destroy();

    const renderer = try sdl.Renderer.create(allocator, screen);
    defer renderer.destroy();

    const font = try sdl_ttf.Font.open(allocator, "assets/fonts/Roboto-Regular.ttf", 24);
    defer font.close();

    const result = add(2, 4);

    var text_buffer: [20]u8 = undefined;
    _ = try std.fmt.bufPrint(&text_buffer, "2 + 4 = {}", .{result});

    const color = c.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };

    const text_surface = try font.renderTextSolid(&text_buffer, color);
    defer text_surface.destroy();

    var text_rect = sdl.Rect.create(100, 50, text_surface.inner.w, text_surface.inner.h);
    const text_texture = try sdl.Texture.create_from_surface(allocator, renderer, text_surface);
    defer text_texture.destroy();

    var quit = false;

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            if (event.type == c.SDL_QUIT) {
                quit = true;
            }
        }

        renderer.set_draw_color(0, 0, 0, 255);
        renderer.clear();
        renderer.render(text_texture, &text_rect);
        renderer.present();

        c.SDL_Delay(10);
    }
}
