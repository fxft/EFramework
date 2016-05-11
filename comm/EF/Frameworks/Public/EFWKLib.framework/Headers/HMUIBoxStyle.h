//
//  HMUIBoxStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStyle.h"

@interface HMUIBoxStyle : HMUIStyle{
    UIEdgeInsets  _margin;
    UIEdgeInsets  _padding;
    CGSize        _minSize;
    TTPosition    _position;
}

@property (nonatomic) UIEdgeInsets  margin;
@property (nonatomic) UIEdgeInsets  padding;
@property (nonatomic) CGSize        minSize;
@property (nonatomic) TTPosition    position;

+ (HMUIBoxStyle*)styleWithMargin:(UIEdgeInsets)margin next:(HMUIStyle*)next;
+ (HMUIBoxStyle*)styleWithPadding:(UIEdgeInsets)padding next:(HMUIStyle*)next;
+ (HMUIBoxStyle*)styleWithFloats:(TTPosition)position next:(HMUIStyle*)next;
+ (HMUIBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                          next:(HMUIStyle*)next;
+ (HMUIBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                       minSize:(CGSize)minSize position:(TTPosition)position next:(HMUIStyle*)next;

@end
