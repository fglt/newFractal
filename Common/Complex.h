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

- (Complex *)addWith:(Complex const*)com;
- (Complex *)mutiplyWith:(Complex *)com;

- (Complex *)square;
- (CGFloat)model;
- (CGFloat)modelSquare;
@end
