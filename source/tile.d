
module tile;

import types;

struct Tile {
    
    Point!float position;
    bool alive;
    
    this(Point!float m_pos) nothrow @nogc{
        position = m_pos;
        
        alive = true;
        
    }
    
    Point!float get_position() nothrow @nogc{
        return this.position;
    }

    void set_position(Point!float position_) nothrow @nogc {
        this.position = position_;
    }

    void die() nothrow @nogc{
        this.alive = false;
    }
    bool is_alive() nothrow @nogc{
        return this.alive;
    }
    
}
