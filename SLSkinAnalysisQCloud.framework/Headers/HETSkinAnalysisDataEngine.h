//
//  HETSkinAnalysisDataEngine.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/4.
//  Copyright © 2019 马远征. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "HETSkinAnalysisDefine.h"
#import "HETSkinAnalysisResult.h"

/**
 HETImageAnalysisStep

 - HETImageAnalysisStepUpload: 图像上传
 - HETImageAnalysisStepCloudAnalysis: 大数据肤质分析
 */
typedef NS_ENUM(NSInteger, HETImageAnalysisStep)
{
    HETImageAnalysisStepUpload,
    HETImageAnalysisStepCloudAnalysis,
};

@interface HETSkinAnalysisDataEngine : NSObject

- (void)stop;

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
- (void)analysisWithImageURL:(NSString*)imageURL result:(void(^)( HETSkinAnalysisResult *skinAnalysisResult,NSDictionary *responseJSON, NSError *error))retHandler;



/// 包含高清人脸的图像上传于分析
/// @param image 高清人脸图像
/// @param progressBlock 处理进度回调block
/// @param retHandler 分析结果回调block
- (void)analysisImage:(UIImage*)image
             progress:(void(^)( HETImageAnalysisStep step, CGFloat progress))progressBlock
               result:(void(^)( HETSkinAnalysisResult *skinAnalysisResult,NSDictionary *responseJSON, NSError *error))retHandler;

@end


/// 解密QCloud 云图片链接
/// @param encryptedURL 加密的图片链接
FOUNDATION_EXPORT void HETSkinAnalysisDecryptQCloudImageURL(NSString *encryptedURL, void(^retHandler)(NSString *decryptedURL, NSError *error));
