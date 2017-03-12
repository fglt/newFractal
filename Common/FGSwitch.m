//
//  FGSwitch.m
//  Fractal
//
//  Created by Coding on 12/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import "FGSwitch.h"

@interface FGSwitch ()
@end

@implementation FGSwitch

- (BOOL)check{
    
#if TARGET_OS_IPHONE
    return self.isOn;
#else
    return self.state;
#endif
}
@end
