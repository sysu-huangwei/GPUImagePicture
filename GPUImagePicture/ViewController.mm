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
#import "GPUImageLuxFilter.h"

#import "GPUImageGaussianFilter.h"
#import "GPUImageBlurredLumAdjustFilter.h"

@interface ViewController ()
@property (nonatomic, strong) GPUImagePicture *picture;

@property (nonatomic, strong) GPUImageLuxFilter *luxFilter;

@property (nonatomic, strong) GPUImageGaussianFilter *gaussianFilterX;
@property (nonatomic, strong) GPUImageGaussianFilter *gaussianFilterY;
@property (nonatomic, strong) GPUImageBlurredLumAdjustFilter *blurredLumAdjustFilter;

@property (nonatomic, strong) GPUImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //调用相机和相册
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"逆向.JPG"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    _imageView = [[GPUImageView alloc] initWithFrame:self.showView.frame];
    [self.showView addSubview:_imageView];
    
    _picture = [[GPUImagePicture alloc] initWithImage:image];

    [_picture addTarget:self.gaussianFilterX];
    [_picture addTarget:self.gaussianFilterY];
    [_picture addTarget:self.blurredLumAdjustFilter];
    [self.gaussianFilterX addTarget:self.blurredLumAdjustFilter];
    [self.gaussianFilterY addTarget:self.blurredLumAdjustFilter];
    [self.blurredLumAdjustFilter addTarget:_imageView];
    
    [_picture processImage];
    
    [self.blurredLumAdjustFilter useNextFrameForImageCapture];
    UIImage* result = [self.blurredLumAdjustFilter imageFromCurrentFramebuffer];
    NSLog(@"1");
    
}


- (GPUImageLuxFilter *)luxFilter {
    if (!_luxFilter) {
        _luxFilter = [[GPUImageLuxFilter alloc] init];
    }
    return _luxFilter;
}

- (GPUImageGaussianFilter *)gaussianFilterX {
    if (!_gaussianFilterX) {
        _gaussianFilterX = [[GPUImageGaussianFilter alloc] init];
        [_gaussianFilterX setBlurAlongX:YES];
    }
    return _gaussianFilterX;
}

- (GPUImageGaussianFilter *)gaussianFilterY {
    if (!_gaussianFilterY) {
        _gaussianFilterY = [[GPUImageGaussianFilter alloc] init];
        [_gaussianFilterY setBlurAlongX:NO];
    }
    return _gaussianFilterY;
}

- (GPUImageBlurredLumAdjustFilter *)blurredLumAdjustFilter {
    if (!_blurredLumAdjustFilter) {
        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"splines.png"];
        _blurredLumAdjustFilter = [[GPUImageBlurredLumAdjustFilter alloc] initWithSPLinesPath:path];
        [_blurredLumAdjustFilter setHighlights:1.0f];
    }
    return _blurredLumAdjustFilter;
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
    [self.luxFilter useNextFrameForImageCapture];
    [_picture processImage];
    UIImage* result = [self.luxFilter imageFromCurrentFramebuffer];
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
        [_sliderValueText setText:[NSString stringWithFormat:@"%d", (int)(value * 100)]];
        [self.blurredLumAdjustFilter setHighlights:value];
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
        [_picture addTarget:self.luxFilter];
        [self.luxFilter addTarget:_imageView];
        [_picture processImage];
    }
}
@end
