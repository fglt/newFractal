//
//  FGFractal.m
//  Fractal
//
//  Created by Coding on 12/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import "FGLTFractal.h"
#import "FGTHSBSupport.h"
#import <mach-o/arch.h>
#import <sys/sysctl.h>

@implementation FGLTFractal
{
    void *imgData;
    UInt16 *kdata;
    CGContextRef context;
    int _loops;
    NSMutableArray *complexArray;
}

- (instancetype)initWithComplex:(Complex *)complex radius:(uint)radius times:(uint)times size:(CGSize)size{
    self = [super init];
    _cComplex = [complex copy];
    _radius = radius;
    _times = times;
    _width = size.width;
    _height = size.height;
    return self;
}

- (instancetype)initWithComplexR:(CGFloat )r ComplexI:(CGFloat)i radius:(uint)radius times:(uint)times width:(CGFloat)w height:(CGFloat)h{
    self = [super init];
    _cComplex = [[Complex alloc] initWithReal:r image:i];
    _radius = radius;
    _times = times;
    _width = w;
    _height = h;
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    FGLTFractal *f= [[FGLTFractal alloc] init];
    f.cComplex = [_cComplex copy];
    f.radius = _radius;
    f.times = _times;
    f.width= _width;
    f.height = _height;
    return f;
}

- (void)fractalsWithCompletion:(void (^)())completion
{
    [self imgContextWithWidth:_width height:_height];
    
    int bytesPerRow = 4*_width;
    int threadCount = [self countOfCores];
    int heightPerThread = _height/threadCount;
    int mod = _height%threadCount;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    for(int count=0; count<threadCount; count++){
        dispatch_group_async(group, queue, ^{
            UInt8 *ptr= imgData+count*bytesPerRow*heightPerThread;
            int startY = heightPerThread*count;
            int endY = startY + heightPerThread + mod*((count+1)/threadCount);
            [self fractalStepWidthStartY:startY endY:endY data:ptr];
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if(completion)
            completion();
        CGContextRelease(context);
    });
}

- (void)fractalGradientWithStepHandler:(nonnull void (^)())handler completion:(void (^)())completion
{
    if(!complexArray){
        complexArray = [NSMutableArray arrayWithCapacity:_width*_height];
        kdata = malloc(_width*_height *sizeof(UInt16));
    }
    if(_loops>= _times) {
        if(completion)
            completion();
        free(imgData);
        imgData = nil;
        CGContextRelease(context);
        free(kdata);
        kdata = nil;
        [complexArray removeAllObjects];
        complexArray = nil;
        _loops = 0;
        return;
    }
    
    [self imgContextWithWidth:_width height:_height];
    
    UInt8 *ptr= imgData;
    for(int i=0 ; i<_height; i++){
        for(int j= 0; j<_width; j++){
            UInt8 bgr[3] = {0};
            int index = j+i*_width;
            Complex *tmpc;
            if(_loops==0){
                complexArray[index] = [[Complex alloc] initWithReal:(CGFloat)j*3/_width-1.5 image:(CGFloat)i*3/_height-1.5];
                kdata[index] = 0;
            }else{
                tmpc = complexArray[index];
                if([tmpc modelSquare]<_radius*_radius){
                    complexArray[index] = [[tmpc square] addWith:_cComplex];
                    kdata[index]++ ;
                }
            }
            
            [self color: kdata[index] bgr:bgr];
            
            ptr[0] = bgr[0];
            ptr[1] = bgr[1];
            ptr[2] = bgr[2];
            ptr += 4;
        }
    }
    
    _loops++;
    handler();
}

- (void)imgContextWithWidth:(int) width height:(int) height{
    if(!imgData)
        imgData = malloc(_width * _height * 4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo kBGRxBitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    
    context = CGBitmapContextCreate(imgData,width, height, 8, width * 4, colorSpace, kBGRxBitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
}

- (CGImageRef)newCGImage
{
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    return cgimage;
}

- (CGFloat)progress
{
    return (CGFloat)_loops/_times;
}

- (void)configComplexWithReal:(CGFloat)real image:(CGFloat)image
{
    _cComplex = [[Complex alloc] initWithReal:real image:image];
}

#pragma mark - private
-(void) fractalStepWidthStartY:(int)startY endY:(int)endY data:(UInt8 *)ptr
{
    UInt8 bgr[3] = {0};
    
    for(int i=startY ; i<endY; i++){
        Complex * z;
        Complex *z0;
        for(int j= 0; j<_width; j++){
            int m =0;
            z0 = [[Complex alloc] initWithReal:(CGFloat)j*3/_width-1.5 image:(CGFloat)i*3/_height-1.5];
            z = z0;
            for(; m <_times; m++){
                if([z modelSquare]>=_radius*_radius) break;
                z =  [[z square] addWith:_cComplex];
            }
            [self color:m bgr:bgr];
            ptr[0]= bgr[0];
            ptr[1] = bgr[1];
            ptr[2] = bgr[2];
            ptr += 4;
        }
    }
}

- (void)color:(CGFloat)value bgr:(UInt8 *)bgr
{
    CGFloat hsv[3] = {0,1,1};
    //hsv[0] =  value/_times*1.2;
    hsv[0] = value<=5?  value/_times/1.4 : value/_times/1.4+exp(value-_times)/2;
    hsv[0] = hsv[0]<=1? hsv[0]:0;
    CGFloat bgrf[3] ={0,0,0};
    HSVtoRGB(hsv, bgrf);
    bgr[0] = bgrf[0]*255;
    bgr[1] = bgrf[1]*255;
    bgr[2] = bgrf[2]*255;
    
}

- (UInt32)countOfCores
{
    UInt32 ncpu;
    size_t len = sizeof(ncpu);
    sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
    
    return ncpu;
}

@end
