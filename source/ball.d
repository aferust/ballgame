
module ball;

import std.math;
import std.conv;
import std.stdio;
import std.random;

import dlib.container;

import types;
import tile;
import globals;

bool contains(T)(Rect!T rect1, Rect!T rect2){
    
    auto l1 = rect1.p1;
    auto r1 = rect1.p2;
    
    auto l2 = rect2.p1;
    auto r2 = rect2.p2;
    
    if (l1.x > r2.x || l2.x > r1.x) 
        return false; 
        
    if (l1.y < r2.y || l2.y < r1.y) 
        return false; 
  
    return true; 
}

bool contains(T)(Rect!T rect, Point!T p){
    T x1 = rect.p1.x;
    T y1 = rect.p1.y;
    T x2 = rect.p2.x;
    T y2 = rect.p2.y;
    T x = p.x;
    T y = p.y;
    
    if (x > x1 && x < x2 && y > y1 && y < y2) 
        return true; 
  
    return false; 
}

bool contains(T)(Rect!T rect, T x, T y){
    T x1 = rect.p1.x;
    T y1 = rect.p1.y;
    T x2 = rect.p2.x;
    T y2 = rect.p2.y;
    
    if (x > x1 && x < x2 && y > y1 && y < y2) 
        return true; 
  
    return false; 
}

class Ball {
    private:
        float stepx;
        float stepy; 
        bool alive;
        
    public:
        Point!float position;
        
        int speed = 100;
        
        this(Point!int pos){
            position = Point!float(pos.x.to!float, pos.y.to!float);
            
            alive = true;
            auto rnd = Random(unpredictableSeed);
            stepx = uniform!"[]"(1.5f, 2.0f, rnd);
            stepy = -(4-sin(stepx)) ;//-factor*cos(stAngle*PI/180.0f);
        }
        
        this(){
            position = Point!float(SCREEN_WIDTH/2, SCREEN_HEIGHT-50);
        
            alive = true;
            auto rnd = Random(unpredictableSeed);
            stepx = uniform!"[]"(1.5f, 2.0f, rnd);
            stepy = -(4-sin(stepx)) ;//-factor*cos(stAngle*PI/180.0f);
            
        }
        
        void set_stepx(float stepx_){
            this.stepx = stepx_;
        }

        void set_stepy(float stepy_){
            this.stepy = stepy_;
        }

        Point!float get_position(){
            return this.position;
        }

        void set_position(Point!float position_){
            this.position = position_;
        }

        bool is_alive(){
            return this.alive;
        }

        void killTheBall(){
            this.alive = false;
        }
        
        void update_ball(Point!int padposition, int padlen, DynamicArray!Tile tiles, double dt){
            
            float pad_x = padposition.x.to!float;
            float pad_y = padposition.y.to!float;
            
            float ball_x = this.position.x;
            float ball_y = this.position.y;
            //this.stepy.writeln;
            if (ball_y + b_radius >= pad_y){
                
                if (ball_x + b_radius > pad_x && ball_x < pad_x + padlen){ // did the ball hit the pad?
                    // where did it hit?
                    this.set_stepx(getReflection(this.get_position.x - padposition.x));
                    this.set_stepy(-this.stepy);
                    /*float rlx = pad_x - ball_x;
                    float nrlx = (rlx/(padlen));
                    float bAngle = nrlx * 140;
                    
                    this.set_stepx(-factor*sin(bAngle*PI/180.0f));
                    this.set_stepy(-factor*cos(bAngle*PI/180.0f));
                    */
                } else {
                    
                    this.killTheBall();
                }
            }
            
            if (ball_y < 0) { this.set_stepy(-this.stepy);} // collision check for roof
            
            if (ball_x <= 0 || ball_x + b_radius >= SCREEN_WIDTH){ this.set_stepx(-this.stepx);} // collision check for sides
            
            if (tiles.length != 0 ) { // collision check for tiles
                foreach(it; tiles){
                    Point!float tpos = it.get_position();
                    // Brick x and y coordinates
                    float brickx = tpos.x + tileoffsetx;
                    float bricky = tpos.y + tileoffsety;
     
                    // Center of the ball x and y coordinates
                    float ballcenterx = this.get_position.x + 0.5f*b_radius;
                    float ballcentery = this.get_position.y + 0.5f*b_radius;
     
                    // Center of the brick x and y coordinates
                    float brickcenterx = brickx + 0.5f*tile_w;
                    float brickcentery = bricky + 0.5f*tile_h;
     
                    if (this.get_position.x <= brickx + tile_w &&
                        this.get_position.x+b_radius >= brickx &&
                        this.get_position.y <= bricky + tile_h &&
                        this.get_position.y + b_radius >= bricky) {
                        // Collision detected, remove the brick
                        it.die();
     
                        // Asume the ball goes slow enough to not skip through the bricks
     
                        // Calculate ysize
                        float ymin = 0;
                        if (bricky > this.get_position.y) {
                            ymin = bricky;
                        } else {
                            ymin = this.get_position.y;
                        }
     
                        float ymax = 0;
                        if (bricky+tile_h < this.get_position.y+b_radius) {
                            ymax = bricky+tile_h;
                        } else {
                            ymax = this.get_position.y+b_radius;
                        }
     
                        float ysize = ymax - ymin;
     
                        // Calculate xsize
                        float xmin = 0;
                        if (brickx > this.get_position.x) {
                            xmin = brickx;
                        } else {
                            xmin = this.get_position.x;
                        }
     
                        float xmax = 0;
                        if (brickx+tile_w < this.get_position.x+b_radius) {
                            xmax = brickx+tile_w;
                        } else {
                            xmax = this.get_position.x+b_radius;
                        }
     
                        float xsize = xmax - xmin;
     
                        // The origin is at the top-left corner of the screen!
                        // Set collision response
                        if (xsize > ysize) {
                            if (ballcentery > brickcentery) {
                                // Bottom
                                this.get_position.y += ysize + 0.01f; // Move out of collision
                                ballBrickResponse(3);
                            } else {
                                // Top
                                this.get_position.y -= ysize + 0.01f; // Move out of collision
                                ballBrickResponse(1);
                            }
                        } else {
                            if (ballcenterx < brickcenterx) {
                                // Left
                                this.get_position.x -= xsize + 0.01f; // Move out of collision
                                ballBrickResponse(0);
                            } else {
                                // Right
                                this.get_position.x += xsize + 0.01f; // Move out of collision
                                ballBrickResponse(2);
                            }
                        }
                    } 
                }
            }
            
            this.set_position(Point!float(this.stepx*dt*speed + position.x, this.stepy*dt*speed + position.y));
        
        }
        
        float getReflection(float hitx) {
            // Make sure the hitx variable is within the width of the paddle
            if (hitx < 0) {
                hitx = 0;
            } else if (hitx > padlen) {
                hitx = padlen;
            }
         
            // Everything above the center of the paddle is reflected upward
            // while everything below the center is reflected downward
            hitx -= padlen / 2.0f;
         
            // Scale the reflection, making it fall in the range -ballReflScale to ballReflScale
            
            return ballReflScale * (hitx / (padlen / ballReflScale));
        }
        
        void ballBrickResponse(int dirindex) {
            // dirindex 0: Left, 1: Top, 2: Right, 3: Bottom
         
            // Direction factors
            int mulx = 1;
            int muly = 1;
         
            if (stepx > 0) {
                // Ball is moving in the positive x direction
                if (stepy > 0) {
                    // Ball is moving in the positive y direction
                    // +1 +1
                    if (dirindex == 0 || dirindex == 3) {
                        mulx = -1;
                    } else {
                        muly = -1;
                    }
                } else if (stepy < 0) {
                    // Ball is moving in the negative y direction
                    // +1 -1
                    if (dirindex == 0 || dirindex == 1) {
                        mulx = -1;
                    } else {
                        muly = -1;
                    }
                }
            } else if (stepx < 0) {
                // Ball is moving in the negative x direction
                if (stepy > 0) {
                    // Ball is moving in the positive y direction
                    // -1 +1
                    if (dirindex == 2 || dirindex == 3) {
                        mulx = -1;
                    } else {
                        muly = -1;
                    }
                } else if (stepy < 0) {
                    // Ball is moving in the negative y direction
                    // -1 -1
                    if (dirindex == 1 || dirindex == 2) {
                        mulx = -1;
                    } else {
                        muly = -1;
                    }
                }
            }
         
            // Set the new direction of the ball, by multiplying the old direction
            // with the determined direction factors
            stepx *= mulx;
            stepy *= muly;
            //this.set_position(Point!float(this.stepx + mulx*position.x, muly*position.y));
        }

}
