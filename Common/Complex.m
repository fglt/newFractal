//
//  Complex.m
//  Fractal
//
//  Created by Coding on 06/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import "Complex.h"

@implementation Complex

- (instancetype)initWithReal:(CGFloat) real image: (CGFloat) image
{
    self = [super init];
    _real = real;
    _image = image;

    return self;
}

- (Complex *)addWith:(Complex const*)complex
{
    Complex *c = [[Complex alloc] initWithReal:self.real+complex.real image:self.image+complex.image ];
    
    return c;
}

- (Complex *)mutiplyWith:(Complex *)complex
{
    CGFloat r = self.real * complex.real-self.image*complex.image;
    CGFloat i = self.real*complex.image + self.image * complex.real;
    
    return [[Complex alloc] initWithReal:r image:i];
}


- (Complex *)square
{
    return  [self mutiplyWith:self];
}

- (CGFloat)model
{
    return sqrt(self.real*self.real + self.image*self.image);
}

- (CGFloat)modelSquare
{
    return self.real*self.real + self.image*self.image;
}

- (id)copyWithZone:(NSZone *)zone
{
    Complex *c= [[Complex alloc] init];
    c.real = _real;
    c.image = _image;
    return c;
}
@end
