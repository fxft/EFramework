//
//  EncryptionURI.m
//  EFMWKLib
//
//  Created by mac on 16/12/21.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "EncryptionURI.h"
#include <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

/**
 Returns a percent-escaped string following RFC 3986 for a query string key or value.
 RFC 3986 states that the following characters are "reserved" characters.
 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
 
 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
 should be percent-escaped in the query string.
 - parameter string: The string to be percent-escaped.
 - returns: The percent-escaped string.
 */
HM_EXTERN_C_BEGIN
NSString * HMPercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(string.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    [allowedCharacterSet release];
    
    return [escaped autorelease];
}
HM_EXTERN_C_END
#pragma mark -

@interface HMQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;
@end

@implementation HMQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}
- (void)dealloc
{
    self.field = nil;
    self.value = nil;
    HM_SUPER_DEALLOC();
}
- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return HMPercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", HMPercentEscapedStringFromString([self.field description]), HMPercentEscapedStringFromString([self.value description])];
    }
}
- (NSString *)stringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return [self.field description];
    } else {
        return [NSString stringWithFormat:@"%@=%@", [self.field description], [self.value description]];
    }
}
@end

FOUNDATION_EXPORT NSArray * HMQueryStringPairsFromDictionary(NSDictionary *dictionary);
FOUNDATION_EXPORT NSArray * HMQueryStringPairsFromKeyAndValue(NSString *key, id value);
HM_EXTERN_C_BEGIN
NSString * HMQueryStringFromParameters(NSDictionary *parameters,BOOL encode) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (HMQueryStringPair *pair in HMQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:encode?[pair URLEncodedStringValue]:[pair stringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * HMQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return HMQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * HMQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:HMQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:HMQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:HMQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[[HMQueryStringPair alloc] initWithField:key value:value] autorelease]];
    }
    
    return mutableQueryStringComponents;
}

uint64_t HMMurmurHash64A ( const void * key, unsigned long len, unsigned int seed )
{
    const uint64_t m = 0xc6a4a7935bd1e995;
    const int r = 47;
    
    uint64_t h = (seed&0xffffffffL) ^ (len * m);
    
    const uint64_t * data = (const uint64_t *)key;
    const uint64_t * end = data + (len/8);
    
    while(data != end)
    {
        uint64_t k = *data++;
        
        k *= m;
        k ^= k >> r;
        k *= m;
        
        h ^= k;
        h *= m;
    }
    
    const unsigned char * data2 = (const unsigned char*)data;
    
    switch(len & 7)
    {
        case 7: h ^= ((uint64_t)(data2[6])) << 48;
        case 6: h ^= ((uint64_t)(data2[5])) << 40;
        case 5: h ^= ((uint64_t)(data2[4])) << 32;
        case 4: h ^= ((uint64_t)(data2[3])) << 24;
        case 3: h ^= ((uint64_t)(data2[2])) << 16;
        case 2: h ^= ((uint64_t)(data2[1])) << 8;
        case 1: h ^= ((uint64_t)(data2[0]));
            h *= m;
    };
    
    h ^= h >> r;
    h *= m;
    h ^= h >> r;
    
    return h;
}
HM_EXTERN_C_END

@implementation EncryptionURI

+ (NSString *)reverse:(NSString*)str {
    NSMutableArray *stra = [NSMutableArray array];
    for (int i=0; i<str.length; i++) {
        [stra insertObject:[str substringWithRange:NSMakeRange(i, 1)] atIndex:0];
    }
    return [stra componentsJoinedByString:@""];
}

+ (NSString *)encryption:(NSString*)str {
    NSString *str2 = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    NSString *str3 = @"O3GQ2VEZehzfInBH4jaDvcU9Y1lpXmKqR6ACWL5xgT0iMrds8SNt7PkbyuowJF";
    NSMutableString *stringBuffer = [NSMutableString string];
    NSUInteger length = str.length;
    for (int i = 0; i < length; i++)
    {
        NSUInteger index = [str2 rangeOfString:[str substringWithRange:NSMakeRange(i, 1)]].location;
        [stringBuffer appendString:[str3 substringWithRange:NSMakeRange(index, 1)]];
    }
    return stringBuffer;
}

+ (NSString*)halfpartAndReverse:(NSString*)str{
    NSString *sb1 = [str substringToIndex:str.length/2];
    NSString *sb2 = [str substringFromIndex:str.length/2];
    NSString *sb = [[self reverse:sb1] add:[self reverse:sb2]];
    return sb;
}
+ (NSString *)encryptionStringForValue:(long long)j {
    NSString * str = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    NSUInteger length = str.length;
    
    long long ji = j<0?llabs(j):j;
    
    NSMutableString *stringBuffer = [NSMutableString string];
    while (true) {
        long long j2 = ji / length;
        
        [stringBuffer insertString:[str substringWithRange:NSMakeRange((int) (ji % ((long long) length)), 1)] atIndex:0];
        if (j2 == 0) {
            return stringBuffer;
        }
        ji = j2;
    }
}
+ (long long)valueForString:(NSString*)str {
    NSString *str2 = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    long length = (long) str2.length;
    long length2 = str.length;
    long j = 0;
    for (int i = 0; i < length2; i++) {
        NSString * substring = [str substringWithRange:NSMakeRange(i, 1)];//substring(i, i + 1);
        long j2 = 0;
        long length3 = length;
        long length4 = substring.length;
        for (int i2 = 0; i2 < length4; i2++) {
            NSUInteger index = [str2 rangeOfString:[substring substringWithRange:NSMakeRange(i2, 1)]].location;
            j2 += pow((double) length3, (double) ((length4 - i2) - 1)) * index;
        }
        j += (j2 * ((long) i)) * (length - 1);
    }
    return j % length;
}
+ (NSString *)appendStringLength:(NSString*)str {
    NSString *base = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    return [[[[base substringWithRange:NSMakeRange(str.length,1)] mutableCopy] autorelease] stringByAppendingString:str];
}

//url带路径，param为get方式拼接
+ (NSString *)statIdWithUrl:(NSString*)url para:(NSDictionary *)param encrKey:(NSString*)key encrValue:(unsigned int)value{
    
    NSURL *URL = [NSURL URLWithString:url];
    if (URL==nil) {
        return nil;
    }
    NSString *path = URL.path;
    INFO(@"1 substring:",path);
    INFO(@"2 hashMap:",param);
    
    NSString *query = HMQueryStringFromParameters(param,NO);
    
    NSString *stringBuilder = [[[[path trim] add:@","]add:[[query stringByReplacingOccurrencesOfString:@"&" withString:@","] stringByReplacingOccurrencesOfString:@"=" withString:@","]] add:key];
    INFO(@"3 jiami:%@",stringBuilder);
    uint64_t l = HMMurmurHash64A(stringBuilder.UTF8String, strlen(stringBuilder.UTF8String), value);
    
    INFO(@"4 HMMurmurHash64A:",@(l));
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
    NSMutableString *statidBuilder = [NSMutableString string];
    [statidBuilder appendString:[self appendStringLength:[self encryptionStringForValue:1001]]];
    INFO(@"5 appendStringLength(encryptionValue(1001)):",statidBuilder);
    [statidBuilder appendString:[self appendStringLength:[self encryptionStringForValue:t]]];
    INFO(@"6 appendStringLength(encryptionValue(currentTimeMillis)):",statidBuilder);
    [statidBuilder appendString:[self appendStringLength:[self encryptionStringForValue:l]]];
    INFO(@"7 appendStringLength(encryptionValue(l.longValue())):",statidBuilder);
    [statidBuilder appendString:[self appendStringLength:[self encryptionStringForValue:4]]];
    INFO(@"8 appendStringLength(encryptionValue(4)):",statidBuilder);
    
    [statidBuilder appendString:[self encryptionStringForValue:[self valueForString:statidBuilder]]];
    INFO(@"9 encryptionStringForValue(valueForString(stringBuilder.toString())):",statidBuilder);
    
    NSString *statId = [self encryption:[self halfpartAndReverse:statidBuilder]];
    INFO(@"10 statId:encryption(halfpartAndReverse(stringBuilder.toString()))",statId);
    return statId;
}

@end


/**
 Common cryptography methods
 */
@implementation NSData (DTCrypto)

- (NSData *)encryptedDataUsingSHA256WithKey:(NSData *)key
{
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, [key bytes], [key length], [self bytes], [self length], cHMAC);
    
    return [NSData dataWithBytes:&cHMAC length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData *)encryptedDataUsingSHA1WithKey:(NSData *)key
{
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, [key bytes], [key length], [self bytes], [self length], cHMAC);
    
    return [NSData dataWithBytes:&cHMAC length:CC_SHA1_DIGEST_LENGTH];
}

- (NSData *)dataWithMD5Hash
{
    const char *cStr = [self bytes];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)[self length], digest );
    
    return [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

@end

