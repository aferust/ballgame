
module tile;

import types;

struct Tile {
    
    Point!float position;
    bool alive;
    
    this(Point!float m_pos) nothrow @nogc{
        position = m_pos;
        
        alive = true;
        
    }

    void die() nothrow @nogc{
        this.alive = false;
    }
    bool is_alive() nothrow @nogc{
        return this.alive;
    }
    
}
