//
//  GPUImageBlurredLumAdjustFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/11.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageBlurredLumAdjustFilter : GPUImageThreeInputFilter

@property(readwrite, nonatomic) CGFloat highlights;

@property(readwrite, nonatomic) CGFloat shadows;

- (instancetype) initWithSPLinesPath:(NSString*) path;

@end

NS_ASSUME_NONNULL_END
