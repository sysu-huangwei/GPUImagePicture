//
//  GPUImageStarLightFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageFilter.h"

NS_ASSUME_NONNULL_BEGIN


/**
 Ins顶端的变暗效果
 */
@interface GPUImageStarLightFilter : GPUImageFilter


/**
 效果程度  0.0 ~ 1.0
 */
@property(readwrite, nonatomic) CGFloat filterStrength;


/**
 @param path CDF素材的路径
 */
- (instancetype) initWithCDFPath:(NSString *) path;

@end

NS_ASSUME_NONNULL_END
