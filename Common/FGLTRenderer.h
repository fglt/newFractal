//
//  FGLTRenderer.h
//  MetalDemo
//
//  Created by Coding on 17/03/2017.
//  Copyright © 2017 objc.io. All rights reserved.
//

@import Foundation;
@import MetalKit;

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

@interface FGLTRenderer : NSObject<MTKViewDelegate>
{
    FractalOptions _fractalOptions;
    ColorOptions _colorOptions;
}
- (instancetype)initWithView:(MTKView *)view;

- (void)fractal;
- (void)fractalGradient;

- (void)setFractalOptions:(FractalOptions) options;
- (void)setColorOptions:(ColorOptions) options;
@end
