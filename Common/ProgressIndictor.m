//
//  ProgressIndictor.m
//  Fractal
//
//  Created by Coding on 12/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import "ProgressIndictor.h"

@implementation ProgressIndictor

- (void)setDoubleValue:(CGFloat)doubleValue
{
#if TARGET_OS_IPHONE
    self.progress = doubleValue;
#else
    [super setDoubleValue:doubleValue*100];
#endif
}

- (CGFloat)doubleValue
{
#if TARGET_OS_IPHONE
    return self.progress;
#else
    return [super doubleValue]/100.0;
#endif
}
@end
