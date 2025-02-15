const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL_ttf.h");
});

pub usingnamespace c;
