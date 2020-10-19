//
//  SSCameraViewController.m
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/25.
//

#import "SSCameraViewController.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <lottie-ios/Lottie/Lottie.h>
#import "SSBufferAnalysisStateView.h"
#import "SSFaceRectDraw.h"
#import "SSBufferAnalysisStateView.h"
#import "SSStillImageValityCheckView.h"
#import "SSFaceShelterView.h"
#import "SSCloudAnalysisViewController.h"

#ifdef __QCloud__
    #import <SLSkinAnalysisQCloud/SLSkinAnalysisQCloud.h>
#else
    #import <SLSkinAnalysis/SLSkinAnalysis.h>
#endif

@interface SSCameraViewController () <SLSACameraBufferOutputDelegate>
@property (nonatomic, strong) SLSACamera *camera;
@property (nonatomic, strong) SLSAVideoBufferAnalysisEngine *bufferAnalysisEngine;
@property (nonatomic, assign) CGRect renderRect;
@property (nonatomic, strong) SSFaceRectDraw *faceRectDraw;
@property (nonatomic, strong) LOTAnimationView *faceAlignAnimationView;
@property (nonatomic, strong) UIView *faceAnimationContainer;
@property (nonatomic, strong) UIStackView *statusStackView;
@property (nonatomic, strong) SSBufferAnalysisStateView *lightStateView;
@property (nonatomic, strong) SSBufferAnalysisStateView *distanceStateView;
@property (nonatomic, strong) SSBufferAnalysisStateView *faceAngleStateView;
@property (nonatomic, strong) SSFaceShelterView *eyeShelterView;
@property (nonatomic, strong) SSFaceShelterView *foreheadShelterView;
@property (nonatomic, strong) SSFaceShelterView *muzzleShelterView;
@property (nonatomic, strong) QMUIButton *closeButton;
@property (nonatomic, strong) QMUIButton *voiceButton;
@property (nonatomic, strong) QMUIButton *guideButton;
@property (nonatomic, strong) QMUIButton *switchButton;
@property (nonatomic, strong) UILabel *voiceTextLabel;
@property (nonatomic, strong) SSStillImageValityCheckView *stillImageCheckView;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SLSAFaceDataAnalysisEngine *dataEngine;

- (void)showAlert:(NSString*)message doneHandler:(void(^)(void))handler;
@end


@implementation SSCameraViewController

#pragma mark - dealloc

- (void)dealloc {
    if (_camera) {
        [_camera clear];
        _camera = nil;
    }
    if (_faceAlignAnimationView) {
        [_faceAlignAnimationView stop];
        _faceAlignAnimationView = nil;
    }
}


#pragma mark - life cycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.camera && self.camera.prepared) {
        self.camera.videoPreviewLayer.frame = self.view.bounds;
    }
    self.renderRect = self.view.bounds;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.renderRect = self.view.bounds;
    if (self.faceAlignAnimationView) {
        [self.faceAlignAnimationView play];
    }
    if (self.camera && self.camera.prepared) {
        self.camera.videoPreviewLayer.frame = self.view.bounds;
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.camera stopRunning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self.camera isRunning]) {
        _stillImageCheckView.hidden = YES;
        [_stillImageCheckView setChecking:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    BOOL isFrontCamera = [self.camera isCameraPositionBack];
    self.voiceTextLabel.text = isFrontCamera ? @"请平视前置摄像头" : @"请平视后置摄像头";
    if(![self.camera isRunning]) {
        _stillImageCheckView.hidden = YES;
        [_stillImageCheckView setChecking:NO];
        [self.camera startRunning];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(prepareToTakePhoto) object:nil];
        [self setFaceAlignAnimationHidden:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.titleView.title = @"相机拍照";
    [self makeConstraints];
    [self requestCameraAccess];
}


#pragma mark - Camera

- (void)requestCameraAccess {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        [self prepareCamera];
        return;
    }
    @weakify(self);
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        SLSAAsyncMain(^{
            if (granted) {
                [self prepareCamera];
                return;
            }
            [self showAlert:@"无相机访问许可，请更改隐私设置允许访问相机" doneHandler:^{
                @strongify(self);
                [self.navigationController popViewControllerAnimated:YES];
            }];
        });
    }];
}


- (void)prepareCamera {
    NSError *error;
    _camera = [[SLSACamera alloc]init];
    _camera.delegate = self;
    BOOL ret = [_camera prepareCamera:AVCaptureDevicePositionFront error:&error];
    if (!ret) {
        NSLog(@"---相机设备初始化失败--%@",error);
        
        @weakify(self);
        [self showAlert:@"相机初始化出错" doneHandler:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    if (_camera.prepared) {
        _camera.videoPreviewLayer.frame = self.view.bounds;
    }
    [self.view.layer insertSublayer:_camera.videoPreviewLayer atIndex:0];
    [self refreshUIStatus];
    [_camera startRunning];
}

- (void)refreshUIStatus{
    self.voiceButton.selected = SLSAVoiceIsMute();
    if (self.voiceButton.selected) {
        SLSAStopVoicePlay();
    }
    self.switchButton.selected = [self.camera isCameraPositionBack];
}

#pragma mark - 隐藏动画

- (void)setFaceAlignAnimationHidden:(BOOL)hidden {
    [self.faceAnimationContainer setHidden:hidden];
    [self.voiceTextLabel setHidden:hidden];
    if (hidden) {
        [self.faceAlignAnimationView stop];
    }
    else {
        [self.faceAlignAnimationView play];
    }
}

#pragma mark - SLSACameraBufferOutputDelegate

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    CVImageBufferRef imageBuffer =  pixelBufferRef;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}


- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    NSDictionary *options = @{
                              (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary]
                              };
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

//other
- (UIImage *)convert:(CVPixelBufferRef)pixelBuffer {
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
        createCGImage:ciImage
             fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];

    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);

    return uiImage;
}


- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer faceObjects:(NSArray *)faceObjects fromConnection:(AVCaptureConnection *)connection {
    
    @autoreleasepool {
//        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
//        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
//        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
//        CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
//        if (attachments) {
//            CFRelease(attachments);
//        }
//        UIImage *image = [[UIImage alloc]initWithCIImage:ciImage];
//        NSDictionary *options = @{CIDetectorAccuracy:CIDetectorAccuracyHigh};
//        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:NULL options:options];
//        NSArray *features = [detector featuresInImage:ciImage];
//        NSMutableArray *faceInfoArray = [NSMutableArray array];
//        for (CIFaceFeature *faceFeature in features) {
//            SLSAFaceObject *faceObj = [[SLSAFaceObject alloc]init];
//             faceObj.bounds = faceFeature.bounds;
//             faceObj.faceID = faceFeature.trackingID;
////             if (faceobject.hasYawAngle) {
////                 faceObj.hasYawAngle = faceobject.hasYawAngle;
////                 faceObj.yawAngle = faceobject.yawAngle;
////             }
////             if (faceobject.hasRollAngle) {
////                 faceObj.hasRollAngle = faceobject.hasRollAngle;
////                 faceObj.rollAngle = faceobject.rollAngle;
////             }
//             [faceInfoArray addObject:faceObj];
//         }
//        if (features.count > 0) {
//            NSLog(@"---检测到人脸--%@",features);
//        }
//        else {
//            NSLog(@"---未检测到人脸--%@",features);
//        }
//        CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
//        SLSAAsyncMain(^{
//            self.imageView.image = image;
//        });
        
    
//    CGRect convertedRect = [SLSAConverter convertRect:faceRect inRect:ciImage.extent toRect:renderRect mode:UIViewContentModeScaleAspectFill];
//    CGFloat distance = 0;
//    CGFloat renderWidth = CGRectGetWidth(renderRect);
//    if (renderWidth > 0) {
//        distance = CGRectGetWidth(convertedRect)/renderWidth;
//    }
//    NSInteger YUVLightValue = [SLSAVideoBufferAnalysisUtils YUVLightFromSampleBuffer:sampleBuffer faceRect:faceRect];
//    CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
    
    @weakify(self);
    AVCaptureDevicePosition position = [self.camera getCameraPosition];
    [self.bufferAnalysisEngine analysisVideoBuffer:sampleBuffer position:position faces:faceObjects renderRect:self.renderRect boundingRect:self.renderRect targetFace:^(CGRect faceRect) {
        NSLog(@"--人脸框--%@",NSStringFromCGRect(faceRect));
        SLSAAsyncMain(^{
            @strongify(self);
            [self.faceRectDraw drawFaceRect:faceRect];
        });
    } result:^(SLSAVideoBufferAnalysisResult * _Nonnull result) {
        NSLog(@"--result--%@",result);
        @strongify(self);
        [self handleBufferAnalysisResult:result];
    }];
    }
}

- (void)setVoiceTextWithResult:(SLSAVideoBufferAnalysisResult*)result {
    AVCaptureDevicePosition position = [self.camera getCameraPosition];
    SLSAVoiceItem *voiceItem = [self.bufferAnalysisEngine getVoiceItemWithAnlysisResult:result position:position];
    self.voiceTextLabel.text = voiceItem.text;
    NSLog(@"---文本提示--【%@】…%@",@(result.shelters.count),voiceItem.text);
}

- (void)handleBufferAnalysisResult:(SLSAVideoBufferAnalysisResult*)result {
    if (!result) {
        return;
    }
    [self setVoiceTextWithResult:result];
    
    if (result.state == SSVideoBufferAnalysisStateNoFace) {
        [self.lightStateView setStateValid:NO description:@"无人脸"];
        [self.distanceStateView setStateValid:NO description:@"无人脸"];
        [self.faceAngleStateView setStateValid:NO description:@"未直视"];
        self.foreheadShelterView.shelterNameLabel.text = @"无遮挡";
        self.eyeShelterView.shelterNameLabel.text = @"无遮挡";
        self.muzzleShelterView.shelterNameLabel.text = @"无遮挡";
    }
    else if (result.state == SSVideoBufferAnalysisStateMultiFaces) {
        [self.lightStateView setStateValid:NO description:@"无人脸"];
        [self.distanceStateView setStateValid:NO description:@"无人脸"];
        [self.faceAngleStateView setStateValid:NO description:@"有人抢镜"];
        self.foreheadShelterView.shelterNameLabel.text = @"无遮挡";
        self.eyeShelterView.shelterNameLabel.text = @"无遮挡";
        self.muzzleShelterView.shelterNameLabel.text = @"无遮挡";
    }
    else {
        
        if (result.state == SSVideoBufferAnalysisStateFaceShelter) {
            
            if (result.distance > self.bufferAnalysisEngine.configuration.maxDistance) {
                [self.distanceStateView setStateValid:NO description:@"过近"];
            }
            else if (result.distance < self.bufferAnalysisEngine.configuration.minDistance){
                [self.distanceStateView setStateValid:NO description:@"过远"];
            }
            else {
                [self.distanceStateView setStateValid:YES description:@"合适"];
            }
            
            if (result.yuvLight > self.bufferAnalysisEngine.configuration.maxYUVLight) {
                [self.lightStateView setStateValid:NO description:@"过亮"];
            }
            else if (result.yuvLight < self.bufferAnalysisEngine.configuration.minYUVLight){
                [self.lightStateView setStateValid:NO description:@"过暗"];
            }
            else {
                [self.lightStateView setStateValid:YES description:@"合适"];
            }

            [self.faceAngleStateView setStateValid:YES description:@"直视"];
            
            self.foreheadShelterView.shelterNameLabel.text = @"无遮挡";
            self.eyeShelterView.shelterNameLabel.text = @"无遮挡";
            self.muzzleShelterView.shelterNameLabel.text = @"无遮挡";
            for (SLSAFaceShelterItem *shelterItem in result.shelters) {
                if (shelterItem.shelterRegion == SSFaceShelterRegionEye) {
                    self.eyeShelterView.shelterNameLabel.text = shelterItem.shelterName;
                }
                else if (shelterItem.shelterRegion == SSFaceShelterRegionMuzzle) {
                    self.muzzleShelterView.shelterNameLabel.text = shelterItem.shelterName;
                }
                else if (shelterItem.shelterRegion == SSFaceShelterRegionForehead) {
                    self.foreheadShelterView.shelterNameLabel.text = shelterItem.shelterName;
                }
            }
        }
        else {
            self.foreheadShelterView.shelterNameLabel.text = @"无遮挡";
            self.eyeShelterView.shelterNameLabel.text = @"无遮挡";
            self.muzzleShelterView.shelterNameLabel.text = @"无遮挡";
            /// 距离
            if (result.state == SSVideoBufferAnalysisStateDistanceFar) {
                [self.distanceStateView setStateValid:NO description:@"过远"];
            }
            else if (result.state == SSVideoBufferAnalysisStateDistanceNear) {
                [self.distanceStateView setStateValid:NO description:@"过近"];
            }
            else {
                [self.distanceStateView setStateValid:YES description:@"合适"];
            }
            /// 光线
            if (result.state == SSVideoBufferAnalysisStateLightDark) {
                [self.lightStateView setStateValid:NO description:@"过暗"];
            }
            else if (result.state == SSVideoBufferAnalysisStateLightBright) {
                [self.lightStateView setStateValid:NO description:@"过亮"];
            }
            else {
                [self.lightStateView setStateValid:YES description:@"合适"];
            }
            
            /// 人脸角度
            if (result.state == SSVideoBufferAnalysisStateInvalidFaceAngle) {
                [self.faceAngleStateView setStateValid:NO description:@"未直视"];
            }
            else {
                [self.faceAngleStateView setStateValid:YES description:@"直视"];
            }
        }
    }
    
    if (result.state == SSVideoBufferAnalysisStateWillTakePhoto) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(prepareToTakePhoto) withObject:nil afterDelay:3.0];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"取消拍照");
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(prepareToTakePhoto) object:nil];
        });
    }
}

- (void)prepareToTakePhoto {
    if ([self.camera isCapturingStillImage]) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(prepareToTakePhoto) object:nil];
    
    @weakify(self);
    [self.camera takePhotosAsynchronously:^(CMSampleBufferRef  _Nonnull imageDataSampleBuffer, NSError * _Nonnull error) {
        @strongify(self);
        SLSAAsyncMain(^{
            self.voiceTextLabel.text = @"拍照成功";
        });
    } result:^(NSData * _Nonnull imageData, NSError * _Nonnull error) {
        if (!imageData  || error) {
            return;
        }
        @strongify(self);
        [self setFaceAlignAnimationHidden:YES];
        [self.stillImageCheckView setHidden:NO];
        [self.stillImageCheckView setChecking:YES];
        UIImage *originImage = [[UIImage alloc]initWithData:imageData];
//        UIImage *resultImage = [originImage slsa_fixedOrientationImage];
        self.imageView.image = originImage;
        
        /// 检测拍摄的静态图片的可用性
        SSStillImageAnalysisOptions options = SSStillImageAnalysisNone;
        options = (options | SSStillImageAnalysisFaceFeature);
        options = (options | SSStillImageAnalysisFaceShelters);
        options = (options | SSStillImageAnalysisAspectRedio);
        options = (options | SSStillImageAnalysisPixels);
//        options = (options | SSStillImageAnalysisSize);
//        options = (options | SSStillImageAnalysisPixels);
        
        SLSAStillImageAnalysisConfiguration *config = [[SLSAStillImageAnalysisConfiguration alloc]init];
        config.options = options;
        config.maxPixels = 50000000;
        config.maxImageWidth = 2000;
        config.maxImageHeight = 2500;
        
        SLSAStillImageAnalysisEngine *engine = [[SLSAStillImageAnalysisEngine alloc]initWithConfiguration:config];
        NSError *stillImageError;
        if (![engine isValidStillImage:originImage error:&stillImageError]) {
            [QMUITips showError:stillImageError.localizedDescription];
            [self setFaceAlignAnimationHidden:NO];
            [self.stillImageCheckView setHidden:YES];
            [self.stillImageCheckView setChecking:NO];
            [self.camera startRunning];
            return;
        }
        [self uploadAndAnalysisImage:originImage];
    }];
}

- (void)uploadAndAnalysisImage:(UIImage*)image {
#ifdef __QCloud__
    [QMUITips showLoading:@"图片上传中" inView:self.view];
    _dataEngine = [[SLSAFaceDataAnalysisEngine alloc]init];
    [_dataEngine uploadImage:image progress:^(float progress) {
        NSLog(@"--上传进度--%@",@(progress));
    } result:^(NSString * _Nonnull imageURL, NSError * _Nonnull error) {
        [QMUITips hideAllTips];
        if (error) {
            [QMUITips showError:error.localizedDescription];
            [self setFaceAlignAnimationHidden:NO];
            [self.stillImageCheckView setHidden:YES];
            [self.stillImageCheckView setChecking:NO];
            [self.camera startRunning];
            return;
        }
        NSLog(@"---上传成功--%@",imageURL);
        SLSkinAnalysisDecryptQCloudImageURL(imageURL, ^(NSString *decryptedURL, NSError *error) {
            if (error) {
                NSLog(@"--图片解密错误--%@",error);
                return;
            }
            NSLog(@"--图片解密成功--%@",decryptedURL);
        });
        SSCloudAnalysisViewController *cloudAnalysis = [[SSCloudAnalysisViewController alloc]init];
        cloudAnalysis.imageURL = imageURL;
        [self.navigationController pushViewController:cloudAnalysis animated:YES];
    }];
#else
    // 自行上传图片到云服务器
    NSString *imageURL = @"你上传的图片url";
    SSCloudAnalysisViewController *cloudAnalysis = [[SSCloudAnalysisViewController alloc]init];
    cloudAnalysis.imageURL = imageURL;
    [self.navigationController pushViewController:cloudAnalysis animated:YES];
#endif
}

#pragma mark - 按钮交互

- (void)clickToBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickToSwitchCamera {
    // 1、未授权，检查授权
    // 2、正在拍照取消切换摄像头
    if ([self.camera isCapturingStillImage]) {
        return;
    }
    // 3、切换摄像头判断像素是否符合要求
    AVCaptureDevicePosition devicePosition = [self.camera getCameraPosition];
    if (devicePosition == AVCaptureDevicePositionBack) {
        devicePosition = AVCaptureDevicePositionFront;
    }
    else {
        devicePosition = AVCaptureDevicePositionBack;
    }
    @weakify(self);
    [self.camera setCameraPosition:devicePosition result:^(AVCaptureDevicePosition position) {
        @strongify(self);
        BOOL isFrontCamera = [self.camera isCameraPositionBack];
        self.voiceTextLabel.text = isFrontCamera ? @"请平视前置摄像头" : @"请平视后置摄像头";
        self.switchButton.selected = (position == AVCaptureDevicePositionBack);
    }];
}

- (void)clickToChangeMute {
    
    if (self.voiceButton.selected) {
        SLSASetVoiceMute(NO);
    }
    else {
        SLSASetVoiceMute(YES);
    }
    self.voiceButton.selected = SLSAVoiceIsMute();
    if (self.voiceButton.selected) {
        [QMUITips showWithText:@"跟随语音提示，拍照效率更高哦"];
    }
    else {
//        [self changeVoiceVolume];
    }
}


- (void)clickToShowGuide
{
 
}


#pragma mark - Constraints

- (void)makeConstraints {
    
    UIView *alphaView = [[UIView alloc]init];
    alphaView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
    [self.view addSubview:alphaView];
    [alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _faceRectDraw = [[SSFaceRectDraw alloc]init];
    [self.view addSubview:_faceRectDraw];
    [_faceRectDraw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    @weakify(self);
    _closeButton = [[QMUIButton alloc]init];
    _closeButton.qmui_outsideEdge = UIEdgeInsetsMake(-20, -20, -20, -20);
    [_closeButton setImage:[UIImage imageNamed:@"ico_camera_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(clickToBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(13.5);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.width.height.equalTo(@(40));
    }];
    {
        _lightStateView = [[SSBufferAnalysisStateView alloc]init];
        _lightStateView.backgroundColor = [UIColor clearColor];
        _lightStateView.layer.cornerRadius = 0;
        _lightStateView.titleLabel.text = @"拍照光源";
        [_lightStateView setStateValid:NO description:@"过暗"];
        CGFloat lightWidth = _lightStateView.intrinsicContentSize.width;
        
        _distanceStateView = [[SSBufferAnalysisStateView alloc]init];
        _distanceStateView.backgroundColor = [UIColor clearColor];
        _distanceStateView.layer.cornerRadius = 0;
        _distanceStateView.titleLabel.text = @"人脸距离";
        [_distanceStateView setStateValid:YES description:@"合适"];
        CGFloat distanceWidth = _distanceStateView.intrinsicContentSize.width;
        
        _faceAngleStateView = [[SSBufferAnalysisStateView alloc]init];
        _faceAngleStateView.backgroundColor = [UIColor clearColor];
        _faceAngleStateView.layer.cornerRadius = 0;
        _faceAngleStateView.titleLabel.text = @"直视镜头";
        [_faceAngleStateView setStateValid:YES description:@"直视"];
        CGFloat faceAngleWidth = _faceAngleStateView.intrinsicContentSize.width;
        
        UIView *statusContentView = [UIView new];
        statusContentView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
        statusContentView.layer.cornerRadius = 15;
        statusContentView.layer.masksToBounds = YES;
        [self.view addSubview:statusContentView];
        
        _statusStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_lightStateView, _distanceStateView, _faceAngleStateView]];
        _statusStackView.axis = UILayoutConstraintAxisHorizontal;
        _statusStackView.alignment = UIStackViewAlignmentCenter;
        [[_statusStackView.heightAnchor constraintEqualToConstant:60] setActive:YES];
        [statusContentView addSubview:_statusStackView];
        
        CGFloat space = ((SCREEN_WIDTH - lightWidth - distanceWidth - faceAngleWidth) - 16 * 2) / 4;
        _statusStackView.spacing = space;
        [_statusStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(statusContentView).offset(space);
            make.right.equalTo(statusContentView).offset(-space);
            make.top.equalTo(statusContentView);
            make.bottom.equalTo(statusContentView);
        }];
        
        [statusContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.closeButton.mas_bottom).offset(12.5);
        }];
    }
    
    {
        NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
        _voiceButton = [[QMUIButton alloc]init];
        _voiceButton.imagePosition = QMUIButtonImagePositionTop;
        _voiceButton.spacingBetweenImageAndTitle = 5.0;
        _voiceButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_voiceButton setTitleColor:[UIColor qmui_colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [_voiceButton setTitleColor:[UIColor qmui_colorWithHexString:@"#FFFFFF"] forState:UIControlStateSelected];
        [_voiceButton setImage:[UIImage imageNamed:@"ico_camera_voice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ico_camera_voice_mute"] forState:UIControlStateSelected];
        [_voiceButton setTitle:@"语音打开" forState:UIControlStateNormal];
        [_voiceButton setTitle:@"语音关闭" forState:UIControlStateSelected];
        [_voiceButton addTarget:self action:@selector(clickToChangeMute) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_voiceButton];
        [tmpArray addObject:_voiceButton];
        
        _guideButton = [[QMUIButton alloc]init];
        _guideButton.imagePosition = QMUIButtonImagePositionTop;
        _guideButton.spacingBetweenImageAndTitle = 5.0;
        _guideButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_guideButton setTitleColor:[UIColor qmui_colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [_guideButton setImage:[UIImage imageNamed:@"ico_camera_guide"] forState:UIControlStateNormal];
        [_guideButton setTitle:@"拍照教程" forState:UIControlStateNormal];
        [_guideButton addTarget:self action:@selector(clickToShowGuide) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_guideButton];
        [tmpArray addObject:_guideButton];
        
        _switchButton = [[QMUIButton alloc]init];
        _switchButton.imagePosition = QMUIButtonImagePositionTop;
        _switchButton.spacingBetweenImageAndTitle = 5.0;
        _switchButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_switchButton setTitleColor:[UIColor qmui_colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [_switchButton setTitleColor:[UIColor qmui_colorWithHexString:@"#FFFFFF"] forState:UIControlStateSelected];
        [_switchButton setImage:[UIImage imageNamed:@"ico_camera_switch"] forState:UIControlStateNormal];
        [_switchButton setImage:[UIImage imageNamed:@"ico_camera_switch"] forState:UIControlStateSelected];
        [_switchButton setTitle:@"后置" forState:UIControlStateNormal];
        [_switchButton setTitle:@"前置" forState:UIControlStateSelected];
        [_switchButton addTarget:self action:@selector(clickToSwitchCamera) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_switchButton];
        [tmpArray addObject:_switchButton];
        
        [tmpArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:21.5 leadSpacing:16 tailSpacing:16];
        [tmpArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop).offset(-10);
        }];
    }
    _faceAnimationContainer = [[UIView alloc]init];
    [self.view addSubview:_faceAnimationContainer];
    [_faceAnimationContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY).offset(-20);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(self.faceAnimationContainer.mas_width);
    }];
    
    [self.faceAnimationContainer addSubview:self.faceAlignAnimationView];
    [self.faceAlignAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.faceAnimationContainer);
    }];
    [self.faceAlignAnimationView play];
    
    _stillImageCheckView = [[SSStillImageValityCheckView alloc]init];
    _stillImageCheckView.hidden = YES;
    [_stillImageCheckView setButtonDidClickBlock:^{
        @strongify(self);
//        [self resetCameraStatus];
    }];
    [self.view addSubview:_stillImageCheckView];
    [self.stillImageCheckView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(120));
    }];
    
    _voiceTextLabel = [[UILabel alloc]init];
    _voiceTextLabel.font = [UIFont systemFontOfSize:16];
    _voiceTextLabel.textColor = [UIColor qmui_colorWithHexString:@"#FFFFFF"];
    _voiceTextLabel.textAlignment = NSTextAlignmentCenter;
    [self.faceAnimationContainer addSubview:_voiceTextLabel];
    [self.voiceTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.faceAnimationContainer.mas_bottom).dividedBy(4);
        make.centerX.equalTo(self.faceAnimationContainer.mas_centerX);
    }];
    
    {
        _foreheadShelterView = [[SSFaceShelterView alloc]init];
        _foreheadShelterView.backgroundColor = [UIColor clearColor];
        _foreheadShelterView.layer.cornerRadius = 0;
        _foreheadShelterView.regionLabel.text = @"额头区域";
        _foreheadShelterView.shelterNameLabel.text = @"无遮挡";
        CGFloat lightWidth = _foreheadShelterView.intrinsicContentSize.width;
        
        _eyeShelterView = [[SSFaceShelterView alloc]init];
        _eyeShelterView.backgroundColor = [UIColor clearColor];
        _eyeShelterView.layer.cornerRadius = 0;
        _eyeShelterView.regionLabel.text = @"眼周区域";
        _eyeShelterView.shelterNameLabel.text = @"无遮挡";
        CGFloat distanceWidth = _eyeShelterView.intrinsicContentSize.width;
        
        _muzzleShelterView = [[SSFaceShelterView alloc]init];
        _muzzleShelterView.backgroundColor = [UIColor clearColor];
        _muzzleShelterView.layer.cornerRadius = 0;
        _muzzleShelterView.regionLabel.text = @"口鼻区域";
        _muzzleShelterView.shelterNameLabel.text = @"无遮挡";
        CGFloat faceAngleWidth = _muzzleShelterView.intrinsicContentSize.width;
        
        UIView *shelterContainer = [UIView new];
        shelterContainer.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
        shelterContainer.layer.cornerRadius = 15;
        shelterContainer.layer.masksToBounds = YES;
        [self.view addSubview:shelterContainer];
        
        UIStackView *shelterStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_foreheadShelterView, _eyeShelterView, _muzzleShelterView]];
        shelterStackView.axis = UILayoutConstraintAxisHorizontal;
        shelterStackView.alignment = UIStackViewAlignmentCenter;
        [[shelterStackView.heightAnchor constraintEqualToConstant:60] setActive:YES];
        [shelterContainer addSubview:shelterStackView];
        
        CGFloat space = ((SCREEN_WIDTH - lightWidth - distanceWidth - faceAngleWidth) - 16 * 2) / 4;
        shelterStackView.spacing = space;
        [shelterStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(shelterContainer).offset(space);
            make.right.equalTo(shelterContainer).offset(-space);
            make.top.equalTo(shelterContainer);
            make.bottom.equalTo(shelterContainer);
        }];
        
        [shelterContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.voiceButton.mas_top).offset(-40);
        }];
    }
    
    _imageView = [[UIImageView alloc]init];
    _imageView.hidden = YES;
    [self.view addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.width.equalTo(@(80));
        make.height.equalTo(@(120));
    }];
}


#pragma mark - Alert

- (void)showAlert:(NSString*)message doneHandler:(void(^)(void))handler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler) handler();
    }]];
    [self.navigationController presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark - Getter

- (SLSAVideoBufferAnalysisEngine*)bufferAnalysisEngine {
    if (_bufferAnalysisEngine) {
        return _bufferAnalysisEngine;
    }
    SLSAVideoBufferAnalysisConfiguration *config = [[SLSAVideoBufferAnalysisConfiguration alloc]init];
    config.minDistance = 0.55;
    config.maxDistance = 0.95;
    _bufferAnalysisEngine = [[SLSAVideoBufferAnalysisEngine alloc]initWithConfiguation:config];
    return _bufferAnalysisEngine;
}

- (LOTAnimationView*)faceAlignAnimationView
{
    if (_faceAlignAnimationView) {
        return _faceAlignAnimationView;
    }
    _faceAlignAnimationView  = [LOTAnimationView animationNamed:@"take_photo"];
    _faceAlignAnimationView.cacheEnable = YES;
    _faceAlignAnimationView.contentMode = UIViewContentModeScaleAspectFit;
    _faceAlignAnimationView.animationSpeed = 1.0;
    _faceAlignAnimationView.loopAnimation = YES;
    _faceAlignAnimationView.autoReverseAnimation = NO;
    return _faceAlignAnimationView;
}


#pragma mark - QMUI

- (BOOL)preferredNavigationBarHidden
{
    return YES;
}
@end
