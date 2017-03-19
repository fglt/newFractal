//
//  GPURender.h
//  Fractal
//
//  Created by Coding on 18/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

struct FractalOptions{
    UInt32 maxTime;
    UInt32 radius;
    float complexr;
    float complexi;
};

typedef struct FractalOptions FractalOptions;

struct ColorOptions{
    float start;
    float rot;
    float hue;
    float gamma;
};

typedef struct ColorOptions ColorOptions;


typedef void (^FractalHandler)() ;
@protocol RendererDelegate <NSObject>

@property (weak) FractalHandler handler;
- (void)fractal;

- (void)setFractalOptions:(FractalOptions) options;
- (void)setColorOptions:(ColorOptions) options;

@end

