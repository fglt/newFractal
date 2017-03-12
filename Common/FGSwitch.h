//
//  FGSwitch.h
//  Fractal
//
//  Created by Coding on 12/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE

@import UIKit;

@interface FGSwitch : UISwitch
@property (nonatomic, readonly) BOOL check;
@end

#else

@import Cocoa;
@interface FGSwitch : NSButton
@property (readonly) BOOL check;
@end

#endif


