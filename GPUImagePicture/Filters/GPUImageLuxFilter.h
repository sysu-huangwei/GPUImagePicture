//
//  GPUImageLuxFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/11.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageFilterGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageLuxFilter : GPUImageFilterGroup

- (void) setLuxBlendAmount:(CGFloat) degree;

@end

NS_ASSUME_NONNULL_END
