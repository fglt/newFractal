//
//  help.h
//  Fractal
//
//  Created by Coding on 12/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#ifndef help_h
#define help_h

#if TARGET_OS_IPHONE

@import UIKit;

#define RootView UIViewController
#define NameView(name) UI##name
#define CheckButton UISwitch
#define ProgressView UIProgressView
#define IMAGE_CLASS UIImage

#else

@import Cocoa;
#define RootView NSViewController
#define NameView(name) NS##name
#define CheckButton NSButton
#define ProgressView NSProgressIndicator
#define IMAGE_CLASS NSImage
#endif

#endif /* help_h */
