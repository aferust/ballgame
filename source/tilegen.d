module tilegen;

import core.stdc.stdlib;

import types;
import globals;
import dvector;

// very stupid way of generating tiles/bricks. just used heap for testing our mallocs
struct TilePattern {
    
    float tw;
    float th;

    Dvector!Point2f positions;

    this(float tile_w, float tile_h) nothrow @nogc{
        tw = tile_w;
        th = tile_h;
    }
    
    auto get_tile_positions(int seed) nothrow @nogc{
        //int y_offset = 3*th;
        
        if(seed == 0){
            foreach (row; 0..15) {
                foreach (col;6..10) {
                    auto p = Point2f(row*tw, col*th);
                    positions ~= p;
                }
            }
        }else{
            foreach (row; 0..6) {
                foreach (col; 0..20) {
                    auto p = Point2f(row*tw, col*th);
                    positions ~= p;
                }
            }
        }
        return positions;
    }

    void free() nothrow @nogc {
        positions.free();
    }
    
}
