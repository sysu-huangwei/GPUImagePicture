//
//  GPUImageStarLightFilter.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageStarLightFilter.h"
#import "GLUtils.h"

NSString *const kGPUImageStarLightFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 uniform sampler2D cdf;
 uniform float filterStrength;
 
 vec3 rgb_to_hsv(vec3 rgb) {
     float rc = rgb.r;
     float gc = rgb.g;
     float bc = rgb.b;
     
     float h = 0.0;
     float s = 0.0;
     float v = 0.0;
     
     float max_v = max(rc, max(gc, bc));
     float min_v = min(rc, min(gc, bc));
     float delta = max_v - min_v;
     
     v = max_v;
     
     if (max_v != 0.0) {
         s = delta / max_v;
     } else {
         s = 0.0;
     }
     
     if (s == 0.0) {
         h = 0.0;
     } else {
         if (rc == max_v) {
             h = (gc - bc) / delta;
         } else if (gc == max_v) {
             h = 2.0 + (bc - rc) / delta;
         } else if (bc == max_v) {
             h = 4.0 + (rc - gc) / delta;
         }
         
         h *= 60.0;
         if (h < 0.0) {
             h += 360.0;
         }
     }
     
     return vec3(h,s,v);
     
 }
 
 vec3 hsv_to_rgb(vec3 hsv) {
     float r; float g; float b;
     
     int i = 0;
     float f; float p; float q; float t;
     if( hsv.y == 0.0 ) {
         // achromatic (grey)
         r = g = b = hsv.z;
     } else {
         hsv.x /= 60.0;            // sector 0 to 5
         i = int(floor( hsv.x ));
         f = hsv.x - float(i);            // factorial part of h
         p = hsv.z * ( 1.0 - hsv.y );
         q = hsv.z * ( 1.0 - hsv.y * f );
         t = hsv.z * ( 1.0 - hsv.y * ( 1.0 - f ) );
         
         if (i == 0) {
             r = hsv.z;
             g = t;
             b = p;
         } else if (i == 1) {
             r = q;
             g = hsv.z;
             b = p;
         } else if (i == 2) {
             r = p;
             g = hsv.z;
             b = t;
         } else if (i == 3) {
             r = p;
             g = q;
             b = hsv.z;
         } else if (i == 4) {
             r = t;
             g = p;
             b = hsv.z;
             
         } else {
             r = hsv.z;
             g = p;
             b = q;
         }
     }
     return vec3(r,g,b);
 }
 
 // see: http://en.wikipedia.org/wiki/Adaptive_histogram_equalization
 float clahe2D(sampler2D cdfTexture, vec2 coord, float brightness) {
     const float xHalfPix = 0.001953125; // (1.0/256.0)/2.0;
     const float yHalfPix = .03125; // (1.0/16.0)/2.0;
     brightness = brightness + xHalfPix;
     
     // find the coordinate within the interpolation mesh
     coord = clamp(coord, 0.125, 1.0 - 0.125001) - 0.125;
     coord = coord * (3.0 / (1.0-0.125*2.0));
     vec2 weight = fract(coord);     // the fractional part are our interpolation weights
     coord = floor(coord);           // floor to get the top-right corner
     
     // compute the 4 corners of the mesh we'll be interpolating
     // tl = top-left, tr = top-right etc
     float tl = float(coord.y*4.0 + coord.x)/16.0 + yHalfPix;
     float tr = float(coord.y*4.0 + coord.x + 1.0)/16.0 + yHalfPix;
     float bl = float((coord.y + 1.0)*4.0 + coord.x)/16.0 + yHalfPix;
     float br = float((coord.y + 1.0)*4.0 + coord.x + 1.0)/16.0 + yHalfPix;
     
     // obtain the cdf values of the 4 corners
     vec4 b1 = texture2D(cdfTexture, vec2(brightness, tl));
     vec4 b2 = texture2D(cdfTexture, vec2(brightness, tr));
     vec4 b3 = texture2D(cdfTexture, vec2(brightness, bl));
     vec4 b4 = texture2D(cdfTexture, vec2(brightness, br));
     
     // Commented out for efficiency and subbed in
     //float cdf = cdfColor.r;
     //float cdfMin = cdfColor.b;
     
     // FIXME: this looks wrong!
     float c1 = ((b1.r - b1.b) / (1.0 - b1.b));
     float c2 = ((b2.r - b2.b) / (1.0 - b2.b));
     float c3 = ((b3.r - b3.b) / (1.0 - b3.b));
     float c4 = ((b4.r - b4.b) / (1.0 - b4.b));
     
     // linearly interpolate to obtain the final brightness
     float c1_2 = mix(c1, c2, weight.x);
     float c3_4 = mix(c3, c4, weight.x);
     return mix(c1_2, c3_4, weight.y);
 }
 
 void main() {
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
         vec4 inputTexel = texel;
         vec3 hsv = rgb_to_hsv(texel.rgb);
         hsv.z = clahe2D(cdf, textureCoordinate, hsv.z);
         hsv.y = min(hsv.y*1.2, 1.0);
         texel.rgb = mix(texel.rgb, hsv_to_rgb(hsv), filterStrength);
     gl_FragColor = texel;
 }

);


@interface GPUImageStarLightFilter ()
@property(readwrite, nonatomic) GLint cdfTextureUniform;
@property(readwrite, nonatomic) GLuint cdfTextureID;
@property(readwrite, nonatomic) GLint filterStrengthUniform;
@end

@implementation GPUImageStarLightFilter


- (instancetype) initWithCDFPath:(NSString *) path {
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageStarLightFragmentShaderString]))
    {
        return nil;
    }
    runSynchronouslyOnVideoProcessingQueue(^{
        _cdfTextureUniform = [filterProgram uniformIndex:@"cdf"];
        _filterStrengthUniform = [filterProgram uniformIndex:@"filterStrength"];
        _filterStrength = 1.0f;
        _cdfTextureID = [GLUtils LoadFileToTexture:path];
    });
    
    return self;
}


- (void)dealloc {
    runSynchronouslyOnVideoProcessingQueue(^{
        if (_cdfTextureID != 0) {
            glDeleteTextures(1, &_cdfTextureID);
            _cdfTextureID = 0;
        }
    });
}

- (void)setFilterStrength:(CGFloat)filterStrength {
    _filterStrength = filterStrength;
    [self setFloat:_filterStrength forUniform:_filterStrengthUniform program:filterProgram];
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex {
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _cdfTextureID);
    glUniform1i(_cdfTextureUniform, 1);
}

@end
