//
//  GPUImageGaussianFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/11.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageGaussianFilter : GPUImageFilter

@property(readwrite, nonatomic) BOOL blurAlongX;

@end

NS_ASSUME_NONNULL_END
