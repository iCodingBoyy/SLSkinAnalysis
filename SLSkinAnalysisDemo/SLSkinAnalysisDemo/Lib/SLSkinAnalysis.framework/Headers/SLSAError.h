//
//  SLSAError.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/24.
//

#import <Foundation/Foundation.h>


/// 远程服务器错误码
typedef NS_ENUM(UInt64, SLSARemoteErrorCode) {
    SLSAErrorInvalidAuthInfo = 100010100, ///< 缺少授权信息，请检查AppId等是否缺失或者错误
    SLSAErrorInvalidToken = 100010101, ///< token错误或者已过期
    SLSAErrorInvalidAppId = 100010103,///< AppId不合法
    SLSAErrorInvalidTimeStamp = 100010104,///< timeStamp过期
    SLSAErrorInvalidSignature = 100010105,///< 签名错误
    SLSAErrorInvalidRequestURL = 100010106,///< 请求地址错误
    SLSAErrorInvalidScheme = 100010107,///< 请求scheme错误
    SLSAErrorFailed = 100010200,///< 失败，未知原因，请重试
    SLSAErrorMissingParameters = 100010201,///< 缺失必传参数
    SLSAErrorAnalysisFailed = 107001011,///< 图⽚片分析失败
    SLSAErrorNoFaceFound = 107001013,///< 图⽚片中未检测到⼈人脸
    SLSAErrorMultipleFaces = 107001014,///< 有两张或多张⼈人脸
    SLSAErrorTooLargePicture = 107001032,///< 图⽚太⼤
    SLSAErrorInvalidImageFormat = 107001033,///< 图⽚片格式错误
    SLSAErrorImageProcessingTimeout = 107001034,///< 图片处理超时
    SLSAErrorInvalidImageUrl = 107001035,///< 非法的图片路径
    SLSAErrorImageParsingFailed = 107001036,///< 图片解析错误
    SLSAErrorLowPixels = 107001037, ///< 像素未达到要求
    SLSAErrorInvalidDimension = 107001038, ///< 无效的维度值
    SLSAErrorAnalysisSkinColorFailed = 107003010, ///< 肤色检测失败
    SLSAErrorAnalysisFaceShapeFailed = 107003011, ///< 脸型检测失败
    SLSAErrorAnalysisBlackheadFailed = 107003012, ///< 黑头检测失败
    
    SLSAErrorInvalidImageQuality = 107003089, ///< 图片质量检测错误
    SLSAErrorInvalidFaceAngle = 107003090,///< 人脸姿态检测错误
    SLSAErrorServerAlgorithmTimeout = 107003091,///< 算法服务请求超时
    SLSAErrorAuthTimeout = 107004000, ///< 授权超时
    SLSAErrorInvalidPostData = 107005000, ///< 数据解析失败
};


/// SDK本地错误码
typedef NS_ENUM(UInt64, SLSALocalErrorCode) {
    SLSAErrorInvalidInputParameter = 108000000, ///< 无效的输入参数
    SLSAErrorInvalidResponseJSON, ///< 无效的响应数据
    SLSAErrorUploadImageToQCloudFailed,/// 图片上传到QCloud出错
    SLSAErrorUnsupportFaceShelter, ///< 不支持人脸遮挡物检测
    SLSAErrorNoFaceDetected, ///< 本地人脸识别没有识别到人脸
    SLSAErrorMultiFacesDetected, ///< 本地人脸识别检测到多个人脸
    SLSAErrorImageHeightIsNotLessThanTheWidth, /// 横屏无法检测识别人脸
    SLSAErrorImagePixelsExceedTheMaximum, /// 像素超过最大值
    SLSAErrorInvalidImageSize, /// 图片尺寸不满足要求，通常指图片过小
    SLSAErrorHasFaceSheltersInImage, /// 检测到人脸遮挡物
};


typedef NSString *SLSAErrorDomainIdentifier NS_STRING_ENUM;
FOUNDATION_EXTERN SLSAErrorDomainIdentifier const SLSAHTTPErrorDomain;
FOUNDATION_EXTERN SLSAErrorDomainIdentifier const SLSAAnalysisErrorDomain;

@interface SLSAError : NSObject

@end


