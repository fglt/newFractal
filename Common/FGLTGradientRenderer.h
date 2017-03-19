//
//  FGLTGradientRenderer.h
//  Fractal
//
//  Created by Coding on 18/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

@import Foundation;

#import "GPURender.h"
@class MTKView;



@interface FGLTGradientRenderer : NSObject<RendererDelegate>
{
    FractalOptions _fractalOptions;
    ColorOptions _colorOptions;
}
@property (nonatomic) FractalOptions fractalOptions;
@property (nonatomic) ColorOptions colorOptions;
@property (weak) FractalHandler handler;
@property (nonatomic) BOOL gradient;
- (instancetype)initWithView:(MTKView *)view;
- (CGFloat)progress;
@end
