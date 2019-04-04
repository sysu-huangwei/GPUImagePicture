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
#import "GPUImageTwoWayMixFilter.h"

@interface ViewController ()
@property (nonatomic, strong) GPUImagePicture *picture;

@property (nonatomic, strong) GPUImageBlurFilter *blurFilterHorizontal;
@property (nonatomic, strong) GPUImageBlurFilter *blurFilterVertical;
@property (nonatomic, strong) GPUImageAntiLuxFilter *antiluxFilter;
@property (nonatomic, strong) GPUImageStarLightFilter *starlightFilter;
@property (nonatomic, strong) GPUImageTwoWayMixFilter *mixFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"逆向.png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    GPUImageView *view = [[GPUImageView alloc] initWithFrame:self.showView.frame];
    [self.showView addSubview:view];
    
    _picture = [[GPUImagePicture alloc] initWithImage:image];

    //变亮的部分
    [_picture addTarget:self.blurFilterHorizontal];
    [_picture addTarget:self.antiluxFilter];
    [_picture addTarget:self.mixFilter];
    [self.blurFilterHorizontal addTarget:self.blurFilterVertical];
    [self.blurFilterVertical addTarget:self.antiluxFilter];
    [self.antiluxFilter addTarget:self.mixFilter];
    
    //变暗的部分
    [_picture addTarget:self.starlightFilter];
    [self.starlightFilter addTarget:self.mixFilter];
    
    [self.mixFilter addTarget:view];
    
    [_picture processImage];
    
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


- (GPUImageTwoWayMixFilter *)mixFilter {
    if (!_mixFilter) {
        _mixFilter = [[GPUImageTwoWayMixFilter alloc] init];
        [_mixFilter setLuxBlendAmount:0.0f];
    }
    return _mixFilter;
}


- (IBAction)openAlbum:(id)sender {
}

- (IBAction)saveImage:(id)sender {
}


- (IBAction)sliderChange:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider* slider = (UISlider*)sender;
        float value = slider.value;
        [self.mixFilter setLuxBlendAmount:value];
        [_picture processImage];
    }
}

@end
