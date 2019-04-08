//
//  GPUImageAntiLuxFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

NS_ASSUME_NONNULL_BEGIN


/**
 Ins顶端的变亮效果
 */
@interface GPUImageAntiLuxFilter : GPUImageTwoInputFilter


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
