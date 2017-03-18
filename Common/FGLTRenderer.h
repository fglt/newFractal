//
//  FGLTRenderer.h
//  MetalDemo
//
//  Created by Coding on 17/03/2017.
//  Copyright © 2017 objc.io. All rights reserved.
//

@import Foundation;
@import MetalKit;

#import "GPURender.h"

@interface FGLTRenderer : NSObject<MTKViewDelegate, RendererDelegate>
{
    FractalOptions _fractalOptions;
    ColorOptions _colorOptions;
}
- (instancetype)initWithView:(MTKView *)view;

@end
