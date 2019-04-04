//
//  ViewController.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/3.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "GLUtils.h"
#import "GPUImageStarLightFilter.h"

@interface ViewController ()
@property (nonatomic, strong) GPUImageFilter *blurFilterHorizontal;
@property (nonatomic, strong) GPUImageFilter *blurFilterVertical;
@property (nonatomic, strong) GPUImageTwoInputFilter *antiluxFilter;
@property (nonatomic, strong) GPUImageStarLightFilter *starlightFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"逆向.png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    GPUImageView *view = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:view];
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];

    //变亮的部分
//    [picture addTarget:self.blurFilterHorizontal];
//    [self.blurFilterHorizontal addTarget:self.blurFilterVertical];
//    [picture addTarget:self.antiluxFilter];
//    [self.blurFilterVertical addTarget:self.antiluxFilter];
//    [self.antiluxFilter addTarget:view];
    
    //变暗的部分
    [picture addTarget:self.starlightFilter];
    [self.starlightFilter addTarget:view];
    
    [picture processImage];
    
//    [self.blurFilterVertical useNextFrameForImageCapture];
//    UIImage* result = [self.blurFilterVertical imageFromCurrentFramebuffer];
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
        GLuint cdf = [GLUtils LoadFileToTexture:path];
        [_antiluxFilter setInteger:cdf forUniformName:@"cdf"];
    }
    return _antiluxFilter;
}


- (GPUImageStarLightFilter *)starlightFilter {
    if (!_starlightFilter) {
        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"cdf.png"];
        _starlightFilter = [[GPUImageStarLightFilter alloc] initWithCDFPath:path];
        [_starlightFilter setFilterStrength:1.0f];
    }
    return _starlightFilter;
}


@end
