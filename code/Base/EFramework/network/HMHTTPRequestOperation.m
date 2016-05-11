//
//  HMHTTPRequestOperation.m
//  CarAssistant
//
//  Created by Eric on 14-3-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMHTTPRequestOperation.h"

#import "HMCache.h"
#import "HMCategoryComm.h"
#import "HMHTTPRequestOperationManager.h"
#import "HMFoundation.h"

#pragma mark -
@interface NSObject (SuperMethodDeclaration)

- (void)operationDidStart;

- (void)finish;

- (void)pause;

- (void)operationDidPause;

- (void)resume;

+ (NSThread *)networkRequestThread;

@end
@implementation NSObject (SuperMethodDeclaration)

- (void)operationDidStart{
    
}

- (void)finish{
    
}
- (void)pause{
    
}
- (void)operationDidPause{
    
}

-(void)resume{
    
}

+ (NSThread *)networkRequestThread{
    return nil;
}


@end

#pragma mark -
inline NSString * descWithState(NSInteger sate){
    NSString *ret = @"unknown";
    if (sate == [HMHTTPRequestOperation STATE_CREATED]) {
        ret = @"CREATED";
    }else if (sate == [HMHTTPRequestOperation STATE_SENDING]) {
        ret = @"SENDING";
    }else if (sate == [HMHTTPRequestOperation STATE_RECVING]) {
        ret = @"RECVING";
    }else if (sate == [HMHTTPRequestOperation STATE_SUCCEED]) {
        ret = @"SUCCEED";
    }else if (sate == [HMHTTPRequestOperation STATE_FAILED]) {
        ret = @"FAILED";
    }else if (sate == [HMHTTPRequestOperation STATE_CANCELLED]) {
        ret = @"CANCELLED";
    }else if (sate == [HMHTTPRequestOperation STATE_PAUSE]) {
        ret = @"PAUSE";
    }
    return ret;
}

static inline NSString *descForErrorcode(NSInteger code){
    NSString *ret = @"no error";
    switch (code) {
        case 0:
            break;
        case NSURLErrorUnknown:
            ret = @"unknown";
            break;
            
        case NSURLErrorBadURL:
            ret = @"bad URL";
            break;
        case NSURLErrorTimedOut:
            ret = @"time out";
            break;
            
        case NSURLErrorUnsupportedURL:
            ret = @"unsupported url";
            break;
        case NSURLErrorCannotFindHost:
            ret = @"cannot find host";
            break;
        case NSURLErrorCannotConnectToHost:
            ret = @"cannot connect to Host";
            break;
        case NSURLErrorNetworkConnectionLost:
            ret = @"network connecton lost";
            break;
        case NSURLErrorNotConnectedToInternet:
            ret = @"not connected to internet";
            break;
            
        case NSURLErrorResourceUnavailable:
            ret = @"resource unavailable";
            break;
        case NSURLErrorBadServerResponse:
            ret = @"bad server response";
            break;
            
        default:
            ret = [NSString stringWithFormat:@"othe error %ld",(long)code];
            break;
    }
    return ret;
}

inline NSString * AFDataCacheKeyFromURLRequest(NSURL *url) {
    if ([url isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    return [NSString stringWithFormat:@"%lu", (unsigned long)[url hash]];
}

inline NSString * AFGetHttpHeaderDefaultUserInfoWithUserId(NSString *userId){
    NSString *userAgent = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    userAgent = [NSString stringWithFormat:@"%@/%@(iOS %@;%@;%@)",
                 [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey],
                 (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey],
                 [[UIDevice currentDevice] systemVersion],
                 [[UIDevice currentDevice] model] ,
                 userId==nil?@"":userId];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@;%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString],userId==nil?@"":userId];
#endif
#pragma clang diagnostic pop
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false);
            userAgent = mutableUserAgent;
        }
    }
    return userAgent;
}

static NSString *defaultUserAgent = nil;

static NSString *defaultImageCachePath = @"images";

@interface HMHTTPRequestOperation ()

@property (nonatomic, readwrite) long long                  uploadBytes;
@property (nonatomic, readwrite) long long                  uploadTotalBytes;

@property (nonatomic, readwrite) long long                  downloadBytes;
@property (nonatomic, readwrite) long long                  downloadTotalBytes;

@property (readwrite, nonatomic, HM_STRONG) NSURLRequest *  request;
@property (readwrite, nonatomic, HM_STRONG) NSData *        responseData;
@property (readwrite, nonatomic, strong) NSHTTPURLResponse *response;

@property (nonatomic,readwrite) BOOL               isCache;

@property (nonatomic,readwrite) BOOL               isResponseCompressed;

@property (nonatomic) NSTimeInterval               initTimeStamp;
@property (nonatomic) NSTimeInterval               sendTimeStamp;
@property (nonatomic) NSTimeInterval               recvTimeStamp;
@property (nonatomic) NSTimeInterval               doneTimeStamp;

@property (readwrite, nonatomic, HM_STRONG) NSError *       error;
@property (nonatomic,readwrite)BOOL                isBadURL;

@property (nonatomic, HM_STRONG) NSRecursiveLock *          pauseLock;
@property (nonatomic, readonly,getter = isStatusAvailable) BOOL                        statusAvailable;
- (void)praserError;

@end



@implementation HMHTTPRequestOperation
{
    AFHTTPRequestSerializer <AFURLRequestSerialization> *_requestSerializer;
    NSDictionary *          _parameters;
    NSMutableArray *		_responders;
    
    NSTimeInterval			_initTimeStamp;
    NSTimeInterval			_sendTimeStamp;
    NSTimeInterval			_recvTimeStamp;
    NSTimeInterval			_doneTimeStamp;
    NSTimeInterval          _pauseTimeStamp;
    NSTimeInterval          _pauseTime;
    
    BOOL					_sendProgressed;
    BOOL					_recvProgressed;
    
    long long				_uploadBytes;
    long long				_uploadTotalBytes;
    long long				_downloadBytes;
    long long				_downloadTotalBytes;
    
    NSString *				_errorDomain;	// 错误域
    NSInteger				_errorCode;		// 错误码
    NSString *				_errorDesc;		// 错误描述
    
    BOOL                    _useFileCacheOnly;
    BOOL                    _isCache;
    HTTPRequestType         _requestType;
    HTTPResponseType        _responseType;
    BOOL                    _isResponseCompressed;
    BOOL                    _isResuming;
    BOOL                    _isBadURL;
    NSString *              _headUserInfo;
    
    NSRecursiveLock *       _pauseLock;
}

DEF_INT( STATE_CREATED,		0 );
DEF_INT( STATE_SENDING,		1 );
DEF_INT( STATE_RECVING,		2 );
DEF_INT( STATE_FAILED,		3 );
DEF_INT( STATE_SUCCEED,		4 );
DEF_INT( STATE_CANCELLED,	5 );
DEF_INT( STATE_REDIRECTED,	6 );
DEF_INT( STATE_PAUSE,		7 );
DEF_INT( STATE_SUCCEEDOLD,	8 );

@synthesize uploadPercent;
@synthesize uploadBytes=_uploadBytes;
@synthesize uploadTotalBytes=_uploadTotalBytes;

@synthesize downloadPercent;
@synthesize downloadBytes=_downloadBytes;
@synthesize downloadTotalBytes=_downloadTotalBytes;

@synthesize status = _status;
@synthesize statusCode = _statusCode;
@synthesize statusDesc = _statusDesc;

@synthesize order = _order;
@synthesize tagString;
@synthesize url;
@synthesize timeOut = _timeOut;
@synthesize timeOutInterval = _timeOutInterval;
@synthesize responders = _responders;
@synthesize requestHeaders;

@synthesize errorDomain = _errorDomain;
@synthesize errorCode = _errorCode;
@synthesize errorDesc = _errorDesc;

@synthesize initTimeStamp = _initTimeStamp;
@synthesize sendTimeStamp = _sendTimeStamp;
@synthesize recvTimeStamp = _recvTimeStamp;
@synthesize doneTimeStamp = _doneTimeStamp;

@synthesize timeCostPending;	// 排队等待耗时
@synthesize timeCostOverDNS;	// 网络连接耗时（DNS）
@synthesize timeCostRecving;	// 网络收包耗时
@synthesize timeCostOverAir;	// 网络整体耗时

@dynamic created;
@dynamic sending;
@dynamic recving;
@dynamic failed;
@dynamic succeed;
@dynamic paused;
@dynamic redirected;

@synthesize sendProgressed = _sendProgressed;
@synthesize recvProgressed = _recvProgressed;
@synthesize attentRecvProgress = _attentRecvProgress;
@synthesize attentSendProgress = _attentSendProgress;

@synthesize requestSerializer = _requestSerializer;
@synthesize requestType = _requestType;
@synthesize responseType = _responseType;
@synthesize parameters = _parameters;
@synthesize useCookiePersistence;
@synthesize useCache;
@synthesize refreshAndNoRemoveCache;
@synthesize cacheDuration;
@synthesize useFileCacheOnly = _useFileCacheOnly;
@synthesize refreshCache;
@synthesize isCache=_isCache;
@synthesize cacheInBranch;
@synthesize cachePath;

@synthesize isResponseCompressed=_isResponseCompressed;

@synthesize shouldResume = _shouldResume;
@synthesize uploadDataBlock;
@synthesize isBadURL = _isBadURL;
@synthesize badURLCheckAllow;
@synthesize headUserAgent = _headUserAgent;

@synthesize requestBuildedBlock;
@synthesize redirectBlock;

@synthesize request=_request;
@synthesize responseData;
@synthesize error=_error;
@synthesize response;

@synthesize autoLoad;

#pragma  mark - init

- (void)dealloc
{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"HTTP",@"[[][][][]t[%@]n[%@]]remove the request '%@'",self.tagString,self.order,self.url);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    [_responders removeAllObjects];
    [_responders release];
    self.order = nil;
    self.requestSerializer = nil;
    self.parameters = nil;
    self.cacheInBranch = nil;
    self.cachePath = nil;
    self.uploadDataBlock = nil;
    self.headUserInfo = nil;
    self.statusDesc = nil;
    self.errorDesc = nil;
    self.url = nil;
    self.tagString = nil;
    self.pauseLock = nil;
    self.requestHeaders = nil;
    self.requestBuildedBlock = nil;
    self.redirectResponseBlock = nil;
    HM_SUPER_DEALLOC();
}

+ (instancetype)spawnForMethod:(NSString*)method
                     URLString:(NSString *)URLString
                         error:(NSError *__autoreleasing_type *)error
{
    
    NSParameterAssert(method);
    NSParameterAssert(URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSParameterAssert(url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    
    HMHTTPRequestOperation *operation = [[HMHTTPRequestOperation alloc]initWithRequest:request];
    
    return [operation autorelease];
}


-(instancetype)initWithRequest:(NSURLRequest *)urlRequest{
    
    self = [super initWithRequest:urlRequest];
    if (self) {
        _responders = [[NSMutableArray nonRetainingArray] retain];//[[NSMutableArray array]retain];//
        _responseType = -1;
        _requestType = -1;
        _status = -1;
        _initTimeStamp = [NSDate timeIntervalSinceReferenceDate];
        _sendTimeStamp = _initTimeStamp;
        _recvTimeStamp = _initTimeStamp;
        _doneTimeStamp = _initTimeStamp;
        _pauseLock = [[NSRecursiveLock alloc]init];
        self.url = urlRequest.URL.absoluteString;
    }
    return self;
}


#pragma mark - overwrite

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"HMAFNetworking"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

-(NSString *)description{
    NSString *string = [super description];
    
    return [NSString stringWithFormat:@"%@\n up %@ down %@ {Pending:%.3f-DNS:%.3f-Recving:%.3f-Air:%.3f}",string,[NSString formatVolume:self.uploadBytes],[NSString formatVolume:self.downloadBytes],self.timeCostPending,self.timeCostOverDNS,self.timeCostRecving,self.timeCostOverAir];
}

- (void)start{
    
    [self changeStatus:[HMHTTPRequestOperation STATE_CREATED]];
    
    [super start];
    
}
- (NSMutableURLRequest *)bulidHeaders{
    NSError *error;
    
    NSMutableURLRequest *request = nil;
    
    if (self.redirectBlock) {
        [self setRedirectResponseBlock:redirectBlock];
    }
    
    if (self.uploadDataBlock) {
        request = [[self.requestSerializer multipartFormRequestWithMethod:self.request.HTTPMethod URLString:self.url parameters:self.parameters constructingBodyWithBlock:self.uploadDataBlock error:&error] mutableCopy];
    }else{
        request = [[self.requestSerializer requestBySerializingRequest:self.request withParameters:self.parameters error:&error] mutableCopy];
    }
    
    
    if (self.headUserAgent||defaultUserAgent) {
        
        NSString *userAgentString = [self headUserAgent];
        if (!userAgentString) {
            userAgentString = defaultUserAgent;
        }
        if (userAgentString) {
            [request setValue:userAgentString forHTTPHeaderField:@"User-Agent"];
        }
    }
    
    if (self.useCookiePersistence) {
        
        [request setHTTPShouldHandleCookies:YES];
    }
    
    request.timeoutInterval = self.timeOutInterval?self.timeOutInterval:DEFAULT_GET_TIMEOUT;
    self.timeOutInterval = request.timeoutInterval;
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    // do we need to resume the file download?
    _isResuming = NO;
    if (_shouldResume && self.useCache) {
        
        NSString *tmpPath = [[HMFileCache sharedInstance] fileNameForKey:AFDataCacheKeyFromURLRequest(self.request.URL) branch:DEFAULT_PORTION_DOWNLOAD];
        unsigned long long downloadedBytes = [[HMFileCache sharedInstance] fileSizeForPath:tmpPath];
        if (downloadedBytes > 0) {
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [request setValue:requestRange forHTTPHeaderField:@"Range"];
            _isResuming = YES;
            self.outputStream = [NSOutputStream outputStreamToFileAtPath:tmpPath append:YES];
            [self.outputStream setProperty:[NSNumber numberWithLongLong:downloadedBytes] forKey:NSStreamFileCurrentOffsetKey];
            self.downloadBytes = downloadedBytes;
        }
    }else{
        if (self.downloadBytes>0) {
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", self.downloadBytes];
            [request setValue:requestRange forHTTPHeaderField:@"Range"];
        }
    }
    if (self.requestHeaders.allKeys.count) {
        for (NSString *key in self.requestHeaders.allKeys) {
            id value = [self.requestHeaders valueForKey:key];
            if (value) {
                [request setValue:value forHTTPHeaderField:key];
            }
        }
    }
    
    return [request autorelease];
}

- (void)removeCached{
    [[HMMemoryCache sharedInstance] removeObjectForKey:AFDataCacheKeyFromURLRequest(self.request.URL)];
    [[HMFileCache sharedInstance] removeObjectForKey:AFDataCacheKeyFromURLRequest(self.request.URL) branch:self.cacheInBranch];
}

- (BOOL)checkCache{
    
    if (self.useCache) {
        self.cachePath = [[HMFileCache sharedInstance] fileNameForKey:AFDataCacheKeyFromURLRequest(self.request.URL) branch:self.cacheInBranch];
        if (self.cacheDuration>0) {//缓存过期时间
            NSError *error = nil;
            NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:self.cachePath error:&error];
            if (!error) {
                NSDate *modityDate =  [dic fileModificationDate];
                if (modityDate==nil) {
                    modityDate = [dic fileCreationDate];
                }
                NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:modityDate];
                
                if (fabs(timeInterval)>self.cacheDuration) {
                    self.refreshCache = YES;
                }
#if (__ON__ == __HM_DEVELOPMENT__)
                CC( @"HTTP",@"%@ '%@' %@ modityDate:%@ durationDate:%@",self.request.HTTPMethod,self.url,self.refreshCache?@"refresh":@"cached",[modityDate stringWithDateFormat:nil],[[modityDate dateByAddingTimeInterval:self.cacheDuration] stringWithDateFormat:nil]);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
            }
        }
        
        if (self.refreshCache) {
            [self removeCached];
            return YES;
        }
        
        if (self.refreshAndNoRemoveCache) {
            return YES;
        }
        
        NSData *data = nil;
        
        if (!self.useFileCacheOnly) {
            data = [[HMMemoryCache sharedInstance] objectForKey:AFDataCacheKeyFromURLRequest(self.request.URL)];
        }
        
        if (!data) {
            //form disk
            data = [[HMFileCache sharedInstance] objectForKey:AFDataCacheKeyFromURLRequest(self.request.URL) branch:self.cacheInBranch];
        }
        
        if (data) {
            _isCache = YES;
            self.responseData = data;
            self.response = [[[NSHTTPURLResponse alloc]initWithURL:self.request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{@"Content-Type":@"application/json; charset=UTF-8"}]autorelease];

            self.downloadTotalBytes =  data.length;
            if ([self valueForKey:@"downloadProgress"]) {
                
                void (^downloadProgress)(NSUInteger bytes, long long totalBytes, long long totalBytesExpected)  = [self valueForKey:@"downloadProgress"];
                if (downloadProgress) {
                    downloadProgress((NSUInteger)self.downloadTotalBytes,self.downloadTotalBytes,self.downloadTotalBytes);
                }
            }
            self.statusCode = 200;
            
            [self finish];
            return NO;
        }
        
    }
    return YES;
}

- (BOOL)isFinished{
    if (_isCache) {
        return YES;
    }
    return  [super isFinished];
}

- (BOOL)checkBadUrl{
    
    int ret = 0;
    if (badURLCheckAllow && (ret = [[HMHTTPRequestOperationManager sharedInstance] checkResourceBroken:self.url])) {
        
        if (ret==-1) {
            NSDictionary *userInfo = nil;
            if ([self.request URL]) {
                userInfo = [NSDictionary dictionaryWithObject:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
            }
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
            self.error = error;
            self.isBadURL = YES;
            self.statusCode = 403;//（禁止）
            [self finish];
            return NO;
        }
        if (ret == 1) {//已经超过上次请求时间界限,这样可以去掉block
            self.isBadURL = YES;
        }
    }
    
    
    return YES;
}

- (void)operationDidStart{
    
    NSMutableURLRequest *request = [self bulidHeaders];
    
    self.request = request;
    
    /*cache check*/
    if (![self checkCache]) {
        return;
    }
    
    /*bad url  check*/
    if (![self checkBadUrl]) {
        return;
    }
    
    if (self.requestBuildedBlock) {
        self.requestBuildedBlock(request);
        if (request.HTTPBody) {
            if (![request valueForHTTPHeaderField:@"Content-Type"]) {
                
                NSString *contenttype = @"application/form-data;charset=UTF-8";
                if (self.requestSerializer.stringEncoding==NSGBK2312StringEncoding){
                    
                    contenttype = @"application/form-data;charset=gb2312";
                    
                }else if (self.requestSerializer.stringEncoding==NSGBK18030StringEncoding){
                   
                    contenttype = @"application/form-data;charset=gbk";
                }
                [request setValue:contenttype forHTTPHeaderField:@"Content-Type"];
                
            }
        }
        
    }
    
    [super operationDidStart];
    
    if (self.isCancelled==NO && self.created) {
        
        [self changeStatus:[HMHTTPRequestOperation STATE_SENDING]];
        
    }else{
        if (self.isCancelled) {
            [self changeStatus:[HMHTTPRequestOperation STATE_CANCELLED]];
        }else{
            [self changeStatus:[HMHTTPRequestOperation STATE_FAILED]];
        }
    }
    self.uploadTotalBytes = self.request.HTTPBody.length;
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"HTTP",@"%@ '%@' start \n",self.request.HTTPMethod,self.url);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}

- (void)cancel {
    [super cancel];
    if (self.isPaused) {
        [self performSelector:NSSelectorFromString(@"cancelConnection") onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
    }
}

- (void)finish{
    
    [super finish];
    
    [self praserError];
    self.statusDesc = [NSHTTPURLResponse localizedStringForStatusCode:self.statusCode];
    BOOL readError = NO;
    BOOL avilabel = self.isStatusAvailable;
    if (self.error) {
        readError = YES;
        if (self.error.code == NSURLErrorCancelled) {
            //timeout or cancel
            
            [self changeStatus:[HMHTTPRequestOperation STATE_CANCELLED]];
            
        }else if (self.error.code == NSURLErrorTimedOut){
            _timeOut = YES;
            //timeout
            [self changeStatus:[HMHTTPRequestOperation STATE_FAILED]];
            
        }else if (!avilabel){
            BOOL oldData = NO;
            if (self.refreshAndNoRemoveCache) {
                NSData *data = nil;
                
                if (!self.useFileCacheOnly) {
                    data = [[HMMemoryCache sharedInstance] objectForKey:AFDataCacheKeyFromURLRequest(self.request.URL)];
                }
                
                if (!data) {
                    //form disk
                    data = [[HMFileCache sharedInstance] objectForKey:AFDataCacheKeyFromURLRequest(self.request.URL) branch:self.cacheInBranch];
                }
                
                if (data) {
                    self.responseData = data;
                    oldData = YES;
                }
            }
            //error
            [self changeStatus:oldData?[HMHTTPRequestOperation STATE_SUCCEEDOLD]:[HMHTTPRequestOperation STATE_FAILED]];
            
        }else{
            readError = NO;
        }
        
    }
    
    if (readError) {
        
        [self cacheTmpData];
        
    }else if (avilabel) {
        
        if (self.useCache&&!_isCache) {
            
            if (!self.useFileCacheOnly
                &&(self.responseData.length
                   < [HMHTTPRequestOperationManager sharedInstance].maxMemeryCache)) {
                    
                    [[HMMemoryCache sharedInstance] setObject:self.responseData forKey:AFDataCacheKeyFromURLRequest(self.request.URL)];
                    
                }
            
            if (_isResuming) {
                
                [[HMFileCache sharedInstance]
                 moveItemForKey:AFDataCacheKeyFromURLRequest(self.request.URL)
                 atBranch:DEFAULT_PORTION_DOWNLOAD toBranch:self.cacheInBranch];
            }else{
                
                [[HMFileCache sharedInstance]
                 setObject:self.responseData
                 forKey:AFDataCacheKeyFromURLRequest(self.request.URL)
                 branch:self.cacheInBranch];
                
            }
            
        }
        
        [self changeStatus:[HMHTTPRequestOperation STATE_SUCCEED]];
    }
    
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"HTTP",@"%d(%@) cost:%.3fs body:%@ stream:%@ %@ %@ \n headers:%@ \n parameters:%@\nrespone:%@ \n error:%@",
       self.statusCode,
       self.statusDesc,
       self.timeCostOverAir,
       [NSString formatVolume:self.responseData.length],
       [NSString formatVolume:[[self.request valueForHTTPHeaderField:@"Content-Length"] longLongValue]],
       self.request.HTTPMethod,
       self.url,
       [self.request.allHTTPHeaderFields JSONString],
       [self.parameters JSONString],
       self.responseData.length>[HMUIConfig sharedInstance].allowedLogWebDataLength?[[@"{很多数据,不显示了,自己去查结果}" add:@"[HMUIConfig sharedInstance].allowedLogWebDataLength:"] add:[@([HMUIConfig sharedInstance].allowedLogWebDataLength) description]]:self.responseString,
       self.error);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    
    [HMHTTPRequestOperationManager cancelRequest:self];
}

- (void)pause{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (self.outputStream.streamStatus == NSStreamStatusWriting);
        
        [self.pauseLock lock];
        [super pause];
        [self.pauseLock unlock];
        
    });
    
}
- (void)cacheTmpData{
    if (self.shouldResume && self.useCache
        && self.isStatusAvailable) {
        
        NSData *data = [self.outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        if (data.length>0) {
            [[HMFileCache sharedInstance] setObject:data
                                             forKey:AFDataCacheKeyFromURLRequest(self.request.URL)
                                             branch:DEFAULT_PORTION_DOWNLOAD];
        }
    }
}
- (void)operationDidPause{
    [super operationDidPause];
    
    [self changeStatus:[HMHTTPRequestOperation STATE_PAUSE]];
    
    [self cacheTmpData];
    
}

-(instancetype)resumeOrNewIfIsfinished{
    if ([self isFinished]||[self isCancelled]) {
        HMHTTPRequestOperation *operation = [self copy];
        [[HMHTTPRequestOperationManager sharedInstance] startAsync:operation];
        return [operation autorelease];
        
    }else{
        [super resume];
        return self;
    }
    
}

#pragma mark - lifecycle
+ (NSString *)defaultUserAgentString
{
    // If we already have a default user agent set, return that
    return defaultUserAgent;
}
+ (void)setDefaultUserAgentString:(NSString *)agent
{
    defaultUserAgent = agent;
}

+ (void)setDefaultImageCachePath:(NSString *)imagePath{
    defaultImageCachePath = imagePath;
}

+ (NSData *)imageDataCachedWithURL:(NSURL *)url branch:(NSString*)branch{
    
    if (url==nil) {
        return nil;
    }
    NSString *path = AFDataCacheKeyFromURLRequest(url);
    NSData *data = [[HMMemoryCache sharedInstance] objectForKey:path];
    
    if (!data) {
        //form disk
        data = [[HMFileCache sharedInstance] objectForKey:path branch:branch];
    }
    return data;
}

+ (NSData *)imageDataCachedWithURL:(NSURL *)url{
    return [HMHTTPRequestOperation imageDataCachedWithURL:url branch:defaultImageCachePath];
}

+ (BOOL)imageDataCachedWithURL:(NSURL *)url branch:(NSString*)branch block:(void(^)(NSData *))block{
    
    if (block==nil) {
        return NO;
    }
    NSString *path = AFDataCacheKeyFromURLRequest(url);
//    NSLog(@"%@>>>%@",path,url);
    NSData *data = [[HMMemoryCache sharedInstance] objectForKey:path];
    BOOL ret = YES;
    if (!data&&[[HMFileCache sharedInstance] hasObjectForKey:path branch:branch]) {
        //form disk
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *retData= [[HMFileCache sharedInstance] objectForKey:path branch:branch];
            block(retData);
        });
    }else{
        block(data);
        ret= !!data;
    }
  
    return ret;
}

+ (BOOL)imageDataCachedWithURL:(NSURL *)url block:(void(^)(NSData *))block{
    return !![HMHTTPRequestOperation imageDataCachedWithURL:url branch:defaultImageCachePath block:block];
}

+ (void)cachedImage:(id)image withURL:(NSURL *)url{
    if (image==nil) {
        return;
    }
    
    [[HMMemoryCache sharedInstance] setObject:image forKey:AFDataCacheKeyFromURLRequest(url)];
    
}

-(void)setUseFileCacheOnly:(BOOL)useFileCacheOnly{
    _useFileCacheOnly = useFileCacheOnly;
    if (useFileCacheOnly) {
        self.useCache = YES;
    }
}

- (BOOL)isStatusAvailable{
    if (self.statusCode == 200
        || self.statusCode == 206//断点下载
        || self.statusCode == 416//断点下载超出范围
        ) {
        if (self.statusCode == 416 && self.downloadTotalBytes!=self.downloadBytes) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (void)praserError{
    if (self.error) {
        self.errorCode = self.error.code;
    }
    self.errorDesc = descForErrorcode(self.errorCode);
    self.errorDomain = NSURLErrorDomain;
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
    self.requestSerializer = requestSerializer;
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
            //            responseSerializer = [AFImageResponseSerializer serializer];
            responseSerializer = [AFHTTPResponseSerializer serializer];
            badURLCheckAllow = YES;
            if (!self.cacheInBranch) {
                self.cacheInBranch = defaultImageCachePath;
            }
            
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
    self.responseSerializer = responseSerializer;
    
}

- (void)setTimeOut:(BOOL)timeOut{
    _timeOut = timeOut;
    
    if (timeOut) {
        
        if (self.created||self.sending) {
            [self cancel];
        }
    }
}
- (CGFloat)uploadPercent{
    long long bytes1 = self.uploadBytes;
    long long bytes2 = self.uploadTotalBytes;
    
    return bytes2 ? ((CGFloat)bytes1 / (CGFloat)bytes2) : 0.0f;
}
- (CGFloat)downloadPercent{
    long long bytes1 = self.downloadBytes;
    long long bytes2 = self.downloadTotalBytes;
    
    return bytes2 ? ((CGFloat)bytes1 / (CGFloat)bytes2) : 0.0f;
}

- (NSTimeInterval)timeCostPending
{
    return _sendTimeStamp - _initTimeStamp;
}

- (NSTimeInterval)timeCostOverDNS
{
    return _recvTimeStamp - _sendTimeStamp;
}

- (NSTimeInterval)timeCostRecving
{
    return _doneTimeStamp - _recvTimeStamp;
}

- (NSTimeInterval)timeCostOverAir
{
    return _doneTimeStamp - _sendTimeStamp;
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    [super connection:connection willSendRequestForAuthenticationChallenge:challenge];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection __unused *)connection {
    BOOL ret = [super connectionShouldUseCredentialStorage:connection];
    
    return ret;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse
{
    NSURLRequest *redirect = [super connection:connection willSendRequest:request redirectResponse:redirectResponse];
    if (redirect != request) {
        [self changeStatus:[HMHTTPRequestOperation STATE_REDIRECTED]];
    }
    return redirect;
}


- (void)connection:(NSURLConnection __unused *)connection
didReceiveResponse:(NSURLResponse *)responses
{
    self.uploadTotalBytes = self.request.HTTPBody.length;
    // check if we have the correct response
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)responses;
    NSDictionary *httpHeaders = nil;
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        httpHeaders = [NSDictionary dictionaryWithDictionary:[httpResponse allHeaderFields]];
    }
    self.downloadTotalBytes = [[httpHeaders objectForKey:@"Content-Length"] longLongValue];
    
    // check for valid response to resume the download if possible
    long long totalContentLength = responses.expectedContentLength;
    
    self.statusCode = httpResponse.statusCode;
    
    if (_shouldResume && _isResuming && self.useCache) {
        
        long long fileOffset = 0;
        if(self.statusCode == 206) {//部分内容
            NSString *contentRange = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
            if ([contentRange hasPrefix:@"bytes"]) {
                NSArray *bytes = [contentRange componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -/"]];
                if ([bytes count] == 4) {
                    fileOffset = [[bytes objectAtIndex:1] longLongValue];
                    totalContentLength = [[bytes objectAtIndex:2] longLongValue]; // if this is *, it's converted to 0
                }
            }
        }
        [self.outputStream setProperty:[NSNumber numberWithLongLong:fileOffset] forKey:NSStreamFileCurrentOffsetKey];
    }
    
    self.downloadTotalBytes = totalContentLength == -1?_downloadTotalBytes:MAX(totalContentLength, _downloadTotalBytes);
    
    NSString *encoding = [httpHeaders objectForKey:@"Content-Encoding"];
    if (encoding && [encoding rangeOfString:@"gzip"].location != NSNotFound) {
        _isResponseCompressed = YES;
    }
    
    [self changeStatus:[HMHTTPRequestOperation STATE_RECVING]];
    //#if (__ON__ == __HM_DEVELOPMENT__)
    //    CC( @"HTTP",@"request ",self.request.allHTTPHeaderFields,@"respond",[(NSHTTPURLResponse *)response allHeaderFields],@"%lld;%lld",response.expectedContentLength,self.downloadTotalBytes);
    //#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    [super connection:connection didReceiveResponse:responses];
    
}

- (void)connection:(NSURLConnection __unused *)connection
    didReceiveData:(NSData *)data
{
    
    self.downloadBytes += data.length;
    
    if (_attentRecvProgress) {
        
        [self updateRecvProgress];
        
    }
    
    if (self.downloadTotalBytes==self.downloadBytes) {
        _attentRecvProgress = NO;
    }
    
    [self.pauseLock lock];
    [super connection:connection didReceiveData:data];
    [self.pauseLock unlock];
    
    
}

- (void)connection:(NSURLConnection __unused *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
    self.uploadBytes += bytesWritten;
    if (self.uploadTotalBytes<=0) {
        self.uploadTotalBytes = totalBytesExpectedToWrite;
    }
    if (_attentSendProgress) {
        
        [self updateSendProgress];
        
    }
    if (self.uploadTotalBytes==self.uploadBytes) {
        _attentSendProgress = NO;
    }
    
    
    [super connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

- (void)connectionDidFinishLoading:(NSURLConnection __unused *)connection {
    
    self.statusCode = self.response.statusCode;
    BOOL avilabel = self.isStatusAvailable;
    if (!avilabel){
        self.error = [NSError errorWithDomain:NSURLErrorDomain code:self.statusCode userInfo:nil];
    }
    
    [super connectionDidFinishLoading:connection];
    
    if ( self.badURLCheckAllow ){
        /*排除返回数据为空 或 带有UTF8标志头的无效链接*/
        if (!avilabel||self.responseData.length==0||(self.responseData.length==3&&[[self.responseData description] rangeOfString:@"efbbbf"].location!=NSNotFound)) {
            
            self.isBadURL = YES;
            [[HMHTTPRequestOperationManager sharedInstance] blockURL:[self.request.URL absoluteString]];//标记
            
        }
        else{
            self.isBadURL = NO;
            [[HMHTTPRequestOperationManager sharedInstance] unblockURL:[self.request.URL absoluteString]];//解除
        }
    }
    
}

- (void)connection:(NSURLConnection __unused *)connection
  didFailWithError:(NSError *)error
{
    self.uploadTotalBytes = self.request.HTTPBody.length;
    [super connection:connection didFailWithError:error];
    if (self.error.code==NSURLErrorCancelled) {
        
    }
    if ( self.badURLCheckAllow
        && !self.isStatusAvailable) {
        
        self.isBadURL = YES;
        [[HMHTTPRequestOperationManager sharedInstance] blockURL:[self.request.URL absoluteString]];//标记
        
    }
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    
    return [super connection:connection willCacheResponse:cachedResponse];
    
}

#pragma mark - State

- (void)changeStatus:(NSUInteger)state
{
    if ( _status != state )
    {
        _status = state;
        
        if ( HMHTTPRequestOperation.STATE_SENDING == _status )
        {
            if (_pauseTimeStamp>0) {
                _pauseTimeStamp = [NSDate timeIntervalSinceReferenceDate] - _pauseTimeStamp;
                _pauseTime += _pauseTimeStamp;
            }else{
                _sendTimeStamp = [NSDate timeIntervalSinceReferenceDate];
            }
        }
        else if ( HMHTTPRequestOperation.STATE_RECVING == _status )
        {
            if (_pauseTimeStamp>0) {
                
            }else{
                _recvTimeStamp = [NSDate timeIntervalSinceReferenceDate];
            }
        }
        else if ( HMHTTPRequestOperation.STATE_PAUSE == _status )
        {
            _pauseTimeStamp = [NSDate timeIntervalSinceReferenceDate];
        }
        else if ( HMHTTPRequestOperation.STATE_FAILED == _status || HMHTTPRequestOperation.STATE_SUCCEED == _status || HMHTTPRequestOperation.STATE_CANCELLED == _status || HMHTTPRequestOperation.STATE_SUCCEEDOLD == _status)
        {
            _doneTimeStamp = [NSDate timeIntervalSinceReferenceDate]-_pauseTime;
            _pauseTime = 0;
        }
        
        [self callResponders];
        
    }
}
- (void)callResponders
{
    NSArray * responds = [self.responders copy];
    
    for ( NSObject * responder in responds)
    {
        [self forwardResponder:responder];
    }
    if (responds.count==0) {
        //#if (__ON__ == __HM_DEVELOPMENT__)
        //        CC( @"HTTP",@"'%@' no responder Handle Request now state:%@",self.order,descWithState(_status));
        //#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    [responds release];
}

- (void)forwardResponder:(NSObject *)obj
{
    BOOL allowed = YES;
    
    if ( [obj respondsToSelector:@selector(prehandleRequest:)] )
    {
        allowed = [obj prehandleRequest:self];
    }
    
    if ( allowed )
    {
        [obj retain];
        
        if ( [obj respondsToSelector:@selector(handleRequest:)] )
        {
            //#if (__ON__ == __HM_DEVELOPMENT__)
            //            CC( @"HTTP",@"'%@' responder Handle Request now state:%@",self.order,descWithState(_status));
            //#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
            [obj handleRequest:self];
        }
        
        [obj posthandleRequest:self];
        
        [obj release];
    }
}

- (BOOL)hasResponder:(id)responder
{
    return [_responders containsObject:responder];
}

- (void)addResponder:(id)responder
{
    if ([self hasResponder:responder]) {
        return;
    }
    [_responders addObject:responder];
}

- (void)removeResponder:(id)responder
{
    [_responders removeObject:responder];
}

- (void)removeAllResponders
{
    [_responders removeAllObjects];
}
- (BOOL)created
{
    return HMHTTPRequestOperation.STATE_CREATED == _status ? YES : NO;
}

- (BOOL)sending
{
    return HMHTTPRequestOperation.STATE_SENDING == _status ? YES : NO;
}

- (BOOL)recving
{
    return HMHTTPRequestOperation.STATE_RECVING == _status ? YES : NO;
}

- (BOOL)succeed
{
    return HMHTTPRequestOperation.STATE_SUCCEED == _status ? YES : NO;
}

- (BOOL)succeedOld
{
    return HMHTTPRequestOperation.STATE_SUCCEEDOLD == _status ? YES : NO;
}


- (BOOL)failed
{
    return HMHTTPRequestOperation.STATE_FAILED == _status ? YES : NO;
}

- (BOOL)beCancelled
{
    return HMHTTPRequestOperation.STATE_CANCELLED == _status ? YES : NO;
}

- (BOOL)redirected
{
    return HMHTTPRequestOperation.STATE_REDIRECTED == _status ? YES : NO;
}

- (BOOL)paused
{
    return HMHTTPRequestOperation.STATE_PAUSE == _status ? YES : NO;
}

- (void)updateSendProgress
{
    _sendProgressed = YES;
    
    [self callResponders];
    
    _sendProgressed = NO;
}

- (void)updateRecvProgress
{
    if ( self.created || self.failed ||self.beCancelled )
        return;
    
    if ( _isCache )
        return;
    
    _recvProgressed = YES;
    
    [self callResponders];
    
    _recvProgressed = NO;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.requestSerializer = [decoder decodeObjectForKey:NSStringFromSelector(@selector(requestSerializer))];
    self.parameters = [decoder decodeObjectForKey:NSStringFromSelector(@selector(parameters))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.requestSerializer forKey:NSStringFromSelector(@selector(requestSerializer))];
    [coder encodeObject:self.parameters forKey:NSStringFromSelector(@selector(parameters))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.request.URL];
    [request setHTTPMethod:self.request.HTTPMethod];
    
    HMHTTPRequestOperation *operation = [[[self class] allocWithZone:zone] initWithRequest:request];
    
    operation.requestType = self.requestType;
    operation.responseType = self.responseType;
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;
    
    operation.useCookiePersistence = self.useCookiePersistence;
    operation.shouldResume = self.shouldResume;
    operation.useCache = self.useCache;
    operation.useFileCacheOnly = self.useFileCacheOnly;
    operation.cacheInBranch = self.cacheInBranch;
    
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    operation.parameters = self.parameters;
    operation.responders = self.responders;
    operation.requestHeaders = self.requestHeaders;
    
    operation.badURLCheckAllow = self.badURLCheckAllow;
    
    if ([self valueForKey:@"downloadProgress"]) {
        
        void (^downloadProgress)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)  = [self valueForKey:@"downloadProgress"];
        [operation setDownloadProgressBlock:downloadProgress];
    }
    
    if ([self valueForKey:@"uploadProgress"]) {
        
        void (^uploadProgress)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)  = [self valueForKey:@"uploadProgress"];
        [operation setUploadProgressBlock:uploadProgress];
    }
    
    [operation setCompletionBlock:self.completionBlock];
    
    return operation;
}

@end