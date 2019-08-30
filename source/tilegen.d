module tilegen;

import core.stdc.stdlib;

import types;
import globals;
import dvector;

// very stupid way of generating tiles/bricks. just used heap for testing our mallocs
struct TilePattern {
    
    float tw;
    float th;

    Dvector!(Point2f*) positions;

    void _init_(float tile_w, float tile_h) nothrow @nogc{
        tw = tile_w;
        th = tile_h;
    }
    
    auto get_tile_positions(int seed) nothrow @nogc{
        //int y_offset = 3*th;
        positions._init_;
        if(seed == 0){
            foreach (row; 0..15) {
                foreach (col;6..10) {
                    auto p = cast(Point2f*)malloc(Point2f.sizeof);
                    p.x = row*tw; p.y = col*th;
                    positions.pBack(p);
                }
            }
        }else{
            foreach (row; 0..6) {
                foreach (col; 0..20) {
                    auto p = cast(Point2f*)malloc(Point2f.sizeof);
                    p.x = row*tw; p.y = col*th;
                    positions.pBack(p);
                }
            }
        }
        return positions;
    }

    void freeChildren() nothrow @nogc {
        for(int i = 0; i < positions.length; i++){
            free(positions[i]);
        }
    }
    
};
