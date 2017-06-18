//
//  HMHTTPRequestOperationManager.m
//  CarAssistant
//
//  Created by Eric on 14-2-25.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMHTTPRequestOperationManager.h"
#import <AFNetworking/AFNetworking.h>
#import "HMCache.h"
#import "HMCategoryComm.h"

#pragma mark -
#pragma mark -
#pragma mark ----------HMHTTPFlowManager------------
#pragma mark -


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
    [self saveWithArchiver:[NSString stringWithFormat:@"HMHTTPFlowManager/%@",[[NSDate date] stringWithDateFormat:@"yyyy-MM"]]];
}
+ (instancetype)spwanTody{
    HMHTTPFlowManager *flow = [HMHTTPFlowManager restoreWithArchiver:[NSString stringWithFormat:@"HMHTTPFlowManager/%@",[[NSDate date] stringWithDateFormat:@"yyyy-MM"]]];
    if (flow==nil) {
        flow = [[[HMHTTPFlowManager alloc]init]autorelease];
        flow.fromDate = [NSDate date];
    }
    return flow;
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

#pragma mark -
#pragma mark ----------HMHTTPRequestOperationManager------------
#pragma mark -

@interface HMHTTPRequestOperationManager ()

@property(nonatomic,HM_STRONG,readwrite) NSMutableArray *requests;
@property(nonatomic,readwrite) AFNetworkReachabilityStatus   status;
@property(nonatomic,HM_STRONG) NSRecursiveLock *lock;
@property (nonatomic, HM_STRONG) NSURL *baseURL;

@end

@implementation HMHTTPRequestOperationManager{
    AFNetworkReachabilityStatus   _status;
    NSMutableArray * _requests;
    long long _maxMemeryCache;
}

@synthesize requests = _requests;
@synthesize flower;
@synthesize status = _status;
@synthesize lock=_lock;

@synthesize	blackListEnable = _blackListEnable;
@synthesize	blackListTimeout = _blackListTimeout;
@synthesize blackListTrytime;
@synthesize	blackList = _blackList;
@synthesize maxMemeryCache = _maxMemeryCache;
@synthesize baseURL;
@synthesize reachableDomain=_reachableDomain;

#pragma mark - init

DEF_SINGLETON_AUTOLOAD(HMHTTPRequestOperationManager)
+ (instancetype)sharedImageInstance{
    return [[self class] sharedInstance:@"IMGE_HMHTTPRequestOperationManager"];
}
+ (instancetype)sharedInstance:(NSString*)key
{
    static dispatch_once_t once;
    static NSMutableDictionary * __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[NSMutableDictionary alloc] init]; } );
    @synchronized(__singleton__){
        HMHTTPRequestOperationManager *manager = [__singleton__ objectForKey:key];
        if (manager==nil) {
            manager = [[[HMHTTPRequestOperationManager alloc]init]autorelease];
            [__singleton__ setObject:manager forKey:key];
        }
        return manager;
    }
}

-(id)init{
    return [self initWithBaseURL:nil];
}
- (void)dealloc
{
    [_lock release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_requests removeAllObjects];
    [_requests release];
    [_blackList removeAllObjects];
    [_blackList release];
    self.reachableDomain = nil;
    self.baseURL = nil;
    self.flower = nil;
    HM_SUPER_DEALLOC();
}
- (id)initWithBaseURL:(NSURL *)url
{
    static BOOL netNotif=NO;
    self = [super initWithBaseURL:url];
    if (self) {
        [self.operationQueue setMaxConcurrentOperationCount:8];
        _requests = [[NSMutableArray alloc]init];
        _blackListEnable = YES;
        _blackListTimeout = DEFAULT_BLACKLIST_TIMEOUT;
        blackListTrytime = 3;
        _blackList = [[NSMutableDictionary alloc] init];
        _maxMemeryCache = DEFAULT_MAX_MEMERYCACHE;
        _lock = [[NSRecursiveLock alloc]init];
//        [self observeNotification:AFNetworkingOperationDidStartNotification];
//        [self observeNotification:UIApplicationWillEnterForegroundNotification];
        [self observeNotification:UIApplicationDidEnterBackgroundNotification];
        if (!netNotif) {
            netNotif = YES;
            [self observeNotification:AFNetworkingOperationDidFinishNotification];
            [self observeNotification:AFNetworkingReachabilityDidChangeNotification];
            
            self.reachableDomain = @"www.apple.com";
            [self resetFlowdata];
        }
        
    }
    return self;
}

- (void)setReachableDomain:(NSString *)reachableDomain{
    [_reachableDomain release];
    _reachableDomain = [reachableDomain copy];
    if (reachableDomain) {
        if (self.reachabilityManager) {
            [self.reachabilityManager stopMonitoring];
        }
        self.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:reachableDomain];
        [self.reachabilityManager startMonitoring];
        
        _status = self.reachabilityManager.networkReachabilityStatus;
    }
}

ON_NOTIFICATION(notification){
    if ([notification is:AFNetworkingOperationDidFinishNotification]){
        
        [self requestFinish:notification];
        
    }else if ([notification is:AFNetworkingReachabilityDidChangeNotification]) {
        
        AFNetworkReachabilityStatus status = [[notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
        self.status = status;
        NSString *state = @"";
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                state = @"wifi";
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                state = @"WWAN";
                break;
            case AFNetworkReachabilityStatusNotReachable:
                state = @"notReachable";
                break;
                
            default:
                state = @"unknown";
                break;
        }
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"HTTP",@">>>>>>>>>>>>>>>>>>>>>reachability changed %@",state);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        
    }else if ([notification is:UIApplicationDidEnterBackgroundNotification]){
        
        [self stroeFlowdata];
        
    }else if ([notification is:UIApplicationWillEnterForegroundNotification]){
       

    }
}

- (void)resetFlowdata{
    self.flower = [HMHTTPFlowManager spwanTody];
}

- (void)stroeFlowdata{
    [self.flower stroe];
}

- (void)clearFlowdata{
    
    [self.flower clear];
    
}

-(void)requestFinish:(NSNotification *)notif{
    HMHTTPRequestOperation *operation = notif.object;
    BOOL isCache = NO;
    if ([operation respondsToSelector:@selector(isCache)]) {
        isCache = operation.isCache;
    }
   
    long long up = 0;
    long long down = 0;
    if ([operation respondsToSelector:@selector(uploadBytes)]) {
        up = operation.uploadBytes;
        down = operation.downloadBytes;
    }else{
        up = operation.request.HTTPBody.length;
        down = operation.responseData.length;
    }
    if (!isCache) {
        if ([self isNetworkWifi]) {
            self.flower.flowUpload += up;
            self.flower.flowDownload += down;
        }else if ([self isNetworkWWAN]){
            self.flower.flowUploadWWAN += up;
            self.flower.flowDownloadWWAN += down;
        }
        
    }
    
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"HTTP",@"Kbps up/dn wifi:%@/%@  gprs/edge/3g:%@/%@",[NSString formatVolume:self.flower.flowUpload],[NSString formatVolume:self.flower.flowDownload],[NSString formatVolume:self.flower.flowUploadWWAN],[NSString formatVolume:self.flower.flowDownloadWWAN]);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    
}

#pragma mark - lifecycle
+(void)setBaseUrl:(NSURL *)url{
    
    [HMHTTPRequestOperationManager sharedInstance].baseURL = url;
    [HMHTTPRequestOperationManager sharedImageInstance].baseURL = url;
}

- (int)checkResourceBroken:(NSString *)url
{
	if ( _blackListEnable )
	{		
		NSMutableDictionary *dic = [_blackList objectForKey:url];
        if (dic==nil) {
            return 0;
        }
        NSDate * date = nil;
		NSDate * now = [NSDate date];
        NSNumber *count = [dic objectForKey:@"count"];
        
		date = [dic objectForKey:@"date"];
		if (count && date && [count compare:[NSNumber numberWithUnsignedInteger:blackListTrytime]]==NSOrderedDescending && ([now timeIntervalSince1970] - [date timeIntervalSince1970]) < _blackListTimeout )
		{
			ERROR( @"resource broken:%@ %@",count, url );
			return -1;
		}
        if (date) {
            return 1;
        }
	}
    
	return 0;
}
- (void)blockURL:(NSString *)url
{
    if (!_blackListEnable) {
        return;
    }
    
    [self.lock lock];
    
    NSMutableDictionary *dic = [_blackList objectForKey:url];
    NSNumber *count = [NSNumber numberWithInt:1];
    if (!dic){
        dic = [NSMutableDictionary dictionary];
    }else{
        count = [dic valueForKey:@"count"];
        count = [NSNumber numberWithInteger:[count integerValue]+1];
    }
    
    [dic setObject:[NSDate date] forKey:@"date"];
    [dic setObject:count forKey:@"count"];
    
	[_blackList setObject:dic forKey:url];
#if (__ON__ == __HM_DEVELOPMENT__)
    ERROR( @"blockURL broken:%@ %@",count, url );
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    [self.lock unlock];
}

- (void)unblockURL:(NSString *)url
{
    if (!_blackListEnable) {
        return;
    }
    [self.lock lock];
	if ( [_blackList objectForKey:url] )
	{
		[_blackList removeObjectForKey:url];
#if (__ON__ == __HM_DEVELOPMENT__)
      ERROR( @"blockURL unblock: %@", url );
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
	}
    [self.lock unlock];
}
#pragma mark life time


+ (NSArray *)requests:(NSString *)url
{
	return [[HMHTTPRequestOperationManager sharedInstance] requests:url];
}

- (NSArray *)requests:(NSString *)url
{
	NSMutableArray * array = [NSMutableArray array];
	[self.lock lock];
	for ( HMHTTPRequestOperation * request in _requests )
	{
		if ( [[request.request.URL absoluteString] isEqualToString:url] )
		{
			[array addObject:request];
		}
	}
	[self.lock unlock];
	return array;
}

+ (NSArray *)requests:(NSString *)url byResponder:(id)responder
{
	return [[HMHTTPRequestOperationManager sharedInstance] requests:url byResponder:responder];
}

- (NSArray *)requests:(NSString *)url byResponder:(id)responder
{
	NSMutableArray * array = [NSMutableArray array];
    [self.lock lock];
	for ( HMHTTPRequestOperation * request in _requests )
	{
		if ( responder && NO == [request hasResponder:responder] )
			continue;
		
		if ( nil == url || [[request.request.URL absoluteString] isEqualToString:url] )
		{
			[array addObject:request];
		}
	}
    [self.lock unlock];
	return array;
}


+ (void)cancelRequest:(HMHTTPRequestOperation *)request
{
	[[HMHTTPRequestOperationManager sharedInstance] cancelRequest:request];
    [[HMHTTPRequestOperationManager sharedImageInstance] cancelRequest:request];
}

- (void)cancelRequest:(HMHTTPRequestOperation *)request
{
	[self.lock lock];
	if ( [_requests containsObject:request] )
	{

		if ( request.created || request.sending || request.recving )
		{
			[request cancel];
#if (__ON__ == __HM_DEVELOPMENT__)
            CC( @"HTTP",@"canceling the request now state:%@ will remove responders",descWithState(request.status));
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
		}
        
        [request removeAllResponders];
        [_requests removeObject:request];
        
	}
    [self.lock unlock];
}

+ (void)cancelRequestByResponder:(id)responder
{
	[[HMHTTPRequestOperationManager sharedInstance] cancelRequestByResponder:responder];
    [[HMHTTPRequestOperationManager sharedImageInstance] cancelRequestByResponder:responder];
}

- (void)cancelRequestByResponder:(id)responder
{
	if ( nil == responder )
	{
        return;
//		[self cancelAllRequests];
	}
	else
	{
		NSMutableArray * tempArray = [NSMutableArray array];
		[self.lock lock];
		for ( HMHTTPRequestOperation * request in _requests )
		{
			if ( [request hasResponder:responder]  )
			{
				[tempArray addObject:request];
			}
		}
		[self.lock unlock];
		for ( HMHTTPRequestOperation * request in tempArray )
		{
			[self cancelRequest:request];
		}
	}
}

+ (void)cancelAllRequests
{
	[[HMHTTPRequestOperationManager sharedInstance] cancelAllRequests];
}

- (void)cancelAllRequests
{
	NSMutableArray * allRequests = [NSMutableArray arrayWithArray:_requests];
	
	for ( HMHTTPRequestOperation * request in allRequests )
	{
		[self cancelRequest:request];
	}
}

+ (void)disableResponder:(id)respnder
{
	[[HMHTTPRequestOperationManager sharedInstance] disableResponder:respnder];
	[[HMHTTPRequestOperationManager sharedImageInstance] disableResponder:respnder];
}

- (void)disableResponder:(id)respnder
{
    [self.lock lock];
	NSMutableArray * allRequests = [NSMutableArray arrayWithArray:_requests];
	
	for ( HMHTTPRequestOperation * request in allRequests )
	{
        if ([request.responders containsObject:respnder]) {
            [request.responders removeObject:respnder];
            if (request.responders.count==0) {
                request.completionBlock = nil;
//                [request setCompletionBlockWithSuccess:nil failure:nil];
            }
        }
	}
    [self.lock unlock];
}

+ (void)disableResponder:(id)respnder byStringUrl:(NSString *)url
{
	[[HMHTTPRequestOperationManager sharedInstance] disableResponder:respnder  byStringUrl:(NSString *)url];
    [[HMHTTPRequestOperationManager sharedImageInstance] disableResponder:respnder  byStringUrl:(NSString *)url];
}

- (void)disableResponder:(id)respnder  byStringUrl:(NSString *)url
{
    [self.lock lock];
	NSMutableArray * allRequests = [NSMutableArray arrayWithArray:_requests];
	
	for ( HMHTTPRequestOperation * request in allRequests )
	{
		if ([request.responders containsObject:respnder]) {
            if (url!=nil&&[request.url isEqualToString:url]) {
                [request.responders removeObject:respnder];
            }else if (url==nil){
                [request.responders removeObject:respnder];
            }
            if (request.responders.count==0) {
                request.completionBlock = nil;
//                [request setCompletionBlockWithSuccess:nil failure:nil];
            }
        }
	}
    [self.lock unlock];
}

+ (void)disableRespondersByTagString:(NSString *)tagString
{
    [self disableRespondersByTagString:tagString responder:nil];
}

+ (void)disableRespondersByTagString:(NSString *)tagString responder:(id)responder
{
    [[HMHTTPRequestOperationManager sharedInstance] disableRespondersByTagString:tagString responder:responder];
    
    [[HMHTTPRequestOperationManager sharedImageInstance] disableRespondersByTagString:tagString responder:responder];
}

- (void)disableRespondersByTagString:(NSString *)tagString responder:(id)responder{
    if (tagString.length==0&&responder==nil) {
        return;
    }
    [self.lock lock];
    NSMutableArray * allRequests = [NSMutableArray arrayWithArray:_requests];
    
    for ( HMHTTPRequestOperation * request in allRequests )
    {
        if ([request.responders containsObject:responder]) {
            request.completionBlock = nil;
            [request.responders removeObject:responder];
        }
        if ([request.tagString isEqualToString:tagString]) {
            request.completionBlock = nil;
            //            [request setCompletionBlockWithSuccess:nil failure:nil];
            [request.responders removeAllObjects];
        }
    }
    [self.lock unlock];

}

- (void)disableRespondersByTagString:(NSString *)tagString
{
    if (tagString.length==0) {
        return;
    }
    [self.lock lock];
    NSMutableArray * allRequests = [NSMutableArray arrayWithArray:_requests];
    
    for ( HMHTTPRequestOperation * request in allRequests )
    {
        if ([request.tagString isEqualToString:tagString]) {
            request.completionBlock = nil;
//            [request setCompletionBlockWithSuccess:nil failure:nil];
            [request.responders removeAllObjects];
        }
    }
    [self.lock unlock];
}


+(HMHTTPRequestOperation *)requestByResponse:(id)response{
    return [[HMHTTPRequestOperationManager sharedInstance] requestByResponse:response];
}

-(HMHTTPRequestOperation *)requestByResponse:(id)response{
    NSMutableArray * allRequests = [NSMutableArray arrayWithArray:_requests];
	
	for ( HMHTTPRequestOperation * request in allRequests )
	{
		if ([request.responders containsObject:response]) {
            return request;
        }
	}
    return nil;
}

#pragma mark -

-(void)startAsync:(HMHTTPRequestOperation *)operation{
    if (![operation isFinished]) {
        [self.operationQueue addOperation:operation];
    }
    
}
+ (HMHTTPRequestOperation*)sendingForURLString:(NSString *)URLString addResponder:(id)responder{
    
   HMHTTPRequestOperation *operation =  [[HMHTTPRequestOperationManager sharedInstance] sendingForURLString:URLString addResponder:responder];
    if (!operation) {
        operation = [[HMHTTPRequestOperationManager sharedImageInstance] sendingForURLString:URLString addResponder:responder];
    }
    return operation;
}
- (HMHTTPRequestOperation*)sendingForURLString:(NSString *)URLString addResponder:(id)responder{
    if (URLString==nil) {
        return nil;
    }
    NSString *url = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
    NSArray *array = [NSArray arrayWithArray:_requests];
    for (HMHTTPRequestOperation *operation in array) {
        
        if ([operation.url isEqualToString:url]&&(operation.status==-1||[operation created]||[operation recving]||[operation sending])) {
            if (responder) {
                [operation addResponder:responder];
            }
            return operation;
        }
    }
    return nil;
}

- (HMHTTPRequestOperation *)REQUESTForMethod:(NSString *)method
                                   URLString:(NSString *)URLString
                                  parameters:(NSDictionary *)parameters
                                   responder:(id)responder
                                     timeOut:(NSTimeInterval)seconds
                                    autoLoad:(BOOL)autoLoad
{
    NSString *url = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
    
    HMHTTPRequestOperation *operation = [HMHTTPRequestOperation spawnForMethod:method URLString:url error:nil];
    
    [operation setRequestType:HTTPRequestType_Normal];
    [operation setResponseType:HTTPResponseType_JSON];
    
    operation.parameters = parameters;
    operation.timeOutInterval = seconds;
    
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    [operation addResponder:responder];
    
    if (![_requests containsObject:operation]) {
        
        [self.lock lock];
        [_requests addObject:operation];
//#if (__ON__ == __HM_DEVELOPMENT__)
//        CC( @"HTTP",@"now request count:%d",_requests.count);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        [self.lock unlock];
        
    }
    
    operation.autoLoad = autoLoad;
    
    if (autoLoad) {
//        __block __strong_type typeof(self) blockSelf = self;
//        [self delay:.05 invoke:^{
//            [blockSelf startAsync:operation];
//        }];
        [self performSelector:@selector(startAsync:) withObject:operation afterDelay:0.01f inModes:@[NSRunLoopCommonModes]];
    }

    
    return operation;
    
}

- (HMHTTPRequestOperation *)REQUESTForMethod:(NSString *)method
                                   URLString:(NSString *)URLString
                                  parameters:(NSDictionary *)parameters
                                   responder:(id)responder
                                     timeOut:(NSTimeInterval)seconds
{
    return  [self REQUESTForMethod:method URLString:URLString parameters:parameters responder:responder timeOut:seconds autoLoad:YES];
    
}
#pragma mark -

- (HMHTTPRequestOperation *)GET_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [self REQUESTForMethod:@"GET" URLString:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}
+ (HMHTTPRequestOperation *)GET_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [[HMHTTPRequestOperationManager sharedInstance] GET_HTTP:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}

- (HMHTTPRequestOperation *)POST_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [self REQUESTForMethod:@"POST" URLString:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}

+ (HMHTTPRequestOperation *)POST_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [[HMHTTPRequestOperationManager sharedInstance] POST_HTTP:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}

- (HMHTTPRequestOperation *)UPLOAD_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds constructingBodyWithBlock:(HTTPUploadDataBlock)block
{
    
    HMHTTPRequestOperation * opertion = [self REQUESTForMethod:@"POST" URLString:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    [opertion setUploadDataBlock:block];
    
    return opertion;
}
+ (HMHTTPRequestOperation *)UPLOAD_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds constructingBodyWithBlock:(HTTPUploadDataBlock)block{
    
    return [[HMHTTPRequestOperationManager sharedInstance] UPLOAD_HTTP:URLString parameters:parameters responder:responder timeOut:seconds constructingBodyWithBlock:block];
    
}

#pragma mark other

- (HMHTTPRequestOperation *)PUT_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [self REQUESTForMethod:@"PUT" URLString:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}
+ (HMHTTPRequestOperation *)PUT_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [[HMHTTPRequestOperationManager sharedInstance] PUT_HTTP:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}
- (HMHTTPRequestOperation *)DELETE_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [self REQUESTForMethod:@"DELETE" URLString:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}
+ (HMHTTPRequestOperation *)DELETE_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [[HMHTTPRequestOperationManager sharedInstance] DELETE_HTTP:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}

- (HMHTTPRequestOperation *)HEAD_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [self REQUESTForMethod:@"HEAD" URLString:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}
+ (HMHTTPRequestOperation *)HEAD_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [[HMHTTPRequestOperationManager sharedInstance] HEAD_HTTP:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}
- (HMHTTPRequestOperation *)PATCH_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [self REQUESTForMethod:@"PATCH" URLString:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}
+ (HMHTTPRequestOperation *)PATCH_HTTP:(NSString *)URLString parameters:(NSDictionary *)parameters responder:(id)responder timeOut:(NSTimeInterval)seconds{
    
    return [[HMHTTPRequestOperationManager sharedInstance] PATCH_HTTP:URLString parameters:parameters responder:(id)responder timeOut:seconds];
    
}

@end

#pragma mark -
#pragma mark ----------NSObject (OperationManger)------------
#pragma mark -

@implementation NSObject (OperationManger)


- (HMHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    if ([self isKindOfClass:[HMHTTPRequestOperationManager class]]) {
        NSAssert(false, @"you must call HMHTTPRequestOperationManager self method");
    }
    return [HMHTTPRequestOperationManager
            GET_HTTP:URLString
            parameters:parameters
            responder:self
            timeOut:seconds?seconds:DEFAULT_GET_TIMEOUT];
    
}

- (HMHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [HMHTTPRequestOperationManager
            POST_HTTP:URLString
            parameters:parameters
            responder:self
            timeOut:seconds?seconds:DEFAULT_GET_TIMEOUT];
    
}

- (HMHTTPRequestOperation *)UPLOAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds  constructingBodyWithBlock:(HTTPUploadDataBlock)block{
    
    return [HMHTTPRequestOperationManager
            UPLOAD_HTTP:URLString
            parameters:parameters
            responder:self
            timeOut:seconds?seconds:DEFAULT_UPLOAD_TIMEOUT
            constructingBodyWithBlock:block];
    
}

-(HMHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [HMHTTPRequestOperationManager
            PUT_HTTP:URLString
            parameters:parameters
            responder:self
            timeOut:seconds?seconds:DEFAULT_GET_TIMEOUT];
    
}

-(HMHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [HMHTTPRequestOperationManager
            DELETE_HTTP:URLString
            parameters:parameters
            responder:self
            timeOut:seconds?seconds:DEFAULT_GET_TIMEOUT];
    
}

-(HMHTTPRequestOperation *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [HMHTTPRequestOperationManager
            HEAD_HTTP:URLString
            parameters:parameters
            responder:self
            timeOut:seconds?seconds:DEFAULT_GET_TIMEOUT];
    
}

-(HMHTTPRequestOperation *)PATCH:(NSString *)URLString parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds{
    
    return [HMHTTPRequestOperationManager
            PATCH_HTTP:URLString
            parameters:parameters
            responder:self
            timeOut:seconds?seconds:DEFAULT_GET_TIMEOUT];
    
}

- (HMHTTPRequestOperation *)DOWNLOAD:(NSString *)URLString
                         parameters:(NSDictionary *)parameters timeOut:(NSTimeInterval)seconds
                            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSURL *URL = [NSURL URLWithString:URLString];
    
    if (URL==nil) {
        if (failure) {
            failure(nil,nil);
        }
        return nil;
    }
    NSData *data = [HMHTTPRequestOperation imageDataCachedWithURL:URL];
    if (data) {
        if (success) {
            success(nil,data);
        }
        return nil;
    }
    HMHTTPRequestOperation * opertaion = [self attemptingForURLString:URLString];
    if (opertaion) {
        return opertaion;
    }
    if (seconds==0) {
        seconds = 60;
    }
    if ([[[URLString pathExtension] lowercaseString] rangeOfString:@"gif"].location != NSNotFound) {
        opertaion = [self GET:URLString parameters:parameters timeOut:MAX(seconds, 120)];
    }else{
        opertaion = [self GET:URLString parameters:parameters timeOut:seconds];
    }
    
    [opertaion setResponseType:HTTPResponseType_Normal];
    opertaion.order = AFDataCacheKeyFromURLRequest(URL);
    opertaion.useCache = YES;
    opertaion.shouldResume = YES;
    opertaion.refreshCache = YES;
    [opertaion setCompletionBlockWithSuccess:success failure:failure];
    return opertaion;
    
}

#pragma mark -
- (BOOL)prehandleRequest:(HMHTTPRequestOperation *)request
{
	return YES;
}

- (void)posthandleRequest:(HMHTTPRequestOperation *)request
{
	
}

- (void)handleRequest:(HMHTTPRequestOperation *)request
{
    //#if (__ON__ == __HM_DEVELOPMENT__)
    //    WARN(@"HTTP:",@"\t'%@' %@ %@ \n%@",request.order,@"does not be processed",descForState(request.status),request.responseObject);
    //#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}
#pragma mark -
- (HMHTTPRequestOperation *)ownRequest{
    return [HMHTTPRequestOperationManager requestByResponse:self];
}

-(id)responseData{
    return [self.ownRequest responseObject];
}

- (void)startAsync{
    if ([self isKindOfClass:[HMHTTPRequestOperation class]]) {
        [[HMHTTPRequestOperationManager sharedInstance] startAsync:(HMHTTPRequestOperation*)self];
    }
}

-(void)cancelRequest{
    [HMHTTPRequestOperationManager cancelRequestByResponder:self];
}

- (HMHTTPRequestOperation*)sendingForURLString:(NSString *)URLString{
    return [HMHTTPRequestOperationManager sendingForURLString:URLString addResponder:nil];
}
- (HMHTTPRequestOperation*)attemptingForURLString:(NSString *)URLString{
    return [HMHTTPRequestOperationManager sendingForURLString:URLString addResponder:self];
}

- (void)disableHttpRespondersByTagString:(NSString *)tagString{
    [HMHTTPRequestOperationManager disableRespondersByTagString:tagString responder:self];
}

#pragma mark -

- (BOOL)isNetworkNotReachable{

    return [HMHTTPRequestOperationManager sharedInstance].status <= AFNetworkReachabilityStatusNotReachable;
}

- (BOOL)isNetworkWifi{

    return [HMHTTPRequestOperationManager sharedInstance].status == AFNetworkReachabilityStatusReachableViaWiFi;
    
}
- (BOOL)isNetworkWWAN{

    return [HMHTTPRequestOperationManager sharedInstance].status == AFNetworkReachabilityStatusReachableViaWWAN;
    
}

@end
