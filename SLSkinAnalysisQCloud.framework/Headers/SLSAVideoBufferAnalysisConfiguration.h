//
//  SLSAVideoBufferAnalysisConfiguration.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, SSAVideoBufferAnalysisOptions) {
    SSVideoBufferAnalysisNone,
    SSVideoBufferAnalysisFaceAngle = 1 << 0, ///< 支持标准人脸状态检测
    SSVideoBufferAnalysisYUVLight = 1 << 1, ///< 支持光线亮度检测
    SSVideoBufferAnalysisDistance = 1 << 2, ///< 支持距离检测
    SSVideoBufferAnalysisFaceBoundary = 1 << 3, ///< 支持人脸边界检查
    SSVideoBufferAnalysisFaceShelter = 1 << 4, ///< 支持人脸遮挡物检测
    SSVideoBufferAnalysisAll = 1 << 8, /// 支持全功能检测
};


@interface SLSAVideoBufferAnalysisConfiguration : NSObject <NSCopying>
/// 最大yuv亮度，范围 240（0~250）
@property (nonatomic, assign) int maxYUVLight;
/// 最大yuv亮度，默认 60（0~250）
@property (nonatomic, assign) int minYUVLight;
/// 最小距离，默认0.85 （0.0~1.0）
@property (nonatomic, assign) float maxDistance;
/// 最小距离，默认0.18 （0.0~1.0）
@property (nonatomic, assign) float minDistance;
@property (nonatomic, assign) SSAVideoBufferAnalysisOptions options;

/// 可用于静态图片捕捉的最小稳定帧数，大于此值将提示即将拍照 默认为 3
@property (nonatomic, assign) NSInteger minStableFramesToCaptureStillImage;


/// 状态检测最小稳定帧，大于此帧数输出状态，默认为 3
/// @warning 此参数在静音模式下有效
/// @see minStableFramesToCaptureStillImage 进入即将拍照状态检测此参数
@property (nonatomic, assign) NSInteger minStableFramesToOutputState;


/// 废弃的帧数，为了防止处理过于频繁可以设置此值，默认为0
@property (nonatomic, assign) NSInteger discardedFramesInBufferAnalysis;
@end

NS_ASSUME_NONNULL_END
