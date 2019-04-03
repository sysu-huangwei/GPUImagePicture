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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"逆向.png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    GPUImageView *view = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:view];
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:image];
    
    GPUImageFilter *filter = [[GPUImageFilter alloc] init];
    
    [picture addTarget:filter];
    [filter addTarget:view];
    
    [picture processImage];
}


@end
