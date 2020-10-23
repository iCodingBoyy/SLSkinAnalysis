//
//  SLSAVoicePlayer.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN


@class SLSAVoicePlayer;
@protocol SLSAVoicePlayerPlayDelegate <NSObject>
@required
- (void)player:(SLSAVoicePlayer*)player didFinishPlaying:(BOOL)flag;
- (void)player:(SLSAVoicePlayer *)player didOccurError:(NSError *)error;
@end

typedef void(^SLSAVoicePlayerDidFinishPlayingBlock)(SLSAVoicePlayer *voicePlayer, BOOL flag,  NSError * _Nullable error);

@interface SLSAVoicePlayer : NSObject
@property (nonatomic, weak) id<SLSAVoicePlayerPlayDelegate> delegate;
@property (nonatomic, strong, readonly) AVAudioPlayer *audioPlayer;
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;

/// 延时播放，为 YES 时可以调用`playWithDelay：`播放接口设置延时时长
@property (nonatomic, assign) BOOL shouldDelayToPlay;

@property (nonatomic, copy, nullable) SLSAVoicePlayerDidFinishPlayingBlock finishPlayingBlock;

- (instancetype)init NS_UNAVAILABLE;

/// 初始化播放器，
/// @param filePath 音频文件路径
/// @param error NSError,返回nil是可以查看此错误信息
+ (instancetype)playerWithFile:(nullable NSString*)filePath error:(NSError**)error;


/// 准备播放
- (BOOL)prepareToPlay;



/// 延时播放语音
/// @param delay 延时时长 s
- (void)playWithDelay:(NSTimeInterval)delay;


/// 播放语音，成功返回YES
- (BOOL)play;


/// 停止语音播放
- (void)stop;


/// 清理播放器资源，销毁时调用
- (void)clear;
@end

NS_ASSUME_NONNULL_END
