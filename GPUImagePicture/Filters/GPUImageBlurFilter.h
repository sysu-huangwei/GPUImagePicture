//
//  GPUImageBlurFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBlurFilter : GPUImageFilter


/**
 模糊程度，x：横向  y：纵向   0.0 ~ 1.0
 */
@property(readwrite, nonatomic) CGPoint blurVector;

@end

NS_ASSUME_NONNULL_END
