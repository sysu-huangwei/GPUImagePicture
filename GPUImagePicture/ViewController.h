//
//  ViewController.h
//  GPUImagePicture
//
//  Created by HW on 2019/4/3.
//  Copyright © 2019 meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *sliderValueText;
@property (strong, nonatomic) IBOutlet UIView *showView;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UISlider *valueSlider;
@property (strong, nonatomic) IBOutlet UIButton *highLightButton;
@property (strong, nonatomic) IBOutlet UIButton *shadowButtom;
@end

