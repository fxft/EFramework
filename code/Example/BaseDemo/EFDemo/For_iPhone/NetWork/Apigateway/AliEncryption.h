//
//  Encryption.h
//  MadeInFXFT
//
//  Created by fxft on 16/5/26.
//  Copyright © 2016年 yc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*For Content-Type
 */
#define CONTENT_TYPE_BOUNDARY [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()]//每次获取都不同
#define CONTENT_TYPE_FORM(boundary) [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
#define CONTENT_TYPE_QUERY @"application/x-www-form-urlencoded; charset=utf-8"
#define CONTENT_TYPE_STREAM @"application/octet-stream; charset=utf-8"
#define CONTENT_TYPE_JSON @"application/json; charset=utf-8"
#define CONTENT_TYPE_XML @"application/xml; charset=utf-8"
#define CONTENT_TYPE_TEXT @"application/text; charset=utf-8"

/*For Http Header
 */
#define HTTP_HEADER_ACCEPT @"Accept"
#define HTTP_HEADER_CONTENT_MD5 @"Content-MD5"
#define HTTP_HEADER_CONTENT_TYPE @"Content-Type"
#define HTTP_HEADER_USER_AGENT @"User-Agent"
#define HTTP_HEADER_DATE @"Date"

#define X_CA_STAGE_TEST @"test"
#define X_CA_STAGE_RELEASE @"release"

/*For API Gateway
 */

#define X_CA_SIGNATURE  @"X-Ca-Signature"
#define X_CA_SIGNATURE_HEADERS @"X-Ca-Signature-Headers"
#define X_CA_TIMESTAMP  @"X-Ca-Timestamp"
#define X_CA_NONCE      @"X-Ca-Nonce"
#define X_CA_KEY        @"X-Ca-Key"
#define X_CA_STAGE      @"X-Ca-Stage"



@interface AliEncryption : NSObject
@property (nonatomic,copy) NSString *secretForApiGateway;

+(instancetype) sharedInstance;


/**
 *  signature for Api gateway
 *
 *  @param stringToSign +[Encryption prepareAPIGatewayForSignWithMethod:headers:param:path:signHeaderKey]
 *
 *  @return signature
 */

+ (NSString *)signature:(NSString*)stringToSign;

+ (NSString *)nonce;//for X-Ca-Nonce

+ (NSString *)timestamp;//for X-Ca-Timestamp

+ (NSString *)queryString:(NSDictionary*)paramDict;//for Post Body

/**
 *  根据Api网关的签名规则进行数据拼接
 *
 *  @param HTTPMethod    POST／GET
 *  @param Headers       标准Http头部＋API网关必选头部＋可选头部＋用户自定义头部
 *  @param param         接口参数
 *  @param path          接口路径“/”开头
 *  @param signHeaderKey 返回被签名的Key字符串
 *
 *  @return 待签名的字符串
 */
+ (NSString*)prepareAPIGatewayForSignWithMethod:(NSString*)HTTPMethod
                                        headers:(NSDictionary*)Headers
                                          param:(NSDictionary*)param
                                           path:(NSString *)path
                                  signHeaderKey:(NSString **)signHeaderKey;

@end



@interface NSString (URL)

- (NSString *)formatURLEnocde;

/**
 *  URLEncode
 */
- (NSString *)URLEncodedString;

/**
 *  URLDecode
 */
-(NSString *)URLDecodedString;

@end