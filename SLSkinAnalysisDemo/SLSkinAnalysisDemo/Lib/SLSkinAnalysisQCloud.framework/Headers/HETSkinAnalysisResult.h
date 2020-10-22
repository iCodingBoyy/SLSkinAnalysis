//
//  HETSkinAnalysisResult.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/18.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HETSkinInfoBase : NSObject<NSCopying>
+ (instancetype)modelWithJSON:(NSDictionary*)json;
@end

#pragma mark - HETSkinInfoOil

@interface HETSkinInfoOil : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *facePart;
@end


#pragma mark - HETSkinInfoMoisture

@interface HETSkinInfoMoisture : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *facePart;
@property (nonatomic, strong) NSNumber *className;
@end


#pragma mark - HETSkinInfoAcne
@interface HETSkinInfoAcne : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *facePart;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSNumber *acneTypeId;
@end

#pragma mark - HETSkinInfoEyeShape
@interface HETSkinInfoEyeShape : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *narrow;
@property (nonatomic, strong) NSNumber *updown;
@property (nonatomic, strong) NSNumber *eyelid;
@end

#pragma mark - HETSkinInfoEyeBrow
@interface HETSkinInfoEyeBrow : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *left;
@property (nonatomic, strong) NSNumber *right;
@end

#pragma mark - HETSkinInfoDarkCircle
@interface HETSkinInfoDarkCircle : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *position;
@property (nonatomic, strong) NSNumber *type;
@end

#pragma mark - HETSkinInfoBlackHead
@interface HETSkinInfoBlackHead : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *maskPath;
@end

#pragma mark - HETSkinInfoFacePose
@interface HETSkinInfoFacePose : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *pitch;
@property (nonatomic, strong) NSNumber *roll;
@property (nonatomic, strong) NSNumber *yam;
@end

#pragma mark - HETSkinInfoFatGranule

@interface HETSkinInfoFatGranule : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *fatGranuleTypeId;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *maskPath;
@end

#pragma mark - HETSkinInfoImageQuality
@interface HETSkinInfoImageQuality : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *blurType;
@property (nonatomic, strong) NSNumber *lightType;
@end

#pragma mark - HETSkinInfoPigmentation
@interface HETSkinInfoPigmentation : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *facePart;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *pigmentationTypeId;
@property (nonatomic, strong) NSNumber *area;
@property (nonatomic, strong) NSNumber *areaRatio;
@end

#pragma mark - HETSkinInfoPore

@interface HETSkinInfoPore : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSString *maskPath;
@end

#pragma mark - HETSkinInfoPouch

@interface HETSkinInfoPouchOverallArea : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *left;
@property (nonatomic, strong) NSNumber *right;
@end

@interface HETSkinInfoPouch : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *exist;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSString *maskPath;
@property (nonatomic, strong) HETSkinInfoPouchOverallArea *overallArea;
@end

#pragma mark - HETSkinInfoSensitivityCategory

@interface HETSkinInfoSensitivityCategory : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *facePart;
@end

#pragma mark - HETSkinInfoSensitivity
@class HETSkinInfoOverall;
@interface HETSkinInfoSensitivity : HETSkinInfoBase
@property (nonatomic, strong) NSArray <HETSkinInfoSensitivityCategory*>*sensitivityCategory;
@property (nonatomic, strong) NSNumber *typeId;
@property (nonatomic, strong) NSNumber *sensitivityMaskPath;
@property (nonatomic, strong) HETSkinInfoOverall *sensitivityOverall;
@end

#pragma mark - HETSkinInfoWrinkles


@interface HETSkinInfoOverallArea : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *left;
@property (nonatomic, strong) NSNumber *right;
@end


@interface HETSkinInfoWrinkles : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *wrinkleTypeId;
@property (nonatomic, strong) NSNumber *level;
@property (nonatomic, strong) NSNumber *left;
@property (nonatomic, strong) NSNumber *right;
@property (nonatomic, strong) NSNumber *area;
@property (nonatomic, strong) HETSkinInfoOverallArea *overallArea;
@end

#pragma mark - HETSkinInfoFaceShelter
@interface HETFaceShelterType : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *hat;
@property (nonatomic, strong) NSNumber *hair;
@property (nonatomic, strong) NSNumber *glass;
@property (nonatomic, strong) NSNumber *sticker;
@property (nonatomic, strong) NSNumber *mask;
@property (nonatomic, strong) NSNumber *facial;
@end

@interface HETSkinInfoFaceShelter : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *exist;
@property (nonatomic, strong) HETFaceShelterType *types;
@end


@interface HETSkinInfoOverall : HETSkinInfoBase
@property (nonatomic, strong) NSNumber *area;
@property (nonatomic, strong) NSNumber *areaRatio;
@property (nonatomic, strong) NSNumber *level;
@end

@interface HETSkinInfoStarResult : HETSkinInfoBase
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *similarity;
@property (nonatomic, strong) NSString *starPath;
@end

#pragma mark - HETSkinAnalysisResult
@interface HETSkinAnalysisResult : HETSkinInfoBase
@property (nonatomic, strong) NSString *photographId;
@property (nonatomic, strong) NSString *originalImageUrl;
@property (nonatomic, strong) NSNumber *isface;
@property (nonatomic, strong) NSNumber *sex;
@property (nonatomic, strong) NSNumber *skinAge;
@property (nonatomic, strong) NSNumber *skinType;
@property (nonatomic, strong) NSNumber *furrows;
@property (nonatomic, strong) NSString *facecolor;
@property (nonatomic, strong) NSNumber *faceshape;
@property (nonatomic, strong) NSString *pigmentationLayer;
@property (nonatomic, strong) NSString *acneLayer;
@property (nonatomic, strong) NSString *wrinkleLayer;
@property (nonatomic, strong) NSString *crowfeetMaskPath;
@property (nonatomic, strong) NSString *darkCircleMaskPath;
@property (nonatomic, strong) NSString *moistureMaskPath;
@property (nonatomic, strong) NSString *oilMaskPath;

@property (nonatomic, strong) NSArray<NSString*> *basemapPaths;
@property (nonatomic, strong) NSArray<NSNumber*> *orgimageFaceLocation;
@property (nonatomic, strong) HETSkinInfoPore *pore;
@property (nonatomic, strong) HETSkinInfoPouch *pouch;
@property (nonatomic, strong) HETSkinInfoEyeShape *eyeshape;
@property (nonatomic, strong) HETSkinInfoEyeBrow *eyebrow;
@property (nonatomic, strong) HETSkinInfoBlackHead *blackHead;
@property (nonatomic, strong) HETSkinInfoFacePose *facePose;
@property (nonatomic, strong) HETSkinInfoImageQuality *imageQuality;
@property (nonatomic, strong) HETSkinInfoFaceShelter *faceShelter;
@property (nonatomic, strong) HETSkinInfoOverall *moistureOverall;
@property (nonatomic, strong) HETSkinInfoOverall *oilOverall;
@property (nonatomic, strong) HETSkinInfoSensitivity *sensitivity;
@property (nonatomic, strong) HETSkinInfoStarResult *starResult;

@property (nonatomic, strong) NSArray <HETSkinInfoWrinkles*>*wrinkles;
@property (nonatomic, strong) NSArray <HETSkinInfoPigmentation*>*pigmentations;
@property (nonatomic, strong) NSArray <HETSkinInfoDarkCircle*>*darkCircle;
@property (nonatomic, strong) NSArray <HETSkinInfoOil*>*oil;
@property (nonatomic, strong) NSArray <HETSkinInfoMoisture*>*moisture;
@property (nonatomic, strong) NSArray <HETSkinInfoAcne*>*acnes;
@property (nonatomic, strong) NSArray <HETSkinInfoFatGranule*>*fatGranule;
@end

