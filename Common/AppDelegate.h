//
//  AppDelegate.h
//  Fractal
//
//  Created by Coding on 06/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IOS
@import UIKit;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

#elif TARGET_OS_OSX
@import Cocoa;
@interface AppDelegate : NSObject <NSApplicationDelegate>


@end

#endif
