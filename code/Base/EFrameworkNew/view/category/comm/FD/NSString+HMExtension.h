//
//  NSString+HMExtension.h
//  CarAssistant
//
//  Created by Eric on 14-3-9.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

#define   NSGBK18030StringEncoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
#define   NSGBK2312StringEncoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80)

#define Math_K	(1024UL)
#define Math_M	(Math_K * 1024)
#define Math_G	(Math_M * 1024)
#define Math_T	(Math_G * 1024)
#define DEFAULT_MAX_MEMERYCACHE Math_M

@interface NSString (HMExtension)

/**
 *  去掉空格、换行
 *
 *  @return 
 */
- (NSString *)trim;
/**
 *  去掉头尾"'符号
 *
 *  @return
 */
- (NSString *)unwrap;

/**
 *  隐藏中间部分 eg.13489888888
 *
 *  @return 13********8
 */
- (NSString *)trimMiddle;

/**
 *  拼接
 *
 *  @param append
 *
 *  @return
 */
- (NSString *)add:(NSString*)append;


/**
 *  汉字转拼音
 *
 *  @return hanzizhuanpinyin
 */
- (NSString *)ch2phonetic;

/**
 *  拼音首字母
 *
 *  @return PYSZM
 */
- (NSString *)ch2phoneticFirstLetter;

/**
 *  是否满足某个正则表达式
 *
 *  @param expression 正则表达式
 *
 *  @return YES满足
 */
- (BOOL)match:(NSString *)expression;
/**
 *  是否包含某字符串
 *
 *  @param s 字符串
 *
 *  @return YES包含
 */
- (BOOL)contains:(NSString*)s;

- (BOOL)startWith:(NSString*)s;
- (BOOL)endWith:(NSString*)s;

- (BOOL)empty;
- (BOOL)notEmpty;

- (BOOL)is:(NSString *)other;
- (BOOL)isNot:(NSString *)other;

- (BOOL)isTelephone;
- (BOOL)isUserName;
- (BOOL)isPassword;
- (BOOL)isEmail;
- (BOOL)isUrl;
- (BOOL)isPlate;
- (BOOL)isCardNo; //身份证,中国
- (BOOL)isCreditCard;//信用卡
- (BOOL)isBankCard;//银行卡

/**
 *  时间解析
 *
 *  @param format eg.@"yyyy-MM-dd HH:mm:ss.sss"
 *
 *  @return 
 */
- (NSDate*)dateFormat:(NSString *)format;

/**
 *  时间格式化解析
 *
 *  @param format   eg.@"yyyy-MM-dd HH:mm:ss.sss"
 *  @param timezone 时区
 *
 *  @return
 */
- (NSDate *)dateFormat:(NSString*)format timeZoneName:(NSString *)zoneName;


/**
 *  时间格式转换
 *
 *  @param form eg.@"yyyy-MM-dd HH:mm:ss.sss"
 *  @param to   eg.@"yyyy-MM-dd"
 *
 *  @return @"2010-10-01"
 */
- (NSString *)dateFormatFrom:(NSString*)form to:(NSString*)to;


/**
 *  输出带单位的流量数据大小
 *
 *  @param n  2014
 *
 *  @return 2K(B\K\M\G)
 */
+ (NSString *)formatVolume:(int64_t)n;

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width;
- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height;
- (CGSize)sizeWithFont:(UIFont *)font bySize:(CGSize)size;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

/**
 *  json字符串转换成Data
 *
 *  @return
 */
- (NSData *)JSONData;
/**
 *  json字符串转换成json对象
 *
 *  @return json对象
 */
- (id)JSONObject;
/**
 *  生成二维码
 *
 *  @return 200*200的二维码
 */
- (UIImage *)QRCode;
- (UIImage *)QRCodeWithSize:(CGSize)size;


/**
 *  去掉html的tag标签
 *
 *  @param replace 替换成某个字符串
 *
 *  @return 替换后的结果
 */
- (NSString *)filterHTMLTagReplace:(NSString*)replace;

/**
 *  URL请求地址UTF8编码
 *
 *
 *  @return 替换后的结果
 */
- (NSString*)stringByAddingPercentEscapesForURL;
@end

@interface NSAttributedString (HMExtension)
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
- (CGSize)sizeByWidth:(CGFloat)width;
- (CGSize)sizeByHeight:(CGFloat)height;
- (CGSize)sizeBySize:(CGSize)size;
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
@end
