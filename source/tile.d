
module tile;

import types;

struct Tile {
    
    Point!float position;
    bool alive;
    
    void _init_(Point!float m_pos) nothrow @nogc{
        position = m_pos;
        
        alive = true;
        
    }
    
    Point!float get_position() nothrow @nogc{
        return this.position;
    }

    void set_position(Point!float position_){
        this.position = position_;
    }

    void die(){
        this.alive = false;
    }
    bool is_alive(){
        return this.alive;
    }
    
}
