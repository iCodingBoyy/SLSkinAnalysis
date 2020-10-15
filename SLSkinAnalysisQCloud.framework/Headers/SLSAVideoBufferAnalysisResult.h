//
//  SLSAVideoBufferAnalysisResult.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSVideoBufferAnalysisState) {
    SSVideoBufferAnalysisStateUnknown, ///< 未知状态
    SSVideoBufferAnalysisStateDistanceFar, ///< 太远
    SSVideoBufferAnalysisStateDistanceNear, ///< 太近
    SSVideoBufferAnalysisStateLightDark, ///< 光线偏暗
    SSVideoBufferAnalysisStateLightBright,///< 光线偏亮
    SSVideoBufferAnalysisStateNoFace,///< 没有检测到人脸
    SSVideoBufferAnalysisStateMultiFaces, ///< 有人抢镜
    SSVideoBufferAnalysisStateInvalidFaceAngle, ///< 请保持正脸
    SSVideoBufferAnalysisStateOutOfBoundingBox, ///< 请将人脸对准示意框
    SSVideoBufferAnalysisStateFaceShelter,/// 面部有遮挡物
    SSVideoBufferAnalysisStateWillTakePhoto,///< 即将拍照
    SSVideoBufferAnalysisStateTakePhotoSuccess, ///< 拍照成功
};


typedef NS_ENUM(NSInteger, SSFaceShelterRegion) {
    SSFaceShelterRegionUnknown,
    SSFaceShelterRegionEye = 1 << 0, ///< 眼部区域，识别 facial,glas
    SSFaceShelterRegionMuzzle = 1 << 1,///< 鼻口区域，识别 mask,sticker
    SSFaceShelterRegionForehead = 1 << 2,///< 额头区域，识别 hat,hair
};

#pragma mark - SLSAFaceShelterItem

@interface SLSAFaceShelterItem : NSObject <NSCopying>
@property (nonatomic, strong) NSString *shelterName;
@property (nonatomic, assign) SSFaceShelterRegion shelterRegion;
@end


#pragma mark - SLSAVideoBufferAnalysisResult

@class SLSAVoiceItem;
@protocol SLSAVoiceConfigDelegate;
@interface SLSAVideoBufferAnalysisResult : NSObject <NSCopying>
@property (nonatomic, assign) SSVideoBufferAnalysisState state;
@property (nonatomic, assign) NSInteger yuvLight;
@property (nonatomic, assign) float distance;
/// 转换到设备窗口的人脸框
@property (nonatomic, assign) CGRect faceRect;
@property (nonatomic, strong) NSArray<SLSAFaceShelterItem*> *shelters;
@end


/// 根据肤质分析状态类型获取对应的语音文件
/// @warning 此接口不包含遮挡物语音文件获取
/// @param voiceDelegate 语音代理
/// @param state 人脸分析结果
/// @param isFrontCamera YES 前置摄像头
FOUNDATION_EXPORT SLSAVoiceItem *SSVBAGetVoiceItem(id<SLSAVoiceConfigDelegate> voiceDelegate, SSVideoBufferAnalysisState state, BOOL isFrontCamera);


/// 根据检测到的遮挡物获取对应的遮挡物语音播报文件
/// @param voiceDelegate 语音代理
/// @param shelters 检测到的遮挡物
FOUNDATION_EXPORT SLSAVoiceItem *SSVBAGetShelterVoiceItem(id<SLSAVoiceConfigDelegate> voiceDelegate, NSArray<SLSAFaceShelterItem*> *shelters);

NS_ASSUME_NONNULL_END
