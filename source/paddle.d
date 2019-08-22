module paddle;

import derelict.sdl2.sdl;

import types;
import globals;

class Paddle {
    Point!int position;
    SDL_Rect r;
    
    this(){
        this.position = Point!int(SCREEN_WIDTH/2, SCREEN_HEIGHT-30);
    }
    
    Rect!int asRect(){
        return Rect!int(r.x, r.y, r.w, r.h);
    }
}
