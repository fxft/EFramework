//
//  HMNetWork.h
//  CarAssistant
//
//  Created by Eric on 14-3-4.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking.h>


@interface HMHTTPFlowManager : NSObject
AS_SINGLETON(HMHTTPFlowManager)
@property(atomic,readonly) long long                     flowDownload;
@property(atomic,readonly) long long                     flowUpload;
@property(atomic,readonly) long long                     flowDownloadWWAN;
@property(atomic,readonly) long long                     flowUploadWWAN;
@property(nonatomic,HM_STRONG,readonly) NSDate          *fromDate;

- (void)clear;
- (void)stroe;

@end


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

typedef NS_ENUM(NSInteger, HTTPRequestPrioritization) {
    HTTPRequestPrioritizationFIFO,
    HTTPRequestPrioritizationLIFO
};

@protocol HMNetWorkResponseHandler <NSObject>

- (void)taskSuccess:(NSURLSessionDataTask*)task request:(NSURLRequest*)resuest response:(NSHTTPURLResponse *)response responseObject:(id)responseObject;

- (void)taskFailure:(NSURLSessionDataTask*)task request:(NSURLRequest*)resuest response:(NSHTTPURLResponse *)response error:(NSError*)error;

- (void)taskProgressSend:(NSURLSessionDataTask*)task request:(NSURLRequest*)resuest response:(NSHTTPURLResponse *)response countOfBytesSend:(int64_t) countOfBytesSend countOfBytesExpectedToSend:(int64_t) countOfBytesExpectedToSend;

- (void)taskProgressReceived:(NSURLSessionDataTask*)task request:(NSURLRequest*)resuest response:(NSHTTPURLResponse *)response countOfBytesReceived:(int64_t) countOfBytesReceived countOfBytesExpectedToReceived:(int64_t) countOfBytesExpectedToReceived;

@end

@interface HMHTTPResponseHandler : NSObject
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic,HM_WEAK) id<HMNetWorkResponseHandler> responser;
@property (nonatomic,HM_WEAK) NSURLSessionDataTask *task;
@property (nonatomic, copy) void (^successBlock)(NSURLRequest*, NSHTTPURLResponse*, id);
@property (nonatomic, copy) void (^failureBlock)(NSURLRequest*, NSHTTPURLResponse*, NSError*);
@property (nonatomic, copy) void (^sendProgressBlock)(NSURLRequest*, NSHTTPURLResponse*,int64_t countOfBytesSend,int64_t countOfBytesExpectedToSend);
@property (nonatomic, copy) void (^receiveProgressBlock)(NSURLRequest*, NSHTTPURLResponse*,int64_t countOfBytesReceived,int64_t countOfBytesExpectedToReceive);


- (void)setProgressWithUploadProgressOfTask:(NSURLSessionDataTask *)task;
- (void)setProgressWithDownloadProgressOfTask:(NSURLSessionDataTask *)task;

@end

@interface HMHTTPRequestOperation : NSObject
@property (nonatomic, strong) NSString *URLIdentifier;
@property (nonatomic, strong) NSUUID *identifier;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSMutableArray <HMHTTPResponseHandler*> *responseHandlers;
@property (nonatomic,strong) NSString * tagString;
@end

@interface NSURLSessionTask (NetWork)
@property (nonatomic,readonly) CGFloat uploadPercent;
@property (nonatomic,readonly) CGFloat downloadPercent;
@property (readonly, nonatomic, strong) id responseObject;


@end

@interface HMNetWork : NSObject

/**
 The shared default instance of `HMNetWork` initialized with default values.
 */
AS_SINGLETON(HMNetWork)

/**
 The `AFHTTPSessionManager` used to download images. By default, this is configured with an `AFImageResponseSerializer`, and a shared `NSURLCache` for all image downloads.
 */
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
/**
 Defines the order prioritization of incoming download requests being inserted into the queue. `HTTPRequestPrioritizationFIFO` by default.
 */
@property (nonatomic, assign) HTTPRequestPrioritization requestPrioritizaton;


@property (nonatomic) HTTPRequestType                   requestType;
@property (nonatomic) HTTPResponseType                  responseType;

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration;

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration;

- (instancetype)initWithSessionManager:(AFHTTPSessionManager *)sessionManager
                downloadPrioritization:(HTTPRequestPrioritization)requestPrioritizaton
                maximumActiveDownloads:(NSInteger)maximumActiveDownloads;

- (HMHTTPRequestOperation*)operationForResponser:(id)responser;

- (NSMutableURLRequest *)taskRequestMethod:(NSString *)method
                                 urlString:(NSString *)URLString
                                parameters:(id)parameters
                 constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                     error:(NSError *__autoreleasing *)error;

- (HMHTTPRequestOperation *)taskMethod:(NSString *)method
                             urlString:(NSString *)URLString
                            parameters:(id)parameters
                             responser:(id)responser
             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                               success:(void (^)(NSURLRequest * _request, NSHTTPURLResponse  * _response, id  _responseObject))success
                     sendProgressBlock:(void (^)(NSURLRequest * _request, NSHTTPURLResponse * _response,int64_t countOfBytesSend,int64_t countOfBytesExpectedToSend))sendProgress
                  receiveProgressBlock:(void (^)(NSURLRequest * _request, NSHTTPURLResponse * _response,int64_t countOfBytesReceived,int64_t countOfBytesExpectedToReceive))receiveProgress
                               failure:(void (^)(NSURLRequest * _request, NSHTTPURLResponse * _response, NSError * _error))failure
                               timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)taskRequest:(NSURLRequest *)request
                              responser:(id)responser
                                success:(void (^)(NSURLRequest * _request, NSHTTPURLResponse  * _response, id  _responseObject))success
                      sendProgressBlock:(void (^)(NSURLRequest * _request, NSHTTPURLResponse * _response,int64_t countOfBytesSend,int64_t countOfBytesExpectedToSend))sendProgress
                   receiveProgressBlock:(void (^)(NSURLRequest * _request, NSHTTPURLResponse * _response,int64_t countOfBytesReceived,int64_t countOfBytesExpectedToReceive))receiveProgress
                                failure:(void (^)(NSURLRequest * _request, NSHTTPURLResponse * _response, NSError * _error))failure
                                timeOut:(NSTimeInterval)seconds;
@end


@interface NSObject (OperationManger)

/**
 *  当某一类对象使用了网络加载功能，当释放时请调用该方法，防止也指针异常
 *
 *  @param tagString 对象的的属性值
 */
//- (void)disableHttpRespondersByTagString:(NSString *)tagString;

//- (HMHTTPRequestOperation*)sendingForURLString:(NSString *)URLString;
//- (HMHTTPRequestOperation*)attemptingForURLString:(NSString *)URLString;

#pragma mark -
- (HMHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;
//block can no be nil
- (HMHTTPRequestOperation *)UPLOAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block;

- (HMHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)DOWNLOAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;


- (HMHTTPRequestOperation *)GET:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)POST:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)second;

//block can no be nil
- (HMHTTPRequestOperation *)UPLOAD:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block;

- (HMHTTPRequestOperation *)PUT:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)DELETE:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)HEAD:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)second;

- (HMHTTPRequestOperation *)PATCH:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;

- (HMHTTPRequestOperation *)DOWNLOAD:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds;
@end
