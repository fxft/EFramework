//
//  UILabel+SupportLinkStyle.h
//  CarAssistant
//
//  Created by Eric on 14-3-18.
//  Copyright (c) 2014年 Eric. All rights reserved.
//


/*
 eg.
 
 UILabel *label = [UILabel spawn];
 label.numberOfLines = 0;
 label.frame = CGRectMake(10,100, 300, 200);
 
 [label enableLink];
 label.dataDetectorTypes = UIDataDetectorTypeLink;
 //    label.style__ = [HMUISolidFillStyle styleWithColor:[UIColor yellowColor] next:
 //                     [HMUISolidBorderStyle styleWithColor:RGB(158, 163, 172) width:1 next:
 //                      [HMUIInsetStyle styleWithInset:UIEdgeInsetsMake(2, 20, 1, 1) next:nil]]];
 [label setDetectorFilter:^BOOL(NSTextCheckingResult *result) {
 
 return YES;
 }];
 
 //    [label setDetector:^NSArray *(NSString *string) {
 //
 //        return [NSArray arrayWithObject:[NSTextCheckingResult linkCheckingResultWithRange:NSMakeRange(5, 20) URL:[NSURL URLWithString:@"http://www.apple.com"]]];
 //    }];
 
 label.text = @"test http://www.apple.com ok\ntest http://www.apple.com ok\ntest http://www.apple.com ok\ntest http://www.apple.com ok\n";
 [label sizeToFit];
 [label addLinkToURL:[NSURL URLWithString:@"http://www.baidu.coom"] withRange:NSMakeRange(0, 3)];
 */
#import <UIKit/UIKit.h>

#import "HMMacros.h"
#import "HMEvent.h"

#define ON_Label( signal) ON_SIGNAL2(UILabel, signal)

@protocol ON_Label_handle <NSObject>

ON_Label( __notification );

@end

@class HMUIStyleContext;


@interface UILabel (SupportLinkStyle)


AS_SIGNAL(TOUCHLINK)


@property (nonatomic) CGRect    contentFrame;

/**
 A bitmask of `UIDataDetectorTypes` which are used to automatically detect links in the label text. This is `UIDataDetectorTypeNone` by default.
 
 @warning You must specify `dataDetectorTypes` before setting the `text`, with either `setText:` or `setText:afterInheritingLabelAttributesAndConfiguringWithBlock:`.
 */
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;


/**
 A dictionary containing the `NSAttributedString` attributes to be applied to links detected or manually added to the label text. The default link style is blue and underlined.
 
 @warning You must specify `linkAttributes` before setting autodecting or manually-adding links for these attributes to be applied.
 */
@property (nonatomic, HM_STRONG) NSDictionary *linkAttributes;


/**
 A dictionary containing the `NSAttributedString` attributes to be applied to links detected or manually added to the label text. The default link style is blue and underlined.
 
 @warning You must specify `linkAttributes` before setting autodecting or manually-adding links for these attributes to be applied.
 */
@property (nonatomic, HM_STRONG) NSDictionary *linkTouchedAttributes;

/**
 一个过滤器，用于过滤默认通过体统识别的链接,需要过滤时 RETURN NO.
 
 @warning 请在 setText:之前配置此参数.
 */
@property (nonatomic, copy) BOOL (^detectorFilter)(NSTextCheckingResult *result);


/**
 一个自定义过滤器.
 
 返回 NSTextCheckingResult 列表
 @warning 请在 setText:之前配置此参数,必须先设置 dataDetectorTypes 为非 UIDataDetectorTypeNone.
 */
@property (nonatomic, copy) NSArray* (^detector)(NSString * string);



/**
 启用链接检测器
 
 @warning 请在 setText:之前配置此参数.
 */
- (void)enableLink;

@property (nonatomic,assign) BOOL                              mEnableLink;

/**
 解析完text后得到的links.
 
 @warning 请在 setText:之后配置此参数.
 */
- (NSArray*)allLinks;

//如果texts不为空，则重新设置text；为空则在原有text上叠加属性
- (void)setText:(NSString *)texts color:(UIColor *)color font:(UIFont*)font range:(NSRange)range;
//设置link的颜色,默认蓝色
- (void)setLinkColor:(UIColor *)color;
//启用下划线(全文)
- (void)enableUnderline;

///-------------------
/// @name Adding Links
///-------------------

/**
 Adds a link to an `NSTextCheckingResult`.
 
 @param result An `NSTextCheckingResult` representing the link's location and type.
 @param attributes The attributes to be added to the text in the range of the specified link. If `nil`, no attributes are added.
 */
- (void)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result attributes:(NSDictionary *)attributes;

/**
 Adds a link to a URL for a specified range in the label text.
 
 @param url The url to be linked to
 @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
 */
- (void)addLinkToURL:(NSURL *)url withRange:(NSRange)range;

/**
 Adds a link to an address for a specified range in the label text.
 
 @param addressComponents A dictionary of address components for the address to be linked to
 @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
 
 @discussion The address component dictionary keys are described in `NSTextCheckingResult`'s "Keys for Address Components."
 */
- (void)addLinkToAddress:(NSDictionary *)addressComponents withRange:(NSRange)range;

/**
 Adds a link to a phone number for a specified range in the label text.
 
 @param phoneNumber The phone number to be linked to.
 @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
 */
- (void)addLinkToPhoneNumber:(NSString *)phoneNumber withRange:(NSRange)range;

/**
 Adds a link to a date for a specified range in the label text.
 
 @param date The date to be linked to.
 @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
 */
- (void)addLinkToDate:(NSDate *)date withRange:(NSRange)range;

/**
 Adds a link to a date with a particular time zone and duration for a specified range in the label text.
 
 @param date The date to be linked to.
 @param timeZone The time zone of the specified date.
 @param duration The duration, in seconds from the specified date.
 @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
 */
- (void)addLinkToDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration withRange:(NSRange)range;



///---------------------------------------
/// @name Acccessing Text Style Attributes
///---------------------------------------

/**
 The amount to kern the next character. Default is standard kerning. If this attribute is set to 0.0, no kerning is done at all.
 */
@property (nonatomic, assign) CGFloat mykern;

///--------------------------------------------
/// @name Acccessing Paragraph Style Attributes
///--------------------------------------------

/**
 The distance, in points, from the leading margin of a frame to the beginning of the paragraph's first line. This value is always nonnegative, and is 0.0 by default.
 */
@property (nonatomic, assign) CGFloat myfirstLineIndent;

/**
 The space in points added between lines within the paragraph. This value is always nonnegative and is 0.0 by default.
 */
@property (nonatomic, assign) CGFloat mylineSpacing;

/**
 The minimum line height within the paragraph. If the value is 0.0, the minimum line height is set to the line height of the `font`. 0.0 by default.
 */
@property (nonatomic, assign) CGFloat myminimumLineHeight;

/**
 The maximum line height within the paragraph. If the value is 0.0, the maximum line height is set to the line height of the `font`. 0.0 by default.
 */
@property (nonatomic, assign) CGFloat mymaximumLineHeight;

/**
 The line height multiple. This value is 1.0 by default.
 */
@property (nonatomic, assign) CGFloat mylineHeightMultiple;


//private
- (void)dectecedText:(id)text;
- (void)unload_link;
- (void)drawText:(NSString*)text;
- (CGSize)sizeToFitText:(CGSize)size;

@end
