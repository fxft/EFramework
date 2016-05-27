//
//  NSData+DTCrypto.h
//  DTFoundation
//
//  Created by Stefan Gugarel on 10/3/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

/**
 Useful cryptography methods.
 */
#import <Foundation/Foundation.h>

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
