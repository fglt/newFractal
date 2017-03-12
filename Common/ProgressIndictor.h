//
//  ProgressIndictor.h
//  Fractal
//
//  Created by Coding on 12/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

@import UIKit;


@interface ProgressIndictor : UIProgressView
@property (nonatomic) CGFloat doubleValue;
@end

#else

@import Cocoa;

@interface ProgressIndictor : NSProgressIndicator

@end

#endif

