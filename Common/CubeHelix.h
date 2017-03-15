//
//  CubeHelix.h
//  Fractal
//
//  Created by Coding on 13/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

typedef NS_ENUM(NSInteger, RotationDirection){
    RotationDirectionPositive,
    RotationDirectionNegative
};

@interface CubeHelix : NSObject
@property (nonatomic)CGFloat startColor;
@property (nonatomic)CGFloat rotation;
@property (nonatomic)CGFloat hue;
@property (nonatomic)CGFloat gamma;
@property (nonatomic)RotationDirection rotationDirection;

- (instancetype) initWithStartColor:(CGFloat)color rotation:(CGFloat)rotaion hue:(CGFloat)hue gamma:(CGFloat)gamma;
- (CGColorRef) colorWithLamda:(CGFloat)lamda;
- (CGColorRef) colorWithLamdaHSL:(CGFloat)lamda;
- (CGColorRef) color:(CGFloat)value;
@end

