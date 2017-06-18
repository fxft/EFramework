//
//  Encryption.m
//  MadeInFXFT
//
//  Created by fxft on 16/5/26.
//  Copyright © 2016年 yc. All rights reserved.
//

#import "AliEncryption.h"

#import <CommonCrypto/CommonCrypto.h>

#import "NSData+DTCrypto.h"
//#import "NSString+URLEncoding.h"
//#import "NSData+URLEncode.h"


@implementation AliEncryption{
    NSMutableDictionary *headerDic;
}

+ (instancetype) sharedInstance
{
    
    static AliEncryption *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstace = [[self alloc] init];
    });
    
    return sharedInstace;
}



#pragma mark -  for aliyun api gateway

#pragma mark - HMAC-SHA1
+ (NSString *)dataString:(NSData*)value{
    if ( value )
    {
        char			tmp[16];
        unsigned char *	hex = (unsigned char *)malloc( 2048 + 1 );
        unsigned char *	bytes = (unsigned char *)[value bytes];
        unsigned long	length = [value length];
        
        hex[0] = '\0';
        
        for ( unsigned long i = 0; i < length; ++i )
        {
            sprintf( tmp, "%02X", bytes[i] );
            strcat( (char *)hex, tmp );
        }
        
        NSString * result = [NSString stringWithUTF8String:(const char *)hex];
        free( hex );
        return result;
    }
    return nil;
}
+ (NSString *)signature:(NSString*)stringToSign{
    
//    INFO(@"signature:%@",stringToSign);
    
    NSData *dataToSign=[stringToSign dataUsingEncoding:NSUTF8StringEncoding];

    NSData *dataToKey=[[AliEncryption sharedInstance].secretForApiGateway dataUsingEncoding:NSUTF8StringEncoding];
//    INFO([AliEncryption sharedInstance].secretForApiGateway);
    NSData *data = [dataToSign encryptedDataUsingSHA256WithKey:dataToKey];
//    INFO([[self dataString:data] lowercaseString]);
    NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    INFO(base64);
    return base64;
}

+ (NSString*)prepareAPIGatewayForSignWithMethod:(NSString*)HTTPMethod
                                        headers:(NSDictionary*)Headers
                                          param:(NSDictionary*)param
                                           path:(NSString *)path
                                  signHeaderKey:(NSString **)signHeaderKey{
    
    
    /*
     String stringToSign=
     HTTPMethod + "\n" +
     Accept + "\n" +
     Content-MD5 + "\n"
     Content-Type + "\n" +
     Date + "\n" +
     Headers +
     Url
     */
    
    NSMutableDictionary *prepareHeaders = [NSMutableDictionary dictionaryWithDictionary:Headers];
    
    NSMutableString *sign = [@"" mutableCopy];
    
    [sign appendString:[HTTPMethod uppercaseString]];
    [sign appendString:@"\n"];
    
    NSString *Accept = [Headers valueForKey:HTTP_HEADER_ACCEPT];
    if (Accept) {
        [sign appendString:Accept];
        [prepareHeaders removeObjectForKey:HTTP_HEADER_ACCEPT];
    }
    [sign appendString:@"\n"];
    
    NSString *Content_MD5 = [Headers valueForKey:HTTP_HEADER_CONTENT_MD5];
    if (Content_MD5) {
        [sign appendString:Content_MD5];
        [prepareHeaders removeObjectForKey:HTTP_HEADER_CONTENT_MD5];
    }
    [sign appendString:@"\n"];
    
    NSString *Content_Type = [Headers valueForKey:HTTP_HEADER_CONTENT_TYPE];
    if (Content_Type) {
        [sign appendString:Content_Type];
        [prepareHeaders removeObjectForKey:HTTP_HEADER_CONTENT_TYPE];
    }
    [sign appendString:@"\n"];
    
    NSString *Date = [Headers valueForKey:HTTP_HEADER_DATE];
    if (Date) {
        [sign appendString:Date];
        [prepareHeaders removeObjectForKey:HTTP_HEADER_DATE];
    }
    [sign appendString:@"\n"];
    
    //Headers指所有参与签名计算的Header的Key、Value，这里要注意参与签名计算的Header是不包含X-Ca-Signature、X-Ca-Signature-Headers的
    NSArray *keys = prepareHeaders.allKeys;
    
    if (keys.count) {
        //获取签名的头部key字符串
        *signHeaderKey = [keys componentsJoinedByString:@","];
        
        NSArray *keysSort = [keys sortedArrayUsingSelector:@selector(compare:)];
        
        for (NSString *key in keysSort) {
            [sign appendFormat:@"%@:%@\n",key,[Headers valueForKey:key]];
        }

    }
    //Url指Path + Query + Body中Form参数，组织方法：
    if (path) {
        [sign appendString:path];
    }
    
    if (param) {
        [sign appendString:@"?"];
        [sign appendString:[[self class] queryString:param]];
    }
    
    return sign;
}


+ (NSString*)prepareIotAPIGatewayForSignWithMethod:(NSString*)HTTPMethod
                                        headers:(NSDictionary*)Headers
                                          param:(NSDictionary*)param
                                           path:(NSString *)path
                                  signHeaderKey:(NSString **)signHeaderKey{
    
    
    /*
     String stringToSign=
     Content-MD5 + "\n" +
     Headers +
     Url
     */
    
    NSMutableDictionary *prepareHeaders = [NSMutableDictionary dictionaryWithDictionary:Headers];
    
    NSMutableString *sign = [@"" mutableCopy];
    
    NSString *Content_MD5 = [Headers valueForKey:HTTP_HEADER_CONTENT_MD5];
    if (Content_MD5) {
        [sign appendString:Content_MD5];
        [prepareHeaders removeObjectForKey:HTTP_HEADER_CONTENT_MD5];
    }
    [sign appendString:@"\n"];
    
    //Headers指所有参与签名计算的Header的Key、Value，这里要注意参与签名计算的Header是不包含X-Ca-Signature、X-Ca-Signature-Headers的
    NSArray *keys = prepareHeaders.allKeys;
    
    if (keys.count) {
        //获取签名的头部key字符串
        *signHeaderKey = [keys componentsJoinedByString:@","];
        
        NSArray *keysSort = [keys sortedArrayUsingSelector:@selector(compare:)];
        
        for (NSString *key in keysSort) {
            [sign appendFormat:@"%@:%@\n",key,[Headers valueForKey:key]];
        }
        
    }
    //Url指Path + Query + Body中Form参数，组织方法：
    if (path) {
        [sign appendString:path];
    }
    
    if (param.allKeys.count) {
        [path rangeOfString:@"?"].location!=NSNotFound?[sign appendString:@"&"]:[sign appendString:@"?"];
        [sign appendString:[[self class] queryString:param]];
    }
    INFO(sign);
    return sign;
}

#pragma mark - common

+ (NSString *)timestamp
{
    NSTimeInterval timeInterval=[[NSDate date] timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%lld",(unsigned long long)timeInterval*1000];
}

+ (NSString *)nonce
{
    NSString *timestemp=[self timestamp];
    
    NSString *signStr = [NSString stringWithFormat:@"%@%@",
                         [AliEncryption sharedInstance].secretForApiGateway,
                         timestemp];
    
    return [NSString stringWithFormat:@"%@%@",[signStr MD5String],timestemp];
}

+ (NSString *)queryString:(NSDictionary*)paramDict
{
    NSArray *temp=[[paramDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableString *paramString=[@"" mutableCopy];
    
    for(NSString *key in temp){
        NSString *val = [paramDict valueForKey:key];
        if (![val notEmpty]) {
            if (paramString.length) {
                [paramString appendFormat:@"&%@",key];//[key formatURLEnocde],[val formatURLEnocde]];
            }else{
                [paramString appendFormat:@"%@",key];//[key formatURLEnocde],[val formatURLEnocde]];
            }
            
        }else{
            if (paramString.length) {
                [paramString appendFormat:@"&%@=%@",key,val];//[key formatURLEnocde],[val formatURLEnocde]];
            }else{
                [paramString appendFormat:@"%@=%@",key,val];//[key formatURLEnocde],[val formatURLEnocde]];
            }
            
        }
        
    }
    return paramString;
//    return [paramString length]>0?[paramString substringFromIndex:1]:@"";
}




@end


@implementation NSString (URL)

- (NSString *)formatURLEnocde
{
    return [[[[self URLEncodedString] stringByReplacingOccurrencesOfString:@"+" withString:@"%%20"]
             stringByReplacingOccurrencesOfString:@"*" withString:@"%%2A"]
            stringByReplacingOccurrencesOfString:@"%%7E" withString:@"~"];
}

/**
 *  URLEncode
 */
- (NSString *)URLEncodedString
{
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *unencodedString = self;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

/**
 *  URLDecode
 */
-(NSString *)URLDecodedString
{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *encodedString = self;
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

@end
