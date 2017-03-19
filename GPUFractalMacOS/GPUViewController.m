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
#import "FGLTGradientRenderer.h"

@interface GPUViewController ()

@property (weak) IBOutlet NSView *mtkBoardView;
@property (weak) IBOutlet NSTextField *crText;
@property (weak) IBOutlet NSTextField *ciText;
@property (weak) IBOutlet NSTextField *timesText;
@property (weak) IBOutlet FGSwitch *typeSwitch;
@property (weak) IBOutlet FGSwitch *realTime;
@property (weak) IBOutlet NSSlider *complexRSlider;
@property (weak) IBOutlet NSSlider *complexISlider;

@property (weak, nonatomic) IBOutlet ProgressIndictor *progressIndicator;

@property (nonatomic, strong) FGLTGradientRenderer *renderer;

@property (nonatomic, strong) MTKView *mtkView;
@end

@implementation GPUViewController{
    FractalHandler handler;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMetal];
    _renderer = [[FGLTGradientRenderer alloc] initWithView:_mtkView];
    __weak typeof(self) weakSelf = self;
    handler =^(){
        weakSelf.progressIndicator.doubleValue = [(FGLTGradientRenderer *)weakSelf.renderer progress];
        
    };
    [_renderer setHandler:handler];

    //_renderer = [[FGLTRenderer alloc] initWithView:_mtkView];
}

- (IBAction)fractalButtonAction:(id)sender {
    
    [self configFractal];
    self.renderer.gradient = _typeSwitch.check;
    [self.renderer fractal];
}

- (IBAction)sliderChanged:(NSSlider *)sender {
    _crText.floatValue = _complexRSlider.floatValue;
    _ciText.floatValue = _complexISlider.floatValue;

    if(_realTime.check && !_typeSwitch.check){
        _renderer.gradient = false;
        [self configFractal];
        [self.renderer fractal];
    }
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
    //_mtkView.drawableSize = _mtkView.bounds.size;
    _mtkView.enableSetNeedsDisplay = YES;
    _mtkView.paused = YES;
    [_mtkBoardView addSubview:_mtkView];
    
    //self.view.contentScaleFactor = [UIScreen mainScreen].scale;
}
@end
