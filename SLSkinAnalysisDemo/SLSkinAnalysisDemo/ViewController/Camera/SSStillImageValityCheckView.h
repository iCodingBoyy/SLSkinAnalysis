//
//  SSStillImageValityCheckView.h
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSStillImageValityCheckView : UIView
@property (nonatomic, assign, getter=isChecking) BOOL checking;
@property (nonatomic, copy) void (^buttonDidClickBlock)(void);
- (void)setText:(NSString*)text;
@end

NS_ASSUME_NONNULL_END
