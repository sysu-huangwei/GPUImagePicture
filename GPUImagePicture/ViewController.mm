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
#import "GPUImageHighLightFilter.h"

typedef NS_ENUM(NSInteger, InsEffectType){
    InsEffectTypeHighLight = 1,
    InsEffectTypeShadow = 2,
};

@interface ViewController ()
@property (nonatomic, strong) GPUImagePicture *picture;

@property (nonatomic, strong) GPUImageLuxFilter *luxFilter;
@property (nonatomic, strong) GPUImageHighLightFilter *highLightFilter;

@property (nonatomic, strong) GPUImageView *imageView;

@property (nonatomic, assign) InsEffectType effectType;
@property (nonatomic, assign) float highLightValue;
@property (nonatomic, assign) float shadowValue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _effectType = InsEffectTypeHighLight;
    _highLightValue = 0.0f;
    _shadowValue = 0.0f;
    [_highLightButton setBackgroundColor:[[UIColor alloc] initWithRed:0.9 green:0.9 blue:1.0 alpha:1.0]];
    
    //调用相机和相册
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    
    NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"逆向.JPG"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    
    _imageView = [[GPUImageView alloc] initWithFrame:self.showView.frame];
    [self.showView addSubview:_imageView];
    
    _picture = [[GPUImagePicture alloc] initWithImage:image];

    [_picture addTarget:self.highLightFilter];
    [self.highLightFilter addTarget:_imageView];
    
    [_picture processImage];
    
    [self.highLightFilter useNextFrameForImageCapture];
    UIImage* result = [self.highLightFilter imageFromCurrentFramebuffer];
    NSLog(@"1");
    
}


- (GPUImageLuxFilter *)luxFilter {
    if (!_luxFilter) {
        _luxFilter = [[GPUImageLuxFilter alloc] init];
    }
    return _luxFilter;
}


- (GPUImageHighLightFilter *)highLightFilter {
    if (!_highLightFilter) {
        _highLightFilter = [[GPUImageHighLightFilter alloc] init];
        [_highLightFilter setHighlights:0.0f];
        [_highLightFilter setShadows:0.0f];
    }
    return _highLightFilter;
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
    [_picture processImage];
    [self.highLightFilter useNextFrameForImageCapture];
    UIImage* result = [self.highLightFilter imageFromCurrentFramebuffer];
    UIImageWriteToSavedPhotosAlbum(result, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}


- (IBAction)highLightButton:(id)sender {
    _effectType = InsEffectTypeHighLight;
    [_shadowButtom setBackgroundColor:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.0]];
    [_highLightButton setBackgroundColor:[[UIColor alloc] initWithRed:0.9 green:0.9 blue:1.0 alpha:1.0]];
    [_valueSlider setValue:_highLightValue];
    [_sliderValueText setText:[NSString stringWithFormat:@"%d", (int)(_highLightValue * 100)]];
    
}

- (IBAction)shadowButton:(id)sender {
    _effectType = InsEffectTypeShadow;
    [_highLightButton setBackgroundColor:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.0]];
    [_shadowButtom setBackgroundColor:[[UIColor alloc] initWithRed:0.9 green:0.9 blue:1.0 alpha:1.0]];
    [_valueSlider setValue:_shadowValue];
    [_sliderValueText setText:[NSString stringWithFormat:@"%d", (int)(_shadowValue * 100)]];
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
        if (_effectType == InsEffectTypeHighLight) {
            [self.highLightFilter setHighlights:value];
            _highLightValue = value;
        }
        else {
            [self.highLightFilter setShadows:value];
            _shadowValue = value;
        }
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
        [_picture removeAllTargets];
        _picture = [[GPUImagePicture alloc] initWithImage:image];
        [_picture addTarget:self.highLightFilter];
        [self.highLightFilter addTarget:_imageView];
        [_picture processImage];
    }
}
@end
