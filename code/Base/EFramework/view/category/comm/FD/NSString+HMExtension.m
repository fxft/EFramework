//
//  NSString+HMExtension.m
//  CarAssistant
//
//  Created by Eric on 14-3-9.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSString+HMExtension.h"
#import "HMMacros.h"
#import "HMViewCategory.h"

@implementation NSString (HMExtension)

- (BOOL)empty
{
	return [self length] > 0 ? NO : YES;
}

- (BOOL)notEmpty
{
	return [self length] > 0 ? YES : NO;
}

- (BOOL)is:(NSString *)other
{
	return [self isEqualToString:other];
}

- (BOOL)isNot:(NSString *)other
{
	return NO == [self isEqualToString:other];
}

// thanks to @uxyheaven
- (NSString *)SHA1
{
    const char *	cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *		data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t			digest[CC_SHA1_DIGEST_LENGTH] = { 0 };
	CC_LONG			digestLength = (CC_LONG)data.length;
    
    CC_SHA1( data.bytes, digestLength, digest );
    
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
    for ( int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++ )
	{
		[output appendFormat:@"%02x", digest[i]];
	}
    
    return output;
}

- (NSString *)trim
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)unwrap
{
	if ( self.length >= 2 )
	{
		if ( [self hasPrefix:@"\""] && [self hasSuffix:@"\""] )
		{
			return [self substringWithRange:NSMakeRange(1, self.length - 2)];
		}
        
		if ( [self hasPrefix:@"'"] && [self hasSuffix:@"'"] )
		{
			return [self substringWithRange:NSMakeRange(1, self.length - 2)];
		}
	}
    
	return self;
}

- (NSString *)trimMiddle{
    NSRange range = self.length>2?NSMakeRange(1, self.length-2):NSMakeRange(0, 0);
    NSString *string = @"*";
    if (range.length>0) {
        for (int a=1; a<range.length; a++) {
            string = [NSString stringWithFormat:@"%@*",string];
        }
        string = [NSString stringWithFormat:@"%@%@%@",[self substringToIndex:1],string,[self substringFromIndex:range.length+1]];
    }else{
        string = self;
    }
    return string;
}

- (NSString *)add:(NSString *)append{
    return [NSString stringWithFormat:@"%@%@",self,append];
}

- (NSString *) ch2phonetic{
    if (self.length==0) {
        return nil;
    }
    NSMutableString *source = [self mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    return [source autorelease];
}

- (NSString *)ch2phoneticFirstLetter{
    NSMutableString *string = [NSMutableString string];
    NSString *one = [self ch2phonetic];
    NSArray *aa = [one componentsSeparatedByString:@" "];
    
    for (NSString *o in aa) {
        
        if (o.length) {
            [string appendString:[o substringToIndex:1]];
        }
    }
    return string;
}

- (BOOL)isUserName
{
	NSString *		regex = @"(^[A-Za-z0-9]{3,20}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isPassword
{
	NSString *		regex = @"(^[A-Za-z0-9]{6,20}$)";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isEmail
{
	NSString *		regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isUrl
{
    NSString *		regex = @"((http|ftp|https):\\/\\/)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?";//@"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- \\/_!~*'().;?:@&=+$,%#-]*)?";
    
	NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	
	return [pred evaluateWithObject:self];
}

- (BOOL)isPlate{
    
    NSString *		regex = @"^[\u4e00-\u9fa5]{1}[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

- (BOOL)isCardNo{
    // 身份证号码为15位或者18位，15位时全为数字，18位前17位为数字，最后一位是校验位，可能为数字或字符X
    NSString *		regex = @"(^\\d{15}$)|(^\\d{18}$)|(^\\d{17}(\\d|X|x)$)";
    NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

/*
 * 常用信用卡卡号规则
 * Issuer Identifier  Card Number                            Length
 * Diner's Club       300xxx-305xxx, 3095xx, 36xxxx, 38xxxx  14
 * American Express   34xxxx, 37xxxx                         15
 * VISA               4xxxxx                                 13, 16
 * MasterCard         51xxxx-55xxxx                          16
 * JCB                3528xx-358xxx                          16
 * Discover           6011xx                                 16
 * 银联                622126-622925                          16
 *
 * 信用卡号验证基本算法：
 * 偶数位卡号奇数位上数字*2，奇数位卡号偶数位上数字*2。
 * 大于10的位数减9。
 * 全部数字加起来。
 * 结果不是10的倍数的卡号非法。
 * prefrences link:http://www.truevue.org/licai/credit-card-no
 *
 */

- (BOOL)isCreditCard{
    NSString *		regex =  @"^[3,4,5,6]{1}[0-9]{12,13,14,15}";
    NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

- (BOOL)isBankCard{
    NSString *		regex =  @"\\d{16,19}";
    NSPredicate *	pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

- (BOOL)isTelephone
{
    NSString * MOBILE = @"^1(4[0-9]|3[0-9]|5[0-35-9]|8[0125-9])\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";//移动
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";//联通
    NSString * CT = @"^1((33|53|77|73|70|8[0139])[0-9]|349)\\d{7}$";//电信
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{6,8}$";
    NSString * UNION400 = @"(^\\(?400\\)?-?\\(?\\d{3}\\)?-?\\(?\\d{4}\\)?)|(^100[0-9]{2})";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    NSPredicate *regextest400 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", UNION400];
    
    NSString *selfS = [[self trim] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return  [regextestmobile evaluateWithObject:selfS]   ||
    [regextestphs evaluateWithObject:selfS]      ||
    [regextestct evaluateWithObject:selfS]       ||
    [regextestcu evaluateWithObject:selfS]       ||
    [regextestcm evaluateWithObject:selfS]       ||
    [regextest400 evaluateWithObject:selfS]    ;
}

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width
{
    CGSize size = CGSizeZero;
    NSDictionary *dic = @{(NSString *)NSFontAttributeName: font};
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, 999999.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    size = rect.size;
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
	return size;
}

- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height
{
    CGSize size = CGSizeZero;
    NSDictionary *dic = nil;
    if (font!=nil) {
        dic = @{(NSString *)NSFontAttributeName: font};
    }
    CGRect rect = [self boundingRectWithSize:CGSizeMake(999999.0f,height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    size = rect.size;
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
	return size;
}

- (CGSize)sizeWithFont:(UIFont *)font bySize:(CGSize)size{
    CGSize size1 = CGSizeZero;
    NSDictionary *dic = nil;
    if (font!=nil) {
        dic = @{(NSString *)NSFontAttributeName: font};
    }
    CGRect rect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    size1 = rect.size;
    size1.width = ceilf(size1.width);
    size1.height = ceilf(size1.height);
    return size1;
}

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

- (BOOL)match:(NSString *)expression
{
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expression
																			options:NSRegularExpressionCaseInsensitive
																			  error:nil];
	if ( nil == regex )
		return NO;
	
	NSUInteger numberOfMatches = [regex numberOfMatchesInString:self
														options:0
														  range:NSMakeRange(0, self.length)];
	if ( 0 == numberOfMatches )
		return NO;
    
	return YES;
}

- (BOOL)contains:(NSString *)s{
    if (s.length==0) {
        return false;
    }
    return [self rangeOfString:s].location!=NSNotFound;
}

- (BOOL)startWith:(NSString *)s{
    if (s.length==0) {
        return false;
    }
    NSRange rang = [self rangeOfString:s];
    return rang.location==0;
}

- (BOOL)endWith:(NSString *)s{
    if (s.length==0) {
        return false;
    }
    NSRange rang = [self rangeOfString:s];
    return rang.location+rang.length==self.length;
}

- (NSDate *)dateFormat:(NSString*)format timeZoneName:(NSString *)zoneName
{
    NSString * text = format.length<self.length?[self substringToIndex:format.length]:self;
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:format];
    NSTimeZone *zone = zoneName.length==0?nil:[NSTimeZone timeZoneWithName:zoneName];
    if (zone==nil) {
        zone = [NSTimeZone defaultTimeZone];
    }
    [dateFormatter setTimeZone:zone];
    return [dateFormatter dateFromString:text];
    
//    NSTimeZone * local = [NSTimeZone localTimeZone];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//    return [NSDate dateWithTimeInterval:(3600+[local secondsFromGMT])
//                              sinceDate:[dateFormatter dateFromString:text]];
}

- (NSDate *)dateFormat:(NSString*)format
{
	
    return [self dateFormat:format timeZoneName:nil];
	
}
- (NSString *)dateFormatFrom:(NSString*)form to:(NSString*)to{
    NSDate *fromDate =[self dateFormat:form];
    return [fromDate stringWithDateFormat:to];
}


- (NSData *)JSONData{
    if (![NSJSONSerialization isValidJSONObject:self]) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"JSON",@"is not valid json object:: %@",self);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"JSON-NSString",error,self);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    return data;
    
}

- (id)JSONObject{

    return [[self asNSData] objectFromJSONData];
}

- (UIImage *)QRCode{
    return [self QRCodeWithSize:CGSizeMake(200, 200)];
}

- (UIImage *)QRCodeWithSize:(CGSize)size{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];
    
    // Resize without interpolating
    UIImage *resized = [image resizeWithQuality:kCGInterpolationNone newSize:size];
    
    CGImageRelease(cgImage);
    
    return resized;
}


+ (NSString *)formatVolume:(int64_t)n
{
//    return [NSByteCountFormatter stringFromByteCount:n countStyle:NSByteCountFormatterCountStyleFile];
    if ( n < Math_K )
    {
        return [NSString stringWithFormat:@"%lldB", n];
    }
    else if ( n < Math_M )
    {
        return [NSString stringWithFormat:@"%.1fK", (double)n / (double)Math_K];
    }
    else if ( n < Math_G )
    {
        return [NSString stringWithFormat:@"%.1fM", (double)n / (double)Math_M];
    }
    else if ( n < Math_T )
    {
        return [NSString stringWithFormat:@"%.1fG", (double)n / (double)Math_G];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fT", (double)n / (double)Math_T];
    }
}

/**
 *  替换html中的标签
 *
 *   str     需要被替换的字符串
 *   tag     替换的标签（span，b，.....）
 *   replace 替换成什么
 *
 *   return 去掉标签的字符串
 */
- (NSString *)filterHTMLTagReplace:(NSString*)replace
{
    NSString *str = self;
    NSScanner * scanner = [NSScanner scannerWithString:str];
    NSString * text = nil;
    
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        str  =  [str  stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:replace];
        
    }
    
    return str;
}
@end

@implementation NSAttributedString (HMExtension)

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
- (CGSize)sizeByWidth:(CGFloat)width
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width,999999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize size = rect.size;
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    return size;
}

- (CGSize)sizeByHeight:(CGFloat)height
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(999999.0f,height) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize size = rect.size;
    size.width = ceilf(size.width);
    return size;
}

- (CGSize)sizeBySize:(CGSize)size{
    CGRect rect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize size1 = rect.size;
    size1.width = ceilf(size1.width);
    return size1;
}

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

@end
