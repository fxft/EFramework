//
//  UIImage+HMExtension.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"

@class HMUIStyle;

/**
 *  图片生成、缩放、圆角、旋转、合并、二维码识别、gif解码
 */
@interface UIImage (HMExtension)

/*
 * Resizes an image. Optionally rotates the image based on imageOrientation.
 */
- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height rotate:(BOOL)rotate;

/**
 * Returns a CGRect positioned within rect given the contentMode.
 */
- (CGRect)convertRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode;

/**
 * Draws the image using content mode rules.
 */
- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode;

/**
 * Draws the image as a rounded rectangle.
 */
- (void)drawInRect:(CGRect)rect radius:(CGFloat)radius;
- (void)drawInRect:(CGRect)rect radius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode;

//增加透明通道，让图片支持透明属性
- (UIImage *)transprent;

- (UIImage *)rounded;
- (UIImage *)rounded:(CGRect)rect;

- (UIImage *)stretched;
- (UIImage *)stretched:(UIEdgeInsets)capInsets;
//拉伸，平铺
- (UIImage *)stretched:(UIEdgeInsets)capInsets resizMode:(UIImageResizingMode)mode;

//- (UIImage *)stretcheds:(UIEdgeInsets)capInsets inSize:(CGSize)size;

- (UIImage *)rotateToFit:(CGFloat)angle;
- (UIImage *)rotate:(CGFloat)angle;//和rotateToFit一样
- (UIImage *)rotateCW90;
- (UIImage *)rotateCW180;
- (UIImage *)rotateCW270;

//灰度
- (UIImage *)grayscale;
//把图片加载成颜色块，比较耗内存
- (UIColor *)patternColor;

- (NSData *)dataWithExt:(NSString *)ext;
+ (UIImage *)imageWithDataAtScale:(NSData *)data scale:(CGFloat)scale;

+ (UIImage *)imageFromString:(NSString *)name;
+ (UIImage *)imageFromString:(NSString *)name atPath:(NSString *)path;
+ (UIImage *)imageFromString:(NSString *)name stretched:(UIEdgeInsets)capInsets;
//视频快照
+ (UIImage *)imageFromVideo:(NSURL *)videoURL atTime:(CMTime)time scale:(CGFloat)scale;

//图片剪切
- (UIImage *)crop:(CGRect)rect;
- (UIImage *)imageInRect:(CGRect)rect;//和crop一样
//按路径剪裁
- (UIImage *)cropWithPath:(CGPathRef)path EOC:(BOOL)eoc;

//图片合成
+ (UIImage *)merge:(NSArray *)images;
- (UIImage *)merge:(UIImage *)image;
- (UIImage *)mergeText:(NSAttributedString*)text offset:(CGPoint)offset;

//只能往小调整
- (UIImage *)resize:(CGSize)newSize;
//按比例调整 kCGInterpolationNone 不失真
- (UIImage *)resizeWithQuality:(CGInterpolationQuality)quality rate:(CGFloat)rate;
//任意调整 kCGInterpolationNone 不失真
- (UIImage *)resizeWithQuality:(CGInterpolationQuality)quality newSize:(CGSize)newSize;

//获取某点颜色
- (UIColor *)colorAtPixel:(CGPoint)point;

/*生成蒙层效果*/
- (UIImage *)dilateWithBlurLevel:(CGFloat)blur;/*>.3 1.0 is a good effect*/
- (UIImage *)blurryWithBlurLevel:(CGFloat)blur;/*>.5 big blurry .15 is a good effect*/
- (UIImage *)blurryImageWithBlurLevel:(CGFloat)blur iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;
- (UIImage *)blurryImageWithBlurLevel:(CGFloat)blur iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor blendRect:(CGRect)referFrame radius:(CGFloat)radius;

- (UIImage*)imageByApplyingBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
- (UIImage *)imageByApplyingBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor blendRect:(CGRect)referFrame;

//黑色替换成对应颜色
- (UIImage*)imageBlackToTransparentWithColor:(UIColor *)color;

//图片二维码识别
- (NSString*)QRCodeString NS_AVAILABLE(10_10, 8_0);

//用于摄像头捕获图像
+ (CGImageRef)createImageFromBuffer:(CVImageBufferRef)buffer CF_RETURNS_RETAINED;
+ (CGImageRef)createImageFromBuffer:(CVImageBufferRef)buffer
                               left:(size_t)left
                                top:(size_t)top
                              width:(size_t)width
                             height:(size_t)height CF_RETURNS_RETAINED;
+ (CGImageRef)createRotatedImage:(CGImageRef)original degrees:(float)degrees CF_RETURNS_RETAINED;

//用来缓存常用图片－－－阴影图片
+ (UIImage*)cacheImage:(UIImage*)image forKey:(NSString*)key;

/*生成边框阴影图片*/
typedef enum __EmbossShadowStyle {
    styleEmbossDarkLineLeft=1,
    styleEmbossDarkLineRight,
    styleEmbossDarkLineTop,
    styleEmbossDarkLineBottom,
    styleEmbossDarkLineLeftBottom,
    styleEmbossDarkLineRightTop,
    styleEmbossDarkLineLeftTop,
    styleEmbossDarkLineRightBottom,
    styleEmbossDarkLineLeftBottomRight,
    styleEmbossDarkLineLeftTopRight,
    styleEmbossDarkLineTopLeftBottom,
    styleEmbossDarkLineTopRightBottom,
    styleEmbossDarkLineArround,
} StyleEmbossShadow;

/*   styleEmbossLight:返回图片请放到视图底部 设置 clipsToBounds = NO;
    |       |
    |       |
    ^^^ ~ ^^^
 */

/*  styleEmbossDark:返回图片请放到视图底部 设置 clipsToBounds = NO;
    |       |
    |       |
    ~ ^^^^^ ~
 */

/*  styleEmbossDarkEllipse:返回图片请放到视图底部 设置 clipsToBounds = NO;
    |       |
    |       |
    ~ ##### ~
 */

/* styleEmbossLightSide:返回图片大小会增加 UIEdgeInsetsMake(0, -8, -16, -8);
     |          |
     |          |  _
    )|          |( | < 1/3
     ^^^^    ^^^^  -
     |---|1/3|--|
 */

+ (UIImage *)imageEmbossStyle:(StyleEmbossShadow)style;

+ (UIImage *)imageEmbossStyle:(StyleEmbossShadow)style color:(UIColor*)shadowColor;

/**
 *   blur 调整阴影模糊度范围 -1 <= blur <= 1  styleEmbossLightSide暂不支持该方法配置，请调用上面方法
 *   level 调整模糊度
 */

+ (UIImage *)imageEmbossStyle:(StyleEmbossShadow)style blur:(CGFloat)blur level:(CGFloat)level color:(UIColor*)shadowColor;

/**
 *  生成纯色图片
 *
 *  @param color 色值
 *  @param scale 跟主屏比例一般2.0
 *  @param size  大小
 *  @param radius  圆角
 *
 *  @return
 */
+ (UIImage *)imageForColor:(UIColor*)color scale:(CGFloat)scale size:(CGSize)size;
+ (UIImage *)imageForColor:(UIColor *)color scale:(CGFloat)scale size:(CGSize)size radius:(CGFloat)radius;
/**
 *  根据Style样式生成图片
 *
 *  @param style 请选选定一种ShapeStyle进行绘制
 *  @param size  返回图片大小
 *  @param scale 缩放比例
 *
 *  @return 所绘制图片
 */
+ (UIImage *)imageForStyle:(HMUIStyle *)style size:(CGSize)size scale:(CGFloat)scale;

/*gif*/
+ (UIImage *)sd_imageWithData:(NSData *)data;

+ (UIImage *)sd_animatedGIFNamed:(NSString *)name;
+ (UIImage *)sd_animatedGIFWithData:(NSData *)data;

//gif整体剪裁
- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size;
- (UIImage *)sd_animatedImageByScaling:(CGFloat)scale;

HM_EXTERN UIImage *SDScaledImageForScale(CGFloat scale, UIImage *image);


@end
