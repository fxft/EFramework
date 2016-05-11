//
//  HMUITextView.h
//  GPSService
//
//  Created by Eric on 14-4-25.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HMMacros.h"
#import "HMFoundation.h"

#define ON_TextView( signal) ON_SIGNAL2(HMUITextView, signal)
@protocol ON_TextView_handle <NSObject>

ON_TextView( signal);

@end

@interface UIResponder (HMUITextView)

@property (nonatomic) BOOL			active;

@end

@interface HMUITextView : UITextView

AS_SIGNAL( WILL_ACTIVE )		// 将要获取焦点
AS_SIGNAL( DID_ACTIVED )		// 已经获取焦点
AS_SIGNAL( WILL_DEACTIVE )		// 已经丢失焦点
AS_SIGNAL( DID_DEACTIVED )		// 已经丢失焦点
AS_SIGNAL( TEXT_CHANGED )		// 文字变了
AS_SIGNAL( TEXT_OVERFLOW )		// 文字超长
AS_SIGNAL( SELECTION_CHANGED )	// 光标位置
AS_SIGNAL( RETURN_ACTION )				// 换行

@property (nonatomic, HM_STRONG) NSString *	placeholder;
@property (nonatomic, HM_STRONG) UILabel *		placeholderLabel;
@property (nonatomic, HM_STRONG) UIColor *		placeholderColor;
@property (nonatomic,HM_STRONG) UIFont*         placeholderFont;
@property (nonatomic, assign) NSUInteger	maxLength;
@property (nonatomic, HM_WEAK) NSObject *	nextChain;
@property (nonatomic,assign) BOOL	shouldHideIfReturn;

@end
