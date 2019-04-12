//
//  GPUImageBlurredLumAdjustFilter.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/11.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageBlurredLumAdjustFilter.h"
#import "GLUtils.h"

NSString *const kGPUImageBlurredLumAdjustFragmentShaderString = SHADER_STRING
(
 precision highp float;
 precision highp int;
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;
 uniform sampler2D inputImageTexture;//image
 uniform sampler2D inputImageTexture2;//sharpenBlur
 uniform sampler2D inputImageTexture3;//shadowsBlur
 uniform sampler2D splines;
 uniform float highlights;
 const float TOOL_ON_EPSILON = 0.009;
 const float shadows = 0.0;
 const float sharpen = 0.0;
 const float splines_shadows_offset = 0.25;
 const float splines_shadowsNeg_offset = 0.75;

 vec3 rgb_to_hsv(vec3 c) {
     vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
     vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
     vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
     
     float d = q.x - min(q.w, q.y);
     float e = 1.0e-10;
     return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
 }
 
 // power bow. at 0 returns a linear curve on the inval.
 // at + mag returns an inceasingly "bowed up" curve,
 // at - mag returns the symmetrical function across the (y = x) line.
 // it's reflected so it's heavier at the bottom.
 float powerBow(float inVal, float mag) {
     float outVal;
     float power = 1.0 + abs(mag);
     
     if (mag > 0.0) {
         // flip power, and use abs so it magnitude negative values
         // have curves that are symmetric to positive.
         power = 1.0 / power;
     }
     inVal = 1.0 - inVal;
     outVal = pow((1.0 - inVal), power);
     
     return outVal;
 }
 
 // shadowsAdjust
 // for a passed in luminance curve adjust it by the "shadows area" strong bow or
 // the "non shadows area" by the gentle bow function.
 // the blurred luminance value is used to determing if we're in a "shadows area"
 // or "non shadows area"
 // the curves used are here: https://www.facebook.com/pxlcld/l7Dh
 float shadowsAdjust(float inLum, float inBlurredLum, float shadowsAmount) {
     float darkVal;
     float brightVal;
     if (shadowsAmount > 0.0) {
         darkVal = texture2D(splines, vec2(inLum, splines_shadows_offset)).r;
         brightVal = powerBow(inLum, 0.1);
     } else {
         darkVal = texture2D(splines, vec2(inLum, splines_shadowsNeg_offset)).r;
         brightVal = powerBow(inLum, -0.1);
     }
     float mixVal = clamp((inBlurredLum - 0.00)/0.4, 0.0, 1.0);
     float mixedVal = mix(darkVal, brightVal, inBlurredLum);
     
     return mix(inLum, mixedVal, abs(shadowsAmount));
 }
 
 // highlightsAdjust
 // for a passed in luminance curve adjust it by the "highlights area" strong bow or
 // the "non highlights area" by the gentle bow function.
 // this mirrors the shadowsAdjust implmentation, by mirroring the curves used.
 // the curves used are here: https://www.facebook.com/pxlcld/l7Dh
 float highlightsAdjust(float inLum, float inBlurredLum, float highlightsAmount) {
     float darkVal;
     float brightVal;
     if (highlightsAmount < 0.0) {
         brightVal = 1.0 - texture2D(splines, vec2(1.0 - inLum, splines_shadows_offset)).r;
         darkVal = 1.0 - powerBow(1.0 - inLum, 0.1);
     } else {
         brightVal = 1.0 - texture2D(splines, vec2(1.0 - inLum, splines_shadowsNeg_offset)).r;
         darkVal = 1.0 - powerBow(1.0 - inLum, -0.1);
     }
     float mixVal = clamp((inBlurredLum - 0.6)/0.4, 0.0, 1.0);
     float mixedVal = mix(darkVal, brightVal, inBlurredLum);
     
     return mix(inLum, mixedVal, abs(highlightsAmount));
 }
 
 vec3 BlurredLumAdjust(vec3 texel)
{
    // sharpen
    // A zero value actually does something, a default sharpening, so don't put in a TOOL_ON_EPSILON check here
    vec3 blurredTexel = texture2D(inputImageTexture2, textureCoordinate).rgb;
    vec3 diff = texel.rgb - blurredTexel;
    // sharpen magnitude has a default value of 0.35 at input 0, and a maximum of 2.5 at input 1.0.
    float mag = mix(0.35, 2.5, sharpen);
    texel.rgb = clamp(texel.rgb + diff * mag, 0.0, 1.0);
    
    // highlights and shadows both use a blurred texture
    float blurredLum;
    if ((abs(highlights) > TOOL_ON_EPSILON) ||
        (abs(shadows) > TOOL_ON_EPSILON)) {
        vec4 blurredVal = texture2D(inputImageTexture3, textureCoordinate);
        blurredLum = rgb_to_hsv(blurredVal.rgb).z;
    }
    
    // highlights
    if ((abs(highlights) > TOOL_ON_EPSILON)) {
        // highlights tend to look better adjusted in RGB space.
        //                         texel.rgb = hsv_to_rgb(hsv);
        texel.r = highlightsAdjust(texel.r, blurredLum, highlights);
        texel.g = highlightsAdjust(texel.g, blurredLum, highlights);
        texel.b = highlightsAdjust(texel.b, blurredLum, highlights);
    }
    
    //  shadows
    if (abs(shadows) > TOOL_ON_EPSILON) {
        texel.r = shadowsAdjust(texel.r, blurredLum, shadows);
        texel.g = shadowsAdjust(texel.g, blurredLum, shadows);
        texel.b = shadowsAdjust(texel.b, blurredLum, shadows);
    }
    
    return texel;
}
 
 void main(void)
{
    vec4 texel = texture2D(inputImageTexture, textureCoordinate);
    texel.rgb = BlurredLumAdjust(texel.rgb);
    gl_FragColor = texel;
}
 );


@interface GPUImageBlurredLumAdjustFilter()
@property(readwrite, nonatomic) GLint highlightsUniform;
@property(readwrite, nonatomic) GLint splinesTextureUniform;
@property(readwrite, nonatomic) GLuint splinesTextureID;
@end


@implementation GPUImageBlurredLumAdjustFilter

- (instancetype) initWithSPLinesPath:(NSString*) path {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageBlurredLumAdjustFragmentShaderString]))
    {
        return nil;
    }
    runSynchronouslyOnVideoProcessingQueue(^{
        _highlightsUniform = [filterProgram uniformIndex:@"highlights"];
        _highlights = 0.0f;
        _splinesTextureUniform = [filterProgram uniformIndex:@"splines"];
        _splinesTextureID = [GLUtils LoadFileToTexture:path];
    });
    
    return self;
}

- (void)dealloc {
    runSynchronouslyOnVideoProcessingQueue(^{
        if (_splinesTextureID != 0) {
            glDeleteTextures(1, &_splinesTextureID);
            _splinesTextureID = 0;
        }
    });
}

- (void)setHighlights:(CGFloat)highlights {
    _highlights = highlights;
    [self setFloat:_highlights forUniform:_highlightsUniform program:filterProgram];
}


- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex {
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _splinesTextureID);
    glUniform1i(_splinesTextureUniform, 1);
}

@end
