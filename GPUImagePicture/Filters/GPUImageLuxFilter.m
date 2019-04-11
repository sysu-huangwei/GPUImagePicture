//
//  GPUImageLuxFilter.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/11.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageLuxFilter.h"

#import "GPUImageStarLightFilter.h"
#import "GPUImageAntiLuxFilter.h"
#import "GPUImageBlurFilter.h"
#import "GPUImageTwoWayMixFilter.h"

@interface GPUImageLuxFilter()
@property (nonatomic, strong) GPUImageBlurFilter *blurFilterHorizontal;
@property (nonatomic, strong) GPUImageBlurFilter *blurFilterVertical;
@property (nonatomic, strong) GPUImageAntiLuxFilter *antiluxFilter;
@property (nonatomic, strong) GPUImageStarLightFilter *starlightFilter;
@property (nonatomic, strong) GPUImageTwoWayMixFilter *mixFilter;
@end

@implementation GPUImageLuxFilter

- (instancetype) init {
    self = [super init];
    if (self) {
        //设置内部滤镜链
        [self.blurFilterHorizontal addTarget:self.blurFilterVertical];
        [self.blurFilterVertical addTarget:self.antiluxFilter atTextureLocation:1];
        [self.antiluxFilter addTarget:self.mixFilter atTextureLocation:1];
        [self.starlightFilter addTarget:self.mixFilter atTextureLocation:2];
        //最终滤镜
        self.terminalFilter = self.mixFilter;
        //需要接收输入的滤镜
        self.initialFilters = @[self.blurFilterHorizontal, self.antiluxFilter, self.starlightFilter, self.mixFilter];
        //总的滤镜数组
        [self addFilter:self.blurFilterHorizontal];
        [self addFilter:self.blurFilterVertical];
        [self addFilter:self.antiluxFilter];
        [self addFilter:self.starlightFilter];
        [self addFilter:self.mixFilter];
    }
    return self;
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


- (void) setLuxBlendAmount:(CGFloat) degree {
    [self.mixFilter setLuxBlendAmount:degree];
}


@end
