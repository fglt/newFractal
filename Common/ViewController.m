//
//  ViewController.m
//  Fractal
//
//  Created by Coding on 06/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import "ViewController.h"
#import "FGTHSBSupport.h"
#import "FGSwitch.h"
#import "ProgressIndictor.h"
#import "FGLTFractal.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet NameView(ImageView) *imgView;
@property (weak, nonatomic) IBOutlet NameView(TextField) *crText;
@property (weak, nonatomic) IBOutlet NameView(TextField) *ciText;
@property (weak, nonatomic) IBOutlet NameView(TextField) *timesText;
@property (weak) IBOutlet FGSwitch *typeSwitch;

@property (weak, nonatomic) IBOutlet ProgressIndictor *progressIndicator;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) FGLTFractal *fractal;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _fractal = [[FGLTFractal alloc] init];
    _fractal.radius = 20;
    _fractal.width = 602;
    _fractal.height = 602;
}

- (IBAction)fractalButtonAction:(id)sender {
    
    [self configFractal];
    
    if([_typeSwitch check]){
        if(!self.timer){
            _progressIndicator.doubleValue = 0;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(fractalGradient) userInfo:nil repeats:YES];
        }
        
    }else{
        [self fractals];
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
    [_fractal configComplexWithReal:[crs doubleValue] image:[cis doubleValue]];
    _fractal.times = [timestring intValue];
}

- (void)fractals
{
    [_fractal fractalsWithCompletion:^{
        CGImageRef cgimage = [_fractal newCGImage];
        IMAGE_CLASS *image = [self imageFromCGImageRef:cgimage];
        CGImageRelease(cgimage);
        _imgView.image = image;
    }];
}

- (void)fractalGradient
{
    [_fractal fractalGradientWithStepHandler:^{
        _progressIndicator.doubleValue = _fractal.progress;
        CGImageRef cgimage = [_fractal newCGImage];
        IMAGE_CLASS *image = [self imageFromCGImageRef:cgimage];
        _imgView.image = image;
        CGImageRelease(cgimage);
    } completion:^{
        [_timer invalidate];
        self.timer = nil;
    }];
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



@end
