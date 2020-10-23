//
//  SLSADefaultVoiceConfiguration.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/18.
//

#import <Foundation/Foundation.h>
#import "SLSAVoiceItem.h"
#import "SLSAVideoBufferAnalysisResult.h"

NS_ASSUME_NONNULL_BEGIN

/// 如果需要自定义存储静音状态，可以配置此block
FOUNDATION_EXPORT void SLSAVoiceMuteStateSetBlock(BOOL(^muteSetBlock)(BOOL isMute));
FOUNDATION_EXPORT void SLSAVoiceMuteStateGetBlock(BOOL(^muteGetBlock)(void));


/// 设置静音状态
/// @param mute YES 静音
FOUNDATION_EXPORT BOOL SLSASetVoiceMute(BOOL mute);

/// 获取静音状态
FOUNDATION_EXPORT BOOL SLSAVoiceIsMute(void);

/// 停止语音播放
FOUNDATION_EXPORT void SLSAStopVoicePlay(void);



#pragma mark - SLSAVoiceConfigDelegate

@protocol SLSAVoiceConfigDelegate <NSObject>
@required

/// 根据相机人脸buffer分析状态类别获取对应的语音提示
/// @param state buffer分析状态
/// @param isFrontCamera YES 前置相机 NO 后置相机，用于区分前置或者后置相机的语音提示
- (nullable SLSAVoiceItem*)getVoiceItemByVideoBufferAnalysisState:(SSVideoBufferAnalysisState)state frontCamera:(BOOL)isFrontCamera;


/// 根据遮挡物检测结果查询对应的状态语音
/// @warning 支持遮挡物检测的版本需要设置，不知道遮挡物检测的版本可以直接返回nil
/// @param shelters 遮挡物检测结果
- (nullable SLSAVoiceItem*)getVoiceItemByDetectedFaceShelters:(NSArray<SLSAFaceShelterItem*>*)shelters;
@end


/// 默认语音,未使用自定义语音将使用默认语音播报
@interface SLSADefaultVoiceConfiguration : NSObject <SLSAVoiceConfigDelegate>

@end

NS_ASSUME_NONNULL_END
