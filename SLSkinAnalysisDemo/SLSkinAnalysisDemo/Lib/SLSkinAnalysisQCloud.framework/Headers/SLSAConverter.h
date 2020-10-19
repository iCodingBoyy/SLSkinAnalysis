//
//  SLSAConverter.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface SLSAConverter : NSObject

/// 将inRect上的rect转换到toRect的坐标系中
/// @param rect 待转换的rect
/// @param inRect 包含rect的原始区域
/// @param toRect 目标区域
/// @param mode 内容填充模式 支持 UIViewContentModeScaleToFill、UIViewContentModeScaleAspectFit、UIViewContentModeScaleAspectFill
+ (CGRect)convertRect:(CGRect)rect inRect:(CGRect)inRect toRect:(CGRect)toRect mode:(UIViewContentMode)mode;


/// 将InRect上的点转换到toRect上对应的点
/// @param point 需要转换的原始点坐标
/// @param inRect 包含point的原始区域
/// @param toRect 目标区域
/// @param mode 内容填充模式
+ (CGPoint)convertPoint:(CGPoint)point inRect:(CGRect)inRect toRect:(CGRect)toRect mode:(UIViewContentMode)mode;


/// 将人脸关键点坐标转换为目前区域坐标
/// @param landmarks 包含人脸关键点的数组
/// @param inRect 包含landmarks的原始区域
/// @param toRect 目标区域
/// @param mode 内容填充模式
+ (NSArray*)convertFaceLandmarks:(NSArray*)landmarks inRect:(CGRect)inRect toRect:(CGRect)toRect mode:(UIViewContentMode)mode;
@end

FOUNDATION_EXPORT BOOL SSCIsValidRect(CGRect rect);
FOUNDATION_EXPORT CGRect SSCConvertRect(CGRect rect, CGRect inRect, CGRect toRect, UIViewContentMode mode);
FOUNDATION_EXPORT CGPoint SSCConvertPoint(CGPoint point, CGRect inRect, CGRect toRect, UIViewContentMode mode);
FOUNDATION_EXPORT NSArray *SSCConvertFaceLandmarks(NSArray *landmarks, CGRect inRect, CGRect toRect, UIViewContentMode mode);


NS_ASSUME_NONNULL_END
