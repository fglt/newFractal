//
//  ViewController.m
//  GPUFractalMacOS
//
//  Created by Coding on 17/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

@import Metal;
@import simd;
@import MetalKit;

#import "GPUViewController.h"
#import "FGTHSBSupport.h"
#import "FGSwitch.h"
#import "ProgressIndictor.h"

#import "FGLTRenderer.h"
#import "FGLTGradientRenderer.h"

@interface GPUViewController ()

@property (weak) IBOutlet NSView *mtkBoardView;
@property (weak) IBOutlet NSTextField *crText;
@property (weak) IBOutlet NSTextField *ciText;
@property (weak) IBOutlet NSTextField *timesText;
@property (weak) IBOutlet FGSwitch *typeSwitch;

@property (weak, nonatomic) IBOutlet ProgressIndictor *progressIndicator;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) id<RendererDelegate> renderer;
@property (nonatomic, strong) MTKView *mtkView;
@end

@implementation GPUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMetal];
    _renderer = [[FGLTGradientRenderer alloc] initWithView:_mtkView];
}

- (IBAction)fractalButtonAction:(id)sender {
    
    [self configFractal];
    if(!self.timer){
        _progressIndicator.doubleValue = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(render) userInfo:nil repeats:YES];
    }
//    if([_typeSwitch check]){
//         [self configFractal];
//        if(!self.timer){
//            _progressIndicator.doubleValue = 0;
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(fractalGradients) userInfo:nil repeats:YES];
//        }
//
//    }else{
//        [self configFractal];
//        [self.renderer fractal];
//    }
    
}

- (void)configFractal
{
    NSString *crs,*cis, *timestring;
    
#if TARGET_OS_IPHONE
    crs = _crText.text;
    cis = _ciText.text;
    timestring = _timesText.text;
#else
    crs = [_crText.stringValue isEqual:@""] ? _crText.placeholderString:_crText.stringValue;
    cis = [_ciText.stringValue isEqual:@""] ? _ciText.placeholderString:_ciText.stringValue;
    timestring = [_timesText.stringValue isEqual:@""] ? _timesText.placeholderString:_timesText.stringValue;
    
#endif
    FractalOptions fo = {[timestring intValue], 16, [crs floatValue], [cis floatValue]};
    [_renderer setFractalOptions:fo];
}

- (void)render
{
    if( ![self.renderer fractal]){
        [_timer invalidate];
    }
}

- (IMAGE_CLASS *)imageFromCGImageRef:(CGImageRef)image

{
    IMAGE_CLASS *newImage;
#if TARGET_OS_IPHONE
    newImage = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
#else
    
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    
    CGContextRef imageContext = nil;
    
    
    // Get the image dimensions.
    
    imageRect.size.height = CGImageGetHeight(image);
    
    imageRect.size.width = CGImageGetWidth(image);
    
    
    
    // Create a new image to receive the Quartz image data.
    
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    
    [newImage lockFocus];
    
    
    // Get the Quartz context and draw.
    
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext]
                                  
                                  graphicsPort];
    
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    
    [newImage unlockFocus];
#endif
    return newImage;
}

- (void)setupMetal {
    // Create the default Metal device
    
    CGSize parentSize = _mtkBoardView.bounds.size;
    CGFloat minSize = 301;
    // Create, configure, and add a Metal sublayer to the current layer
    _mtkView = [[MTKView alloc] initWithFrame:CGRectMake((parentSize.width-minSize)/2, (parentSize.height-minSize)/2, minSize, minSize) device:MTLCreateSystemDefaultDevice()];
    
    _mtkView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    _renderer = [[FGLTRenderer alloc] initWithView:_mtkView];
    [_mtkBoardView addSubview:_mtkView];
    
    //self.view.contentScaleFactor = [UIScreen mainScreen].scale;
}
@end
