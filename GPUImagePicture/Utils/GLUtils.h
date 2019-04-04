//
//  GLUtils.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/4.
//  Copyright © 2019 meitu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLUtils : NSObject

+ (GLuint) LoadFileToTexture:(NSString *) path;

+ (GLuint) LoadUIImageToTexture:(UIImage *) image;

+ (GLuint) LoadTexture_BYTE:(GLubyte*) pdata width:(int) width height:(int) height glFormat:(GLenum) glFormat;

+ (unsigned char *) RGBADataWithAlpha:(UIImage*) image;

@end

NS_ASSUME_NONNULL_END
