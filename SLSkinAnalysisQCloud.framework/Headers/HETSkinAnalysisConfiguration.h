//
//  HETSkinAnalysisConfiguration.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HETSkinAnalysisVoice.h"

/**
 对象序列化JSON->Model，你可以使用自定义的序列化框架,如果不配置则使用默认序列化
 e.g 使用yymodel或者MJExtension框架序列化对象实例
 ```
 HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration defaultConfiguration];
 [config setJsonToModelBlock:^id(__unsafe_unretained Class aClass, id obj) {
 // 如果此处不做处理直接返回nil，所有的JSON->Model都会得到空对象
 id model =  [aClass modelWithJSON:obj];
 return model;
 }];
 ```
 @warning 如果配置了block实例，但是直接返回nil会影响对象序列化结果
 @param aClass 要序列化的对象类
 @param obj 服务器响应结果实例，可以是NSDictionary或者NSArray类对象
 @return 序列化的Model
 */
typedef id (^HETJSONToModelBlock)(Class aClass, id obj);

/**
 对象反序列化Model->JSON，
 
 @param aClass 反序列化的对象类型
 @param aModel 被反序列化的对象model
 @return 反序列化的JSON字符串
 */
typedef NSString* (^HETModelToJSONBlock)(Class aClass, id aModel);


@interface HETSkinAnalysisConfiguration : NSObject
@property (nonatomic, copy) HETJSONToModelBlock jsonToModelBlock;
@property (nonatomic, copy) HETModelToJSONBlock modelToJSONBlock;

/**
 如果限制了人脸框范围，则进行人脸识别时会检测人脸是否处于设置的人脸框中默认为YES
 
 @warning 设置为NO `setFaceDetectionBounds:`接口无效
 */
@property (nonatomic, assign) BOOL faceBoundsDetectionEnable;


/**
 是否开启光线检测，默认为YES
 
 @warning 设置为NO将无法获取照片光亮度数据
 */
@property (nonatomic, assign) BOOL yuvLightDetectionEnable;

/**
 最大检测亮度 默认240 （0-250）
 */
@property (nonatomic, assign) NSInteger maxYUVLight;

/**
 最小检测亮度 默认60 （0-250）
 */
@property (nonatomic, assign) NSInteger minYUVLight;


/**
 人脸距离侦测，默认为YES
 
 @warning 设置为NO将关闭距离侦测，无法返回正确的人脸与相机的相对距离参数
 */
@property (nonatomic, assign) BOOL distanceDetectionEnable;

/**
 最大侦测距离 默认.85 (0~1.0)
 */
@property (nonatomic, assign) CGFloat maxDetectionDistance;

/**
 最小侦测距离 默认0.18 (0~1.0)
 */
@property (nonatomic, assign) CGFloat minDetectionDistance;


/**
 标准人脸姿势检查，默认为YES
 
 @warning 正常情况下会对人脸角度识别，确保拍摄到正面人脸，
 如果为 NO，可能拍摄到非标准人脸影响肤质检测
 */
@property (nonatomic, assign) BOOL standardFaceCheckEnable;


/**
 标准人脸检测状态的最小稳定帧，只有图像达到稳定状态才可以启动照片拍摄，默认18
 
 @warning 为防止拍照过程中突然抖动造成图像质量下降，SDK会进行稳定帧检查，你可以根据需要修改此参数，但不宜过大
*/
@property (nonatomic, assign) NSInteger minStableFrameCountOfStandardFaceState;

/**
 是否在`拍照成功语音`播报完成后输出图像 默认为NO,设置为YES，语音播放完成后才回调图像
*/
@property (nonatomic, assign) BOOL outputImageAfterVoice;


#pragma mark - register

/**
 设置clife平台AppId和AppSecret

 @warning 你可以从Clife开发平台注册应用获取，如果不设置将无法进行人脸大数据肤质分析
 @param appId appId
 @param appSecret 访问凭证
 */
- (void)registerWithAppId:(NSString*)appId andSecret:(NSString*)appSecret;



#pragma mark - 静音设置

/**
 设置拍照测肤语音播报静音
 @warning 静音标识只做了内存缓存
 @param muted YES/NO
 @return YES/NO
 */
+ (BOOL)setMute:(BOOL)muted;


/**
 判断拍照测肤是否静音
 @warning 静音标识只做了内存缓存
 @return YES/NO
 */
+ (BOOL)isMuted;


#pragma mark - 检测边界

/**
 设置相机边界，检测出的人脸坐标需要转换为相机检测边界内的真实坐标系，所以需要设置此边界

 @warning 如果不设置此边界或者边界设置不合法，则setFaceDetectionBounds:参数将无效
 
 @param bounds 相机边界
 */
- (void)setCameraBounds:(CGRect)bounds;


/**
 返回当前设置的相机边界

  @warning 如果未设置或者设置不符合条件的值，将返回CGRectZero
 @return CGRect Value
 */
+ (CGRect)getCameraBounds;


/**
 设置人脸检测的边界区域

 @warning 你应该设置合适的边界，确保人脸照片符合大数据分析要求。设置了此边界，如果人脸区域不在此边界内，则会作出越界提示
 @param bounds 检测边界
 */
- (void)setFaceDetectionBounds:(CGRect)bounds;


/**
 获取当前设置的人脸侦测边界

 @warning 如果未设置或者设置不符合条件的值，将返回CGRectZero
 @return CGRect value
 */
+ (CGRect)getFaceDetectionBounds;


#pragma mark - Voice

/**
 设置自定义语音

 @param voiceConfig 自定义语音，如果传入nil则使用默认voice
 */
- (void)setCustomVoice:(id<HETSkinAnalysisVoiceDelegate>)voiceConfig;
- (id<HETSkinAnalysisVoiceDelegate>)getVoiceConfig;

#pragma mark - Config

/**
 返回拍照测肤默认配置对象
 
 @return 默认拍照测肤配置
 */
+ (instancetype)defaultConfiguration;

@end

