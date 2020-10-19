//
//  SSBufferAnalysisStateView.h
//  SLSkinAnalysisDemo
//
//  Created by myz on 2020/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSBufferAnalysisStateView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
- (void)setStateValid:(BOOL)isValid description:(NSString*)description;
@end

NS_ASSUME_NONNULL_END
