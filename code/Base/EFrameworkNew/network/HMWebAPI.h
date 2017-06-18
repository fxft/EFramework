//
//  HMWebAPI.h
//  CarAssistant
//
//  Created by Eric on 14-4-19.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMService.h"
#import "HMDialogue.h"
#import "HMNetWork.h"


#define ON_WebAPI(dlg) ON_SERVICE3(HMWebAPI, WebAPI, dlg)
/**
 *  webapi 服务接口回调
 */
@protocol ON_WebAPI_handle <NSObject>

ON_WebAPI( signal);

@end
/**
 *  与服务器接口通讯类
 */
@interface HMWebAPI : HMService

AS_SERVICE_AUTOSHARE
AS_STATIC_PROPERTY( userinfo )
AS_STATIC_PROPERTY( params )
AS_STATIC_PROPERTY( headers )
AS_STATIC_PROPERTY( command )
AS_STATIC_PROPERTY( name )
AS_STATIC_PROPERTY( method )
AS_STATIC_PROPERTY( uploadBlock )
AS_STATIC_PROPERTY( cacheParams )
AS_STATIC_PROPERTY( urlParams )
AS_STATIC_PROPERTY( configParams )

/**
 value for method key
 */
AS_STATIC_PROPERTY( methodMock )
AS_STATIC_PROPERTY( methodMockTimeOut )
AS_STATIC_PROPERTY( methodMockFail )
AS_STATIC_PROPERTY( methodMockMiss )
AS_STATIC_PROPERTY( methodMockSuccess )
/**
 key for cacheParams dictionary
 */
AS_STATIC_PROPERTY( cacheDuration )//缓存超时持续时间－内存与文件缓存
AS_STATIC_PROPERTY( cacheLast )
/**
 key for urlParams dictionary
 */
AS_STATIC_PROPERTY( urlEncoding )//url编码设置
AS_STATIC_PROPERTY( responseEncoding )
AS_STATIC_PROPERTY( responseJs2oc )

AS_STATIC_PROPERTY( urlResponseType )

AS_STATIC_PROPERTY( urlRequestType )

/**
 key for configParams dictonary
 */
AS_STATIC_PROPERTY( process )


AS_SERVICE(WebAPI)
/**
 *  通用服务器地址，基础url
 */
@property (nonatomic, HM_STRONG) NSURL *                baseUrl;
/**
 *  接口是否支持cookie
 */
@property (nonatomic) BOOL                              useCookiePersistence;
/**
 *  部分服务器的接口分布到域名相同的系统，需要验证同一个cookie时 useCookieFilterHost 设为 true
 */
@property (nonatomic, HM_STRONG) NSMutableDictionary *  cookiesForHost;
@property (nonatomic) BOOL                              useCookieFilterHost;
/**
 *  是否开启http本地模拟数据模式，需要在model里面 实现 valueForUndefinedKey，请查看demo
 */
@property (nonatomic) BOOL                              enableMock;
@property (nonatomic) BOOL                              enableJson2Object;

@property (nonatomic) NSStringEncoding                  defaultEncoding;
@end

@interface HMDialogue (WebAPI)<HMNetWorkResponseHandler>

/**
 HMDialogue 暂时保存的 使用者信息
 */
- (HMDialogue *) setWebUserinfo:(id)userinfo;
- ( id ) webUserinfo;

/**
 url需要传递的参数，uri的方式，get时会添加到url，post时会以json字符串上传
 */
- (HMDialogue *) setWebParams:(NSDictionary*)params;
- (NSDictionary *) webParams;
/**
 url需要传递的参数，uri的方式，get时会添加到url，post时会以json字符串上传
 */
- (HMDialogue *) setWebHeaders:(NSDictionary*)headers;
- (NSDictionary *) webHeaders;
/**
 url的/?之前的命令字
 */
- (HMDialogue *) setWebCommand:(NSString*)command;
/**
 mime方式，“GET” “POST” “DOWNLOAD” “UPLOAD”
 */
- (HMDialogue *) setWebMethod:(NSString*)method;
/**
 上传数据，上传图片多数据，将按name:value的方式添加
 */
- (HMDialogue *) setWebUploadBlock:(void (^)(id <AFMultipartFormData> formData))block;
/**
 上传NSData数据,针对一些服务端需要直接上传字符串数据时使用
 */
- (HMDialogue *) setWebData:(NSData*)data;
/**
 设置模拟数据模式
 */
- (HMDialogue *) setWebHttpMock:(NSString*)mock;
/**
 设置接口名称，默认为setWebCommand的值
 */
- (HMDialogue *) setWebName:(NSString*)name;
/**
 设置url response 类型
 */
- (HMDialogue *) setWebUrlResponseType:(HTTPResponseType)type;
/**
 设置url request 类型
 */
- (HMDialogue *) setWebUrlRequestType:(HTTPRequestType)type;
/**
 设置url编码方式
 */
- (HMDialogue *) setWebUrlEncoding:(NSStringEncoding)encoding;
/**
 设置response编码方式
 */
- (HMDialogue *) setWebResponseEncoding:(NSStringEncoding)encoding;

/**
 设置response是否直接转换成json对象
 */
- (HMDialogue *) setWebEnableJson2Object:(BOOL)js2oc;

/**
 缓存数据的过期时间
 */
- (HMDialogue *) setWebCacheDuration:(NSTimeInterval)cacheDuration;
/**
 是刷新但是不删除本地缓存资源,过期的除外,需要设置 Duration
 */
- (HMDialogue *) setWebDataFromNetwrokElseCache;

/**
  如果本地存在直接区本地，否则去网络获取,需要设置 Duration
 */
- (HMDialogue *) setWebDataFromCacheElseNetwrok;

/**
 当你允许数据进行缓存时，有些数据经过解析后需要删除缓存时的方法,请在 webApi listener（successed/failed）中调用
 */
- (void)removeCached;
/**
 监听加载过程
 */
- (HMDialogue *) setWebListenProcess;

/**
 重定向
 */
//- (HMDialogue *) setWebRedirectBlock:(HTTPRedirectResponseBlock)block;

@end

@interface NSObject (WebAPI)
/**
 与服务器请求接口
 @params command:url的命令字，这里也是webApi的Name
 */
- (HMDialogue *)webApiWithCommand:(NSString *)command;
- (HMDialogue *)webApiWithCommand:(NSString*)command timeout:(NSTimeInterval)seconds;
- (HMDialogue *)webApiWithCommand:(NSString *)command name:(NSString *)name timeout:(NSTimeInterval)seconds;
/**
 判断是否正在发送，如果正在发送就不执行
 @params command:url的命令字，这里也是webApi的Name
 */
- (HMDialogue *)webApiUniqueCommand:(NSString*)command;
- (HMDialogue *)webApiUniqueCommand:(NSString*)command timeout:(NSTimeInterval)seconds;
- (HMDialogue *)webApiUniqueCommand:(NSString*)command name:(NSString*)name timeout:(NSTimeInterval)seconds;

- (void)webApiCancelName:(NSString*)name;
- (void)webApiCancelAndDisableName:(NSString*)name;

/*注意:以下三个方法针对 opertaion与responder一一对应才能安全使用，
 针对多对一的情况，ownRequest返回可能不是想要的对象*/
- (HMHTTPRequestOperation *)ownRequest;

@end


