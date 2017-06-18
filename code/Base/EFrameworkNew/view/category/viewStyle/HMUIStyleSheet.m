//
//  HMUIStyleSheet.m
//  CarAssistant
//
//  Created by Eric on 14-3-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyleSheet.h"
#import "HMViewCategory.h"

@implementation HMUIStyleSheet

+ (HMUIStyle*)badgeExtrudeWithFillColor:(UIColor*)color{
    if (color==nil) {
        color = RGB(221, 17, 27);
    }
    return
    [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:
     [HMUIInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
      [HMUIShadowStyle styleWithColor:RGBA(0,0,0,0.8) blur:3 offset:CGSizeMake(0, 4) next:
       [HMUIReflectiveFillStyle styleWithColor:color next:
        [HMUIInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
         [HMUISolidBorderStyle styleWithColor:[UIColor whiteColor] width:2 next:
          [HMUIBoxStyle styleWithPadding:UIEdgeInsetsMake(2, 6, 2, 6) next:
           [HMUIInsetStyle styleWithInset:UIEdgeInsetsMake(2, 6, 2, 6) next:nil]]]]]]]];
}

+ (HMUIStyle *)badgeFlattenWithFillColor:(UIColor *)color{
    if (color==nil) {
        color = RGB(221, 17, 27);
    }
    
   return [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:[HMUISolidFillStyle styleWithColor:color next:[HMUIInsetStyle styleWithInset:UIEdgeInsetsMake(0, 4, 0, 4) next:nil]]];
}

+ (HMUIStyle *)badgeFlattenBorderWithFillColor:(UIColor *)color border:(UIColor*)colorb width:(CGFloat)width{
    if (color==nil) {
        color = RGB(221, 17, 27);
    }
    if (colorb==nil) {
        colorb = [UIColor whiteColor];
    }
    if (width<=0) {
        width = 2;
    }
    
    
    return [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:[HMUISolidFillStyle styleWithColor:color next:[HMUISolidBorderStyle styleWithColor:colorb width:width next:[HMUIInsetStyle styleWithInset:UIEdgeInsetsMake(0, width*2, 0, width*2) next:nil]]]];
}

+ (HMUIStyle *)badgeFlattenBorderWithFillColor:(UIColor *)color{
    
    return [self badgeFlattenBorderWithFillColor:color border:nil width:0];
//    if (color==nil) {
//        color = RGB(221, 17, 27);
//    }
//    
//    return [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithRadius:TT_ROUNDED] next:[HMUISolidFillStyle styleWithColor:color next:[HMUISolidBorderStyle styleWithColor:[UIColor whiteColor] width:2 next:[HMUIInsetStyle styleWithInset:UIEdgeInsetsMake(0, 4, 0, 4) next:nil]]]];
}

@end
