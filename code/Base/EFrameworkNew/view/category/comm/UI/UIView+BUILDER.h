//
//  UIView+BUILDER.h
//  LightAll
//
//  Created by mac on 15/5/17.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMUITextField,HMUITextView,HMUIPhotoBrowser;

@interface UIView (BUILDER)

+ (instancetype)view;
+ (UIImageView*)viewAsImage;
+ (UIButten *)viewAsButten;
+ (UIButten *)viewAsCheckbox;
+ (UIButten *)viewAsCheckboxRight;
+ (UIButten *)viewAsIcon;
+ (UILabel *)viewAsLabel;
+ (HMUITextField *)viewAsInput;
+ (HMUITextView*)viewAsTextView;
+ (HMUITextField *)viewAsInputTopic;
+ (HMUIPhotoBrowser *)viewAsImageBrowser;

//通用
- (instancetype)EFOwner:(UIView*)view;
- (instancetype)EFSubview:(UIView*)view;

- (instancetype)EFTag:(NSInteger)tag;
- (instancetype)EFTagString:(NSString*)tag;
- (instancetype)EFBackgroundColor:(UIColor*)color;
- (instancetype)EFContentMode:(UIViewContentMode)mode;

//image、Button
- (instancetype)EFImage:(id)image;
- (instancetype)EFImage:(id)image forState:(UIControlState)state;
- (instancetype)EFBackgroundImage:(id)image;
- (instancetype)EFBackgroundImage:(id)image forState:(UIControlState)state;


//Button
- (instancetype)EFTextDisabled:(id)title;
- (instancetype)EFTextSelected:(id)title;
- (instancetype)EFTextHightLight:(id)title;

- (instancetype)EFTextDisabledColor:(UIColor*)color;
- (instancetype)EFTextSelectedColor:(UIColor*)color;
- (instancetype)EFTextHightLightColor:(UIColor*)color;

//Button、支持SetText、setFont、setTextColor、setTextAlignment的控件
- (instancetype)EFText:(id)title;
- (instancetype)EFTextFont:(UIFont *)font;
- (instancetype)EFTextColor:(UIColor*)color;
- (instancetype)EFTextAlign:(NSTextAlignment)align;

//输入TextField TextView快捷方法
- (instancetype)EFAutoHideKeyboardWhenReturn:(BOOL)autoHide;
- (instancetype)EFEventResponder:(id)responder;
- (instancetype)EFNextResponder:(UIResponder*)responder;
- (instancetype)EFKeyBoardType:(UIKeyboardType)type;
- (instancetype)EFReturnType:(UIReturnKeyType)type;
- (instancetype)EFInputAccessory:(UIView*)accessory;//键盘配件
- (instancetype)EFInputView:(UIView*)input;//键盘

- (instancetype)EFPlaceText:(NSString *)title;
- (instancetype)EFPlaceTextColor:(UIColor *)color;
- (instancetype)EFPlaceTextFont:(UIFont *)font;

- (instancetype)EFLeft:(id)source;
- (instancetype)EFRight:(id)source;
- (instancetype)EFFrame:(CGRect)frame;
- (instancetype)EFLeftFrame:(CGRect)frame;
- (instancetype)EFRightFrame:(CGRect)frame;

//Button快捷方法
- (instancetype)EFImageSize:(CGSize)size;
- (instancetype)EFTextMargin:(CGFloat)margin;
- (instancetype)EFAutoSelect:(BOOL)autoSelect;

//TextField、支持HMUIInsetStyle的控件
- (instancetype)EFEdgeInsets:(UIEdgeInsets)insets;


@end