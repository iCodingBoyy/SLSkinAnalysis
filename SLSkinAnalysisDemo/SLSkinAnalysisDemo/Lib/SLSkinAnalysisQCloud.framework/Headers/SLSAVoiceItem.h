//
//  SLSAVoiceItem.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSAVoiceItem : NSObject
@property (nonatomic, strong) NSString *itemId;
/// 语音文件路径
@property (nonatomic, strong) NSString *filePath;
/// 语音文本描述
@property (nonatomic, strong) NSString *text;
@end

NS_ASSUME_NONNULL_END
