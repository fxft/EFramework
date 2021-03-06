//
//  NSData+DTCrypto.m
//  DTFoundation
//
//  Created by Stefan Gugarel on 10/3/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "NSData+DTCrypto.h"
#include <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

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
