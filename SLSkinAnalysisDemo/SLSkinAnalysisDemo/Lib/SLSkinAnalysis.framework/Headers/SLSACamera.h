//
//  SLSACamera.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *SSCameraErrorDomain;

typedef NS_ENUM(NSInteger, SSCameraErrorCode) {
    SSCameraErrorUnknown,
    SSCameraGetCaptureDeviceError,
    SSCameraAddInputError,
    SSCameraAddOutputError,
    SSCameraSetSessionPresetError,
};


@protocol SLSACameraBufferOutputDelegate <NSObject>
@required
- (void)captureOutput:(AVCaptureOutput*)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer faceObjects:(NSArray*)faceObjects fromConnection:(AVCaptureConnection *)connection;
@end

@interface SLSACamera : NSObject
@property (nonatomic, weak) id<SLSACameraBufferOutputDelegate> delegate;
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, assign, getter=isPrepared) BOOL prepared;

/// 初始化相机
/// @param position 默认摄像头位置，如果不可用则调用可用摄像头
/// @param error 返回 NO,查看此错误信息
- (BOOL)prepareCamera:(AVCaptureDevicePosition)position error:(NSError**)error;

- (void)clear;

#pragma mark - run

/// 判断相机是否正在运行
- (BOOL)isRunning;


/// 异步运行相机拍摄，防止卡顿
- (void)startRunning;


/// 启动相机拍摄
/// @param isAsync YES 异步启动 NO 同步启动
- (void)startRunning:(BOOL)isAsync;


/// 异步停止相机拍摄
- (void)stopRunning;




#pragma mark - position

/// 判断是否正在使用后置摄像头
- (BOOL)isCameraPositionBack;


/// 获取调用相机摄像头位置
- (AVCaptureDevicePosition)getCameraPosition;


/// 切换摄像头
/// @param position 摄像头位置
/// @param retHandler 切换结果回调block，返回切换后摄像头位置
- (void)setCameraPosition:(AVCaptureDevicePosition)position result:(void(^)(AVCaptureDevicePosition position))retHandler;


#pragma mark - preset

- (BOOL)setSessionPreset:(AVCaptureSessionPreset)sessionPreset;


#pragma mark - 异步拍照

/// 判断当前是否正在捕捉静态图片
- (BOOL)isCapturingStillImage;


/// 异步拍摄照片
/// @param completionHandler 拍照buffer回调
/// @param retHandler 处理结果回调
- (void)takePhotosAsynchronously:(void(^_Nullable)(CMSampleBufferRef imageDataSampleBuffer,NSError *error))completionHandler result:(void(^)(NSData *imageData, NSError *error))retHandler;


/// 异步拍摄照片
/// @param retHandler 回调block
/// @warning 回调不在主线程，请注意切换到主线程刷新UI
- (void)takePhotosAsynchronously:(void(^)(NSData *imageData, NSError *error))retHandler;
@end

NS_ASSUME_NONNULL_END
