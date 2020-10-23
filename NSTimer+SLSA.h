//
//  NSTimer+SLSA.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSTimer *SLSAScheduleTimer(NSTimeInterval seconds,BOOL repeats, void(^block)(NSTimer *timer));
FOUNDATION_EXPORT NSTimer *SLSATimer(NSTimeInterval seconds,BOOL repeats, void(^block)(NSTimer *timer));


@interface NSTimer (SLSA)
+ (NSTimer*)slsa_scheduledTimerWithBlock:(void(^)(NSTimer *timer))block timeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats;
+ (NSTimer*)slsa_timerWithBlock:(void(^)(NSTimer *timer))block timeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats;
@end

NS_ASSUME_NONNULL_END
