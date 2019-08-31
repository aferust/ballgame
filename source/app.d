/+

Breakout/arkanoid like game that can be compiled with -betterC compatibility.

+/

module app;

import core.stdc.stdlib;
import core.stdc.stdio;

import std.stdint;

import bindbc.sdl;
import bindbc.sdl.image;

import types;
import ball;
import paddle;
import tile;
import tilegen;
import globals;
import dvector;

Dvector!(Ball*) balls;
Dvector!(Tile*) tiles;

void logSDLError(string msg) nothrow @nogc{
	printf("%s: %s \n", msg.ptr, SDL_GetError());
}
char[512] buff;
string getResourcePath(string res_name) nothrow @nogc{
    import core.stdc.string;
    
    string res_folder = "res";
    
    version(Windows){
        string sep = "\\";
    }else{
        string sep = "/";
    }
    const char* root_path = ""; //SDL_GetBasePath();
    
    snprintf(buff.ptr, buff.length, "%.*s%.*s%.*s%.*s",
                 strlen(root_path), root_path,
                 res_folder.length, res_folder.ptr,
                 sep.length, sep.ptr,
                 res_name.length, res_name.ptr);
    //printf("%s \n", buff.ptr);
    return buff;
}

SDL_Texture* loadTexture(string file, SDL_Renderer *ren) nothrow @nogc{
	//Initialize to nullptr to avoid dangling pointer issues
	SDL_Texture *texture = null;
	//Load the image
	SDL_Surface *loadedImage = SDL_LoadBMP(file.ptr);
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

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y, int w, int h) nothrow @nogc{
	//Setup the destination rectangle to be at the position we want
	SDL_Rect dst;
	dst.x = x;
	dst.y = y;
	dst.w = w;
	dst.h = h;
	SDL_RenderCopy(ren, tex, null, &dst);
}

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y) nothrow @nogc{
	int w, h;
	SDL_QueryTexture(tex, null, null, &w, &h);
	renderTexture(tex, ren, x, y, w, h);
}

void drawTiles(SDL_Texture *texTile, SDL_Renderer *ren) nothrow @nogc{
    
    foreach(tl; tiles){
        auto x = cast(int)tl.get_position().x;
        auto y = cast(int)tl.get_position().y;
        
        //SDL_RenderCopy(ren, texTile, null, null);
        renderTexture(texTile, ren, x, y, 53, 26);
        //SDL_RenderCopy(ren, texTile, null, null);
    }
}

void drawPaddle(SDL_Renderer *ren, Paddle* paddle) nothrow @nogc{
    SDL_SetRenderDrawColor( ren, 0, 0, 255, 255);
    SDL_Rect r = SDL_Rect(paddle.position.x, paddle.position.y, padlen, padH);
    SDL_RenderFillRect( ren, &r );
}

void createTiles(int pattern) nothrow @nogc{
    auto t_p = mallocOne!TilePattern; t_p._init_(tile_w, tile_h);
    Dvector!(Point2f*) tile_positions = t_p.get_tile_positions(pattern);
    
    if(tiles.length == 0){
        foreach(tp; tile_positions){
            auto a_tile = mallocOne!Tile; a_tile._init_(*tp);
            tiles ~= a_tile;
        }
    }
    t_p.freeChildren();
    free(t_p);
}

extern(C) int main(string[] args) nothrow @nogc {
    
    version(BindSDL_Static){
    	 // todo: some stuff
    }else{
    	SDLSupport ret = loadSDL();
    }

    balls._init_();
    tiles._init_();
    
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
      
    SDL_Texture *tex = loadTexture(getResourcePath("hello.bmp"), ren);
    //SDL_FreeSurface(bmp);
    if (tex is null){
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        logSDLError("SDL_CreateTextureFromSurface Error: ");
        SDL_Quit();
        return 1;
    }
    
    SDL_Texture *texTile = loadTexture(getResourcePath("tile.bmp"), ren);
    //SDL_FreeSurface(bmp);
    if (texTile is null){
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        logSDLError("SDL_CreateTextureFromSurface Error: ");
        SDL_Quit();
        return 1;
    }
    
    SDL_Texture *texBall = loadTexture(getResourcePath("ball.bmp"), ren);
    //SDL_FreeSurface(bmp);
    if (texBall is null){
        SDL_DestroyRenderer(ren);
        SDL_DestroyWindow(win);
        logSDLError("SDL_CreateTextureFromSurface Error: ");
        SDL_Quit();
        return 1;
    }
    
    createTiles(0);
    
    Paddle* _paddle = mallocOne!Paddle;
    _paddle.position = Point!int(SCREEN_WIDTH/2, SCREEN_HEIGHT-30);
    
    Ball* _ball = mallocOne!Ball;
    _ball._init_(Point!float(SCREEN_WIDTH/2, SCREEN_HEIGHT-50));
    balls ~= _ball;
    
    SDL_Event event;
    bool quit = false;
    
    uint64_t now = SDL_GetPerformanceCounter();
    uint64_t last = 0;
    double dt = 0;
    
    while (!quit){
        last = now;
        now = SDL_GetPerformanceCounter();
        dt = cast(double)((now - last)/cast(double)SDL_GetPerformanceFrequency());
        
        //First clear the renderer
        SDL_RenderClear(ren);
        //Draw the texture
        SDL_RenderCopy(ren, tex, null, null);
        drawTiles(texTile, ren);
        
        drawPaddle(ren, _paddle);
        update_pad(_paddle, event);
        
        removeDeadInstances(balls);
        removeDeadInstances(tiles);
        
        drawUpdateBalls(dt, ren, texBall, _paddle);
        //Update the screen
        SDL_RenderPresent(ren);
        
        while( SDL_PollEvent( &event ) != 0 ){
            //User requests quit
            if(event.type == SDL_KEYDOWN){
                if (event.key.keysym.sym == SDLK_ESCAPE) {
                    quit = true;
                }
                if (event.key.keysym.sym == SDLK_SPACE) {
                    Ball* bl = mallocOne!Ball;
                    bl._init_(Point!float(_paddle.position.x + padlen/2, _paddle.position.y - 20));
                    balls ~= bl;
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
    
    free(_paddle);
    freeALLInstances(balls);
    freeALLInstances(tiles);
    
    SDL_DestroyTexture(tex);
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    SDL_Quit();
    
    return 0;
}

void freeALLInstances(T)(T arr) nothrow @nogc{
    for(int i = 0; i < arr.length; i++){
        free(arr[i]);
    }
    arr.free();
}

void drawUpdateBalls(double dt, SDL_Renderer *ren, SDL_Texture *texBall, Paddle* paddle) nothrow @nogc{
    for(int i = 0; i < balls.length; i++){
        balls[i].update_ball(paddle.position, padlen, tiles, dt);
        renderTexture(texBall, ren, cast(int)balls[i].position.x, cast(int)balls[i].position.y, cast(int)b_radius, cast(int)b_radius);
    }
}

void update_pad(Paddle* m_pad, SDL_Event event) nothrow @nogc{
    float increment = 10.0f;
    
    if (event.type == SDL_MOUSEMOTION){
        if (event.motion.x < 800 - padlen && event.motion.x > 0){
            m_pad.position = Point!int(event.motion.x, m_pad.position.y) ;
        }
    }
    
}

void removeDeadInstances(T)(ref T arr) nothrow @nogc {
    if (arr.length > 0){
        foreach(i, elem; arr){
            if (elem.is_alive() == false) {
                free(elem);
                arr.remove(i);
                break;
            }
        }
    }
}
