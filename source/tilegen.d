module tilegen;

import std.container;
import dlib.container;

import types;
import globals;

class TilePattern {
    
private:
    float tw;
    float th;
    
public:
    
    this(float tile_w, float tile_h){
        tw = tile_w;
        th = tile_h;
    }
    
    auto get_tile_positions_1(){
        //int y_offset = 3*th;
        DynamicArray!(Point!float) positions;
        
        foreach (row; 0..15) {
            foreach (col;6..10) {
                positions ~= Point!float(row*tw, col*th);
            }
        }
        
        return positions;
    }
    
    auto get_tile_positions_2(){
        //int y_offset = 3*th;
        DynamicArray!(Point!float) positions;
        
        foreach (row; 0..6) {
            foreach (col; 0..20) {
                positions ~= Point!float(row*tw, col*th);
            }
        }
        
        return positions;
    }
    
};