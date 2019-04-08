//
//  GPUImageTwoWayMixFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

NS_ASSUME_NONNULL_BEGIN


/**
 Ins顶端的双向滑竿逻辑滤镜
 */
@interface GPUImageTwoWayMixFilter : GPUImageThreeInputFilter



/**
 双向滑竿程度  -1.0 ~ 1.0  滑竿原始在中间0.0  向左滑是 -1.0  向右滑是 1.0
 */
@property(readwrite, nonatomic) CGFloat luxBlendAmount;

@end

NS_ASSUME_NONNULL_END
