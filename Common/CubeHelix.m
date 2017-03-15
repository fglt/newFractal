//
//  CubeHelix.m
//  Fractal
//
//  Created by Coding on 13/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import "CubeHelix.h"

@implementation CubeHelix

- (instancetype)initWithStartColor:(CGFloat)color rotation:(CGFloat)rotaion hue:(CGFloat)hue gamma:(CGFloat)gamma
{
    self = [super init];
    _startColor = color;
    _rotation = rotaion;
    _hue = hue;
    _gamma = gamma;
    _rotationDirection = RotationDirectionNegative;
    return self;
}

- (CGColorRef) colorWithLamda:(CGFloat)lamda
{
    CGFloat theta = 2*M_PI*(_startColor/3 + _rotation * lamda);
    CGFloat sint = sin(theta);
    CGFloat cost = cos(theta);
    CGFloat l = pow(lamda, _gamma);
    CGFloat amplitude =  _hue * l* (1-l)/2;
    
    CGFloat red = l + amplitude *(-0.14861*cost + 1.78277*sint);
    CGFloat green = l + amplitude *(-0.29227*cost - 0.90649*sint);
    CGFloat blue = l + amplitude *1.97294*cost;
    
    CGColorRef color = CGColorCreateGenericRGB(red, green, blue, 1);
    return color;
}


- (CGColorRef) colorWithLamdaHSL:(CGFloat)lamda
{
    CGFloat radians = M_PI/180;
    CGFloat ah = (276+120)*radians;
    CGFloat bh = (96+120)*radians - ah;
    CGFloat as = 0.6;
    CGFloat bs = 0;
    CGFloat al = 0;
    CGFloat bl = 1;
    
    CGFloat theta = ah + bh*lamda;
    CGFloat sint = sin(theta);
    
    CGFloat cost = cos(theta);
    CGFloat l = pow(al+bl*lamda, _gamma);
    CGFloat amplitude =  (as + bs*lamda) * l* (1-l);
    
    CGFloat red = l + amplitude *(-0.14861*cost + 1.78277*sint);
    CGFloat green = l + amplitude *(-0.29227*cost - 0.90649*sint);
    CGFloat blue = l + amplitude *1.97294*cost;
    
    CGColorRef color = CGColorCreateGenericRGB(red, green, blue, 1);
    return color;
}


- (CGColorRef) color:(CGFloat)value
{
    CGFloat sq = value*value;
    CGFloat red = 0.8*value +sq*0.2;
    CGFloat green = 2*value -sq;
    CGFloat blue = 1.4*value - 0.4*sq;
    
    CGColorRef color = CGColorCreateGenericRGB(red, green, blue, 1);
    return color;
}

@end
