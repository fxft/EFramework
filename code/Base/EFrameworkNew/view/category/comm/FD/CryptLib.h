//
//  CryptLib.h
//

/*****************************************************************
 * CrossPlatform CryptLib
 *
 * <p>
 * This cross platform CryptLib uses AES 256 for encryption. This library can
 * be used for encryptoion and de-cryption of string on iOS, Android and Windows
 * platform.<br/>
 * Features: <br/>
 * 1. 256 bit AES encryption
 * 2. Random IV generation.
 * 3. Provision for SHA256 hashing of key.
 * </p>
 *
 * @since 1.0
 * @author navneet
 *****************************************************************/
// How to use :
// //  1. Encryption:

// NSString * _secret = @"This the sample text has to be encrypted"; // this is the text that you want to encrypt.

// NSString * _key = @"shared secret"; //secret key for encryption. To make encryption stronger, we will not use this key directly. We'll first hash the key next step and then use it.

// key = [[StringEncryption alloc] sha256:key length:32]; //this is very important, 32 bytes = 256 bit

// NSString * iv =   [[[[StringEncryption alloc] generateRandomIV:11]  base64EncodingWithLineLength:0] substringToIndex:16]; //Here we are generating random initialization vector (iv). Length of this vector = 16 bytes = 128 bits

// Now that we have input text, hashed key and random IV, we are all set for encryption:
// NSData * encryptedData = [[StringEncryption alloc] encrypt:[secret dataUsingEncoding:NSUTF8StringEncoding] key:key iv:iv];

// NSLog(@"encrypted data:: %@", [encryptedData  base64EncodingWithLineLength:0]); //print the encrypted text
// Encryption = [plainText + secretKey + randomIV] = Cyphertext

// // 2. Decryption
// for decryption, you will have to use the same IV and key which was used for encryption.

// encryptedData = [[StringEncryption alloc] decrypt:encryptedData  key:key iv:iv];
// NSString * decryptedText = [[NSString alloc] initWithData:encryptedData encoding:NSUTF8StringEncoding];
// NSLog(@"decrypted data:: %@", decryptedText); //print the decrypted text

// For base64EncodingWithLineLength refer - https://github.com/jdg/MGTwitterEngine/blob/master/NSData%2BBase64.m

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>


@interface StringEncryption : NSObject

-  (NSData *)encrypt:(NSData *)plainText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)decrypt:(NSData *)encryptedText key:(NSString *)key iv:(NSString *)iv;
-  (NSData *)generateRandomIV:(size_t)length;
-  (NSString *)md5:(NSString *) input;
-  (NSString*)sha256:(NSString *)key length:(NSInteger) length;

@end
