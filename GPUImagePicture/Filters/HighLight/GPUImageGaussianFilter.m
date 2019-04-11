//
//  GPUImageGaussianFilter.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/11.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageGaussionFilter.h"

NSString *const kGPUImageGaussianFragmentShaderString = SHADER_STRING
(
 precision highp float;
 precision highp int;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform int blurAlongX;
 uniform int width;
 uniform int height;
 const float kernelSize = 6.0750003;
 const vec3 initialGaussian = vec3(0.80785817, 0.885208, 0.78359324);
 void main()
{
    vec3 incrementalGaussian = initialGaussian;
    
    vec4 avgValue = vec4(0.0);
    float coefficientSum = 0.0;
    
    avgValue += texture2D(inputImageTexture, textureCoordinate) * incrementalGaussian.x;
    coefficientSum += incrementalGaussian.x;
    incrementalGaussian.xy *= incrementalGaussian.yz;
    
    float centerColFp = textureCoordinate.x * float(width);
    int centerCol = int(centerColFp);
    float centerRowFp = textureCoordinate.y * float(height);
    int centerRow = int(centerRowFp);
    
    for (int i = 1; i <= int(kernelSize); i++) {
        
        float leftFp = textureCoordinate.x;
        float rightFp = textureCoordinate.x;
        float bottomFp = textureCoordinate.y;
        float topFp = textureCoordinate.y;
        
        if (blurAlongX != 0) {
            int left = centerCol - i;
            left = (left >= 0) ? left : 0;
            leftFp = (float(left) + 0.5) / float(width);
            
            int right = centerCol + i;
            int maxRight = width - 1;
            right = (right <= maxRight) ? right : maxRight;
            rightFp = (float(right) + 0.5) / float(width);
        } else {
            int bottom = centerRow - i;
            bottom = (bottom >= 0) ? bottom : 0;
            bottomFp = (float(bottom) + 0.5) / float(height);
            
            int top = centerRow + i;
            int maxTop = height - 1;
            top = (top <= maxTop) ? top : maxTop;
            topFp = (float(top) + 0.5) / float(height);
        }
        
        avgValue += texture2D(inputImageTexture, vec2(leftFp, bottomFp)) * incrementalGaussian.x;
        avgValue += texture2D(inputImageTexture, vec2(rightFp, topFp)) * incrementalGaussian.x;
        
        coefficientSum += 2.0 * incrementalGaussian.x;
        incrementalGaussian.xy *= incrementalGaussian.yz;
    }
    
    gl_FragColor = avgValue / coefficientSum;
}
 );


@interface GPUImageGaussianFilter()
@property(readwrite, nonatomic) GLint blurAlongXUniform;
@property(readwrite, nonatomic) GLint widthUniform;
@property(readwrite, nonatomic) GLint heightUniform;
@end

@implementation GPUImageGaussianFilter

- (instancetype) init {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageGaussionFragmentShaderString]))
    {
        return nil;
    }
    runSynchronouslyOnVideoProcessingQueue(^{
        _blurAlongXUniform = [filterProgram uniformIndex:@"blurAlongX"];
        _blurAlongX = NO;
        _widthUniform = [filterProgram uniformIndex:@"width"];
        _heightUniform = [filterProgram uniformIndex:@"height"];
    });
    
    return self;
}

- (void)setBlurAlongX:(BOOL)blurAlongX {
    _blurAlongX = blurAlongX;
    [self setInteger:_blurAlongX forUniform:_blurAlongXUniform program:filterProgram];
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    [super setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
    [self setInteger:(int)newInputFramebuffer.size.width forUniform:_widthUniform program:filterProgram];
    [self setInteger:(int)newInputFramebuffer.size.height forUniform:_heightUniform program:filterProgram];
}

@end
