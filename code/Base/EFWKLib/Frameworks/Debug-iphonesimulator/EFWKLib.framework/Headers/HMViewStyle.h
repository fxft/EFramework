//
//  HMViewStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
//  自定义绘制图像，three20中获取到的内容


#import <UIKit/UIKit.h>

#import "HMUIShapeStyle.h"

#import "HMUIBevelBorderStyle.h"//斜角边框样式
#import "HMUIBlendStyle.h"//混合样式
#import "HMUIBoxStyle.h"//box方式

#import "HMUIFourBorderStyle.h"//四边框样式
#import "HMUIHighlightBorderStyle.h"//高亮边框

#import "HMUIShadowStyle.h"//阴影样式
#import "HMUIInnerShadowStyle.h"//内阴影样式

#import "HMUIInsetStyle.h"//缩放尺寸

#import "HMUILinearGradientBorderStyle.h"//渐变边框样式
#import "HMUILinearGradientFillStyle.h"//渐变内容样式

#import "HMUIReflectiveFillStyle.h"//反射样式

#import "HMUISolidBorderStyle.h"//填充边框
#import "HMUISolidFillStyle.h"//填充区域

#import "HMUIMaskStyle.h"//mask央视


extern inline void openPath(CGContextRef context,CGRect rect);
extern inline void closePath(CGContextRef context,CGRect rect);

extern  inline void roundedRectangle(CGContextRef context, CGRect rect,CGFloat radius);

@interface HMViewStyle : UIView

@end
