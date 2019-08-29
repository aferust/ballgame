module globals;

__gshared const float tile_w = 53.0f;
__gshared const float tile_h = 26.0f;
__gshared const float tileoffsetx = 0;
__gshared const float tileoffsety = 8;

__gshared const float b_radius = 19.0f;
__gshared int padlen = 120;
__gshared int padH = 20;

__gshared const int SCREEN_WIDTH  = 800;
__gshared const int SCREEN_HEIGHT = 600;

__gshared const float ballReflScale = 2.5f;

float rndFloat(float lo, float up) nothrow @nogc{
    import core.stdc.time;
    import core.stdc.stdlib;
    
    return (up-lo)*(cast(float)rand())/RAND_MAX + lo;
}
