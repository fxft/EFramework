//
//  HMShareService.h
//  CarAssistant
//
//  Created by Eric on 14-4-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
/*
 plist:
 eg.
 <dict>
 <key>className</key>
 <string>HMServiceSinaWB</string>
 <key>enable</key>
 <true/>
 <key>appid</key>
 <string>4259358399</string>
 <key>appSecret</key>
 <string>324ead9789eb4da35ada10fd5e29a4c1</string>
 <key>redirectURI</key>
 <string>http://www.on4s.net</string>
 
 className:微信 HMServiceWeChat  新浪微博 HMServiceSinaWB
 
 </dict>
 
 */
#import <Foundation/Foundation.h>

typedef enum {
    HMShareTypeWeChat  = 0,        /**<  微信    */
    HMShareTypeSinaWeibo  = 1,        /**< 新浪微博    */
    HMShareTypeTencentWeibo  = 2,        /**< 腾讯微博    */
    HMShareTypeSMS  = 3,        /**< 信息   */
    HMShareTypeEmail  = 4,        /**< 信息   */

}HMShareType;

typedef enum {
    /*wechat*/
    HMShareSubType_WXSession  = 0,        /**< 聊天界面    */
    HMShareSubType_WXTimeline = 1,        /**< 朋友圈      */
    HMShareSubType_WXFavorite = 2,        /**< 收藏       */
    
    /*sinaWeibo*/
    HMShareSubType_SLSinaWeibo = 1,        /**< 微博客户端      */
    
}HMShareSubType;

typedef enum {
    /*wechat*/
    HMShareSendType_WXReq  = 0,        /**< 请求    */
    HMShareSendType_WXResp = 1,        /**< 应答      */
    
    /*sinaWeibo*/
    HMShareSendType_SLReq  = 0,        /**< 请求    */
    HMShareSendType_SLResp = 1,        /**< 应答      */
    
}HMShareSendType;

typedef enum {
    /*wechat*/
    HMShareMediaType_WXImage  = 0,        /**< 分享图片    */
    HMShareMediaType_WXMusic = 1,        /**< 分享音乐      */
    HMShareMediaType_WXVideo = 2,        /**< 分享视屏       */
    HMShareMediaType_WXWebpage  = 3,        /**< 分享页面    */
    HMShareMediaType_WXEmoticon = 4,        /**< 分享表情，jpg,png,gif等      */
    HMShareMediaType_WXFile = 5,        /**< 分享文件       */
    HMShareMediaType_WXAppExtend  = 6,        /**< 微信app扩展 NSData,其他分享均采用url方式  */
    HMShareMediaType_WXText  = 7,        /**< 分享文本    */
    
    /*sinaWeibo*/
    HMShareMediaType_SLImage  = 0,        /**< 分享图片    */
    HMShareMediaType_SLMusic = 1,        /**< 分享音乐      */
    HMShareMediaType_SLVideo = 2,        /**< 分享视屏       */
    HMShareMediaType_SLWebpage  = 3,        /**< 分享页面    */
    HMShareMediaType_SLText  = 7,        /**< 分享文本    */
    
    /*tencentWeibo*/
    HMShareMediaType_TCImage  = 0,        /**< 分享图片    */
    HMShareMediaType_TCMusic = 1,        /**< 分享音乐      */
    HMShareMediaType_TCVideo = 2,        /**< 分享视屏       */
    HMShareMediaType_TCWebpage  = 3,        /**< 分享页面    */
    HMShareMediaType_TCText  = 7,        /**< 分享文本    */
    
    HMMediaTypeReplenish  = 100,        /**< 自定义  腾讯微博  */
    
}HMShareMediaType;


typedef enum
{
	HMPublishContentStateBegan = 0, /**< 开始 */
	HMPublishContentStateSuccess = 1, /**< 成功 */
	HMPublishContentStateFail = 2, /**< 失败 */
	HMPublishContentStateCancel = 3 /**< 取消 */
}
HMPublishContentState;

typedef enum {
    
    HMAuthOK            = 1,   /**< 授权成功    */
    HMSuccess           = 0,    /**< 成功    */
    HMErrCodeCommon     = -1,   /**< 普通错误类型    */
    HMErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
    HMErrCodeSentFail   = -3,   /**< 发送失败    */
    HMErrCodeAuthDeny   = -4,   /**< 授权失败    */
    HMErrCodeUnsupport  = -5,   /**< 不支持    */
    HMErrCodeUninstalled  = -101,   /**< 没安装    */
}HMErrCode;

/**
 *	@brief	分享内容事件处理器
 *
 *  @param  type    平台类型
 *  @param  state  发布内容状态
 *  @param  statusInfo  分享信息
 *  @param  error   分享内容失败的错误信息
 *  @param  end     分享完毕标志，对于单个平台分享此值为YES，对于多个分享平台此值在最后一个平台分享完毕后为YES。
 */
typedef void(^HMPublishContentEventHandler) (HMShareType type, HMPublishContentState state, id statusInfo, HMErrCode errorCode);

#pragma mark -

@interface HMShareServiceResult : NSObject

@property (nonatomic, assign) HMShareType                   type;
@property (nonatomic, assign) HMPublishContentState         state;
@property (nonatomic, HM_STRONG) id                         statusInfo;
@property (nonatomic, assign) HMErrCode                errorCode;

+ (instancetype)spawnWith:(HMShareType)shareType state:(HMPublishContentState)contentState statusInfo:(id)info errorCode:(HMErrCode)code;

@end

#pragma mark -

@interface HMShareItemObject : NSObject

@property (nonatomic, HM_STRONG) NSString           *title;
@property (nonatomic, HM_STRONG) NSString           *description;

@property (nonatomic, HM_STRONG) id                 thumb;/*url/image/data*/

@property (nonatomic, HM_STRONG) id                 media;/*url/image/data*/
@property (nonatomic, assign) HMShareMediaType      mediaType;
@property (nonatomic, assign) HMShareSubType        subType;
@property (nonatomic, assign) HMShareSendType       sendType;
@property (nonatomic, assign) HMShareType           shareType;

@property (nonatomic, HM_STRONG) NSString           *appid;
@property (nonatomic, HM_STRONG) NSString           *scheme;/*sina*/
@property (nonatomic, HM_STRONG) NSString           *redirectURI;
@property (nonatomic, HM_STRONG) NSString           *appSecret;

@property (nonatomic , HM_WEAK) UIViewController *  rootController;
/* [replenish valueForKey:@"apiName"]
 [replenish valueForKey:@"params"];*/
@property (nonatomic, HM_STRONG) id                 replensih;

+ (instancetype)spawn;

@end

#pragma mark -

@protocol HMShareServiceProtocol <NSObject>

+ (void)registerApp:(NSString *)appid;
- (void)shareBody:(HMShareItemObject*)body;

@optional
- (void)logout;

@end

#pragma mark -

@interface HMShareService : NSObject
@property (nonatomic, copy) HMPublishContentEventHandler result;

AS_SINGLETON(HMShareService)
AS_NOTIFICATION(HMShareServiceRespone);
- (UIWindow*)window;
+ (void)presentController:(UIViewController*)c;
+ (void)dismiss;

+ (void)share:(HMShareItemObject*)item;
+ (void)share:(HMShareType)shareType shareBody:(HMShareItemObject*)item;
+ (void)shareApp:(HMShareType)shareType description:(NSString*)description;
+ (void)shareApp:(HMShareType)shareType thumb:(UIImage*)thumb url:(NSString*)url description:(NSString *)description;

@end
