//
//  FGTHSBSupport.m
//  BrushTest
//
//  Created by Coding on 8/7/16.
//  Copyright © 2016 Coding. All rights reserved.
//

#import "FGTHSBSupport.h"
#import <mach-o/arch.h>
#import <sys/sysctl.h>

//------------------------------------------------------------------------------
#pragma mark	Floating point conversion
//------------------------------------------------------------------------------

static void hueToComponentFactors(CGFloat h, CGFloat*bgr)
{
    if(h == 1)
        h=0;
    CGFloat h_prime = h * 6;
    int  i = h_prime;
    CGFloat x = 1.0f - fabs(fmod(h_prime, 2.0f) - 1.0f);
    CGFloat bgr0[] = {0,x,1,0,1,x,x,1,0,1,x,0,1,0,x,x,0,1};
    memcpy(bgr, bgr0 + i*3, 3*sizeof(CGFloat));
}

void HSVtoRGB(const CGFloat*hsv, CGFloat* bgr)
{
    hueToComponentFactors(hsv[0], bgr);
    
    CGFloat c = hsv[2] * hsv[1];
    CGFloat m = hsv[2] - c;
    
    bgr[2] = bgr[2] * c + m;
    bgr[1] = bgr[1] * c + m;
    bgr[0] = bgr[0] * c + m;
}
//------------------------------------------------------------------------------

void RGBToHSV(const CGFloat * bgr, CGFloat*hsv, BOOL preserveHS)
{
    CGFloat max = bgr[2];
    CGFloat min = bgr[2];
    
    if (max <  bgr[1])
        max =  bgr[1];
    else{
        min = bgr[1];
    }
    if (max <  bgr[0])
        max =  bgr[0];
    else{
        if (min >  bgr[0])
            min =  bgr[0];
    }
    
    // Brightness (aka Value)
    
    hsv[2] = max;
    
    // Saturation
    
    CGFloat sat;
    
    if (max != 0.0f) {
        sat = (max - min) / max;
        hsv[1] = sat;
    }
    else {
        sat = 0.0f;
        
        if (!preserveHS)
            hsv[1] = 0.0f;             // Black, so sat is undefined, use 0
    }
    
    // Hue
    
    CGFloat delta;
    
    if (sat == 0.0f) {
        if (!preserveHS)
            hsv[0] = 0.0f;           // No color, so hue is undefined, use 0
    }
    else {
        delta = max - min;
        
        CGFloat hue;
        
        if (bgr[2] == max)
            hue = (bgr[1] - bgr[0]) / delta;
        else if (bgr[1] == max)
            hue = 2 + (bgr[0] - bgr[2]) / delta;
        else
            hue = 4 + (bgr[2] - bgr[1]) / delta;
        
        hue /= 6.0f;
        
        if (hue < 0.0f)
            hue += 1.0f;
        
        if (!preserveHS || fabs(hue - hsv[0]) != 1.0f)
            hsv[0] = hue;                               // 0.0 and 1.0 hues are actually both the same (red)
    }
}


void color(CGFloat value, UInt8 *bgr, int max)
{
    CGFloat hsv[3] = {0,1,1};
    
    //hsv[0] = (log2(value+delta)-log2(delta))/(log2(_times+delta)-log2(delta)) ;
    //hsv[0] = log2(value/delta+1)/(log2(_times/delta+1)) ;
    //    hsv[0] = log2(value/_times+1);
    //    hsv[0] = (log2(value+1)+1)/(log2(_times+1)+1);
    //    hsv[0] += value/_times;
    //    CGFloat step = 3*exp((value-_times)/_times)/M_E-0.5;
    //    if(value>_times*0.3)
    //        hsv[0]+= step;
    //    if(value>_times*0.6)
    //        hsv[0]+= step;
    
    hsv[0] = value/max*0.7;
    CGFloat step = exp(value-max)*2;
    if(value>max*0.1)
        hsv[0]+= step;
        hsv[0] = hsv[0]<=1? hsv[0]:0;
        CGFloat bgrf[3] ={0,0,0};
        HSVtoRGB(hsv, bgrf);
        bgr[0] = bgrf[0]*255;
        bgr[1] = bgrf[1]*255;
        bgr[2] = bgrf[2]*255;
        
}

void cubehelix(CGFloat lamda, CGFloat start, CGFloat rot, CGFloat hue, CGFloat gamma, UInt8 *bgr)
{
    CGFloat theta = 2*M_PI*(start/3 + rot * lamda);
    CGFloat sint = sin(theta);
    CGFloat cost = cos(theta);
    CGFloat l = pow(lamda, gamma);
    CGFloat amplitude =  hue * l* (1-l)/2;
    
    CGFloat red = l + amplitude *(-0.14861*cost + 1.78277*sint);
    CGFloat green = l + amplitude *(-0.29227*cost - 0.90649*sint);
    CGFloat blue = l + amplitude *1.97294*cost;

    red = 0>=red ? 0: (red>=1? 255 :red*255);
    green = 0>=green ? 0: (green>=1? 255 :green*255);
    blue = 0>=blue ? 0: (blue>=1? 255 :blue*255);
    
    bgr[2] = red;
    bgr[1] = green;
    bgr[0] = blue;
}

void cubehelixF(CGFloat value, UInt8 *bgr)
{
    cubehelix(value, 0, 7, 5, 1, bgr);
    //cubehelix(value, 1, 2, 2, 1, bgr);
}

UInt32 countOfCPUThreads()
{
    UInt32 ncpu;
    size_t len = sizeof(ncpu);
    sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
    
    return ncpu;
}
