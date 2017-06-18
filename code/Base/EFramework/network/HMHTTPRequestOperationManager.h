//
//  HMHTTPRequestOperationManager.h
//  CarAssistant
//
//  Created by Eric on 14-2-25.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "HMMacros.h"
#import "HMPrecompile.h"
#import "HMHTTPRequestOperation.h"

#pragma mark -
@interface HMHTTPFlowManager : NSObject
@property(atomic,readonly) long long                     flowDownload;
@property(atomic,readonly) long long                     flowUpload;
@property(atomic,readonly) long long                     flowDownloadWWAN;
@property(atomic,readonly) long long                     flowUploadWWAN;
@property(nonatomic,HM_STRONG,readonly) NSDate          *fromDate;

- (void)clear;
- (void)stroe;
+ (instancetype)spwanTody;
@end

#pragma mark -

@interface HMHTTPRequestOperationManager : AFHTTPRequestOperationManager

@property(nonatomic,HM_STRONG,readonly) NSMutableArray *    requests;

@property (nonatomic,HM_STRONG) HMHTTPFlowManager*          flower;

@property(nonatomic) BOOL                                   useCookiePersistence;
@property (nonatomic) long long                    maxMemeryCache;
@property (nonatomic) BOOL                                  blackListEnable;	// 是否使用黑名单
@property (nonatomic) NSTimeInterval                        blackListTimeout;	// 黑名单超时
@property (nonatomic) NSUInteger                            blackListTrytime;//请求多少次无正确结果
@property (nonatomic, HM_STRONG) NSMutableDictionary *		blackList;
@property (nonatomic, copy) NSString * reachableDomain;

AS_SINGLETON(HMHTTPRequestOperationManager)
+ (instancetype)sharedImageInstance;//cached path "caches/images"

+ (instancetype)sharedInstance:(NSString*)key;

+ (void)setBaseUrl:(NSURL*)url;

- (int)checkResourceBroken:(NSString *)url;
- (void)blockURL:(NSString *)url;
- (void)unblockURL:(NSString *)url;

- (HMHTTPRequestOperation *)REQUESTForMethod:(NSString *)method
                                   URLString:(NSString *)URLString
                                  parameters:(NSDictionary *)parameters
                                   responder:(id)responder
                                     timeOut:(NSTimeInterval)seconds
                                    autoLoad:(BOOL)autoLoad;

- (void)startAsync:(HMHTTPRequestOperation *)operation;
#pragma mark - all class methods are for [HMHTTPRequestOperationManager sharedInstance]
#pragma mark for request
+ (void)cancelRequest:(HMHTTPRequestOperation *)request;
+ (void)cancelRequestByResponder:(id)responder;
+ (void)cancelAllRequests;
- (void)cancelRequest:(HMHTTPRequestOperation *)request;
- (void)cancelRequestByResponder:(id)responder;
- (void)cancelAllRequests;

#pragma mark for respnder
+ (void)disableResponder:(id)respnder;
+ (void)disableResponder:(id)respnder byStringUrl:(NSString *)url;
- (void)disableResponder:(id)respnder;
- (void)disableResponder:(id)respnder  byStringUrl:(NSString *)url;

+ (NSArray *)requests:(NSString *)url;
+ (NSArray *)requests:(NSString *)url byResponder:(id)responder;
- (NSArray *)requests:(NSString *)url;
- (NSArray *)requests:(NSString *)url byResponder:(id)responder;

#pragma mark for disable responders with all tagString
//you must mark the HMHTTPRequestOperation object tagString
+ (void)disableRespondersByTagString:(NSString *)tagString;
- (void)disableRespondersByTagString:(NSString *)tagString;

+ (void)disableRespondersByTagString:(NSString *)tagString responder:(id)responder;
- (void)disableRespondersByTagString:(NSString *)tagString responder:(id)responder;

+ (HMHTTPRequestOperation *)requestByResponse:(id)response;
+ (HMHTTPRequestOperation*)sendingForURLString:(NSString *)URLString addResponder:(id)responder;

- (HMHTTPRequestOperation *)requestByResponse:(id)response;
- (HMHTTPRequestOperation*)sendingForURLString:(NSString *)URLString addResponder:(id)responder;

#pragma mark - get post put upload delete

+ (HMHTTPRequestOperation *)GET_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)GET_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)POST_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

+ (HMHTTPRequestOperation *)POST_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)UPLOAD_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds constructingBodyWithBlock:(HTTPUploadDataBlock)block;

+ (HMHTTPRequestOperation *)UPLOAD_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds constructingBodyWithBlock:(HTTPUploadDataBlock)block;

+ (HMHTTPRequestOperation *)PUT_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)PUT_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

+ (HMHTTPRequestOperation *)DELETE_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)DELETE_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

+ (HMHTTPRequestOperation *)HEAD_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)HEAD_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

+ (HMHTTPRequestOperation *)PATCH_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)PATCH_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds;


@end

#pragma mark -

@interface NSObject (OperationManger)

//privte
- (BOOL)prehandleRequest:(HMHTTPRequestOperation *)request;
- (void)posthandleRequest:(HMHTTPRequestOperation *)request;
- (void)handleRequest:(HMHTTPRequestOperation *)request;

- (BOOL)isNetworkWifi;
- (BOOL)isNetworkWWAN;
- (BOOL)isNetworkNotReachable;

/*注意:以下三个方法针对 opertaion与responder一一对应才能安全使用，
 针对多对一的情况，ownRequest返回可能不是想要的对象*/
- (HMHTTPRequestOperation *)ownRequest;
- (id)responseData;
- (void)cancelRequest;

- (void)startAsync;
/**
 *  当某一类对象使用了网络加载功能，当释放时请调用该方法，防止也指针异常
 *
 *   tagString 对象的的属性值
 */
- (void)disableHttpRespondersByTagString:(NSString *)tagString;

- (HMHTTPRequestOperation*)sendingForURLString:(NSString *)URLString;
- (HMHTTPRequestOperation*)attemptingForURLString:(NSString *)URLString;

#pragma mark -
- (HMHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;
//block can no be nil
- (HMHTTPRequestOperation *)UPLOAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block;

- (HMHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)DOWNLOAD:(NSString *)URLString
                          parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
