//
//  GPUImageHighLightFilter.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/12.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageHighLightFilter.h"

#import "GPUImageGaussianFilter.h"
#import "GPUImageBlurredLumAdjustFilter.h"


@interface GPUImageHighLightFilter()
@property (nonatomic, strong) GPUImageGaussianFilter *gaussianFilterX;
@property (nonatomic, strong) GPUImageGaussianFilter *gaussianFilterY;
@property (nonatomic, strong) GPUImageBlurredLumAdjustFilter *blurredLumAdjustFilter;
@end

@implementation GPUImageHighLightFilter


- (instancetype) init {
    self = [super init];
    if (self) {
        //设置内部滤镜链
        [self.gaussianFilterX addTarget:self.blurredLumAdjustFilter atTextureLocation:1];
        [self.gaussianFilterY addTarget:self.blurredLumAdjustFilter atTextureLocation:2];
        //最终滤镜
        self.terminalFilter = self.blurredLumAdjustFilter;
        //需要接收输入的滤镜
        self.initialFilters = @[self.gaussianFilterX, self.gaussianFilterY, self.blurredLumAdjustFilter];
        //总的滤镜数组
        [self addFilter:self.gaussianFilterX];
        [self addFilter:self.gaussianFilterY];
        [self addFilter:self.blurredLumAdjustFilter];
    }
    return self;
}


- (GPUImageGaussianFilter *)gaussianFilterX {
    if (!_gaussianFilterX) {
        _gaussianFilterX = [[GPUImageGaussianFilter alloc] init];
        [_gaussianFilterX setBlurAlongX:YES];
    }
    return _gaussianFilterX;
}

- (GPUImageGaussianFilter *)gaussianFilterY {
    if (!_gaussianFilterY) {
        _gaussianFilterY = [[GPUImageGaussianFilter alloc] init];
        [_gaussianFilterY setBlurAlongX:NO];
    }
    return _gaussianFilterY;
}

- (GPUImageBlurredLumAdjustFilter *)blurredLumAdjustFilter {
    if (!_blurredLumAdjustFilter) {
        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"splines.png"];
        _blurredLumAdjustFilter = [[GPUImageBlurredLumAdjustFilter alloc] initWithSPLinesPath:path];
        [_blurredLumAdjustFilter setHighlights:0.0f];
    }
    return _blurredLumAdjustFilter;
}


- (void)setHighlights:(CGFloat) highlights {
    [self.blurredLumAdjustFilter setHighlights:highlights];
}

@end
