//
//  HMHTTPRequestOperation.h
//  CarAssistant
//
//  Created by Eric on 14-3-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import "HMMacros.h"
#import "HMPrecompile.h"

#pragma mark -

#undef	DEFAULT_BLACKLIST_TIMEOUT
#define DEFAULT_BLACKLIST_TIMEOUT	(60.0f * 2.0f)	// 黑名单请求频率大于2分钟

#undef	DEFAULT_GET_TIMEOUT
#define DEFAULT_GET_TIMEOUT			(30.0f)			// 取图30秒超时

#undef	DEFAULT_POST_TIMEOUT
#define DEFAULT_POST_TIMEOUT		(30.0f)			// 发协议30秒超时

#undef	DEFAULT_PUT_TIMEOUT
#define DEFAULT_PUT_TIMEOUT			(30.0f)			// 上传30秒超时

#undef	DEFAULT_UPLOAD_TIMEOUT
#define DEFAULT_UPLOAD_TIMEOUT		(120.0f)		// 上传图片120秒超时

#define DEFAULT_PORTION_DOWNLOAD    @"downloadPortion"

extern NSString * AFDataCacheKeyFromURLRequest(NSURL *url);
extern NSString * AFGetHttpHeaderDefaultUserInfoWithUserId(NSString *userId);
extern NSString * descWithState(NSInteger sate);

@class HMHTTPRequestOperation;

typedef void (^HTTPProgressSendBlock)(HMHTTPRequestOperation *operation, NSUInteger sendBodyData);
typedef void (^HTTPProgressReceBlock)(HMHTTPRequestOperation *operation, NSUInteger receBodyData);
typedef void (^HTTPUploadDataBlock)(id <AFMultipartFormData> formData);
typedef void (^HTTPRequestBuildedBlock)(NSMutableURLRequest *request);
typedef NSURLRequest * (^HTTPRedirectResponseBlock)(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse);

typedef NS_ENUM(NSInteger, HTTPRequestType) {
    HTTPRequestType_Normal  = 0,
    HTTPRequestType_JSON    = 1,
    HTTPRequestType_PLIST   = 2,
};

typedef NS_ENUM(NSInteger, HTTPResponseType) {
    HTTPResponseType_Normal  = 0,
    HTTPResponseType_JSON    = 1,
    HTTPResponseType_PLIST   = 2,
    HTTPResponseType_IMAGE   = 3,
    HTTPResponseType_XML     = 4,
    HTTPResponseType_COMPOUND= 5,
};

@interface HMHTTPRequestOperation : AFHTTPRequestOperation

AS_INT( STATE_CREATED );
AS_INT( STATE_SENDING );
AS_INT( STATE_RECVING );
AS_INT( STATE_FAILED );
AS_INT( STATE_SUCCEED );
AS_INT( STATE_CANCELLED );
AS_INT( STATE_REDIRECTED );
AS_INT( STATE_PAUSE );
AS_INT( STATE_SUCCEEDOLD );

@property (nonatomic, HM_STRONG) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
@property (nonatomic) HTTPRequestType                   requestType;
@property (nonatomic) HTTPResponseType                  responseType;
@property (nonatomic, HM_STRONG) NSDictionary *			parameters;
@property (nonatomic) BOOL                              useCookiePersistence;

@property (nonatomic, copy) NSString *                  headUserInfo;
@property (nonatomic, copy) NSString *                  headUserAgent;

@property (nonatomic) BOOL                              useCache;/*使用缓存机制*/
@property (nonatomic) BOOL                              useFileCacheOnly;/*不使用内存缓存*/
@property (nonatomic) BOOL                              refreshCache;/*如果本地已缓存则覆盖*/
@property (nonatomic,readonly) BOOL                     isCache;/*获取的数据是否是本地缓存*/
@property (nonatomic, copy) NSString *                  cacheInBranch;/*资源缓存的目录*/
@property (nonatomic, copy) NSString *                  cachePath;/*资源缓存的位置*/
@property (nonatomic) BOOL                              refreshAndNoRemoveCache;/*是刷新但是不删除本地缓存资源,过期的除外*/

@property (nonatomic) NSTimeInterval                    cacheDuration;/*缓存过期间隔，目前只支持文件缓存*/

@property (nonatomic) NSInteger                         status;
@property (nonatomic) NSInteger                         statusCode;
@property (nonatomic, HM_STRONG) NSString *             statusDesc;
@property (nonatomic, copy) NSString *                  order;
@property (nonatomic, copy) NSString *                  tagString;
@property (nonatomic, copy) NSString *                  url;

@property (nonatomic,readonly)BOOL                      isBadURL;
@property (nonatomic)BOOL                               badURLCheckAllow;/*图片资源默认开启坏链监测*/

/*该参数用于 UPLOAD方式下 表单提交，其他方式请不要配置*/
@property (nonatomic, copy) HTTPUploadDataBlock         uploadDataBlock;
@property (nonatomic, copy) HTTPRequestBuildedBlock     requestBuildedBlock;
@property (nonatomic, copy) HTTPRedirectResponseBlock   redirectBlock;

@property (nonatomic, readonly) CGFloat					uploadPercent;
@property (nonatomic, readonly) long long				uploadBytes;
@property (nonatomic, readonly) long long				uploadTotalBytes;

@property (nonatomic, readonly) CGFloat					downloadPercent;
@property (nonatomic, readonly) long long				downloadBytes;
@property (nonatomic, readonly) long long				downloadTotalBytes;

@property (nonatomic,readonly) BOOL                     isResponseCompressed;

@property (nonatomic) NSTimeInterval                    timeOutInterval;
@property (nonatomic) BOOL                              timeOut;
@property (atomic, HM_STRONG) NSMutableArray *          responders;
@property (atomic, HM_STRONG) NSMutableDictionary *     requestHeaders;

@property (nonatomic, HM_STRONG) NSString *             errorDomain;
@property (nonatomic) NSInteger                         errorCode;
@property (nonatomic, HM_STRONG) NSString *             errorDesc;

@property (nonatomic, readonly) NSTimeInterval			timeCostPending;	// 排队等待耗时
@property (nonatomic, readonly) NSTimeInterval			timeCostOverDNS;	// 网络连接耗时（DNS）
@property (nonatomic, readonly) NSTimeInterval			timeCostRecving;	// 网络收包耗时
@property (nonatomic, readonly) NSTimeInterval			timeCostOverAir;	// 网络整体耗时

@property (nonatomic, readonly) BOOL					created;
@property (nonatomic, readonly) BOOL					sending;
@property (nonatomic, readonly) BOOL					recving;
@property (nonatomic, readonly) BOOL					failed;
@property (nonatomic, readonly) BOOL					succeed;
@property (nonatomic, readonly) BOOL					succeedOld;
@property (nonatomic, readonly) BOOL					beCancelled;
@property (nonatomic, readonly) BOOL					redirected;
@property (nonatomic, readonly) BOOL					paused;
@property (nonatomic, readonly) BOOL					sendProgressed;
@property (nonatomic, readonly) BOOL					recvProgressed;

@property (nonatomic) BOOL                     attentSendProgress;
@property (nonatomic) BOOL                     attentRecvProgress;
@property (nonatomic) BOOL                     shouldResume;

@property (nonatomic) BOOL                     autoLoad;//一个标示

/*生成一个待配置的链接*/
+ (instancetype)spawnForMethod:(NSString*)method
                     URLString:(NSString *)URLString
                         error:(NSError *__autoreleasing_type *)error;

/*如果新建了一个新的链接，需要重新设置completeBlock*/
-(instancetype)resumeOrNewIfIsfinished;

- (BOOL)hasResponder:(id)responder;
- (void)addResponder:(id)responder;
- (void)removeResponder:(id)responder;
- (void)removeAllResponders;

- (void)removeCached;

- (void)callResponders;
- (void)forwardResponder:(NSObject *)obj;

+ (void)setDefaultImageCachePath:(NSString*)imagePath;
+ (void)setDefaultUserAgentString:(NSString *)agent;

+ (NSData *)imageDataCachedWithURL:(NSURL *)url;
+ (NSData *)imageDataCachedWithURL:(NSURL *)url branch:(NSString*)branch;

+ (BOOL)imageDataCachedWithURL:(NSURL *)url block:(void(^)(NSData *))block;

+ (void)cachedImage:(id)image withURL:(NSURL *)url;

@end
