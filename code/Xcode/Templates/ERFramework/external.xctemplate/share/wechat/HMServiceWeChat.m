//
//  HMServiceWeChat.m
//  CarAssistant
//
//  Created by Eric on 14-4-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMServiceWeChat.h"
#import "WXApi.h"
#import "HMShareService.h"

@interface BaseResp (HMServiceWeChat)

@end

@implementation BaseResp (HMServiceWeChat)

- (NSString *)description{
    return [NSString stringWithFormat:@"type:%d errcode:%d for %@",self.type,self.errCode,self.errStr];
}

@end

@interface HMServiceWeChat ()<WXApiDelegate,HMShareServiceProtocol>

@end

@implementation HMServiceWeChat

DEF_SINGLETON( HMServiceWeChat )

@dynamic installed;

@synthesize shareType=_shareType;
@synthesize sendType=_sendType;

- (id)init{
    if(self = [super init]){
        _shareType = WXTypeSceneSession;
        [self observeNotification:[HMUIApplication LAUNCHED]];
    }
    return self;
}

- (void)dealloc
{

    HM_SUPER_DEALLOC();
}

ON_NOTIFICATION3(HMUIApplication, LAUNCHED, __notification){
    NSDictionary *params = __notification.object;

    NSURL *url = [params valueForKey:LaunchNotificationUrlKey];
    if (url) {
        [WXApi handleOpenURL:url delegate:self];
    }
    
}


#pragma mark -

- (BOOL)installed{
    return [WXApi isWXAppInstalled];
}

+ (void)registerApp:(NSString *)appid{
    //向微信注册
    [WXApi registerApp:appid];
}

- (BOOL)checkInstalled
{
	BOOL installed = [WXApi isWXAppInstalled];
	if ( NO == installed )
	{
        [self postNotification:[HMShareService HMShareServiceRespone]
                    withObject:[HMShareServiceResult spawnWith:HMShareTypeWeChat
                                                         state:HMPublishContentStateFail
                                                    statusInfo:nil
                                                     errorCode:HMErrCodeUninstalled]];

		return NO;
	}
	
	BOOL support = [WXApi isWXAppSupportApi];
	if ( NO == support )
	{
        [self postNotification:[HMShareService HMShareServiceRespone]
                    withObject:[HMShareServiceResult spawnWith:HMShareTypeWeChat
                                                         state:HMPublishContentStateFail
                                                    statusInfo:nil
                                                     errorCode:HMErrCodeUnsupport]];

		return NO;
	}
    
	return YES;
}

- (void)onReq:(BaseReq *)req{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"WeChat",req);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}

- (void) onResp:(BaseResp*)resp
{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"WeChat",resp);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    if ( [resp isKindOfClass:[SendMessageToWXResp class]] )
    {
        
        if ( WXSuccess == resp.errCode )
        {
			[self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeWeChat
                                                             state:HMPublishContentStateSuccess
                                                        statusInfo:nil
                                                         errorCode:HMSuccess]];
		}
		else if ( WXErrCodeUserCancel == resp.errCode )
		{
			[self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeWeChat
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeUserCancel]];
		}
        else if ( WXErrCodeSentFail == resp.errCode )
		{
			[self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeWeChat
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeSentFail]];
		}
        else if ( WXErrCodeAuthDeny == resp.errCode )
		{
			[self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeWeChat
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeAuthDeny]];
		}

		else
		{
			[self postNotification:[HMShareService HMShareServiceRespone]
                        withObject:[HMShareServiceResult spawnWith:HMShareTypeWeChat
                                                             state:HMPublishContentStateFail
                                                        statusInfo:nil
                                                         errorCode:HMErrCodeCommon]];
			
		}
    }
}

- (void)shareBody:(HMShareItemObject *)body{
    self.sendType = (NSInteger)body.sendType;
    self.shareType = (NSInteger)body.subType;
    [self share:body.title description:body.description thumb:body.thumb media:body.media type:body.mediaType];
}

- (void)share:(NSString*)title description:(NSString*)description
          thumb:(id)thumb media:(id)media type:(NSInteger)type
{
	BOOL result = [self checkInstalled];
	if ( NO == result )
		return;
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init]autoreleaseARC];
    if (self.sendType==WXSendTypeResp) {
        req = (SendMessageToWXReq*)[[[GetMessageFromWXResp alloc] init]autoreleaseARC];
    }else if (self.sendType==WXSendTypeReq){
//        req = [[[SendMessageToWXReq alloc] init]autoreleaseARC];
    }
    if ( media || thumb )
	{
        WXMediaMessage *message = [WXMediaMessage message];
        
        if ( thumb )
		{
			NSData *thumbData = nil;
			
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
			
			message.thumbData = thumbData;
            if (media==nil) {
                WXImageObject * imageObject = [WXImageObject object];
                imageObject.imageData = thumbData;
                message.mediaObject = imageObject;
            }
		}
        
        if ( media )
		{
            id mediaObject = nil;
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
                case WXMediaTypeImage://WXImageObject
                {
                    WXImageObject * imageObject = [WXImageObject object];
                    NSData *data = nil;
                    if (mediaType==0) {
                        data = [(UIImage*)media dataWithExt:@"png"];
                    }else if (mediaType==2){
                        data = (NSData *)media;
                    }

                    if ((mediaType==0)||((mediaType==0))) {
                        imageObject.imageData = data;
                    }else if (mediaType==1){
                        imageObject.imageUrl = (NSString *)media;
                    }
                    mediaObject = [imageObject retainARC];
                }
                    break;
                case WXMediaTypeMusic://WXMusicObject
                {
                    WXMusicObject * imageObject = [WXMusicObject object];
                    NSAssert(mediaType==1, @"share music can only share a url");
                    imageObject.musicDataUrl = (NSString *)media;
                    mediaObject = [imageObject retainARC];
                }
                    break;
                case WXMediaTypeVideo://WXVideoObject
                {
                    WXVideoObject * imageObject = [WXVideoObject object];
                    NSAssert(mediaType==1, @"share video can only share a url");
                    imageObject.videoUrl = (NSString *)media;
                    mediaObject = [imageObject retainARC];
                }
                    break;
                case WXMediaTypeWebpage://WXWebpageObject
                {
                    WXWebpageObject * imageObject = [WXWebpageObject object];
                    NSAssert(mediaType==1, @"share web page can only share a url");
                    imageObject.webpageUrl = (NSString *)media;
                    mediaObject = [imageObject retainARC];
                }
                    break;
                case WXMediaTypeEmoticon://WXEmoticonObject-表情
                {
                    WXEmoticonObject * imageObject = [WXEmoticonObject object];
//                    NSAssert(mediaType!=1, @"share Emoticon can only share a url");
                    NSData *data = nil;
                    if (mediaType==0) {
                        data = [(UIImage*)media dataWithExt:@"png"];
                    }else if (mediaType==1){
                        data = [NSData dataWithContentsOfFile:(NSString *)media];
                    }else if (mediaType==2){
                        data = (NSData *)media;
                    }
                    imageObject.emoticonData = data;
                    
                    mediaObject = [imageObject retainARC];
                }
                    break;
                case WXMediaTypeFile://WXFileObject
                {
                    WXFileObject * imageObject = [WXFileObject object];
                    NSAssert(mediaType==1, @"share file can only share a url");
                    imageObject.fileExtension = [(NSString *)media pathExtension];
                    imageObject.fileData = [NSData dataWithContentsOfFile:(NSString *)media];
                    mediaObject = [imageObject retainARC];
                }
                    break;
                case WXMediaTypeAppExtend://WXAppExtendObject
                {
                    WXAppExtendObject * imageObject = [WXAppExtendObject object];
                    NSAssert(mediaType==2, @"share web page can only share a data");
                    imageObject.fileData = (NSData *)media;
                    mediaObject = [imageObject retainARC];
                }
                    break;
                default:
                    break;
            }
            
			message.mediaObject = mediaObject;
            [mediaObject autoreleaseARC];
		}
        
        message.title = title;
        message.description = description;

        req.message = message;
        req.bText = NO;
        
    }else if (title!=nil) {

        req.text = title;
        req.bText = YES;

    }
    
    if (self.sendType==WXSendTypeReq){
        req.scene = _shareType;
    }
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeWeChat
                                                     state:HMPublishContentStateBegan
                                                statusInfo:nil
                                                 errorCode:HMSuccess]];
    [WXApi sendReq:req];
}

@end
