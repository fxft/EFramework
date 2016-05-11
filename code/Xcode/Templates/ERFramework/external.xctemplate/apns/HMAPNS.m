//
//  HMAPNS.m
//  CarAssistant
//
//  Created by Eric on 14-4-26.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMAPNS.h"
#import "BPush.h"

@interface HMAPNS ()<BPushDelegate>

@end

@implementation HMAPNS

DEF_SINGLETON_AUTOLOAD(HMAPNS)

- (id)init
{
    self = [super init];
    if (self) {
        [self observeNotification:HMUIApplication.APS_REGISTERED];
        [self observeNotification:HMUIApplication.APS_ERROR];
        [self observeNotification:[HMUIApplication LAUNCHOPTIONS]];
        [self observeNotification:[HMUIApplication WILL_INACTION]];
        [self observeNotification:[HMUIApplication DID_ACTION]];
        [self observeNotification:HMUIApplication.REMOTE_NOTIFICATION];
    }
    return self;
}

+ (void)resetAPNS{
    if (!TARGET_IPHONE_SIMULATOR) {
        [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];
    }
    
}

- (void)onMethod:(NSString *)method response:(NSDictionary *)data{
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSDictionary* res = [[[NSDictionary alloc] initWithDictionary:data]autoreleaseARC];

#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"APNS",res);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
//        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
//        NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        
        NSDictionary *token = @{APSNotificationTokenUserIdKey: userid==nil?@"":userid,APSNotificationTokenChannelIdKey:channelid==nil?@"":channelid,APSNotificationTokenAppIdKey:appid==nil?@"":appid};
        
        [self postNotification:[HMUIApplication APS_REGISTERED] withObject:token];
    }
    
}

ON_NOTIFICATION3(HMUIApplication, LAUNCHOPTIONS, __notification){
    NSDictionary *launchOptions = __notification.object;
    [BPush setupChannel:launchOptions];
    [BPush setDelegate:self];
}

ON_NOTIFICATION3(HMUIApplication, WILL_INACTION, __notification){

    NSInteger count =[UIApplication sharedApplication].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = count;
}

ON_NOTIFICATION3(HMUIApplication, REMOTE_NOTIFICATION, __notification){
    NSDictionary *userInfo = [__notification.object objectForKey:APSNotificationUserInfoKey];
    [BPush handleNotification:userInfo];
}

ON_NOTIFICATION3(HMUIApplication, APS_REGISTERED, __notification){
    
    NSData * deviceToken = [__notification.object objectForKey:APSNotificationTokenDataKey];
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannel];
}

@end
