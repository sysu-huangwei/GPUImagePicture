//
//  ViewController.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/3.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>

@interface ViewController ()
@property (nonatomic, strong) GPUImageFilter *blurFilterHorizontal;
@property (nonatomic, strong) GPUImageFilter *blurFilterVertical;
@property (nonatomic, strong) GPUImageTwoInputFilter *antiluxFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"逆向.png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    GPUImageView *view = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:view];
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];

    [picture addTarget:self.blurFilterHorizontal];
    [self.blurFilterHorizontal addTarget:self.blurFilterVertical];
    [self.blurFilterVertical addTarget:view];
//    [picture addTarget:self.antiluxFilter];
//    [self.blurFilterVertical addTarget:self.antiluxFilter];
//    [self.antiluxFilter addTarget:view];
    
    [picture processImage];
    [self.blurFilterVertical useNextFrameForImageCapture];
    UIImage* result = [self.blurFilterVertical imageFromCurrentFramebuffer];
    NSLog(@"1");
}


- (GPUImageFilter *)blurFilterHorizontal {
    if (!_blurFilterHorizontal) {
        _blurFilterHorizontal = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"blur"];
        [_blurFilterHorizontal setPoint:CGPointMake(0.000805, 0.000000) forUniformName:@"blurVector"];
    }
    return _blurFilterHorizontal;
}

- (GPUImageFilter *)blurFilterVertical {
    if (!_blurFilterVertical) {
        _blurFilterVertical = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"blur"];
        [_blurFilterVertical setPoint:CGPointMake(0.000000, 0.000805) forUniformName:@"blurVector"];
    }
    return _blurFilterVertical;
}


- (GPUImageTwoInputFilter *)antiluxFilter {
    if (!_antiluxFilter) {
        _antiluxFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromFile:@"antilux"];
        [_antiluxFilter setFloat:1.00 forUniformName:@"filterStrength"];
        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"cdf.png"];
        GLuint cdf = LoadFileToTexture(path);
        [_antiluxFilter setInteger:cdf forUniformName:@"cdf"];
    }
    return _antiluxFilter;
}



GLuint LoadFileToTexture(NSString *path) {
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
    return LoadUIImageToTexture(image);
}

GLuint LoadUIImageToTexture(UIImage* image) {
    if (image != nil) {
        unsigned char* data = RGBADataWithAlpha(image);
        GLuint texture = LoadTexture_BYTE(data, image.size.width, image.size.height, GL_RGBA);
        free(data);
        return texture;
    }
    return 0;
}

GLuint LoadTexture_BYTE(GLubyte* pdata, int width, int height, GLenum glFormat)
{
    GLuint textures;
    glGenTextures(1, &textures);
    if (textures != 0)
    {
        glBindTexture(GL_TEXTURE_2D, textures);
        if (glFormat == GL_LUMINANCE)
        {
            glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
            glTexImage2D(GL_TEXTURE_2D, 0, glFormat, width, height, 0, glFormat, GL_UNSIGNED_BYTE, pdata);
            glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
        }
        else
        {
            glTexImage2D(GL_TEXTURE_2D, 0, glFormat, width, height, 0, glFormat, GL_UNSIGNED_BYTE, pdata);
        }
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        return textures;
    }
    else
    {
        return 0;
    }
}


//Alpha为原始图像的透明度
unsigned char* RGBADataWithAlpha(UIImage* image)
{
    CGImageAlphaInfo info = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = ((info == kCGImageAlphaPremultipliedLast) ||
                     (info == kCGImageAlphaPremultipliedFirst) ||
                     (info == kCGImageAlphaLast) ||
                     (info == kCGImageAlphaFirst) ? YES : NO);
    
    long width = CGImageGetWidth(image.CGImage);
    long height = CGImageGetHeight(image.CGImage);
    if(width == 0 || height == 0)
        return 0;
    unsigned char* imageData = (unsigned char *) malloc(4 * width * height);
    
    CGColorSpaceRef cref = CGColorSpaceCreateDeviceRGB();
    CGContextRef gc = CGBitmapContextCreate(imageData,
                                            width,height,
                                            8,width*4,
                                            cref,kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(cref);
    UIGraphicsPushContext(gc);
    
    if (hasAlpha == YES)
    {
        CGContextSetRGBFillColor(gc, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(gc, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height));
    }
    CGRect rect = {{ 0 , 0 }, {(CGFloat)width, (CGFloat)height }};
    CGContextDrawImage( gc, rect, image.CGImage );
    UIGraphicsPopContext();
    CGContextRelease(gc);
    
    
    
    if (hasAlpha == YES)
    {
        unsigned char array[256][256] = {0};
        for (int j=1; j<256; j++)
        {
            for (int i=0; i<256; i++)
            {
                array[j][i] = fmin(fmax(0.0f,(j+i-255)*255.0/i+0.5),255.0f);
            }
        }
        GLubyte* alphaData = (GLubyte*) calloc(width * height, sizeof(GLubyte));
        CGContextRef alphaContext = CGBitmapContextCreate(alphaData, width, height, 8, width, NULL, kCGImageAlphaOnly);
        CGContextDrawImage(alphaContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image.CGImage);
        // Draw the image into the bitmap context
        CGContextRelease(alphaContext);
        GLubyte* pDest = imageData;
        GLubyte* alphaTemp = alphaData;
        for (int j=0; j<height; j++)
        {
            for (int i=0; i<width; i++)
            {
                
                //自己反计算回原来的alpha值
                pDest[0] = array[pDest[0]][alphaTemp[0]];
                pDest[1] = array[pDest[1]][alphaTemp[0]];
                pDest[2] = array[pDest[2]][alphaTemp[0]];
                
                pDest[3] = alphaTemp[0];
                pDest += 4;
                alphaTemp++;
            }
        }
        free(alphaData);
    }
    
    
    return imageData;// CGBitmapContextGetData(gc);
}

@end
