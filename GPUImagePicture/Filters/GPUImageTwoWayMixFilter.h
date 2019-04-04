//
//  GPUImageTwoWayMixFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageTwoWayMixFilter : GPUImageThreeInputFilter

@property(readwrite, nonatomic) CGFloat luxBlendAmount;

@end

NS_ASSUME_NONNULL_END
