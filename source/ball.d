module ball;

import core.stdc.math;

import types;
import tile;
import globals;
import dvector;

struct Ball {
    float stepx;
    float stepy; 
    bool alive;
    
    Point!float position;
    
    float speed;

    float sinceLastHit;
    
    this(Point!float pos) nothrow @nogc {
        position = pos;
        speed = 100;
        alive = true;
        stepx = rndFloat(1.5f, 2.0f); 
        stepy = -(4-sin(stepx));
    }

    bool is_alive() nothrow @nogc {
        return this.alive;
    }

    void killTheBall() nothrow @nogc{
        this.alive = false;
    }
    
    void update_ball(Point!int padposition, int padlen, ref Dvector!Tile tiles, double dt) nothrow @nogc {
        
        float pad_x = cast(float)padposition.x;
        float pad_y = cast(float)padposition.y;
        
        float ball_x = position.x;
        float ball_y = position.y;

        if (ball_y + b_width >= pad_y){
            
            if (ball_x + b_width > pad_x && ball_x < pad_x + padlen){ // did the ball hit the pad?
                // where did it hit?
                stepx = getReflection(position.x - padposition.x);
                stepy = -stepy;

            } else {
                
                this.killTheBall();
            }

            sinceLastHit += dt;
        }
        
        if (ball_y < 0) { stepy = -stepy;} // collision check for roof
        
        if (ball_x < 0 || ball_x + b_width >= SCREEN_WIDTH){ stepx = -stepx;} // collision check for sides
        
        if (tiles.length != 0 ) { // collision check for tiles
            // based on: http://rembound.com/articles/the-breakout-tutorial-with-cpp-and-sdl-2
            foreach(ref it; tiles){
                Point!float tpos = it.position;
                // Brick x and y coordinates
                float brickx = tpos.x + tileoffsetx;
                float bricky = tpos.y + tileoffsety;
 
                // Center of the ball x and y coordinates
                float ballcenterx = position.x + 0.5f*b_width;
                float ballcentery = position.y + 0.5f*b_width;
 
                // Center of the brick x and y coordinates
                float brickcenterx = brickx + 0.5f*tile_w;
                float brickcentery = bricky + 0.5f*tile_h;
 
                if (position.x <= brickx + tile_w &&
                    position.x+b_width >= brickx &&
                    position.y <= bricky + tile_h &&
                    position.y + b_width >= bricky) {
                    // Collision detected, remove the brick
                    it.die();
 
                    // Asume the ball goes slow enough to not skip through the bricks
 
                    // Calculate ysize
                    float ymin = 0;
                    if (bricky > position.y) {
                        ymin = bricky;
                    } else {
                        ymin = position.y;
                    }
 
                    float ymax = 0;
                    if (bricky + tile_h < position.y + b_width) {
                        ymax = bricky+tile_h;
                    } else {
                        ymax = position.y + b_width;
                    }
 
                    float ysize = ymax - ymin;
 
                    // Calculate xsize
                    float xmin = 0;
                    if (brickx > position.x) {
                        xmin = brickx;
                    } else {
                        xmin = position.x;
                    }
 
                    float xmax = 0;
                    if (brickx+tile_w < position.x + b_width) {
                        xmax = brickx+tile_w;
                    } else {
                        xmax = position.x + b_width;
                    }
 
                    float xsize = xmax - xmin;
 
                    // The origin is at the top-left corner of the screen!
                    // Set collision response
                    if (xsize > ysize) {
                        if (ballcentery > brickcentery) {
                            // Bottom
                            position.y += ysize + 0.01f; // Move out of collision
                            ballBrickResponse(3);
                        } else {
                            // Top
                            position.y -= ysize + 0.01f; // Move out of collision
                            ballBrickResponse(1);
                        }
                    } else {
                        if (ballcenterx < brickcenterx) {
                            // Left
                            position.x -= xsize + 0.01f; // Move out of collision
                            ballBrickResponse(0);
                        } else {
                            // Right
                            position.x += xsize + 0.01f; // Move out of collision
                            ballBrickResponse(2);
                        }
                    }
                } 
            }
        }
        
        position = Point!float(this.stepx*dt*speed + position.x, this.stepy*dt*speed + position.y);
    
    }
    
    float getReflection(float hitx) nothrow @nogc{
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
    
    void ballBrickResponse(int dirindex)  nothrow @nogc{
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
     
        stepx *= mulx;
        stepy *= muly;
        
    }

}

