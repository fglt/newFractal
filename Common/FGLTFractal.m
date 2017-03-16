//
//  FGFractal.m
//  Fractal
//
//  Created by Coding on 12/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import "FGLTFractal.h"
#import "FGTHSBSupport.h"

@implementation FGLTFractal
{
    UInt8 *imgData;
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
    if(context) return ;
    [self imgContextWithWidth:_width height:_height];
    
    [self fractalWithHandler:^(int startY, int endY) {
        [self fractalWidthStartY:startY endY:endY handler:^CGFloat(int x, int y) {
            int m =0;
            Complex * z = [[Complex alloc] initWithReal:(CGFloat)x*3/_width-1.5 image:(CGFloat)y*3/_height-1.5];
            for(; m <_times; m++){
                if([z modelSquare]>=_radius*_radius) break;
                z =  [[z square] addWith:_cComplex];
            }
            return 1-(CGFloat)m/_times;
        }];
    } completion:^{
        if(completion)
            completion();
        [self clear];
    }];
}

- (void)fractalGradientWithStepHandler:(nonnull void (^)())handler completion:(void (^)())completion
{
    if(!complexArray){
        [self imgContextWithWidth:_width height:_height];
        int halfHeight = (_height+1)/2;
    
        kdata = malloc(_width*halfHeight *sizeof(UInt16));
        complexArray = [NSMutableArray arrayWithCapacity:_width*halfHeight];
        
        for(int i=0 ; i<halfHeight; i++){
            for(int j= 0; j<_width; j++){
                int index = j+i*_width;
                
                complexArray[index] = [[Complex alloc] initWithReal:(CGFloat)j*3/_width-1.5 image:(CGFloat)i*3/_height-1.5];
                kdata[index] = 0;
            }
        }
    }
    
    if(_loops>= _times) {
        if(completion)
            completion();
        [self clear];
        return;
    }
    
    [self fractalWithHandler:^(int startY, int endY) {
        [self fractalWidthStartY:startY endY:endY handler:^CGFloat(int x, int y) {
            int index = x+y*_width;
            Complex *tmpc;
            
            tmpc = complexArray[index];
            if([tmpc modelSquare]<_radius*_radius){
                complexArray[index] = [[tmpc square] addWith:_cComplex];
                kdata[index]++ ;
            }
            
            return 1-(CGFloat)kdata[index]/_times;
        }];
    } completion:^{
        _loops++;
        handler();
    }];
}

- (void)fractalWithHandler:(void (^)(int startY, int endY))handler completion:(void (^)())completion
{
    int threadCount =  countOfCPUThreads();
    int halfHeight = (_height+1)>>1;
    int heightPerThread = halfHeight/threadCount;
    int mod = halfHeight%threadCount;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    for(int count=0; count<threadCount; count++){
        dispatch_group_async(group, queue, ^{
            int startY = heightPerThread*count;
            int endY = startY + heightPerThread + mod*((count+1)/threadCount);
            handler(startY, endY);
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if(completion)
            completion();
    });
}

- (void)imgContextWithWidth:(int) width height:(int) height
{
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
- (void)fractalWidthStartY:(int)startY endY:(int)endY handler:(CGFloat (^)(int x, int y))handler
{
    int bytesPerRow = _width<<2;
    UInt8 bgr[3] = {0};
    UInt8 *ptr = imgData +startY*bytesPerRow;
    UInt8 *ptr2 = imgData + (_height-startY) *bytesPerRow - 4;
    
    for(int i=startY ; i<endY; i++){
        for(int j= 0; j<_width; j++){
            CGFloat value = handler(j, i);
            cubehelixF(value, bgr);
            memcpy(ptr, bgr, 3);
            memcpy(ptr2, bgr, 3);
            ptr += 4;
            ptr2 -=4;
        }
    }
}


- (void)clear
{
    free(imgData);
    imgData = nil;
    CGContextRelease(context);
    context = nil;
    
    if(kdata)
    {
        free(kdata);
        kdata = nil;
    }
    
    if(complexArray)
    {
        [complexArray removeAllObjects];
        complexArray = nil;
    }
    _loops = 0;
}

@end
