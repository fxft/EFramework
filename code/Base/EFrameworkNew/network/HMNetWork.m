//
//  HMNetWork.m
//  CarAssistant
//
//  Created by Eric on 14-3-4.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMNetWork.h"


@interface HMHTTPFlowManager ()<NSCoding>
@property(atomic,readwrite) long long flowDownload;
@property(atomic,readwrite) long long flowUpload;
@property(atomic,readwrite) long long flowDownloadWWAN;
@property(atomic,readwrite) long long flowUploadWWAN;
@property(nonatomic,HM_STRONG) NSDate *fromDate;

@end

@implementation HMHTTPFlowManager

@synthesize flowDownload;
@synthesize flowUpload;
@synthesize flowDownloadWWAN;
@synthesize flowUploadWWAN;
@synthesize fromDate;

- (HMHTTPFlowManager *)sharedInstance
{
    return [HMHTTPFlowManager sharedInstance];
}
+ (HMHTTPFlowManager *)sharedInstance
{
    static dispatch_once_t once;
    static HMHTTPFlowManager * __singleton__;
    dispatch_once( &once, ^{
        __singleton__ = [HMHTTPFlowManager restoreWithArchiver:@"HTTPFlow"];
        if (__singleton__==nil) {
            __singleton__ = [[HMHTTPFlowManager alloc]init];
        }
        __singleton__.fromDate = [NSDate date];
    } );
    return __singleton__;
}
+ (void)load
{
    [self sharedInstance];
}

- (void)dealloc
{
    self.fromDate = nil;
    HM_SUPER_DEALLOC();
}

- (void)clear{
    self.flowDownload = 0;
    self.flowUpload = 0;
    self.flowDownloadWWAN = 0;
    self.flowUploadWWAN = 0;
    self.fromDate = [NSDate date];
}

- (void)stroe{
    [self saveWithArchiver:@"HTTPFlow"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.flowDownload = [[decoder decodeObjectForKey:NSStringFromSelector(@selector(flowDownload))] longLongValue];
    self.flowUpload = [[decoder decodeObjectForKey:NSStringFromSelector(@selector(flowUpload))] longLongValue];
    self.flowDownloadWWAN = [[decoder decodeObjectForKey:NSStringFromSelector(@selector(flowDownloadWWAN))] longLongValue];
    self.flowUploadWWAN = [[decoder decodeObjectForKey:NSStringFromSelector(@selector(flowUploadWWAN))] longLongValue];
    self.fromDate = [decoder decodeObjectForKey:NSStringFromSelector(@selector(fromDate))];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:@(self.flowDownload) forKey:NSStringFromSelector(@selector(flowDownload))];
    [coder encodeObject:@(self.flowUpload) forKey:NSStringFromSelector(@selector(flowUpload))];
    [coder encodeObject:@(self.flowDownloadWWAN) forKey:NSStringFromSelector(@selector(flowDownloadWWAN))];
    [coder encodeObject:@(self.flowUploadWWAN) forKey:NSStringFromSelector(@selector(flowUploadWWAN))];
    [coder encodeObject:self.fromDate forKey:NSStringFromSelector(@selector(fromDate))];
}


@end


static void * HMTaskCountOfBytesSentContext = &HMTaskCountOfBytesSentContext;
static void * HMTaskCountOfBytesReceivedContext = &HMTaskCountOfBytesReceivedContext;


@implementation HMHTTPResponseHandler{
    
    BOOL attentRecvProgress;
    BOOL attentSendProgress;
}

- (instancetype)initWithUUID:(NSUUID *)uuid
                        task:(NSURLSessionDataTask *)task
                     success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, id responseObject))success
           sendProgressBlock:(nullable void (^)(NSURLRequest*, NSHTTPURLResponse*,int64_t countOfBytesSend,int64_t countOfBytesExpectedToSend))sendProgress
        receiveProgressBlock:(nullable void (^)(NSURLRequest*, NSHTTPURLResponse*,int64_t countOfBytesReceived,int64_t countOfBytesExpectedToReceive))receiveProgress
                     failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure {
    
    if (self = [self init]) {
        self.uuid = uuid;
        self.successBlock = success;
        self.failureBlock = failure;
        self.sendProgressBlock = sendProgress;
        self.receiveProgressBlock = receiveProgress;
        self.task = task;
        if (sendProgress) {
            [self setProgressWithUploadProgressOfTask:task];
        }
        if (receiveProgress) {
            [self setProgressWithDownloadProgressOfTask:task];
        }
    }
    return self;
}
- (void)setProgressWithUploadProgressOfTask:(NSURLSessionDataTask *)task
{
    if (attentSendProgress) {
        return;
    }
    attentSendProgress = YES;
    [task addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptions)0 context:HMTaskCountOfBytesSentContext];
    [task addObserver:self forKeyPath:@"countOfBytesSent" options:(NSKeyValueObservingOptions)0 context:HMTaskCountOfBytesSentContext];
    
}

- (void)setProgressWithDownloadProgressOfTask:(NSURLSessionDataTask *)task
{
    if (attentRecvProgress) {
        return;
    }
    attentRecvProgress = YES;
    [task addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptions)0 context:HMTaskCountOfBytesReceivedContext];
    [task addObserver:self forKeyPath:@"countOfBytesReceived" options:(NSKeyValueObservingOptions)0 context:HMTaskCountOfBytesReceivedContext];
    
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(__unused NSDictionary *)change
                       context:(void *)context
{
    if (context == HMTaskCountOfBytesSentContext || context == HMTaskCountOfBytesReceivedContext) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesSent))]) {
            if ([object countOfBytesExpectedToSend] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.sendProgressBlock) {
                        self.sendProgressBlock([(NSURLSessionDataTask*)object currentRequest],(NSHTTPURLResponse*)[(NSURLSessionDataTask*)object response],[object countOfBytesSent],[object countOfBytesExpectedToSend]);
                    }else if ([self.responser respondsToSelector:@selector(taskProgressSend:request:response:countOfBytesSend:countOfBytesExpectedToSend:)]){
                        [self.responser taskProgressSend:object request:[(NSURLSessionDataTask*)object currentRequest] response:(NSHTTPURLResponse*)[(NSURLSessionDataTask*)object response] countOfBytesSend:[object countOfBytesSent] countOfBytesExpectedToSend:[object countOfBytesExpectedToSend]];
                    }
                    
                });
            }
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            if ([object countOfBytesExpectedToReceive] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.receiveProgressBlock) {
                        self.receiveProgressBlock([(NSURLSessionDataTask*)object currentRequest],(NSHTTPURLResponse*)[(NSURLSessionDataTask*)object response],[object countOfBytesReceived],[object countOfBytesExpectedToReceive]);
                    }
                    else if ([self.responser respondsToSelector:@selector(taskProgressReceived:request:response:countOfBytesReceived:countOfBytesExpectedToReceived:)]){
                        [self.responser taskProgressReceived:object request:[(NSURLSessionDataTask*)object currentRequest] response:(NSHTTPURLResponse*)[(NSURLSessionDataTask*)object response] countOfBytesReceived:[object countOfBytesReceived] countOfBytesExpectedToReceived:[object countOfBytesExpectedToReceive]];
                    }
                });
            }
        }
        
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
            if ([(NSURLSessionTask *)object state] == NSURLSessionTaskStateCompleted) {
                @try {
                    [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
                    
                    if (context == HMTaskCountOfBytesSentContext) {
                        [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))];
                        attentSendProgress = NO;
                    }
                    
                    if (context == HMTaskCountOfBytesReceivedContext) {
                        [object removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))];
                        attentRecvProgress = NO;
                    }
                }
                @catch (NSException * __unused exception) {}
            }
        }
    }
}
- (NSString *)description {
    return [NSString stringWithFormat: @"<HMHTTPResponseHandler>UUID: %@", [self.uuid UUIDString]];
}

@end


@implementation HMHTTPRequestOperation

- (instancetype)initWithURLIdentifier:(NSString *)URLIdentifier identifier:(NSUUID *)identifier task:(NSURLSessionDataTask *)task {
    if (self = [self init]) {
        self.URLIdentifier = URLIdentifier;
        self.task = task;
        self.identifier = identifier;
        self.responseHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addResponseHandler:(HMHTTPResponseHandler*)handler {
    [self.responseHandlers addObject:handler];
}

- (void)removeResponseHandler:(HMHTTPResponseHandler*)handler {
    [self.responseHandlers removeObject:handler];
}

@end

@implementation NSURLSessionTask (NetWork)

@dynamic uploadPercent;
@dynamic downloadPercent;
- (CGFloat)uploadPercent{
    long long bytes1 = self.countOfBytesSent;
    long long bytes2 = self.countOfBytesExpectedToSend;
    
    return bytes2 ? ((CGFloat)bytes1 / (CGFloat)bytes2) : 0.0f;
}
- (CGFloat)downloadPercent{
    long long bytes1 = self.countOfBytesReceived;
    long long bytes2 = self.countOfBytesExpectedToReceive;
    
    return bytes2 ? ((CGFloat)bytes1 / (CGFloat)bytes2) : 0.0f;
}
- (id)responseObject {
    return (id)objc_getAssociatedObject(self, @selector(responseObject));
}

- (void)setResponseObject:(id)responseObject {
    objc_setAssociatedObject(self, @selector(responseObject), responseObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@interface HMNetWork ()

@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;
@property (nonatomic, strong) dispatch_queue_t responseQueue;

@property (nonatomic, assign) NSInteger maximumActiveDownloads;
@property (nonatomic, assign) NSInteger activeRequestCount;

@property (nonatomic, strong) NSMutableArray *queuedMergedTasks;
@property (nonatomic, strong) NSMutableDictionary *mergedTasks;

@end

@implementation HMNetWork

DEF_SINGLETON(HMNetWork)

+ (NSURLCache *)defaultURLCache {
    return [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                         diskCapacity:150 * 1024 * 1024
                                             diskPath:@"com.alamofire.webapi"];
}

+ (NSURLSessionConfiguration *)defaultURLSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //TODO set the default HTTP headers
    
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 30.0;
    configuration.URLCache = [self defaultURLCache];
    
    return configuration;
}

- (instancetype)init {
    NSURLSessionConfiguration *defaultConfiguration = [self.class defaultURLSessionConfiguration];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:defaultConfiguration];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return [self initWithSessionManager:sessionManager
                 downloadPrioritization:HTTPRequestPrioritizationFIFO
                 maximumActiveDownloads:5];
}

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration{

    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    return [self initWithSessionManager:sessionManager
                 downloadPrioritization:HTTPRequestPrioritizationFIFO
                 maximumActiveDownloads:5];
}

- (instancetype)initWithSessionManager:(AFHTTPSessionManager *)sessionManager
                downloadPrioritization:(HTTPRequestPrioritization)requestPrioritizaton
                maximumActiveDownloads:(NSInteger)maximumActiveDownloads {
    if (self = [super init]) {
        self.sessionManager = sessionManager;
        self.requestPrioritizaton = requestPrioritizaton;
        self.maximumActiveDownloads = maximumActiveDownloads;
        
        self.queuedMergedTasks = [[NSMutableArray alloc] init];
        self.mergedTasks = [[NSMutableDictionary alloc] init];
        self.activeRequestCount = 0;
        
        NSString *name = [NSString stringWithFormat:@"com.alamofire.webapi.synchronizationqueue-%@", [[NSUUID UUID] UUIDString]];
        self.synchronizationQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        
        name = [NSString stringWithFormat:@"com.alamofire.webapi.responsequeue-%@", [[NSUUID UUID] UUIDString]];
        self.responseQueue = dispatch_queue_create([name cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
        
//        [self.sessionManager setTaskDidSendBodyDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
////            [HMHTTPFlowManager sharedInstance].flowUpload;
//        }];
//        [self.sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//            
//        }];
    }
    
    return self;
}

- (HMHTTPRequestOperation *)operationForResponser:(id)responser{
    for (HMHTTPRequestOperation*oper in self.mergedTasks) {
        for (HMHTTPResponseHandler *handler in oper.responseHandlers) {
            if (responser==handler.responser) {
                return oper;
            }
        }
    }
    return nil;
}

- (HMHTTPRequestOperation *)taskMethod:(NSString *)method
                             urlString:(NSString *)URLString
                            parameters:(id)parameters
                             responser:(id)responser
                               timeOut:(NSTimeInterval)seconds {
    
    return [self taskMethod:method urlString:URLString parameters:parameters responser:responser constructingBodyWithBlock:nil
                    success:nil sendProgressBlock:nil receiveProgressBlock:nil failure:nil timeOut:seconds];
    
}

- (HMHTTPRequestOperation *)taskMethod:(NSString *)method
                             urlString:(NSString *)URLString
                            parameters:(id)parameters
                             responser:(id)responser
             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                               timeOut:(NSTimeInterval)seconds {
    
    return [self taskMethod:method urlString:URLString parameters:parameters responser:responser constructingBodyWithBlock:block
                    success:nil sendProgressBlock:nil receiveProgressBlock:nil failure:nil timeOut:seconds];
    
}

- (NSMutableURLRequest *)taskRequestMethod:(NSString *)method
                             urlString:(NSString *)URLString
                            parameters:(id)parameters
             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                error:(NSError *__autoreleasing *)error{
    
    NSMutableURLRequest *request = nil;
    if ([method isEqualToString:@"UPLOAD"]) {
        request = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
        
    }else{
        request = [self.sessionManager.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
        
    }
    return request;
}

- (HMHTTPRequestOperation *)taskRequest:(NSURLRequest *)request
                              responser:(id)responser
                               success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse  * _Nullable response, id responseObject))success
                     sendProgressBlock:(nullable void (^)(NSURLRequest*, NSHTTPURLResponse*,int64_t countOfBytesSend,int64_t countOfBytesExpectedToSend))sendProgress
                  receiveProgressBlock:(nullable void (^)(NSURLRequest*, NSHTTPURLResponse*,int64_t countOfBytesReceived,int64_t countOfBytesExpectedToReceive))receiveProgress
                               failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
                               timeOut:(NSTimeInterval)seconds{
    
    __block HMHTTPRequestOperation *operation = nil;
    dispatch_sync(self.synchronizationQueue, ^{
        NSString *URLIdentifier = request.URL.absoluteString;
        if (URLIdentifier == nil) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(request, nil, error);
                });
            }
            return;
        }
        NSUUID * receiptID = [NSUUID UUID];
        // 1) Append the success and failure blocks to a pre-existing request if it already exists
        HMHTTPRequestOperation *existingMergedTask = self.mergedTasks[URLIdentifier];
        if (existingMergedTask != nil) {
            HMHTTPResponseHandler *handler = [[HMHTTPResponseHandler alloc] initWithUUID:receiptID
                                                                                    task:existingMergedTask.task
                                                                                 success:success
                                                                       sendProgressBlock:sendProgress
                                                                    receiveProgressBlock:receiveProgress
                                                                                 failure:failure];
            handler.responser = responser;
            [existingMergedTask addResponseHandler:handler];
            operation = existingMergedTask;
            return;
        }
        
        // 2) Attempt to load the image from the image cache if the cache policy allows it
        switch (request.cachePolicy) {
            case NSURLRequestUseProtocolCachePolicy:
            case NSURLRequestReturnCacheDataElseLoad:
            case NSURLRequestReturnCacheDataDontLoad: {
                //                UIImage *cachedImage = [self.imageCache imageforRequest:request withAdditionalIdentifier:nil];
                //                if (cachedImage != nil) {
                //                    if (success) {
                //                        dispatch_async(dispatch_get_main_queue(), ^{
                //                            success(request, nil, cachedImage);
                //                        });
                //                    }
                //                    return;
                //                }
                break;
            }
            default:
                break;
        }
        
        // 3) Create the request and set up authentication, validation and response serialization
        NSUUID *mergedTaskIdentifier = [NSUUID UUID];
        NSURLSessionDataTask *createdTask;
        __weak_type __typeof(&*self)weakSelf = self;
        
        createdTask = [self.sessionManager
                       dataTaskWithRequest:request
                       completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                           dispatch_async(self.responseQueue, ^{
                               __strong __typeof__(weakSelf) strongSelf = weakSelf;
                               HMHTTPRequestOperation *mergedTask = self.mergedTasks[URLIdentifier];
                               if ([mergedTask.identifier isEqual:mergedTaskIdentifier]) {
                                   mergedTask = [strongSelf safelyRemoveMergedTaskWithURLIdentifier:URLIdentifier];
                                   if (error) {
                                       for (HMHTTPResponseHandler *handler in mergedTask.responseHandlers) {
                                           if (handler.failureBlock) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   handler.failureBlock(request, (NSHTTPURLResponse*)response, error);
                                               });
                                           }else if ([handler.responser respondsToSelector:@selector(taskFailure:request:response:error:)]){
                                               [handler.responser taskFailure:mergedTask.task request:request response:(NSHTTPURLResponse*)response error:error];
                                           }
                                       }
                                   } else {
                                       //                                       [strongSelf.imageCache addImage:responseObject forRequest:request withAdditionalIdentifier:nil];
                                       
                                       for (HMHTTPResponseHandler *handler in mergedTask.responseHandlers) {
                                           if (handler.successBlock) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   handler.successBlock(request, (NSHTTPURLResponse*)response, responseObject);
                                               });
                                           }else if ([handler.responser respondsToSelector:@selector(taskSuccess:request:response:responseObject:)]){
                                               [handler.responser taskSuccess:mergedTask.task request:request response:(NSHTTPURLResponse*)response responseObject:responseObject];
                                           }
                                       }
                                       
                                   }
                               }
                               [strongSelf safelyDecrementActiveTaskCount];
                               [strongSelf safelyStartNextTaskIfNecessary];
                           });
                       }];
        
        // 4) Store the response handler for use when the request completes
        HMHTTPResponseHandler *handler = [[HMHTTPResponseHandler alloc] initWithUUID:receiptID
                                                                                task:createdTask
                                                                             success:success
                                                                   sendProgressBlock:sendProgress
                                                                receiveProgressBlock:receiveProgress
                                                                             failure:failure];
        handler.responser = responser;
        HMHTTPRequestOperation *mergedTask = [[HMHTTPRequestOperation alloc]
                                              initWithURLIdentifier:URLIdentifier
                                              identifier:mergedTaskIdentifier
                                              task:createdTask];
        [mergedTask addResponseHandler:handler];
        self.mergedTasks[URLIdentifier] = mergedTask;
        
        // 5) Either start the request or enqueue it depending on the current active request count
        if ([self isActiveRequestCountBelowMaximumLimit]) {
            [self startMergedTask:mergedTask];
        } else {
            [self enqueueMergedTask:mergedTask];
        }
        operation = mergedTask;
    });
    if (operation) {
        return operation;
    } else {
        return nil;
    }
}

- (HMHTTPRequestOperation *)taskMethod:(NSString *)method
                             urlString:(NSString *)URLString
                              parameters:(id)parameters
                             responser:(id)responser
             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                  success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse  * _Nullable response, id responseObject))success
                        sendProgressBlock:(nullable void (^)(NSURLRequest*, NSHTTPURLResponse*,int64_t countOfBytesSend,int64_t countOfBytesExpectedToSend))sendProgress
                     receiveProgressBlock:(nullable void (^)(NSURLRequest*, NSHTTPURLResponse*,int64_t countOfBytesReceived,int64_t countOfBytesExpectedToReceive))receiveProgress
                                  failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
                               timeOut:(NSTimeInterval)seconds{
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self taskRequestMethod:method urlString:URLString parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    request.timeoutInterval = seconds<=0?30.f:seconds;
    
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.responseQueue ?: dispatch_get_main_queue(), ^{
                failure(nil,nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    
    return [self taskRequest:request responser:responser success:success sendProgressBlock:sendProgress receiveProgressBlock:receiveProgress failure:failure timeOut:seconds];
}

- (void)cancelTaskForOperation:(HMHTTPRequestOperation *)operation {
    dispatch_sync(self.synchronizationQueue, ^{
        NSString *URLIdentifier = operation.task.originalRequest.URL.absoluteString;
        HMHTTPRequestOperation *mergedTask = self.mergedTasks[URLIdentifier];
        NSUInteger index = [mergedTask.responseHandlers indexOfObjectPassingTest:^BOOL(HMHTTPResponseHandler * _Nonnull handler, __unused NSUInteger idx, __unused BOOL * _Nonnull stop) {
            return handler.uuid == operation.identifier;
        }];
        
        if (index != NSNotFound) {
            HMHTTPResponseHandler *handler = mergedTask.responseHandlers[index];
            [mergedTask removeResponseHandler:handler];
            NSString *failureReason = [NSString stringWithFormat:@"Network cancelled URL request: %@",operation.task.originalRequest.URL.absoluteString];
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey:failureReason};
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo];
            if (handler.failureBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler.failureBlock(mergedTask.task.originalRequest, nil, error);
                });
            }else if ([handler.responser respondsToSelector:@selector(taskFailure:request:response:error:)]){
                [handler.responser taskFailure:mergedTask.task request:operation.task.originalRequest response:nil error:error];
            }
        }
        
        if (mergedTask.responseHandlers.count == 0 && mergedTask.task.state == NSURLSessionTaskStateSuspended) {
            [mergedTask.task cancel];
            [self removeMergedTaskWithURLIdentifier:URLIdentifier];
        }
    });
}

- (HMHTTPRequestOperation*)safelyRemoveMergedTaskWithURLIdentifier:(NSString *)URLIdentifier {
    __block HMHTTPRequestOperation *mergedTask = nil;
    dispatch_sync(self.synchronizationQueue, ^{
        mergedTask = [self removeMergedTaskWithURLIdentifier:URLIdentifier];
    });
    return mergedTask;
}

//This method should only be called from safely within the synchronizationQueue
- (HMHTTPRequestOperation *)removeMergedTaskWithURLIdentifier:(NSString *)URLIdentifier {
    HMHTTPRequestOperation *mergedTask = self.mergedTasks[URLIdentifier];
    [self.mergedTasks removeObjectForKey:URLIdentifier];
    return mergedTask;
}

- (void)safelyDecrementActiveTaskCount {
    dispatch_sync(self.synchronizationQueue, ^{
        if (self.activeRequestCount > 0) {
            self.activeRequestCount -= 1;
        }
    });
}

- (void)safelyStartNextTaskIfNecessary {
    dispatch_sync(self.synchronizationQueue, ^{
        if ([self isActiveRequestCountBelowMaximumLimit]) {
            while (self.queuedMergedTasks.count > 0) {
                HMHTTPRequestOperation *mergedTask = [self dequeueMergedTask];
                if (mergedTask.task.state == NSURLSessionTaskStateSuspended) {
                    [self startMergedTask:mergedTask];
                    break;
                }
            }
        }
    });
}

- (void)startMergedTask:(HMHTTPRequestOperation *)mergedTask {
    [mergedTask.task resume];
    ++self.activeRequestCount;
}

- (HMHTTPRequestOperation *)dequeueMergedTask {
    HMHTTPRequestOperation *mergedTask = nil;
    mergedTask = [self.queuedMergedTasks firstObject];
    [self.queuedMergedTasks removeObject:mergedTask];
    return mergedTask;
}
- (void)enqueueMergedTask:(HMHTTPRequestOperation *)mergedTask {
    switch (self.requestPrioritizaton) {
        case HTTPRequestPrioritizationFIFO:
            [self.queuedMergedTasks addObject:mergedTask];
            break;
        case HTTPRequestPrioritizationLIFO:
            [self.queuedMergedTasks insertObject:mergedTask atIndex:0];
            break;
    }
}
- (BOOL)isActiveRequestCountBelowMaximumLimit {
    return self.activeRequestCount < self.maximumActiveDownloads;
}


- (void)setRequestType:(HTTPRequestType)requestType{
    if (_requestType!=requestType) {
        [self setSerializeRequest:requestType];
    }
    _requestType = requestType;
}

- (void)setSerializeRequest:(HTTPRequestType)requestType{
    AFHTTPRequestSerializer *requestSerializer = nil;
    
    switch (requestType) {
        case HTTPRequestType_JSON://post 方式 上传一个json字符串
            requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case HTTPRequestType_PLIST://post 方式 上传一份配置列表plist
            requestSerializer = [AFPropertyListRequestSerializer serializer];
            break;
        default://默认的 GET HEAD DELETE 方式用URL拼接parameters 其他用 body的方式
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    self.sessionManager.requestSerializer = requestSerializer;
}

- (void)setResponseType:(HTTPResponseType)responseType{
    if (_responseType!=responseType) {
        [self setSerializeResponse:responseType];
    }
    _responseType = responseType;
}

- (void)setSerializeResponse:(HTTPResponseType)responseType{
    
    AFHTTPResponseSerializer *responseSerializer = nil;
    switch (responseType) {
        case HTTPResponseType_Normal:// 返回 原封不动的数据 nsdata
            responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case HTTPResponseType_JSON://返回json反序列化后的数据 nsdictonary or nsarray
            responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case HTTPResponseType_PLIST://返回属性列表 NSPropertyListSerialization
            responseSerializer = [AFPropertyListResponseSerializer serializer];
            break;
        case HTTPResponseType_IMAGE://返回 图片
            responseSerializer = [AFImageResponseSerializer serializer];
            //            badURLCheckAllow = YES;
            //            if (!self.cacheInBranch) {
            //                self.cacheInBranch = defaultImageCachePath;
            //            }
            
            break;
        case HTTPResponseType_XML://返回 xml对象 NSXMLDocument
#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
            responseSerializer = [AFXMLDocumentResponseSerializer serializer];
#else
            responseSerializer = [AFXMLParserResponseSerializer serializer];
#endif
            break;
        case HTTPResponseType_COMPOUND: //多种组合，默认是json和图片
        {
            AFHTTPResponseSerializer *responseJson = [AFJSONResponseSerializer serializer];
            AFHTTPResponseSerializer *responseImage = [AFImageResponseSerializer serializer];
            responseJson.acceptableContentTypes = nil;
            responseImage.acceptableContentTypes = nil;
            
            responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[responseJson,responseImage]];
        }
            break;
        default:
            break;
    }
    responseSerializer.acceptableContentTypes = nil;
    self.sessionManager.responseSerializer = responseSerializer;
    
}
@end



@implementation NSObject (OperationManger)

#pragma mark -

- (HMHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [[HMNetWork sharedInstance] taskMethod:@"GET" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [[HMNetWork sharedInstance] taskMethod:@"POST" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

//block can no be nil
- (HMHTTPRequestOperation *)UPLOAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block{
    return [[HMNetWork sharedInstance] taskMethod:@"UPLOAD" urlString:URLString parameters:parameters responser:self constructingBodyWithBlock:block timeOut:seconds];
}

- (HMHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [[HMNetWork sharedInstance] taskMethod:@"PUT" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [[HMNetWork sharedInstance] taskMethod:@"DELETE" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [[HMNetWork sharedInstance] taskMethod:@"HEAD" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [[HMNetWork sharedInstance] taskMethod:@"PATCH" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)DOWNLOAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [[HMNetWork sharedInstance] taskMethod:@"GET" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}


- (HMHTTPRequestOperation *)GET:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [network taskMethod:@"GET" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)POST:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [network taskMethod:@"POST" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

//block can no be nil
- (HMHTTPRequestOperation *)UPLOAD:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds  constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block{
    return [network taskMethod:@"UPLOAD" urlString:URLString parameters:parameters responser:self constructingBodyWithBlock:block timeOut:seconds];
}

- (HMHTTPRequestOperation *)PUT:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [network taskMethod:@"PUT" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)DELETE:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [network taskMethod:@"DELETE" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)HEAD:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [network taskMethod:@"HEAD" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)PATCH:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [network taskMethod:@"PATCH" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

- (HMHTTPRequestOperation *)DOWNLOAD:(NSString *)URLString useNetWork:(HMNetWork*)network parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    return [network taskMethod:@"GET" urlString:URLString parameters:parameters responser:self timeOut:seconds];
}

@end
