//
//  WUCustomCameraController.h
//  WUCustomCamera
//
//  Created by 武昌 on 2018/5/3.
//  Copyright © 2018年 武昌. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomCamerDelegate <NSObject>

@optional

- (void)imagePickerController:(UIViewController *)picker didFinishPickingMediaWithInfo:(UIImage *)image;

@end

@interface WUCustomCameraController : UIViewController

@property(nonatomic,weak)id<CustomCamerDelegate> delegate;

@end
