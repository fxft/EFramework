//
//  HMWebAPI.m
//  CarAssistant
//
//  Created by Eric on 14-4-19.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMWebAPI.h"

@interface HMWebAPI ()
@property (nonatomic,strong) NSMutableDictionary * networkS;
@end

@implementation HMWebAPI

DEF_SERVICE_AUTOSHARE(HMWebAPI);
DEF_STATIC_PROPERTY( userinfo )
DEF_STATIC_PROPERTY( params )
DEF_STATIC_PROPERTY( headers )
DEF_STATIC_PROPERTY( command )
DEF_STATIC_PROPERTY( name )
DEF_STATIC_PROPERTY( method )
DEF_STATIC_PROPERTY( cacheParams )
DEF_STATIC_PROPERTY( urlParams )
DEF_STATIC_PROPERTY( configParams )

DEF_STATIC_PROPERTY( methodMock )
DEF_STATIC_PROPERTY( methodMockTimeOut )
DEF_STATIC_PROPERTY( methodMockFail )
DEF_STATIC_PROPERTY( methodMockMiss )
DEF_STATIC_PROPERTY( methodMockSuccess )

DEF_STATIC_PROPERTY( uploadBlock )
DEF_STATIC_PROPERTY( dataBlock )

DEF_STATIC_PROPERTY( cacheDuration )
DEF_STATIC_PROPERTY( cacheLast )

DEF_STATIC_PROPERTY( urlEncoding )
DEF_STATIC_PROPERTY( responseEncoding )
DEF_STATIC_PROPERTY( responseJs2oc )
DEF_STATIC_PROPERTY( urlResponseType )
DEF_STATIC_PROPERTY( urlRequestType )

DEF_STATIC_PROPERTY( process )

@synthesize baseUrl;
@synthesize useCookiePersistence;
@synthesize enableMock;
@synthesize enableJson2Object;
@synthesize cookiesForHost;
@synthesize useCookieFilterHost;
@synthesize defaultEncoding;

- (void)load{
    self.cookiesForHost = [NSMutableDictionary dictionary];
    self.enableJson2Object = YES;
//    [HMHTTPRequestOperationManager sharedInstance];
    self.networkS = [NSMutableDictionary dictionary];
}

- (void)unload{
    self.baseUrl = nil;
    self.cookiesForHost = nil;
    [self.networkS removeAllObjects];
    self.networkS = nil;
}

- (HMNetWork*)networkForRequestType:(HTTPRequestType)urlRequestType requestType:(HTTPResponseType)urlResponeType{
    NSString *key = [NSString stringWithFormat:@"%d %d",(int)urlRequestType,(int)urlResponeType];
    HMNetWork *work = nil;
    @synchronized (self.networkS) {
        work = [self.networkS objectForKey:key];
        if (work==nil) {
            work = [[HMNetWork alloc]init];
            [self.networkS setObject:work forKey:key];
        }
    }
    
    return work;
}

- (void)resetCookie:(NSURL*)URL{
//              self.useCookieFilterHost = NO;
    if (self.useCookieFilterHost&&URL) {
        
       NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:URL];
        if (cookies.count) {
            return;
        }
       cookies = [NSArray arrayWithArray:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
        if (cookies.count==0) {
            return;
        }
        NSMutableString *myCookie = [self.cookiesForHost valueForKey:URL.host];
        if (myCookie==nil) {
            myCookie=[NSMutableString string];
        }
        if (myCookie.length==0) {
            NSString *host = URL.host;
            NSPredicate * pre =[NSPredicate predicateWithFormat:@"domain CONTAINS[cd] %@",host];
        
            NSArray *aaa = [cookies filteredArrayUsingPredicate:pre];
            for (NSHTTPCookie *cookie in aaa) {
                if ([cookie.domain isEqualToString:URL.host]) {
                
                    if (myCookie.length!=0) {
                        [myCookie appendFormat:@", "];
                    }
                    [myCookie appendFormat:@"%@=%@",cookie.name,cookie.value];
                }
            }
        }
        
        if (myCookie.length) {
            [self.cookiesForHost setValue:myCookie forKey:URL.host];
            NSArray *arry = [NSHTTPCookie cookiesWithResponseHeaderFields:@{@"Set-Cookie":myCookie} forURL:URL];
            
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:arry forURL:URL mainDocumentURL:self.baseUrl];
        }
    }
}

DEF_SERVICE2(WebAPI, __dial){
    if (__dial.created){
        __dial.unique = NO;
    }else if (__dial.sending) {
        
        NSDictionary *dic = [__dial.input objectForKey:[HMWebAPI params]];
        NSDictionary *headers = [__dial.input objectForKey:[HMWebAPI headers]];
        NSString *URLString = [__dial.input objectForKey:[HMWebAPI command]];
        NSString *name = [__dial.input objectForKey:[HMWebAPI name]];
        NSString *method = [__dial.input objectForKey:[HMWebAPI method]];
        NSString *mock = [__dial.input objectForKey:[HMWebAPI methodMock]];
        
        NSDictionary *cacheParams = [__dial.input objectForKey:[HMWebAPI cacheParams]];
        NSTimeInterval duration = [[cacheParams valueForKey:[HMWebAPI cacheDuration]] doubleValue];
        NSNumber *cacheDuration = [__dial.input objectForKey:[HMWebAPI cacheDuration]];
        if (cacheDuration) {
            duration = [cacheDuration doubleValue];
        }
        
        BOOL cachelast=NO;
        NSNumber *cacheLast = [__dial.input objectForKey:[HMWebAPI cacheLast]];
        if (cacheLast) {
            cachelast = [cacheLast boolValue];
        }
        
        NSNumber *urlResponeType = [__dial.input objectForKey:[HMWebAPI urlResponseType]];
        
        NSNumber *urlRequestType = [__dial.input objectForKey:[HMWebAPI urlRequestType]];
        
        NSDictionary *urlParams = [__dial.input objectForKey:[HMWebAPI urlParams]];
        if (urlParams==nil) {
            urlParams = __dial.input;
        }
        NSStringEncoding stringEncoding = [[urlParams valueForKey:[HMWebAPI urlEncoding]] unsignedIntegerValue];
        NSStringEncoding responseEncoding = [[urlParams valueForKey:[HMWebAPI responseEncoding]] unsignedIntegerValue];
        
        NSNumber *process = [__dial.input objectForKey:[HMWebAPI process]];
        
        __dial.name = name==nil?URLString:name;
        
        if (mock==nil) {
            mock = method;
        }
        
#ifdef DEBUG
        
#else
        self.enableMock = NO;
        if ([mock notEmpty]&&[mock rangeOfString:[HMWebAPI methodMock]].location != NSNotFound) {
            method = nil;
        }
#endif
        NSURL *URL = [NSURL URLWithString:URLString relativeToURL:self.baseUrl];
        NSString *url = [URL absoluteString];
        
        [self resetCookie:URL];
        
        if (self.enableMock&&mock) {
#if (__ON__ == __HM_DEVELOPMENT__)
            CC(@"SERVICE",mock,@":",url);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
            
            if ([mock notEmpty]&&[mock rangeOfString:[HMWebAPI methodMock]].location != NSNotFound&&[mock rangeOfString:[HMWebAPI methodMockMiss]].location == NSNotFound) {
                __dial.mock = mock;

                if ([mock isEqualToString:[HMWebAPI methodMock]]||[mock isEqualToString:[HMWebAPI methodMockSuccess]]) {
                    __dial.succeed=YES;
                }else if ([mock isEqualToString:[HMWebAPI methodMockFail]]) {
                    __dial.failed=YES;
                }
                return;
            }
        }
        //配置config
        
        HMNetWork *network = [self networkForRequestType:[urlRequestType integerValue] requestType:[urlResponeType integerValue]];
        
        //配置NetWork基础属性
        if (urlResponeType) {
            network.responseType = [urlResponeType integerValue];
        }
        if (urlRequestType) {
            network.requestType = [urlRequestType integerValue];
        }
        
        if (defaultEncoding) {
            network.sessionManager.requestSerializer.stringEncoding = defaultEncoding;
        }
        if (stringEncoding) {
            network.sessionManager.requestSerializer.stringEncoding = stringEncoding;
        }
        
        if (responseEncoding) {
            network.sessionManager.responseSerializer.stringEncoding = responseEncoding;
        }
        
        NSString *Method = method.uppercaseString;
        if ([Method is:@"POST"]||[Method is:@"UPLOAD"]) {
            
            Method = @"POST";
            
        }else if ([Method is:@"DOWNLOAD"]||[Method is:@"GET"]) {
            
            Method = @"GET";
            
        }
        
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [network taskRequestMethod:Method urlString:url parameters:dic constructingBodyWithBlock:nil error:&serializationError];
        
        if (serializationError) {
            
            return;
        }
        //设置URLRequest
        if (headers) {
            [request setAllHTTPHeaderFields:headers];
            
        }
        
        NSData *data = [__dial.input objectForKey:[HMWebAPI dataBlock]];
        if (data) {
            [request setHTTPBody:data];
        }
      
        if (cacheLast) {
            
            if (!cachelast) {
                request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            }else{
                request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
            }
        }
        
        //创建请求
        HMHTTPRequestOperation *operation = [network taskRequest:request responser:__dial success:nil sendProgressBlock:nil receiveProgressBlock:nil failure:nil timeOut:__dial.seconds];
        
        //请求配置
        if (process&&[process boolValue]) {
            if ([Method is:@"POST"]) {
                [(HMHTTPResponseHandler*)operation.responseHandlers.lastObject setProgressWithUploadProgressOfTask:operation.task];
            }else if ([Method is:@"GET"]) {
                [(HMHTTPResponseHandler*)operation.responseHandlers.lastObject setProgressWithDownloadProgressOfTask:operation.task];
            }
        }
        
        __dial.object = operation;

    }else if (__dial.succeed){
        
#if (__ON__ == __HM_DEVELOPMENT__)
        CC(@"SERVICE",@"succeed",__dial.ownRequest);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
#ifdef DEBUG
         if (self.enableMock) {
            if ([__dial.mock notEmpty]&&([__dial.mock isEqualToString:[HMWebAPI methodMock]]||[__dial.mock isEqualToString:[HMWebAPI methodMockSuccess]])) {
                id object = [__dial.mock valueForKey:__dial.name];
                __dial.output = object==nil?nil:([NSMutableDictionary dictionaryWithDictionary:@{[HMWebAPI params]: object}]);
                return;
            }
         }
#endif
        
        BOOL canJson2Object=self.enableJson2Object;
        NSNumber *responseJs2oc = [__dial.input objectForKey:[HMWebAPI responseJs2oc]];
        if (responseJs2oc) {
            canJson2Object = [responseJs2oc boolValue];
        }

        id response = __dial.ownRequest.task.responseObject;
        
//        if (__dial.ownRequest.responseType == HTTPRequestType_JSON) {
//            if (__dial.ownRequest.responseObject==nil&&__dial.ownRequest.responseData) {
//                NSString *string = [NSString stringWithCString:__dial.ownRequest.responseData.bytes encoding:__dial.ownRequest.responseSerializer.stringEncoding];
//                NSError *error = nil;
//                response = [__dial.ownRequest.responseSerializer responseObjectForResponse:__dial.ownRequest.response data:__dial.ownRequest.responseData error:&error];
//#if (__ON__ == __HM_DEVELOPMENT__)
//                CC( @"SERVICE",@"JSON Error: %@",response==nil?@"rehandle":string);
//#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
//            }
//            
//        }
//
        __dial.output = [NSMutableDictionary dictionaryWithObjectsAndKeys:response,[HMWebAPI params], nil];
        
    }else if (__dial.failed){
#ifdef DEBUG
         if (self.enableMock) {
            if ([__dial.mock notEmpty]&&[__dial.mock rangeOfString:[HMWebAPI methodMock]].location != NSNotFound) {
                id object = [__dial.mock valueForKey:__dial.name];
                __dial.output = object==nil?nil:([NSMutableDictionary dictionaryWithDictionary:@{[HMWebAPI params]: object}]);

            }
         }
#endif
    }
    
}

@end


@implementation HMDialogue (WebAPI)

#pragma mark - webApi

- (void)taskFailure:(NSURLSessionDataTask *)task request:(NSURLRequest *)resuest response:(NSHTTPURLResponse *)response error:(NSError *)error{
    
    if ( self.timeout || error.code==408)
    {
        self.errorDomain = HMDialogue.ERROR_DOMAIN_SERVER;
        self.errorCode = HMDialogue.ERROR_CODE_TIMEOUT;
        self.errorDesc = @"timeout";
        self.timeout = YES;
        
        
    }else{
        self.errorDomain = HMDialogue.ERROR_DOMAIN_NETWORK;
        self.errorCode = error.code;
        self.errorDesc = error.description;
    }
    self.failed = YES;
}

- (void)taskSuccess:(NSURLSessionDataTask *)task request:(NSURLRequest *)resuest response:(NSHTTPURLResponse *)response responseObject:(id)responseObject{
    
    self.succeed = YES;
}
- (void)taskProgressSend:(NSURLSessionDataTask *)task request:(NSURLRequest *)resuest response:(NSHTTPURLResponse *)response countOfBytesSend:(int64_t)countOfBytesSend countOfBytesExpectedToSend:(int64_t)countOfBytesExpectedToSend{
    [self internalNotifyProgressUpdated];
}
- (void)taskProgressReceived:(NSURLSessionDataTask *)task request:(NSURLRequest *)resuest response:(NSHTTPURLResponse *)response countOfBytesReceived:(int64_t)countOfBytesReceived countOfBytesExpectedToReceived:(int64_t)countOfBytesExpectedToReceived{
    [self internalNotifyProgressUpdated];
}

#pragma mark -

- (HMDialogue *)setWebUserinfo:(id)userinfo{
    
    [self.input setObject:userinfo forKey:[HMWebAPI userinfo]];
    
    return self;
}

- (NSDictionary *)webUserinfo{
    return [self.input valueForKey:[HMWebAPI userinfo]];
}


- (HMDialogue *)setWebParams:(NSDictionary *)params{
    
    [self.input setObject:params forKey:[HMWebAPI params]];
    
    return self;
}

- (NSDictionary *)webParams{
    return [self.input valueForKey:[HMWebAPI params]];
}

- (HMDialogue *)setWebHeaders:(NSDictionary *)headers{
    
    [self.input setObject:headers forKey:[HMWebAPI headers]];
    
    return self;
}

- (NSDictionary *)webHeaders{
    return [self.input valueForKey:[HMWebAPI headers]];
}

- (HMDialogue *)setWebCommand:(NSString *)command{

    self.command = command;
    
    if (command)[self.input setObject:command forKey:[HMWebAPI command]];
    
    return self;
}

- (HMDialogue *)setWebHttpMock:(NSString *)mock{
    
    [self.input setObject:mock forKey:[HMWebAPI methodMock]];
    
    return self;
}

- (HMDialogue *)setWebName:(NSString *)name{
    self.name = name;
    if (name)[self.input setObject:name forKey:[HMWebAPI name]];
    
    return self;
}

- (HMDialogue *)setWebUrlResponseType:(HTTPResponseType)type{
    
    [self.input setObject:@(type) forKey:[HMWebAPI urlResponseType]];
    
    return self;
    
}

- (HMDialogue *)setWebUrlRequestType:(HTTPRequestType)type{
    
    [self.input setObject:@(type) forKey:[HMWebAPI urlRequestType]];
    
    return self;
}


- (HMDialogue *)setWebMethod:(NSString *)method{
    
    [self.input setObject:method forKey:[HMWebAPI method]];
    
    return self;
}

- (HMDialogue *)setWebUploadBlock:(void (^)(id <AFMultipartFormData> formData))block{

    self.block = block;
//    [self.input setObject:block forKey:[HMWebAPI uploadBlock]];
    
    return self;
}

- (HMDialogue *)setWebData:(NSData *)data{
    
    [self.input setObject:data forKey:[HMWebAPI dataBlock]];
    
    return self;
}


- (HMDialogue *)setWebUrlEncoding:(NSStringEncoding)encoding{
 
    [self.input setObject:@(encoding) forKey:[HMWebAPI urlEncoding]];
    
    return self;
}

- (HMDialogue *)setWebResponseEncoding:(NSStringEncoding)encoding{
    
    [self.input setObject:@(encoding) forKey:[HMWebAPI responseEncoding]];
    
    return self;
}

- (HMDialogue *)setWebEnableJson2Object:(BOOL)js2oc{
    
    [self.input setObject:@(js2oc) forKey:[HMWebAPI responseJs2oc]];
    
    return self;
}


- (HMDialogue *)setWebCacheDuration:(NSTimeInterval)cacheDuration{
    [self.input setObject:@(cacheDuration) forKey:[HMWebAPI cacheDuration]];
    return self;
}

- (HMDialogue *)setWebDataFromNetwrokElseCache{
    [self.input setObject:@(NO) forKey:[HMWebAPI cacheLast]];
    return self;
}

- (HMDialogue *)setWebDataFromCacheElseNetwrok{
    [self.input setObject:@(YES) forKey:[HMWebAPI cacheLast]];
    return self;
}


- (void)removeCached{
    [self.ownRequest removeCached];
}

- (HMDialogue *)setWebListenProcess{
    [self.input setObject:@(YES) forKey:[HMWebAPI process]];
    return self;
}

//- (HMDialogue *)setWebRedirectBlock:(HTTPRedirectResponseBlock)block{
//    self.redirect = block;
//    return self;
//}

@end

@implementation NSObject (WebAPI)

- (HMDialogue *)webApiWithCommand:(NSString *)command{
    return [self webApiWithCommand:command timeout:30.f];
}

- (HMDialogue *)webApiWithCommand:(NSString *)command timeout:(NSTimeInterval)seconds{
    return [self webApiWithCommand:command name:command timeout:seconds];
}

- (HMDialogue *)webApiWithCommand:(NSString *)command name:(NSString *)name timeout:(NSTimeInterval)seconds{
    if (name==nil) {
        name = command;
    }
    return [[[self dealWith:[HMWebAPI WebAPI] timeout:seconds] setWebCommand:command] setWebName:name];
}

- (HMDialogue *)webApiUniqueCommand:(NSString *)command{
    
    return [self webApiUniqueCommand:command timeout:30.f];
}

- (HMDialogue *)webApiUniqueCommand:(NSString *)command timeout:(NSTimeInterval)seconds{
    
    return [self webApiUniqueCommand:command name:command timeout:seconds];
}

- (HMDialogue *)webApiUniqueCommand:(NSString *)command name:(NSString *)name timeout:(NSTimeInterval)seconds{
    if (name==nil) {
        name = command;
    }
    if (![self isSending:[HMWebAPI WebAPI] name:name byResponder:self append:YES]) {
        return [self webApiWithCommand:command name:name timeout:seconds];
    }
    return nil;
}

- (void)webApiCancelName:(NSString *)name{

    [self cancelDial:[HMWebAPI WebAPI] name:name byResponder:self];

}

- (void)webApiCancelAndDisableName:(NSString *)name{
    [self webApiCancelName:name];
    [HMDialogueQueue disableResponder:self];
}

- (HMHTTPRequestOperation *)ownRequest{
    HMHTTPRequestOperation *operation = nil;
    @synchronized ([HMWebAPI shareAutoLoad].networkS) {
        for (HMNetWork*work in [[HMWebAPI shareAutoLoad].networkS allValues]) {
            operation = [work operationForResponser:self];
        }
    }
    
    return operation;

}
@end

