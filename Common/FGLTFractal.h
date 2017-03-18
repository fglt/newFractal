//
//  FGFractal.h
//  Fractal
//
//  Created by Coding on 12/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Complex.h"

#if TARGET_OS_IPHONE
#define DNonatomic nonatomic
#else
#define DNonatomic
#endif

@interface FGLTFractal : NSObject<NSCopying>
@property (DNonatomic) Complex *cComplex;
@property (DNonatomic) uint radius;
@property (DNonatomic) uint times;
@property (DNonatomic) uint width;
@property (DNonatomic) uint height;

- (instancetype)initWithComplex:(Complex *)com radius:(uint)radius times:(uint)times size:(CGSize)size;
- (instancetype)initWithComplexR:(CGFloat )r ComplexI:(CGFloat)i radius:(uint)radius times:(uint)times width:(CGFloat)w height:(CGFloat)h;


- (void)fractalsWithCompletion:(void (^)())completion;
- (void)fractalGradientWithStepHandler:(void (^)())handler completion:(void (^)())completion;

- (CGImageRef)newCGImage;
- (CGFloat)progress;
- (void)configComplexWithReal:(CGFloat)real image:(CGFloat)image;
@end
