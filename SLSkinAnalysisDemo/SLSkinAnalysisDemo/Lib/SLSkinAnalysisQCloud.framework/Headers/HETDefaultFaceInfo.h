//
//  HETDefaultFaceInfo.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/21.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HETFaceAnalysisResult.h"


@interface HETDefaultFaceInfo : NSObject <HETFaceAnalysisResultDelegate,NSCopying>
@property (nonatomic, assign) CGRect faceBounds;
@property (nonatomic, assign) CGRect faceBoxBounds;
@property (nonatomic, assign) CGSize videoBufferImageSize;
@property (nonatomic, assign) BOOL hasFaceAngleValue;
@property (nonatomic, assign) CGFloat faceAngle;
@property (nonatomic, assign) BOOL hasRollAngleValue;
@property (nonatomic, assign) CGFloat rollAngle;
@property (nonatomic, assign) BOOL hasYawAngleValue;
@property (nonatomic, assign) CGFloat yawAngle;
@property (nonatomic, assign) BOOL hasLeftEyePosition;
@property (nonatomic, assign) CGPoint leftEyePosition;
@property (nonatomic, assign) BOOL hasRightEyePosition;
@property (nonatomic, assign) CGPoint rightEyePosition;
@property (nonatomic, assign) BOOL hasMouthPosition;
@property (nonatomic, assign) CGPoint mouthPosition;
@end

