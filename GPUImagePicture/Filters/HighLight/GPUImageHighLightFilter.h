//
//  GPUImageHighLightFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/12.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageFilterGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageHighLightFilter : GPUImageFilterGroup

- (void)setHighlights:(CGFloat) highlights;

@end

NS_ASSUME_NONNULL_END
