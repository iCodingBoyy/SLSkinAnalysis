//
//  SLSAStillImageAnalysisEngine.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



typedef NS_OPTIONS(NSInteger, SSStillImageAnalysisOptions) {
    SSStillImageAnalysisNone,
    SSStillImageAnalysisFaceFeature = 1 << 0, ///< 人脸检测，包含人脸数量和角度
    SSStillImageAnalysisSize = 1 << 1,///< 检测照片尺寸
    SSStillImageAnalysisAspectRedio = 1 << 2, ///< 检测照片比例，判断横竖屏，肤质分析不支持横屏
    SSStillImageAnalysisPixels = 1 << 3, ///< 检测照片像素
    SSStillImageAnalysisFaceShelters = 1 << 4, ///< 检测人脸遮挡物
    SSStillImageAnalysisAll = 1 << 5, ///< 分析所有选项
};

@interface SLSAStillImageAnalysisConfiguration : NSObject
@property (nonatomic, assign) float maxImageWidth; /// 默认 2000
@property (nonatomic, assign) float maxImageHeight; /// 默认2500
@property (nonatomic, assign) float maxPixels; /// 默认五百万像素
@property (nonatomic, assign) SSStillImageAnalysisOptions options;
@end


@class SLSAFaceShelterItem;
/// 静态图像可用性分析
@interface SLSAStillImageAnalysisEngine : NSObject
/// 判断是否支持遮挡物检测，如果导入了遮挡物检测库才可以支持遮挡物检测
@property(nonatomic, readonly, getter=isFaceShelterSupported) BOOL faceShelterSupported;
- (instancetype)initWithConfiguration:(nullable SLSAStillImageAnalysisConfiguration*)configuration;

/// 判断图像是否符合肤质分析要求
/// @param image still image
/// @param error 返回 NO，检查此错误
- (BOOL)isValidStillImage:(nonnull UIImage*)image error:(NSError**)error;


/// 检测照片上的遮挡物
/// @warning faceShelterSupported 为 NO 此接口无效
/// @param image 包含高清人脸的图片
/// @param error 返回 nil，检查此错误
- (NSArray<SLSAFaceShelterItem*>*)analysisFaceShelters:(nullable UIImage*)image error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
