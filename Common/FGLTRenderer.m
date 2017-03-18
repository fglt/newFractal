//
//  FGLTRenderer.m
//  MetalDemo
//
//  Created by Coding on 17/03/2017.
//  Copyright © 2017 objc.io. All rights reserved.
//

#import "FGLTRenderer.h"

@interface FGLTRenderer()
@property (nonatomic, weak) MTKView *view;
@property (nonatomic, weak) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLLibrary> library;
@property (nonatomic, strong) id<MTLRenderPipelineState> renderPipelineState;
@property (nonatomic, strong) id<MTLComputePipelineState> fractalPipelineState;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;

@property (nonatomic, strong) id<MTLTexture> colorTexture;

@property (nonatomic, readonly) MTLSize gridSize;

@end

@implementation FGLTRenderer

- (instancetype)initWithView:(MTKView *)view
{
    if (view.device == nil) {
        NSLog(@"Cannot create renderer without the view already having an associated Metal device");
        return nil;
    }
    
    if ((self = [super init]))
    {
        _view = view;
        _view.delegate = self;
        
        _device = _view.device;
        _library = [_device newDefaultLibrary];
        _commandQueue = [_device newCommandQueue];
        
        CGFloat scale = self.view.layer.contentsScale;
        MTLSize proposedGridSize = MTLSizeMake(_view.drawableSize.width / scale, _view.drawableSize.height / scale, 1);
        
        _gridSize = proposedGridSize;
        FractalOptions f = {100, 16, 0.45, -0.1428};
        _fractalOptions = f;
        ColorOptions c = {0, 7, 5,1};
        _colorOptions =  c;
        [self buildRenderResources];
        [self buildRenderPipeline];
        [self buildComputeResources];
        [self buildComputePipeline];

    }
    
    return self;
}

- (void)buildRenderResources
{
    // Vertex data for a full-screen quad. The first two numbers in each row represent
    // the x, y position of the point in normalized coordinates. The second two numbers
    // represent the texture coordinates for the corresponding position.
    static const float vertexData[] = {
        -1,  1, 0, 0,
        -1, -1, 0, 1,
        1, -1, 1, 1,
        1, -1, 1, 1,
        1,  1, 1, 0,
        -1,  1, 0, 0,
    };
    
    // Create a buffer to hold the static vertex data
    _vertexBuffer = [_device newBufferWithBytes:vertexData
                                         length:sizeof(vertexData)
                                        options:MTLResourceCPUCacheModeDefaultCache | MTLResourceStorageModeShared];
    _vertexBuffer.label = @"Fullscreen Quad Vertices";
}

- (void)buildRenderPipeline {
    
    // Fetch the vertex and fragment functions from the library
    id<MTLFunction> vertexProgram = [self.library newFunctionWithName:@"vertex_function"];
    id<MTLFunction> fragmentProgram = [self.library newFunctionWithName:@"fragment_function"];
    
    MTLVertexDescriptor *vertexDescriptor = [MTLVertexDescriptor new];
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat2;
    vertexDescriptor.attributes[1].offset = sizeof(float) * 2;
    vertexDescriptor.attributes[1].bufferIndex = 0;
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
    vertexDescriptor.layouts[0].stride = sizeof(float) * 4;
    vertexDescriptor.layouts[0].stepRate = 1;
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    
    // Build a render pipeline descriptor with the desired functions
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    [pipelineStateDescriptor setVertexFunction:vertexProgram];
    [pipelineStateDescriptor setFragmentFunction:fragmentProgram];
    pipelineStateDescriptor.vertexDescriptor = vertexDescriptor;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    // Compile the render
    
    
    NSError* error = NULL;
    self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!self.renderPipelineState) {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
}

- (void)reshapeWithDrawableSize:(CGSize)drawableSize
{
    // Select a grid size that matches the size of the view in points
    CGFloat scale = self.view.layer.contentsScale;
    MTLSize proposedGridSize = MTLSizeMake(drawableSize.width / scale, drawableSize.height / scale, 1);
    
    if (_gridSize.width != proposedGridSize.width || _gridSize.height != proposedGridSize.height) {
        _gridSize = proposedGridSize;
        [self buildComputeResources];
    }
}

- (void)buildComputeResources
{
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                          width:_gridSize.width
                                                                                         height:_gridSize.height
                                                                                      mipmapped:NO];
    descriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    
    
    _colorTexture = [_device newTextureWithDescriptor:descriptor];
    _colorTexture.label = @"escapeTime State";
}

- (void)buildComputePipeline
{
    NSError *error = nil;
    
    _commandQueue = [_device newCommandQueue];
    
    // The main compute pipeline runs the game of life simulation each frame
    MTLComputePipelineDescriptor *descriptor = [MTLComputePipelineDescriptor new];
    descriptor.computeFunction = [_library newFunctionWithName:@"fractal_color"];
    descriptor.label = @"fractal color";
    _fractalPipelineState = [_device newComputePipelineStateWithDescriptor:descriptor
                                                                      options:MTLPipelineOptionNone
                                                                   reflection:nil
                                                                        error:&error];
    
    if (!_fractalPipelineState)
    {
        NSLog(@"Error when compiling simulation pipeline state: %@", error);
    }
}

- (MTLRenderPassDescriptor *)renderPassDescriptorForTexture:(id<MTLTexture>) texture
{
    // Configure a render pass with properties applicable to its single color attachment (i.e., the framebuffer)
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPassDescriptor.colorAttachments[0].texture = texture;
    
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    return renderPassDescriptor;
}

#pragma mark - Render and Compute Encoding

- (void)encodeComputeWorkInBuffer:(id<MTLCommandBuffer>)commandBuffer
{
    // The grid we read from to update the simulation is the one that was last displayed on the screen
    //id<MTLTexture> readTexture = [self.textureQueue lastObject];
    // The grid we write the new game state to is the one at the head of the queue
    //id<MTLTexture> writeTexture = [self.textureQueue firstObject];
    
    // Create a compute command encoder with which we can ask the GPU to do compute work
    id<MTLComputeCommandEncoder> commandEncoder = [commandBuffer computeCommandEncoder];
    
    // For updating the game state, we divide our grid up into square threadgroups and
    // determine how many we need to dispatch in order to cover the entire grid
    MTLSize threadsPerThreadgroup = MTLSizeMake(16, 16, 1);
    MTLSize threadgroupCount = MTLSizeMake(ceil((float)self.gridSize.width / threadsPerThreadgroup.width),
                                           ceil((float)self.gridSize.height / threadsPerThreadgroup.height),
                                           1);

    // Configure the compute command encoder and dispatch the actual work
    [commandEncoder setComputePipelineState:self.fractalPipelineState];
    //[commandEncoder setTexture:_currentGradientTexture atIndex:0];
    [commandEncoder setTexture:_colorTexture atIndex:0];
    [commandEncoder setBytes:&_fractalOptions length:sizeof(_fractalOptions) atIndex:0];
    [commandEncoder setBytes:&_colorOptions length:sizeof(_colorOptions) atIndex:1];
    [commandEncoder dispatchThreadgroups:threadgroupCount threadsPerThreadgroup:threadsPerThreadgroup];
    
    // If the user has interacted with the simulation, we now need to dispatch a smaller
    // amount of work to activate random cells near the points they have clicked/touched
    
    [commandEncoder endEncoding];
}

- (void)encodeRenderWorkInBuffer:(id<MTLCommandBuffer>)commandBuffer
{
    MTLRenderPassDescriptor *renderPassDescriptor = self.view.currentRenderPassDescriptor;
    
    if(renderPassDescriptor != nil)
    {
        // Create a render command encoder, which we can use to encode draw calls into the buffer
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        // Configure the render encoder for drawing the full-screen quad, then issue the draw call
        [renderEncoder setRenderPipelineState:self.renderPipelineState];
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [renderEncoder setFragmentTexture:_colorTexture atIndex:0];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
        
        [renderEncoder endEncoding];
        
        // Present the texture we just rendered on the screen
        [commandBuffer presentDrawable:self.view.currentDrawable];
    }
}

#if TARGET_OS_IOS || TARGET_OS_TV
- (CGImageRef)CGImageForImageNamed:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    return [image CGImage];
}
#else
- (CGImageRef)CGImageForImageNamed:(NSString *)imageName {
    NSImage *image = [NSImage imageNamed:imageName];
    return [image CGImageForProposedRect:NULL context:nil hints:nil];
}
#endif

- (void) draw{
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    [self encodeComputeWorkInBuffer:commandBuffer];
    [self encodeRenderWorkInBuffer:commandBuffer];
    
    // Finalize the command buffer and commit it to its queue
    [commandBuffer commit];
}

- (BOOL)fractal
{
    [self draw];
    return true;
}

- (void)setFractalOptions:(FractalOptions) options{
    _fractalOptions = options;
}
- (void)setColorOptions:(ColorOptions) options{
    _colorOptions = options;
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}

- (void)drawInMTKView:(MTKView *)view
{
    
}

@end
