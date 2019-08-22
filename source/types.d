module types;

struct Point(T){
    T x;
    T y;
}

struct Rect(T){
    T x;
    T y;
    T width;
    T height;
    
    Point!T p1(){
        return Point!T(x, y);
    }
    
    Point!T p2(){
        return Point!T(x+width-1, y+height-1);
    }
    
    alias left = x;
    alias top = y;
}
