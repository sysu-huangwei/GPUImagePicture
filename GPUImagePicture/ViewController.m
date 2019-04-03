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
    
    [picture processImage];
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



@end
