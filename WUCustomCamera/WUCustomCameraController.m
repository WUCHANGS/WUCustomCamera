//
//  WUCustomCameraController.m
//  WUCustomCamera
//
//  Created by 武昌 on 2018/5/3.
//  Copyright © 2018年 武昌. All rights reserved.
//

#import "WUCustomCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface WUCustomCameraController ()
<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIView *backView;//底部的view

@property (nonatomic,strong) UIButton *PhotographBut;//底部拍照按钮

@property (nonatomic,strong) UIButton *Before_After_Switchin;//切换前后置镜头

@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;//预览图层
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;

@end

@implementation WUCustomCameraController
{
    BOOL _isBeforeOrAfter;//记录前后置摄像头的转换 默认后置NO
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    if (self.session) {
        
        [self.session startRunning]; //启动数据流
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    
    if (self.session) {
        
        [self.session stopRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title =@"自定义相机";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
    
    [self setUpGesture];
    
    _isBeforeOrAfter = NO;
    
    self.effectiveScale = self.beginGestureScale = 1.0f;
    
}

- (void)createUI{
    
    [self.view addSubview:self.backView];
    [self.view addSubview:self.PhotographBut];
    [self.view addSubview:self.Before_After_Switchin];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake((WIDTH - 540/2.0)/2.0, (HEIGHT-64 - 822/2.0)/2.0 - 50, 540/2.0, 822/2.0)];
    imgView.image = [UIImage imageNamed:@"image_waikuang"];
    [self.view addSubview:imgView];
    
    self.session = [[AVCaptureSession alloc] init];
    
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    self.previewLayer.frame = self.backView.frame;
    self.backView.layer.masksToBounds = YES;
    [self.backView.layer addSublayer:self.previewLayer];
}
#pragma mark 开始拍照
- (void)Photograph{
    
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        UIImage *getaPicture = [UIImage imageWithData:jpegData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)])
        {
            // 调用代理方法
            [self.delegate imagePickerController:nil didFinishPickingMediaWithInfo:getaPicture];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

#pragma 创建手势
- (void)setUpGesture{
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.backView addGestureRecognizer:pinch];
}

#pragma mark gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}
//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.backView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
}

#pragma mark 前后置摄像头转换
- (void)before_After_Click{
    _isBeforeOrAfter = !_isBeforeOrAfter;
    if (_isBeforeOrAfter) {
        [_Before_After_Switchin setTitle:@"后置" forState:UIControlStateNormal];
    }else{
        [_Before_After_Switchin setTitle:@"前置" forState:UIControlStateNormal];
    }
    AVCaptureDevicePosition desiredPosition;
    if (_isBeforeOrAfter){
        desiredPosition = AVCaptureDevicePositionFront;
    }else{
        desiredPosition = AVCaptureDevicePositionBack;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in self.previewLayer.session.inputs) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            [self.previewLayer.session addInput:input];
            [self.previewLayer.session commitConfiguration];
            break;
        }
    }
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        _backView.backgroundColor = [UIColor redColor];
    }
    return _backView;
}
- (UIButton *)PhotographBut{
    if (!_PhotographBut) {
        _PhotographBut = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/2.0 + 30 , HEIGHT - 64 - 100 , 100, 45)];
        [_PhotographBut setTitle:@"拍照" forState:UIControlStateNormal];
        [_PhotographBut addTarget:self action:@selector(Photograph) forControlEvents:UIControlEventTouchUpInside];
        [_PhotographBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _PhotographBut.backgroundColor = HEXCOLOR(0xeecd53);
    }
    return _PhotographBut;
}

- (UIButton *)Before_After_Switchin{
    if (!_Before_After_Switchin) {
        _Before_After_Switchin = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/2.0 - 130, HEIGHT - 64 - 100, 100, 45)];
        [_Before_After_Switchin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_Before_After_Switchin addTarget:self action:@selector(before_After_Click) forControlEvents:UIControlEventTouchUpInside];
        [_Before_After_Switchin setTitle:@"前置" forState:UIControlStateNormal];
        _Before_After_Switchin.backgroundColor = HEXCOLOR(0xeecd53);
    }
    return _Before_After_Switchin;
}

- (void)dealloc{
    [self.session stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
