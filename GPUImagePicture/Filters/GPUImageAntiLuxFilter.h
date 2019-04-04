//
//  GPUImageAntiLuxFilter.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPUImageAntiLuxFilter : GPUImageTwoInputFilter

@property(readwrite, nonatomic) CGFloat filterStrength;

- (instancetype) initWithCDFPath:(NSString *) path;

@end

NS_ASSUME_NONNULL_END
