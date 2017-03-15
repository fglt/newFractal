//
//  ViewController.m
//  CubeHelix
//
//  Created by Coding on 13/03/2017.
//  Copyright © 2017 Coding. All rights reserved.
//

#import "ViewController.h"
#import "CubeHelix.h"

@interface ViewController()
@property (weak) IBOutlet NSImageView *imgView;

@property (weak) IBOutlet NSTextField *startColorText;

@property (weak) IBOutlet NSTextField *rotationText;
@property (weak) IBOutlet NSTextField *hueText;
@property (weak) IBOutlet NSTextField *gammaText;
@property (weak) IBOutlet NSButton *runButton;
@property (weak) IBOutlet NSButton *rotationDirection;

@end
@implementation ViewController
{
    void *_data;
    CGContextRef _context;
    CubeHelix *_helix;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _helix = [[CubeHelix alloc] initWithStartColor:1 rotation:1 hue:2 gamma:2];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)displayColorImage:(id)sender {
    if(_data) return;
    
    _helix.startColor = [_startColorText.stringValue doubleValue];
    _helix.rotation = [[_rotationText stringValue] doubleValue];
    _helix.hue = [[_hueText stringValue] doubleValue];
    _helix.gamma = [[_gammaText stringValue] doubleValue];
    _helix.rotationDirection = _rotationDirection.state ? 1:0;
    
    [self configContext:500 height:50];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UInt8 *ptr = _data;
        
        CGFloat lamda = 0;
        for(int i=0; i<500; i++){
            CGColorRef color = [_helix color:lamda];
            const CGFloat *components = CGColorGetComponents(color);
            ptr[0] = components[2]*255;
            ptr[1] = components[1]*255;
            ptr[2] = components[0]*255;
            ptr+=4;
            lamda +=0.002;
            CGColorRelease(color);
        }
        
        ptr =_data;
        
        for(int j=1; j<50; j++){
            memcpy(ptr+2000, ptr, 2000);
            ptr+=2000;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            CGImageRef cgimg = CGBitmapContextCreateImage(_context);
            _imgView.image = [self imageFromCGImageRef:cgimg];
            CGImageRelease(cgimg);
            CGContextRelease(_context);
            free(_data);
            _context = nil;
            _data = nil;
        });

    });
}

- (IBAction)directionChanged:(NSButton *)sender {
}


- (void)configContext:(int) width height:(int) height{
    if(!_data)
        _data = malloc(width * height * 4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo kBGRxBitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    
    _context = CGBitmapContextCreate(_data,width, height, 8, width * 4, colorSpace, kBGRxBitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
}

- (NSImage *)imageFromCGImageRef:(CGImageRef)image

{
    NSImage *newImage;

    
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
    return newImage;
}

@end
