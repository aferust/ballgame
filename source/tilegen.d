module tilegen;

import std.container;
//import dlib.container;

import types;
import globals;

struct TilePattern {
    
    float tw;
    float th;
    
    void _init_(float tile_w, float tile_h) nothrow @nogc{
        tw = tile_w;
        th = tile_h;
    }
    
    auto get_tile_positions(int seed){
        //int y_offset = 3*th;
        Array!(Point!float) positions;
        if(seed == 0){
            foreach (row; 0..15) {
                foreach (col;6..10) {
                    positions ~= Point!float(row*tw, col*th);
                }
            }
        }else{
            foreach (row; 0..6) {
                foreach (col; 0..20) {
                    positions ~= Point!float(row*tw, col*th);
                }
            }
        }
        return positions;
    }
    
};
