
module tile;

import types;

class Tile {
    
    private:
        Point!float position;
        bool alive;
        
    public:
        this(Point!float m_pos){
            position = m_pos;
            
            alive = true;
            
        }
        
        Point!float get_position(){
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
