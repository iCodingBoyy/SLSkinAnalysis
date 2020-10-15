//
//  SLSAConfiguration.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSAConfiguration : NSObject
+ (instancetype)shared;
@end


/// 使用前先调用此接口
/// @param appId 你申请的appId
/// @param appSecret 你申请的appSecret
void SLSARegister(NSString *_Nonnull appId, NSString *_Nonnull appSecret);

NS_ASSUME_NONNULL_END
