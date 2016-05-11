//
//  HMServiceTencentWB.m
//  CarAssistant
//
//  Created by Eric on 14-4-29.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMServiceTencentWB.h"
#import "WeiboApi.h"

@interface HMServiceTencentWB ()<HMShareServiceProtocol,WeiboAuthDelegate,WeiboRequestDelegate>
@property (nonatomic , HM_STRONG) WeiboApi           *wbapi;
@property (nonatomic , HM_STRONG) HMShareItemObject  *shareBody;
@property (nonatomic , HM_WEAK) UIViewController *  rootController;
@end

@implementation HMServiceTencentWB{
    BOOL            shareWaitting;
    
}
@synthesize wbapi;
@synthesize shareBody;
@synthesize rootController;

DEF_SINGLETON( HMServiceTencentWB )

+ (void)registerApp:(NSString *)appid{
    
}

- (id)init{
    if(self = [super init]){
        [self observeNotification:[HMUIApplication LAUNCHED]];
        
    }
    return self;
}

- (void)dealloc
{
    self.wbapi = nil;
    self.shareBody = nil;
    HM_SUPER_DEALLOC();
}

ON_NOTIFICATION3(HMUIApplication, LAUNCHED, __notification){
    NSDictionary *params = __notification.object;
    
    NSURL *url = [params valueForKey:LaunchNotificationUrlKey];
    if (url) {
        [self.wbapi handleOpenURL:url];
    }
    
}

- (BOOL)checkAuthorizeExpire{
    [self.wbapi checkAuthValid:TCWBAuthCheckServer andDelegete:self];
    return NO;
}

- (void)logout{
    [self.wbapi cancelAuth];
    
}

- (BOOL)installed{
    return YES;
}

- (void)shareBody:(HMShareItemObject *)body{
    
    if (self.wbapi==nil) {
        self.wbapi = [[WeiboApi alloc]initWithAppKey:body.appid andSecret:body.appSecret andRedirectUri:body.redirectURI andAuthModeFlag:0 andCachePolicy:0];
    }
    
    self.rootController = body.rootController;
    self.shareBody = body;
    shareWaitting = YES;
    [self checkAuthorizeExpire];
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeTencentWeibo
                                                     state:HMPublishContentStateBegan
                                                statusInfo:nil
                                                 errorCode:HMAuthOK]];
}

- (void)share:(NSString*)title description:(NSString*)description scheme:(NSString*)scheme
        thumb:(id)thumb media:(id)media type:(NSInteger)type replenish:(NSDictionary*)replenish
{
    UIImage *thumbData = nil;
    if ( thumb )
    {
        if ( [thumb isKindOfClass:[UIImage class]] )
        {
            thumbData = (UIImage *)thumb;
        }
        else if ( [thumb isKindOfClass:[NSString class]] )
        {
            thumbData = [UIImage imageWithContentsOfFile:(NSString *)thumb];//[NSData dataWithContentsOfURL:[NSURL URLWithString:(NSString *)thumb]];
        }
        else if ( [thumb isKindOfClass:[NSData class]] )
        {
            thumbData = [UIImage imageWithData:(NSData *)thumb];
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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params.APPEND(@"format",@"json");
    params.APPEND(@"content",description==nil?title:description);
    NSString *apiName = nil;
    switch (type) {
        case TCMediaTypeImage:
            apiName = @"t/add_pic";
            params.APPEND(@"pic",thumbData);
            break;
        case TCMediaTypeMusic:
            apiName = @"t/add_music";
            NSAssert(mediaType==1, @"share music can only share a url");
            params.APPEND(@"music_url",(NSString*)media);
            params.APPEND(@"music_title",(NSString*)title);
            params.APPEND(@"music_author",(NSString*)title);
            break;
        case TCMediaTypeVideo:
            apiName = @"t/add_video";
            params.APPEND(@"video_url",(NSString*)media);
            break;
        case TCMediaTypeWebpage:
            apiName = @"t/add_pic";
            params.APPEND(@"pic",thumbData);
            if (mediaType==1) {
                NSString *string = [NSString stringWithFormat:@"%@ %@",description==nil?title:description,(NSString *)media];
                params.APPEND(@"content",string);
            }
            break;
        case TCMediaTypeReplenish:
            if (replenish&&[replenish isKindOfClass:[NSDictionary class]]) {
                apiName = [replenish valueForKey:@"apiName"];
                params = [replenish valueForKey:@"params"];
            }
            break;
        default:
            apiName = @"t/add";
            break;
    }
    
    
    [self.wbapi requestWithParams:params apiName:apiName httpMethod:@"POST" delegate:self];
}

#pragma mark - WeiboAuthDelegate

- (void)DidAuthFinished:(WeiboApiObject *)wbobj{
    [HMShareService dismiss];
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeTencentWeibo
                                                     state:HMPublishContentStateSuccess
                                                statusInfo:nil
                                                 errorCode:HMAuthOK]];
}

- (void)DidAuthCanceled:(WeiboApiObject *)wbobj{
    [HMShareService dismiss];
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeTencentWeibo
                                                     state:HMPublishContentStateFail
                                                statusInfo:nil
                                                 errorCode:HMErrCodeUserCancel]];
}

- (void)DidAuthFailWithError:(NSError *)error{
    [HMShareService dismiss];
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeTencentWeibo
                                                     state:HMPublishContentStateFail
                                                statusInfo:nil
                                                 errorCode:HMErrCodeAuthDeny]];
}

- (void)didCheckAuthValid:(BOOL)bResult suggest:(NSString *)strSuggestion{
    if (!bResult) {
        if ([HMShareService sharedInstance].window.hidden==YES) {
            [HMShareService sharedInstance].window.hidden = NO;
        }
        [self.wbapi loginWithDelegate:self andRootController:[HMShareService sharedInstance].window.rootViewController];
    }else{
        if (shareWaitting) {
            [self share:self.shareBody.title description:self.shareBody.description scheme:self.shareBody.scheme thumb:self.shareBody.thumb media:self.shareBody.media type:self.shareBody.mediaType replenish:(NSDictionary*)self.shareBody.replensih];
        }
    }
}

#pragma mark - WeiboRequestDelegate

- (void)didReceiveRawData:(NSData *)data reqNo:(int)reqno{
    
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeTencentWeibo
                                                     state:HMPublishContentStateSuccess
                                                statusInfo:nil
                                                 errorCode:HMSuccess]];
    
}

- (void)didFailWithError:(NSError *)error reqNo:(int)reqno{
    
    [self postNotification:[HMShareService HMShareServiceRespone]
                withObject:[HMShareServiceResult spawnWith:HMShareTypeTencentWeibo
                                                     state:HMPublishContentStateFail
                                                statusInfo:nil
                                                 errorCode:HMErrCodeSentFail]];
    
}

- (void)didNeedRelogin:(NSError *)error reqNo:(int)reqno{
     [self.wbapi loginWithDelegate:self andRootController:[HMShareService sharedInstance].window.rootViewController];
}


@end
