//
//  ViewController.m
//  GPUImagePicture
//
//  Created by HW on 2019/4/3.
//  Copyright © 2019 meitu. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "GLUtils.h"
#import "GPUImageStarLightFilter.h"
#import "GPUImageAntiLuxFilter.h"
#import "GPUImageBlurFilter.h"
#import "GPUImageTwoWayMixFilter.h"

@interface ViewController ()
@property (nonatomic, strong) GPUImagePicture *picture;

@property (nonatomic, strong) GPUImageBlurFilter *blurFilterHorizontal;
@property (nonatomic, strong) GPUImageBlurFilter *blurFilterVertical;
@property (nonatomic, strong) GPUImageAntiLuxFilter *antiluxFilter;
@property (nonatomic, strong) GPUImageStarLightFilter *starlightFilter;
@property (nonatomic, strong) GPUImageTwoWayMixFilter *mixFilter;

@property (nonatomic, strong) GPUImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //调用相机和相册
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"逆向.png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    _imageView = [[GPUImageView alloc] initWithFrame:self.showView.frame];
    [self.showView addSubview:_imageView];
    
    _picture = [[GPUImagePicture alloc] initWithImage:image];

    //变亮的部分
    [_picture addTarget:self.blurFilterHorizontal];
    [_picture addTarget:self.antiluxFilter];
    [_picture addTarget:self.mixFilter];
    [self.blurFilterHorizontal addTarget:self.blurFilterVertical];
    [self.blurFilterVertical addTarget:self.antiluxFilter];
    [self.antiluxFilter addTarget:self.mixFilter];

    //变暗的部分
    [_picture addTarget:self.starlightFilter];
    [self.starlightFilter addTarget:self.mixFilter];

    [self.mixFilter addTarget:_imageView];
    
    [_picture processImage];
    
}


- (GPUImageBlurFilter *)blurFilterHorizontal {
    if (!_blurFilterHorizontal) {
        _blurFilterHorizontal = [[GPUImageBlurFilter alloc] init];
        [_blurFilterHorizontal setBlurVector:CGPointMake(0.000805, 0.000000)];
    }
    return _blurFilterHorizontal;
}

- (GPUImageBlurFilter *)blurFilterVertical {
    if (!_blurFilterVertical) {
        _blurFilterVertical = [[GPUImageBlurFilter alloc] init];
        [_blurFilterHorizontal setBlurVector:CGPointMake(0.000000, 0.000805)];
    }
    return _blurFilterVertical;
}


- (GPUImageAntiLuxFilter *)antiluxFilter {
    if (!_antiluxFilter) {
        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"cdf.png"];
        _antiluxFilter = [[GPUImageAntiLuxFilter alloc] initWithCDFPath:path];
        [_antiluxFilter setFilterStrength:1.0f];
    }
    return _antiluxFilter;
}


- (GPUImageStarLightFilter *)starlightFilter {
    if (!_starlightFilter) {
        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"cdf.png"];
        _starlightFilter = [[GPUImageStarLightFilter alloc] initWithCDFPath:path];
        [_starlightFilter setFilterStrength:1.0f];
    }
    return _starlightFilter;
}


- (GPUImageTwoWayMixFilter *)mixFilter {
    if (!_mixFilter) {
        _mixFilter = [[GPUImageTwoWayMixFilter alloc] init];
        [_mixFilter setLuxBlendAmount:0.0f];
    }
    return _mixFilter;
}


- (IBAction)openAlbum:(id)sender {
    // 进入相册
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imagePickerController animated:YES completion:^{
            NSLog(@"打开相册");
        }];
    }else{
        NSLog(@"不能打开相册");
    }
}

- (IBAction)saveImage:(id)sender {
    [self.mixFilter useNextFrameForImageCapture];
    [_picture processImage];
    UIImage* result = [self.mixFilter imageFromCurrentFramebuffer];
    UIImageWriteToSavedPhotosAlbum(result, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
    }
}



- (IBAction)sliderChange:(id)sender {
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider* slider = (UISlider*)sender;
        float value = slider.value;
        [self.mixFilter setLuxBlendAmount:value];
        [_picture processImage];
    }
}


#pragma mark - UIImagePickerControllerDelegate代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //获取选中的原始图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    //一定要关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (image != nil) {
        _picture = [[GPUImagePicture alloc] initWithImage:image];
        
        [_picture removeAllTargets];
        [self.blurFilterHorizontal removeAllTargets];
        [self.blurFilterVertical removeAllTargets];
        [self.antiluxFilter removeAllTargets];
        [self.starlightFilter removeAllTargets];
        [self.mixFilter removeAllTargets];
        
        //变亮的部分
        [_picture addTarget:self.blurFilterHorizontal];
        [_picture addTarget:self.antiluxFilter];
        [_picture addTarget:self.mixFilter];
        [self.blurFilterHorizontal addTarget:self.blurFilterVertical];
        [self.blurFilterVertical addTarget:self.antiluxFilter];
        [self.antiluxFilter addTarget:self.mixFilter];
        
        //变暗的部分
        [_picture addTarget:self.starlightFilter];
        [self.starlightFilter addTarget:self.mixFilter];
        
        [self.mixFilter addTarget:_imageView];
        
        [_picture processImage];
    }
}
@end
