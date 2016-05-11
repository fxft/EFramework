//
//  HMServiceSinaWB.m
//  CarAssistant
//
//  Created by Eric on 14-4-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMServiceSinaWB.h"
#import "WeiboSDK.h"
#import "HMShareService.h"

@interface HMServiceSinaWB ()<WeiboSDKDelegate,WBHttpRequestDelegate,HMShareServiceProtocol>

@property (nonatomic,retain) NSString *wbToken;

@end

@implementation HMServiceSinaWB

DEF_SINGLETON( HMServiceSinaWB )


@dynamic installed;
@synthesize shareType=_shareType;
@synthesize sendType=_sendType;
@synthesize wbToken;
@synthesize scheme=_scheme;
@synthesize redirectURI;
@synthesize appSecret;

- (id)init{
    if(self = [super init]){
        [self observeNotification:[HMUIApplication LAUNCHED]];
        [self checkAuthorizeExpire];
    }
    return self;
}

- (void)dealloc
{
    self.wbToken = nil;
    self.scheme = nil;
    self.redirectURI = nil;
    self.appSecret = nil;
    HM_SUPER_DEALLOC();
}

- (BOOL)checkAuthorizeExpire{
    NSDictionary *wbDic = [self userDefaultsRead:@"__WBAuthorizeResponse"];
    BOOL ret = YES;
    if (wbDic) {
        NSDate  * expirationDate = [wbDic objectForKey:@"expirationDate"];
        self.wbToken = [wbDic objectForKey:@"accessToken"];
        if ([expirationDate isKindOfClass:[NSDate class]]) {
           ret = [expirationDate compare:[NSDate date]]!=NSOrderedDescending?YES:NO;
        }
        
    }
    if (ret) {
        [self userDefaultsRemove:@"__WBAuthorizeResponse"];
    }
    return ret;
}

- (void)logout{
    
    [WeiboSDK logOutWithToken:self.wbToken delegate:self withTag:@"logout"];
    
}

- (void)inviteFriend:(NSString *)desc uid:(NSString*)uid{
    [WeiboSDK inviteFriend:desc withUid:uid withToken:self.wbToken delegate:self withTag:@"invite"];
}

ON_NOTIFICATION3(HMUIApplication, LAUNCHED, __notification){
    NSDictionary *params = __notification.object;
    
    NSURL *url = [params valueForKey:LaunchNotificationUrlKey];
    if (url) {
        [WeiboSDK handleOpenURL:url delegate:self];
    }
    
}

#pragma mark -

- (BOOL)installed{
    return [WeiboSDK isWeiboAppInstalled];
}

+ (void)registerApp:(NSString *)appid{
#if DEBUG
    [WeiboSDK enableDebugMode:YES];
#endif
    //向微信注册
    [WeiboSDK registerApp:appid];
}

- (BOOL)checkInstalled
{
	BOOL installed = [WeiboSDK isWeiboAppInstalled];
	if ( NO == installed )
	{
        [self postNotification:[HMShareService HMShareServiceRespone]
                    withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                         state:HMPublishContentStateFail
                                                    statusInfo:nil
                                                     errorCode:HMErrCodeUninstalled]];
		return NO;
	}
    
	return YES;
}


- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
       
    }
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"WB",request);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        WeiboSDKResponseStatusCode status = [(WBSendMessageToWeiboResponse *)response statusCode];
        if (status == WeiboSDKResponseStatusCodeSuccess) {
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                             state:HMPublishContentStateSuccess
                                                        statusInfo:nil
                                                         errorCode:HMSuccess]];
        }else if (status == WeiboSDKResponseStatusCodeSentFail) {
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeSentFail]];
        }else if (status == WeiboSDKResponseStatusCodeUserCancel) {
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeUserCancel]];
        }else if (status == WeiboSDKResponseStatusCodeUnsupport) {
            [self postNotification:[HMShareService HMShareServiceRespone]
                    withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                         state:HMPublishContentStateFail
                                                    statusInfo:nil
                                                     errorCode:HMErrCodeUnsupport]];
        }else {
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeCommon]];
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        WeiboSDKResponseStatusCode status = [(WBAuthorizeResponse *)response statusCode];
        if (status == WeiboSDKResponseStatusCodeSuccess) {
            NSString * userID = [(WBAuthorizeResponse *)response userID];
            NSString * wbtoken = [(WBAuthorizeResponse *)response accessToken];
            NSDate * expirationDate = [(WBAuthorizeResponse *)response expirationDate];
            
            NSDictionary *wbDic = @{@"userID": userID==nil?@"":userID,
                                    @"accessToken": wbtoken==nil?@"":wbtoken,
                                    @"expirationDate": expirationDate==nil?[NSDate date]:expirationDate,};
            [self userDefaultsWrite:wbDic forKey:@"__WBAuthorizeResponse"];
            
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                             state:HMPublishContentStateSuccess
                                                        statusInfo:nil
                                                         errorCode:HMAuthOK]];
        }else{
            HMErrCode code = HMErrCodeCommon;
            if (status == WeiboSDKResponseStatusCodeUserCancel){
                code = HMErrCodeUserCancel;
            }else if (status == WeiboSDKResponseStatusCodeAuthDeny){
                code = HMErrCodeAuthDeny;
            }
            [self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:code]];
        }
    }
}

- (void)authorizing
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = self.redirectURI;
    request.scope = @"all";
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                     state:HMPublishContentStateBegan
                                                statusInfo:nil
                                                 errorCode:HMAuthOK]];
    [WeiboSDK sendRequest:request];
}

- (void)shareBody:(HMShareItemObject *)body{
    
    
    self.sendType = (NSInteger)body.sendType;
    self.shareType = (NSInteger)body.subType;
    self.redirectURI = body.redirectURI;
    self.appSecret = body.appSecret;
    
    [self share:body.title description:body.description scheme:body.scheme thumb:body.thumb media:body.media type:body.mediaType];
}

- (void)share:(NSString*)title description:(NSString*)description scheme:(NSString*)scheme
        thumb:(id)thumb media:(id)media type:(NSInteger)type
{
    if ([self checkAuthorizeExpire]) {
        [self authorizing];
        return;
    }
	BOOL result = [self checkInstalled];
	if ( NO == result ){
        //获取授权信息
        //授权
        return;
    }
		
    WBMessageObject *message = [WBMessageObject message];
    
    if ( media )
	{
        NSData *thumbData = nil;
        if ( thumb )
		{
			if ( [thumb isKindOfClass:[UIImage class]] )
			{
				thumbData = [(UIImage *)thumb dataWithExt:@"png"];
			}
			else if ( [thumb isKindOfClass:[NSString class]] )
			{
				thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:(NSString *)thumb]];
			}
			else if ( [thumb isKindOfClass:[NSData class]] )
			{
				thumbData = (NSData *)thumb;
			}
		}

        NSInteger mediaType = 0;
        if ( [media isKindOfClass:[UIImage class]] )
        {
            mediaType=0;//imageObject.imageData = [(UIImage *)media dataWithExt:@"png"];
        }
        else if ( [media isKindOfClass:[NSString class]] )
        {
            mediaType=1;//imageObject.imageUrl = (NSString *)media;
        }else if ( [media isKindOfClass:[NSData class]] )
        {
            mediaType=2;
        }else{
            NSAssert(NO, @"media type not be supported");
        }
        
        switch (type) {
            case SLMediaTypeImage://WBImageObject
            {
                WBImageObject * imageObject = [WBImageObject object];
                NSData *data = nil;
                if (mediaType==0) {
                    data = [(UIImage*)media dataWithExt:@"png"];
                }else if (mediaType==2){
                    data = (NSData *)media;
                }else if (mediaType==1){
                    data = [NSData dataWithContentsOfFile:(NSString*)media];
                }
                
                imageObject.imageData = data;
                message.imageObject = imageObject;
            }
                break;
            case SLMediaTypeMusic://WBMusicObject
            {
                WBMusicObject * imageObject = [WBMusicObject object];
                NSAssert(mediaType==1, @"share music can only share a url");
                imageObject.musicUrl = (NSString *)media;
                imageObject.scheme = scheme;
                imageObject.title = title;
                message.mediaObject = imageObject;
            }
                break;
            case SLMediaTypeVideo://WBVideoObject
            {
                WBVideoObject * imageObject = [WBVideoObject object];
                NSAssert(mediaType==1, @"share video can only share a url");
                imageObject.videoUrl = (NSString *)media;
                imageObject.scheme = scheme;
                imageObject.title = title;
                message.mediaObject = imageObject;
            }
                break;
            case SLMediaTypeWebpage://WBWebpageObject
            {
                WBWebpageObject * imageObject = [WBWebpageObject object];
                NSAssert(mediaType==1, @"share web page can only share a url");
                imageObject.objectID = [NSString stringWithFormat:@"%d",[(NSString *)media hash]];
                imageObject.webpageUrl = (NSString *)media;
                imageObject.description = description;
                imageObject.title = title;
                imageObject.thumbnailData = thumbData;
                imageObject.scheme = scheme;
                message.mediaObject = imageObject;
            }
                break;
            
            default:
                break;
        }
        
    }
    
    message.text = title;
    
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeSinaWeibo
                                                     state:HMPublishContentStateBegan
                                                statusInfo:nil
                                                 errorCode:HMSuccess]];
    
    if (self.sendType==SLSendTypeReq){
        WBBaseRequest *req = [WBSendMessageToWeiboRequest requestWithMessage:message];
        
        [WeiboSDK sendRequest:req];
    }else{
        WBBaseResponse *req = [WBProvideMessageForWeiboResponse responseWithMessage:message];
        
        [WeiboSDK sendResponse:req];
    }
    
}
@end
