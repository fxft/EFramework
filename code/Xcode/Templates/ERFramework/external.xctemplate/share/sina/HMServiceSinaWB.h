//
//  HMServiceSinaWB.h
//  CarAssistant
//
//  Created by Eric on 14-4-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
//for wb+
#import <Foundation/Foundation.h>

typedef enum {
    SLTypeSinaAuthorize  = 0,        /**< sso授权   */
    SLTypeSinaWeibo = 1,        /**< 微博客户端      */
}SLShareType;

typedef enum {
    SLSendTypeReq  = 0,        /**< 请求    */
    SLSendTypeResp = 1,        /**< 应答      */
}SLSendType;

enum SLMediaType{
    SLMediaTypeImage  = 0,        /**< 分享图片    */
    SLMediaTypeMusic = 1,        /**< 分享音乐      */
    SLMediaTypeVideo = 2,        /**< 分享视屏       */
    SLMediaTypeWebpage  = 3,        /**< 分享页面    */
    SLMediaTypeText  = 7,        /**< 分享文本    */
};

@interface HMServiceSinaWB : NSObject

AS_SINGLETON( HMServiceSinaWB )

@property (nonatomic, readonly) BOOL							installed;

@property (nonatomic, HM_STRONG) NSString           *scheme;/*sina*/
@property (nonatomic, HM_STRONG) NSString           *redirectURI;
@property (nonatomic, HM_STRONG) NSString           *appSecret;

@property (nonatomic, assign)   SLShareType     shareType;
@property (nonatomic, assign)   SLSendType      sendType;

- (void)inviteFriend:(NSString *)desc uid:(NSString*)uid;
@end
