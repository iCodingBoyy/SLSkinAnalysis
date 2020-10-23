//
//  NSTimer+SLSA.m
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/18.
//

#import "NSTimer+SLSA.h"

NSTimer *SLSAScheduleTimer(NSTimeInterval seconds,BOOL repeats, void(^block)(NSTimer *timer)) {
    NSTimer *timer = [NSTimer slsa_scheduledTimerWithBlock:block timeInterval:seconds repeats:repeats];
    return timer;
}

NSTimer *SLSATimer(NSTimeInterval seconds,BOOL repeats, void(^block)(NSTimer *timer)) {
    NSTimer *timer = [NSTimer slsa_timerWithBlock:block timeInterval:seconds repeats:repeats];
    return timer;
}

@implementation NSTimer (SLSA)
+ (void)_slsa_execBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)slsa_scheduledTimerWithBlock:(void (^)(NSTimer *timer))block timeInterval:(NSTimeInterval)seconds  repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(_slsa_execBlock:) userInfo:[block copy] repeats:repeats];
}


+ (NSTimer *)slsa_timerWithBlock:(void (^)(NSTimer *timer))block timeInterval:(NSTimeInterval)seconds  repeats:(BOOL)repeats {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(_slsa_execBlock:) userInfo:[block copy] repeats:repeats];
}
@end
