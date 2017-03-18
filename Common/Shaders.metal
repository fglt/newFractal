//
//  Shaders.metal
//  MetalDemo
//
//  Created by Warren Moore on 10/28/14.
//  Copyright (c) 2014 objc.io. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct {
    uint maxTime;
    uint radius;
    float2 complex;
}Fractal;

typedef struct {
    float start;
    float rot;
    float hue;
    float gamma;
}CubeHelix;

typedef struct
{
    packed_float2 position ;
    packed_float2 texCoords;
} VertexIn;

typedef struct {
    float4 position [[position]];
    float2 texCoords;
} VertexOut;

static float4 cubehelix(float lamda, CubeHelix helix)
{
    float theta = 2*3.1415926*(helix.start/3 + helix.rot* lamda);
    float sint = sin(theta);
    float cost = cos(theta);
    float l = pow(lamda, helix.gamma);
    float amplitude =  helix.hue * l* (1-l)/2;
    
    float red = l + amplitude *(-0.14861*cost + 1.78277*sint);
    float green = l + amplitude *(-0.29227*cost - 0.90649*sint);
    float blue = l + amplitude *1.97294*cost;
    
    red = 0>=red ? 0: (red>=1? 1 :red);
    green = 0>=green ? 0: (green>=1? 1 :green);
    blue = 0>=blue ? 0: (blue>=1? 1 :blue);

    return float4(red, green, blue, 1);
}

static float4 cubehelixF(float value, CubeHelix helix)
{
   return cubehelix(value, helix);
    //cubehelix(value, 1, 2, 2, 1, bgr);
}

static float fractal(float2 position, Fractal fra)
{
    float x = position[0]*3.0-1.5;
    float y = position[1]*3.0-1.5;
    for(uint m =0; m <fra.maxTime; ++m){
        
        float sx = x*x;
        float sy = y*y;
        if(sx + sy>fra.radius *fra.radius) return (float)m/fra.maxTime;
        float tmpx = sx-sy+fra.complex[0];
        y = x*y*2+fra.complex[1];
        x = tmpx;
    }
    
    return 1;
}

static float2 squareComplex(float2 complex)
{
    float x = complex[0] *complex[0] -complex[1] *complex[1];
    float y = 2*complex[0]*complex[1];
    return float2(x, y);
}

static float4 gradient_fractal(float2 zcomplex, float time, Fractal fra)
{
    float x = zcomplex[0];
    float y = zcomplex[1]*3.0-1.5;
    float2 com = zcomplex;
    if((x*x +y*y<=fra.radius*fra.radius)){
        time+=1.0/fra.maxTime;
        com = squareComplex(zcomplex);
        com = float2(com[0]+fra.complex[0],com[1]+fra.complex[1] );
    }

    return float4(com, time, 1);
}

vertex VertexOut vertex_function(device VertexIn *vertices [[buffer(0)]],
                                 uint vid [[vertex_id]])
{
    VertexOut out;
    out.position = float4(vertices[vid].position, 0, 1);
    out.texCoords = vertices[vid].texCoords;;
    return out;
}
constexpr sampler lsampler(coord::normalized, filter::linear);

fragment float4 fragment_function(VertexOut in [[stage_in]],
                                 texture2d<float, access::sample> escapeTime [[texture(0)]])
{
    float4 color = escapeTime.sample(lsampler, in.texCoords);
    return color;
}

kernel void fractal_color(texture2d<float, access::write> writeTexture [[texture(0)]],
                         constant Fractal &fra [[buffer(0)]],
                         constant CubeHelix &helix [[buffer(1)]],
                         uint2 gridPosition [[thread_position_in_grid]])
{
    ushort width = writeTexture.get_width();
    ushort height = writeTexture.get_height();
    float2 bounds(width, height);
    float2 position = float2(gridPosition);
    
    if(gridPosition.x < width && gridPosition.y < height){
        float value= fractal(position/bounds,fra);
        float4 color = cubehelixF(1-value, helix);
        writeTexture.write(color, gridPosition);
    }
}

kernel void gradient_fractal_time(texture2d<float, access::sample> readTexture [[texture(0)]],
                                  texture2d<float, access::write> fractalTexture [[texture(1)]],
                         constant Fractal &fra [[buffer(0)]],
                         constant CubeHelix &helix [[buffer(1)]],
                         uint2 gridPosition [[thread_position_in_grid]])
{
    
    ushort width = fractalTexture.get_width();
    ushort height = fractalTexture.get_height();
    float2 bounds(width, height);
    float2 position = float2(gridPosition);
    
    if(gridPosition.x < width && gridPosition.y < height){
        float2 coords = position/ bounds;
        float4 c = readTexture.sample(lsampler, coords);
        c= gradient_fractal(float2(c.x, c.y), c.z, fra);
        fractalTexture.write(c, gridPosition);
    }
}

kernel void gradient_fractal_color(texture2d<float, access::sample> fractalTexture [[texture(0)]],
                                  texture2d<float, access::write> colorTexture [[texture(1)]],
                                  constant Fractal &fra [[buffer(0)]],
                                  constant CubeHelix &helix [[buffer(1)]],
                                  uint2 gridPosition [[thread_position_in_grid]])
{
    ushort width = fractalTexture.get_width();
    ushort height = fractalTexture.get_height();
    float2 bounds(width, height);
    float2 position = float2(gridPosition);
    
    if(gridPosition.x < width && gridPosition.y < height){
        float2 coords = position/ bounds;
        float4 c = fractalTexture.sample(lsampler, coords);
        float4 color = cubehelixF(1-c[2], helix);
        colorTexture.write(color, gridPosition);
    }
}

kernel void init_fractal_time(texture2d<float, access::write> fractalTexture [[texture(0)]],
                                   uint2 gridPosition [[thread_position_in_grid]])
{
    ushort width = fractalTexture.get_width();
    ushort height = fractalTexture.get_height();
    float2 bounds(width, height);
    float2 position = float2(gridPosition);
    
    float2 coords = position/ bounds;
    float4 c = float4(coords,0,1);
    fractalTexture.write(c, gridPosition);
}

