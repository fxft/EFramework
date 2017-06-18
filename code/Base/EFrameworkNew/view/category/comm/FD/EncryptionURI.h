//
//  EncryptionURI.h
//  EFMWKLib
//
//  Created by mac on 16/12/21.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "HMMacros.h"

HM_EXTERN NSString * HMQueryStringFromParameters(NSDictionary *parameters,BOOL encode);
HM_EXTERN NSString * HMPercentEscapedStringFromString(NSString *string);
HM_EXTERN uint64_t HMMurmurHash64A ( const void * key, unsigned long len, unsigned int seed );

@interface EncryptionURI : NSObject

+ (NSString *)encryption:(NSString*)str;
+ (NSString *)encryptionStringForValue:(long long)value;
+ (long long)valueForString:(NSString*)str;
+ (NSString *)appendStringLength:(NSString*)str;
+ (NSString*)halfpartAndReverse:(NSString*)str;
+ (NSString *)reverse:(NSString*)str;
/*
 加密字符
 核心采用 HMMurmurHash64A 加密
 
 */
//实例应用，
//url带路径，param为get方式拼接
+ (NSString *)statIdWithUrl:(NSString*)url para:(NSDictionary *)param encrKey:(NSString*)key encrValue:(unsigned int)value;
@end


@interface NSData (DTCrypto)

/**-------------------------------------------------------------------------------------
 @name Generating HMAC Hashes
 ---------------------------------------------------------------------------------------
 */

/**
 Generates a HMAC from the receiver using the SHA1 algorithm
 @param key The encryption key
 @returns The encrypted hash
 */
- (NSData *)encryptedDataUsingSHA1WithKey:(NSData *)key;

/**-------------------------------------------------------------------------------------
 @name Generating HMAC Hashes
 ---------------------------------------------------------------------------------------
 */

/**
 Generates a HMAC from the receiver using the SHA256 algorithm
 @param key The encryption key
 @returns The encrypted hash
 */
- (NSData *)encryptedDataUsingSHA256WithKey:(NSData *)key;


/**-------------------------------------------------------------------------------------
 @name Digest Hashes
 ---------------------------------------------------------------------------------------
 */

/**
 Generate an md5 checksum from the receiver
 @returns An `NSData` containing the md5 digest.
 */
-(NSData *)dataWithMD5Hash;

@end
