module app;

import core.stdc.stdlib;

import std.stdio;
import std.conv;
import std.string;
import std.stdint;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import dlib.container;

import types;
import ball;
import paddle;
import tile;
import tilegen;
import memory;
import globals;

/*import derelict.sdl2.mixer;
import derelict.sdl2.ttf;
import derelict.sdl2.net;*/

string resPath;

DynamicArray!Ball balls;
DynamicArray!Tile tiles;

void logSDLError(string msg){
	writeln(msg, SDL_GetError());
}

string getResourcePath(string subdir = ""){
    string sep = "/";
    version(Windows){
        sep = "\\";
    }
    return SDL_GetBasePath().to!string ~ "res" ~ sep;
}

SDL_Texture* loadTexture(string file, SDL_Renderer *ren){
	//Initialize to nullptr to avoid dangling pointer issues
	SDL_Texture *texture = null;
	//Load the image
	SDL_Surface *loadedImage = SDL_LoadBMP(file.toStringz);
	//If the loading went ok, convert to texture and return the texture
	if (loadedImage !is null){
		texture = SDL_CreateTextureFromSurface(ren, loadedImage);
		SDL_FreeSurface(loadedImage);
		//Make sure converting went ok too
		if (texture is null){
			logSDLError("CreateTextureFromSurface: ");
		}
	}
	else {
		logSDLError("LoadBMP: ");
	}
	return texture;
}

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y, int w, int h){
	//Setup the destination rectangle to be at the position we want
	SDL_Rect dst;
	dst.x = x;
	dst.y = y;
	dst.w = w;
	dst.h = h;
	SDL_RenderCopy(ren, tex, null, &dst);
}

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y){
	int w, h;
	SDL_QueryTexture(tex, null, null, &w, &h);
	renderTexture(tex, ren, x, y, w, h);
}

void drawTiles(SDL_Texture *texTile, SDL_Renderer *ren){
    
    foreach(tile; tiles){
        auto x = tile.get_position().x.to!int;
        auto y = tile.get_position().y.to!int;
        
        //SDL_RenderCopy(ren, texTile, null, null);
        renderTexture(texTile, ren, x, y, 53, 26);
        //SDL_RenderCopy(ren, texTile, null, null);
    }
}

void drawPaddle(SDL_Renderer *ren, Paddle paddle){
    SDL_SetRenderDrawColor( ren, 0, 0, 255, 255);
    SDL_Rect r = SDL_Rect(paddle.position.x, paddle.position.y, padlen, padH);
    SDL_RenderFillRect( ren, &r );
}

void createTiles(int pattern){
    auto t_p = mallocEmplace!TilePattern(tile_w, tile_h);
    DynamicArray!(Point!float) tile_positions = t_p.get_tile_positions(pattern);
    destroyFree(t_p);
    if(tiles.length == 0){
        foreach(tp; tile_positions){
            auto a_tile = mallocEmplace!Tile(tp);
            tiles ~= a_tile;
        }
    }
}

int main(){
    DerelictSDL2.load();
    DerelictSDL2Image.load();
    
    resPath = getResourcePath();
    
    if (SDL_Init(SDL_INIT_VIDEO) != 0){
        logSDLError("SDL_Init Error: ");
        return 1;
    }
    
    SDL_Window *win = SDL_CreateWindow("Hello World!", 100, 100, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN);
    if (win is null){
        logSDLError("SDL_CreateWindow Error: ");
        SDL_Quit();
        return 1;
    }
    
    SDL_Renderer *ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (ren is null){
        SDL_DestroyWindow(win);
        logSDLError("SDL_CreateRenderer Error: ");
        SDL_Quit();
        return 1;
    }
      
    SDL_Texture *tex = loadTexture(resPath ~ "hello.bmp", ren);
    //SDL_FreeSurface(bmp);
    if (tex is null){
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        logSDLError("SDL_CreateTextureFromSurface Error: ");
        SDL_Quit();
        return 1;
    }
    
    SDL_Texture *texTile = loadTexture(resPath ~ "tile.bmp", ren);
    //SDL_FreeSurface(bmp);
    if (texTile is null){
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        logSDLError("SDL_CreateTextureFromSurface Error: ");
        SDL_Quit();
        return 1;
    }
    
    SDL_Texture *texBall = loadTexture(resPath ~ "ball.bmp", ren);
    //SDL_FreeSurface(bmp);
    if (texBall is null){
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        logSDLError("SDL_CreateTextureFromSurface Error: ");
        SDL_Quit();
        return 1;
    }
    
    createTiles(0);
    
    auto paddle = mallocEmplace!Paddle();
    
    balls ~= mallocEmplace!Ball();
    
    SDL_Event event;
    bool quit = false;
    
    uint64_t now = SDL_GetPerformanceCounter();
    uint64_t last = 0;
    double dt = 0;
    
    while (!quit){
        last = now;
        now = SDL_GetPerformanceCounter();
        dt = cast(double)((now - last)/cast(double)SDL_GetPerformanceFrequency());
        //if(dt == 0) dt = 0.0001;
        //dt.writeln;
        //renderTexture(tex, ren, 0, 0);
        
        //First clear the renderer
        SDL_RenderClear(ren);
        //Draw the texture
        SDL_RenderCopy(ren, tex, null, null);
        drawTiles(texTile, ren);
        
        drawPaddle(ren, paddle);
        update_pad(paddle, event);
        
        removeDeadBalls();
        removeDeadTiles();
        
        drawUpdateBalls(dt, ren, texBall, paddle);
        //Update the screen
        SDL_RenderPresent(ren);
        
        //Take a quick break after all that hard work
        //SDL_Delay(1000);
        
        
        while( SDL_PollEvent( &event ) != 0 ){
            //User requests quit
            if(event.type == SDL_KEYDOWN){
                if (event.key.keysym.sym == SDLK_ESCAPE) {
                    quit = true;
                }
                if (event.key.keysym.sym == SDLK_SPACE) {
                    balls ~= mallocEmplace!Ball(Point!int(paddle.position.x + padlen/2, paddle.position.y - 20));
                }
                if (event.key.keysym.sym == SDLK_1) {
                    createTiles(0);
                }
                if (event.key.keysym.sym == SDLK_2) {
                    createTiles(1);
                }
            }
        }
    }
    
    destroyFree(paddle);
    freeALLInstances(balls);
    freeALLInstances(tiles);
    
    SDL_DestroyTexture(tex);
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
    
    return 0;
}

void freeALLInstances(T)(T arr){
    foreach(elem; arr){
        destroyFree(elem);
    }
    arr.free();
}

void drawUpdateBalls(double dt, SDL_Renderer *ren, SDL_Texture *texBall, Paddle paddle){
    foreach(ball; balls){
        //float factor = ball.ballSpeed * dt;
        ball.update_ball(paddle.position, padlen, tiles, dt);
        
        renderTexture(texBall, ren, ball.position.x.to!int, ball.position.y.to!int, b_radius.to!int, b_radius.to!int);
    }
}

void update_pad(Paddle m_pad, SDL_Event event){
    float increment = 10.0f;
    
    if (event.type == SDL_MOUSEMOTION){
        if (event.motion.x < 800 - padlen && event.motion.x > 0){
            m_pad.position = Point!int(event.motion.x, m_pad.position.y) ;
        }
    }
    
}

void removeDeadBalls(){
    if (balls.length > 0){
        for(size_t k = 0; k < balls.length; k++) {
            if (balls[k].is_alive() == false) {
                destroyFree(balls[k]);
                balls.removeAt(k);
                break;
            }
        }
    }
}

void removeDeadTiles(){
    if (tiles.length > 0) {
        for (size_t k = 0; k < tiles.length; k++) {
            
            if (tiles[k].is_alive() == false) {
                destroyFree(tiles[k]);
                tiles.removeAt(k);
                break;
                
            }
        }
    }
}
