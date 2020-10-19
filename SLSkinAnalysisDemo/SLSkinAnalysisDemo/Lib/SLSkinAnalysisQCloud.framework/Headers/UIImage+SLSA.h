//
//  UIImage+SLSA.h
//  SLSkinAnalysis
//
//  Created by myz on 2020/9/17.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


#pragma mark - SLSACompress

@interface UIImage (SLSACompress)

/// 图片压缩
/// @param quality 压缩系数 0.0-1.0
- (NSData*)slsa_compressWithQuality:(float)quality;

/// 异步压缩图片
/// @param quality 压缩系数 0.0-1.0
/// @param retHandler 压缩结果回调
- (void)slsa_asyncCompressWithQuality:(float)quality result:(void(^)(NSData *data))retHandler;
@end


#pragma mark - SLSAFixOrientation

@interface UIImage (SLSAFixOrientation)
/// 修复图片方向
- (UIImage*)slsa_fixedOrientationImage;

/// 异步修复图片方向
/// @param retHandler 修复结果回调
- (void)slsa_asyncFixedOrientationImage:(void(^)(UIImage *fixedImage))retHandler;
@end


#pragma mark - SLSAMirror

@interface UIImage (SLSAMirror)

/// 水平镜像翻转
- (UIImage*)slsa_mirrorImageHorizontal;
@end


#pragma mark - SLSARGB

@interface UIImage (SLSARGB)
+ (UIImage*)slsa_rgbImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
