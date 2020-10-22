//
//  SLSAFaceObject.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SSFaceObjectDelegate <NSObject>
@required
/// 获取人脸框
- (CGRect)faceBoundsInImage;

/// 判断当前是否是标准人脸姿势
- (BOOL)isStandardFace;

@optional
/// 将图片的人脸坐标转换到设备渲染窗口的坐标
/// @param renderRect 相机渲染窗口
/// @param imageRect 渲染图片的大小
/// @param mode 渲染模式，支持 ScaleToFill、ScaleAspectFit、ScaleAspectFill
- (CGRect)faceRectInRenderRect:(CGRect)renderRect imageRect:(CGRect)imageRect mode:(UIViewContentMode)mode;
@end


@interface SLSAFaceObject : NSObject <NSCopying,SSFaceObjectDelegate>
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) NSInteger faceID;
@property (nonatomic, assign) BOOL hasRollAngle;
@property (nonatomic, assign) CGFloat rollAngle;
@property (nonatomic, assign) BOOL hasYawAngle;
@property (nonatomic, assign) CGFloat yawAngle;
@end

NS_ASSUME_NONNULL_END
