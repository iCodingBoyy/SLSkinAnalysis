//
//  SLSAVoicePlayer.m
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import "SLSAVoicePlayer.h"
#import "NSTimer+SLSA.h"


static NSString *SLSAVoicePlayerException = @"SLSAVoicePlayerException";
static NSString *SLSAVoicePlayerErrorDomain = @"SLSAVoicePlayerErrorDomain";

void SLSADispatchAsyncMain(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@interface SLSAVoicePlayer ()<AVAudioPlayerDelegate>
@property (nonatomic, strong) NSTimer *playTimeoutTimer;
@property (nonatomic, strong) NSTimer *delayTimer;
@end

@implementation SLSAVoicePlayer
@synthesize audioPlayer = _audioPlayer, playing = _playing;

- (instancetype)init {
    NSString *reason = @"请使用playerWithFilePath:error:初始化语音播放器";
    @throw [NSException exceptionWithName:SLSAVoicePlayerException
                                   reason:reason userInfo:nil];
    return self;
}

+ (instancetype)playerWithFile:(NSString *)filePath error:(NSError *__autoreleasing  _Nullable *)error {
    if (!filePath) return nil;
    return [[self alloc]initWithFile:filePath error:error];
}

- (instancetype)initWithFile:(NSString*)filePath error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSURL *url = [NSURL URLWithString:filePath];
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:error];
    if (!player) {
        NSLog(@"--播放器初始化错误--%@",*error);
        return nil;
    }
    self = [super init];
    if (self && url) {
        [self registerNotification];
        [self checkAndActiveAudioSession];
        __weak typeof(self) weakSelf = self;
        [self schedulePlayTimeoutTimer:^(NSTimer *timer) {
            [weakSelf playerDidPlayTimeout];
        }];
        self.audioPlayer = player;
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
    }
    return self;
}

- (void)playerDidPlayTimeout {
    if (self.delegate && [self.delegate respondsToSelector:@selector(player:didOccurError:)]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"音乐播放超时"};
        NSError *error = [NSError errorWithDomain:SLSAVoicePlayerErrorDomain
                                             code:8000 userInfo:userInfo];
        [self.delegate player:self didOccurError:error];
    }
}

#pragma mark - play

- (BOOL)prepareToPlay {
    if (_audioPlayer) {
        return [_audioPlayer prepareToPlay];
    }
    return NO;
}

- (BOOL)isPlaying {
    return (_playing = _audioPlayer.isPlaying);
}

- (BOOL)play {
    if (_audioPlayer && ![self isPlaying]) {
        return [_audioPlayer play];
    }
    return NO;
}

- (void)playWithDelay:(NSTimeInterval)delay {
    __weak typeof(self) weakSelf = self;
    [self scheduleDelayTimer:delay block:^(NSTimer *timer) {
        [weakSelf play];
    }];
}

#pragma mark - stop

- (void)stop {
    if (_audioPlayer) {
        [_audioPlayer stop];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self invalidDelayTimer];
    [self invalidPlayTimeoutTimer];
    if (self.finishPlayingBlock) {
        self.finishPlayingBlock(self, flag, nil);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(player:didFinishPlaying:)]) {
        [self.delegate player:self didFinishPlaying:flag];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    [self invalidDelayTimer];
    [self invalidPlayTimeoutTimer];
    if (self.finishPlayingBlock) {
        self.finishPlayingBlock(self, NO, error);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(player:didOccurError:)]) {
        [self.delegate player:self didOccurError:error];
    }
}

#pragma mark - Timer

- (void)scheduleDelayTimer:(NSTimeInterval)delay block:(void(^)(NSTimer *timer))block {
    SLSADispatchAsyncMain(^{
        [self invalidDelayTimer];
        self.delayTimer = [NSTimer slsa_timerWithBlock:block timeInterval:delay repeats:NO];
        [[NSRunLoop currentRunLoop]addTimer:self.delayTimer forMode:NSRunLoopCommonModes];
    });
}

- (void)invalidDelayTimer {
    if (self.delayTimer) {
        [self.delayTimer invalidate];
    }
}

- (void)schedulePlayTimeoutTimer:(void(^)(NSTimer *timer))block {
    SLSADispatchAsyncMain(^{
        [self invalidPlayTimeoutTimer];
        self.playTimeoutTimer = [NSTimer slsa_timerWithBlock:block timeInterval:30 repeats:NO];
        [[NSRunLoop currentRunLoop]addTimer:self.playTimeoutTimer forMode:NSRunLoopCommonModes];
    });
}

- (void)invalidPlayTimeoutTimer {
    if (self.playTimeoutTimer) {
        [self.playTimeoutTimer invalidate];
    }
}

#pragma mark - audio session
- (void)checkAndActiveAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayback]) {
        NSError *error;
        BOOL ret = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (!ret) {
            NSLog(@"---AVAudioSessionCategoryPlayback设置失败---%@",error);
            return;
        }
    }
    NSError *error;
    BOOL ret = [audioSession setActive:YES error:&error];
    if (!ret) {
        NSLog(@"---AVAudioSession Active失败---%@",error);
    }
}

#pragma mark - notification

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioSessionSilenceSecondaryAudioHint:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:nil];
}

- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        if (self.audioPlayer) {
            [self.audioPlayer pause];
        }
    }
    else {
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            [self play];
        }
    }
}

- (void)audioSessionSilenceSecondaryAudioHint:(NSNotification*)note
{
    NSDictionary *userInfo = note.userInfo;
    if (!userInfo || ![userInfo.allKeys containsObject:AVAudioSessionSilenceSecondaryAudioHintTypeKey]) {
        return;
    }
    NSNumber *type = note.userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey];
    if (type.intValue == AVAudioSessionSilenceSecondaryAudioHintTypeBegin) {
        
    }
    else  {
        NSError *error;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        BOOL ret = [audioSession setActive:YES error:&error];
        if (!ret) {
            NSLog(@"---AVAudioSession Active失败---%@",error);
        }
    }
}

#pragma mark - setter

- (void)setAudioPlayer:(AVAudioPlayer * _Nonnull)audioPlayer {
    if (audioPlayer != _audioPlayer) {
        [self stop];
        _audioPlayer = audioPlayer;
    }
}

#pragma mark - clear

- (void)clear {
    [self invalidDelayTimer];
    [self invalidPlayTimeoutTimer];
    _delegate = nil;
    if (_audioPlayer) {
        [_audioPlayer stop]; _audioPlayer.delegate = nil; _audioPlayer = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)dealloc {
    [self clear];
}
@end
