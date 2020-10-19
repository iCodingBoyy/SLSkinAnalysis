//
//  SLSAFaceDataAnalysisEngine.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SLSAFaceDataAnalysisState) {
    SLSAFaceDataAnalysisStateUploading,
    SLSAFaceDataAnalysisStateAnalyzing,
};


@interface SLSAFaceDataAnalysisEngine : NSObject

/// 上传包含高清人脸的图像
/// @param image 高清人脸图像
/// @param progressBlock 上传进度回调block
/// @param retHandler 上传结果回调block
- (void)uploadImage:(UIImage*)image
           progress:(void(^)(float progress))progressBlock
             result:(void(^)(NSString *imageURL, NSError *error))retHandler;


/// 肤质分析
/// @param imageURL 高清人脸图像url
/// @param retHandler 分析结果回调block
- (void)analysisWithImageURL:(NSString*)imageURL
                      result:(void(^)(NSDictionary *responseJSON, NSError *error))retHandler;


/// 包含高清人脸的图像上传于分析
/// @param image 高清人脸图像
/// @param progressBlock 处理进度回调block
/// @param retHandler 分析结果回调block
- (void)analysisWithImage:(UIImage*)image
                 progress:(void(^)(SLSAFaceDataAnalysisState state, float progress))progressBlock
                   result:(void(^)(NSDictionary *responseJSON, NSError *error))retHandler;
@end



/// 解密QCloud 云图片链接
/// @param encryptedURL 加密的图片链接
FOUNDATION_EXPORT void SLSkinAnalysisDecryptQCloudImageURL(NSString *_Nonnull encryptedURL, void(^retHandler)(NSString *_Nullable decryptedURL, NSError *_Nullable error));

NS_ASSUME_NONNULL_END
