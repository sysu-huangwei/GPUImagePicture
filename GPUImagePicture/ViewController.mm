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
#import "GPUImageAntiLuxFilter.h"
#import "GPUImageBlurFilter.h"

@interface ViewController ()
@property (nonatomic, strong) GPUImageBlurFilter *blurFilterHorizontal;
@property (nonatomic, strong) GPUImageBlurFilter *blurFilterVertical;
@property (nonatomic, strong) GPUImageAntiLuxFilter *antiluxFilter;
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
    [picture addTarget:self.blurFilterHorizontal];
    [self.blurFilterHorizontal addTarget:self.blurFilterVertical];
    [picture addTarget:self.antiluxFilter];
    [self.blurFilterVertical addTarget:self.antiluxFilter];
    [self.antiluxFilter addTarget:view];
    
    //变暗的部分
//    [picture addTarget:self.starlightFilter];
//    [self.starlightFilter addTarget:view];
    
    [picture processImage];
    
    [self.antiluxFilter useNextFrameForImageCapture];
    UIImage* result = [self.antiluxFilter imageFromCurrentFramebuffer];
    NSLog(@"1");
}


- (GPUImageBlurFilter *)blurFilterHorizontal {
    if (!_blurFilterHorizontal) {
        _blurFilterHorizontal = [[GPUImageBlurFilter alloc] init];
        [_blurFilterHorizontal setBlurVector:CGPointMake(0.000805, 0.000000)];
    }
    return _blurFilterHorizontal;
}

- (GPUImageBlurFilter *)blurFilterVertical {
    if (!_blurFilterVertical) {
        _blurFilterVertical = [[GPUImageBlurFilter alloc] init];
        [_blurFilterHorizontal setBlurVector:CGPointMake(0.000000, 0.000805)];
    }
    return _blurFilterVertical;
}


- (GPUImageAntiLuxFilter *)antiluxFilter {
    if (!_antiluxFilter) {
        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"cdf.png"];
        _antiluxFilter = [[GPUImageAntiLuxFilter alloc] initWithCDFPath:path];
        [_antiluxFilter setFilterStrength:1.0f];
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
