//
//  Complex.h
//  Fractal
//
//  Created by Coding on 06/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

@interface Complex : NSObject<NSCopying>

@property (nonatomic) CGFloat real;
@property (nonatomic) CGFloat image;

- (instancetype)initWithReal:(CGFloat) real image: (CGFloat) image;

- (Complex *)addWith:(Complex const*)complex;
- (Complex *)mutiplyWith:(Complex *)complex;

- (Complex *)square;
- (CGFloat)model;
- (CGFloat)modelSquare;
@end
