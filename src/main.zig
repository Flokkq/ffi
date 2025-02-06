const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL_ttf.h");
});

extern fn add(a: i32, b: i32) i32;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    if (c.TTF_Init() != 0) {
        c.SDL_Log("Unable to initialize SDL_ttf: %s", c.TTF_GetError());
        return error.SDLTTFInitializationFailed;
    }
    defer c.TTF_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 400, 140, c.SDL_WINDOW_OPENGL) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.WindowCreationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.RendererCreationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    const font = c.TTF_OpenFont("assets/fonts/Roboto-Regular.ttf", 24) orelse {
        c.SDL_Log("Failed to load font: %s", c.TTF_GetError());
        return error.FontLoadFailed;
    };
    defer c.TTF_CloseFont(font);

    const result = add(2, 4);

    var text_buffer: [20]u8 = undefined;
    _ = try std.fmt.bufPrint(&text_buffer, "2 + 4 = {}", .{result});

    const color = c.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 };

    const text_surface = c.TTF_RenderText_Solid(font, &text_buffer, color) orelse {
        c.SDL_Log("Failed to render text: %s", c.TTF_GetError());
        return error.TextRenderingFailed;
    };
    defer c.SDL_FreeSurface(text_surface);

    const text_texture = c.SDL_CreateTextureFromSurface(renderer, text_surface) orelse {
        c.SDL_Log("Failed to create texture: %s", c.SDL_GetError());
        return error.TextureCreationFailed;
    };
    defer c.SDL_DestroyTexture(text_texture);

    var text_rect = c.SDL_Rect{
        .x = 100,
        .y = 50,
        .w = text_surface.*.w,
        .h = text_surface.*.h,
    };

    var quit = false;

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            if (event.type == c.SDL_QUIT) {
                quit = true;
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);

        _ = c.SDL_RenderCopy(renderer, text_texture, null, &text_rect);

        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(10);
    }
}
