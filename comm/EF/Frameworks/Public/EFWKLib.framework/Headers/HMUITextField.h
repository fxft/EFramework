//
//  HMUITextField.h
//  CarAssistant
//
//  Created by Eric on 14-3-26.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"
#import "HMFoundation.h"

/*
 UITextField *textfield  = signal.source;
 if ([signal is:[HMUITextField WILL_ACTIVE]]) {
 [HMUIKeyboard sharedInstance].accessor =  self.textFieldView;
 [HMUIKeyboard sharedInstance].visabler = textfield;
 
 }else if ([signal is:[HMUITextField RETURN_ACTION]]) {
 
 }else if ([signal is:[HMUITextField TEXT_CHANGED]]){
 if (textfield==self.accountTF && textfield.text!=nil && textfield.text.length>0) {
 NSString *pw = [[SEUserCenter sharedInstance].users valueForKey:textfield.text];
 self.passwdTF.text = pw;
 }
 
 }
 */
#define ON_TextField( signal) ON_SIGNAL2(HMUITextField, signal)
@protocol ON_TextField_handle <NSObject>

ON_TextField( signal);

@end

@interface UIResponder (HMUITextField)

@property (nonatomic) BOOL			active;

@end

typedef NS_ENUM(NSUInteger, TextFieldStyle) {
    TextFieldStyleDefault,
    TextFieldStyleTopTips,
};


@interface HMUITextField : UITextField
@property (nonatomic) NSUInteger	userTag;
@property (nonatomic) NSUInteger	maxLength;
@property (nonatomic,HM_WEAK) UIResponder *	nextChain;
@property (nonatomic,assign) BOOL	shouldHideIfReturn;
@property (nonatomic,HM_STRONG) UIColor* placeholderColor;
@property (nonatomic,HM_STRONG) UIFont* placeholderFont;
@property (nonatomic,assign) TextFieldStyle fieldStyle;
@property (nonatomic,HM_STRONG) UIColor* bottomLineColor;
@property (nonatomic,HM_STRONG) UIColor* topTipsColor;
@property (nonatomic,HM_STRONG) NSString* topTipsText;
@property (nonatomic) UIEdgeInsets  textEdgeInsets;

AS_SIGNAL( WILL_ACTIVE )		// 将要获取焦点
AS_SIGNAL( DID_ACTIVED )		// 已经获取焦点
AS_SIGNAL( WILL_DEACTIVE )		// 已经丢失焦点
AS_SIGNAL( DID_DEACTIVED )		// 已经丢失焦点
AS_SIGNAL( TEXT_CHANGED )		// 文字变了
AS_SIGNAL( TEXT_OVERFLOW )		// 文字超长
AS_SIGNAL( CLEAR )				// 清空
AS_SIGNAL( RETURN_ACTION )				// 换行

@end
