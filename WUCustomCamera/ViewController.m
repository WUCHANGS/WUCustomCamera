//
//  ViewController.m
//  WUCustomCamera
//
//  Created by 武昌 on 2018/5/3.
//  Copyright © 2018年 武昌. All rights reserved.
//

#import "ViewController.h"
#import "WUCustomCameraController.h"//自定义拍照界面

@interface ViewController ()<CustomCamerDelegate>

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *submitBut;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自定义拍照";
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT - 200)];
    [self.view addSubview:self.imageView];
    
    self.submitBut = [[UIButton alloc]initWithFrame:CGRectMake(15, HEIGHT - 100, WIDTH - 30, 50)];
    self.submitBut.backgroundColor = HEXCOLOR(0xeecd53);
    self.submitBut.layer.cornerRadius = 5;
    self.submitBut.layer.masksToBounds = YES;
    [self.submitBut setTitle:@"开始拍照" forState:UIControlStateNormal];
    [self.submitBut addTarget:self action:@selector(addPhotoClicks) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitBut];
}
- (void)addPhotoClicks{
    WUCustomCameraController *vc = [[WUCustomCameraController alloc]init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)imagePickerController:(UIViewController *)picker didFinishPickingMediaWithInfo:(UIImage *)image{
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
