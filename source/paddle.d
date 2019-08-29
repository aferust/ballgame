module paddle;

import bindbc.sdl;

import types;
import globals;

struct Paddle {
    Point!int position = Point!int(SCREEN_WIDTH/2, SCREEN_HEIGHT-30);
    SDL_Rect r;
}
