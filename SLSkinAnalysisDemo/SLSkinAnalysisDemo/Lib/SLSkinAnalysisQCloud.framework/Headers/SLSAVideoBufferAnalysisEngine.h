//
//  SLSAVideoBufferAnalysisEngine.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN


@class SLSAVideoBufferAnalysisConfiguration;
@class SLSAVideoBufferAnalysisResult;
@class SLSAVoiceItem;
@protocol SLSAVoiceConfigDelegate,SSFaceObjectDelegate;


/// 视频帧buffer分析引擎，用于分析可用人脸状态。辅助静态图片拍摄
@interface SLSAVideoBufferAnalysisEngine : NSObject
@property (nonatomic, strong, readonly) SLSAVideoBufferAnalysisConfiguration *configuration;
/// 判断是否支持遮挡物检测，如果导入了遮挡物检测库才可以支持遮挡物检测
@property(nonatomic, readonly, getter=isFaceShelterSupported) BOOL faceShelterSupported;

#pragma mark - init

/// 初始化buffer分析引擎
/// @param configuration buffer分析引擎配置
- (instancetype)initWithConfiguation:(nullable SLSAVideoBufferAnalysisConfiguration*)configuration;


/// 初始化buffer分析引擎，支持自定义语音配置
/// @param configuration buffer分析引擎配置
/// @param voiceConfig 语音配置
- (instancetype)initWithConfiguation:(nullable SLSAVideoBufferAnalysisConfiguration *)configuration
                         voiceConfig:(nullable id<SLSAVoiceConfigDelegate>)voiceConfig;


#pragma mark - SLSAVoiceItem

/// 根据分析结果获取对应的语音文件
/// @param result 分析结果
/// @param position 摄像头位置
- (SLSAVoiceItem*)getVoiceItemWithAnlysisResult:(SLSAVideoBufferAnalysisResult*)result position:(AVCaptureDevicePosition)position;


#pragma mark - Analysis

/// buffer分析
/// @param sampleBuffer buffer数据帧
/// @param position 摄像头位置
/// @param detectedFaces 检测到的人脸，如果传入nil提示未检测到人脸，注意：附带遮挡物检测的sdk不使用此参数，可以传入nil
/// @param renderRect 相机画面渲染区域
/// @param boundingRect 人脸框限制区域，可以将人脸限制在此矩形区域内
/// @param targetFaceBlock 人脸框代理回调block，返回屏幕窗口人脸坐标
/// @param retHanndler 分析结果回调block
- (void)analysisVideoBuffer:(nullable CMSampleBufferRef)sampleBuffer
                   position:(AVCaptureDevicePosition)position
                      faces:(nullable NSArray<id<SSFaceObjectDelegate>>*)detectedFaces
                 renderRect:(CGRect)renderRect
               boundingRect:(CGRect)boundingRect
                 targetFace:(void(^)(CGRect faceRect))targetFaceBlock
                     result:(void (^)(SLSAVideoBufferAnalysisResult *result))retHanndler;
@end

NS_ASSUME_NONNULL_END
