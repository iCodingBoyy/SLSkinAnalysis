//
//  SLSAFaceDataAnalysisEngine.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLSAFaceDataAnalysisEngine : NSObject

- (void)analysisWithImageURL:(NSString*)imageURL result:(void(^)(NSDictionary *responseJSON, NSError *error))retHandler;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
