module paddle;

import derelict.sdl2.sdl;

import types;
import globals;

struct Paddle {
    Point!int position = Point!int(SCREEN_WIDTH/2, SCREEN_HEIGHT-30);
    SDL_Rect r;
    
    Rect!int asRect(){
        return Rect!int(r.x, r.y, r.w, r.h);
    }
}
