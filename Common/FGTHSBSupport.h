//
//  FGTHSBSupport.h
//  BrushTest
//
//  Created by Coding on 8/7/16.
//  Copyright © 2016 Coding. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

//------------------------------------------------------------------------------

	// These functions convert between an RGB value with components in the
	// 0.0f..1.0f range to HSV where Hue, Saturation and
	// Value (aka Brightness) are percentages expressed as 0.0f..1.0f.
	//
	// Note that HSB (B = Brightness) and HSV (V = Value) are interchangeable
	// names that mean the same thing. I use V here as it is unambiguous
	// relative to the B in RGB, which is Blue.


void HSVtoRGB(const CGFloat*hsv, CGFloat* bgr);

void RGBToHSV(const CGFloat *bgr, CGFloat *hsv,
              BOOL preserveHS);

void color(CGFloat value, UInt8 *bgr, int max);

void cubehelixF(CGFloat value, UInt8 *bgr);
UInt32 countOfCPUThreads();
