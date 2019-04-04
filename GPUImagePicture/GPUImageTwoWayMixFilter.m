//
//  GPUImageTwoWayMixFilter.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageTwoWayMixFilter.h"

NSString *const kGPUImageTwoWatMixFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 uniform sampler2D inputImageTexture;//source
 uniform sampler2D inputImageTexture2;//left (-1 ~ 0)
 uniform sampler2D inputImageTexture3;//right (0 ~ 1)
 uniform float luxBlendAmount;
 void main() {
     vec4 texel = texture2D(inputImageTexture, sourceTextureCoordinate);
     vec4 inputTexel = texel;
     if (luxBlendAmount >= 0.0) {
         texel = mix(texel, texture2D(inputImageTexture3, sourceTextureCoordinate), luxBlendAmount);
     } else {
         texel = mix(texel, texture2D(inputImageTexture2, sourceTextureCoordinate), -luxBlendAmount);
     }
     gl_FragColor = texel;
 }

);


@interface GPUImageTwoWayMixFilter()
@property(readwrite, nonatomic) GLint luxBlendAmountUniform;
@end

@implementation GPUImageTwoWayMixFilter

- (instancetype) init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageTwoWatMixFragmentShaderString]))
    {
        return nil;
    }
    runSynchronouslyOnVideoProcessingQueue(^{
        _luxBlendAmountUniform = [filterProgram uniformIndex:@"luxBlendAmount"];
        _luxBlendAmount = 0.0f;
    });
    
    return self;
}

- (void)setLuxBlendAmount:(CGFloat)luxBlendAmount {
    _luxBlendAmount = luxBlendAmount;
    [self setFloat:_luxBlendAmount forUniform:_luxBlendAmountUniform program:filterProgram];
}

@end
