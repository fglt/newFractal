//
//  ViewController.m
//  GPUFractalIOS
//
//  Created by Coding on 19/03/2017.
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

@property (weak) IBOutlet UIView *mtkBoardView;
@property (weak) IBOutlet UITextField *crText;
@property (weak) IBOutlet UITextField *ciText;
@property (weak) IBOutlet UITextField *timesText;
@property (weak) IBOutlet UISlider *complexRSlider;
@property (weak) IBOutlet UISlider *complexISlider;

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
    [self.renderer startFractal:YES];
}

- (IBAction)sliderChanged:(UISlider *)sender {
    _crText.text = [NSString stringWithFormat:@"%.3f",_complexRSlider.value];
    _ciText.text = [NSString stringWithFormat:@"%.3f",_complexISlider.value];

    [self configFractal];
    [self.renderer startFractal:NO];
    
}

- (void)configFractal
{
    NSString *crs,*cis, *timestring;

    crs = _crText.text;
    cis = _ciText.text;
    timestring = _timesText.text;

    FractalOptions fo = {[timestring intValue], 16, [crs floatValue], [cis floatValue]};
    [_renderer setFractalOptions:fo];
}

- (UIImage *)imageFromCGImageRef:(CGImageRef)image

{
    UIImage *newImage;

    newImage = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
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
