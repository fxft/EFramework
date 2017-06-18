//
//  HMUIApplication.h
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+HMNotification.h"

//Start a new background task
#define BackgroundTask(name,body) do{ \
    INFO(@"Doing Task",name);\
    UIBackgroundTaskIdentifier bgTaskId = UIBackgroundTaskInvalid;\
    bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:name expirationHandler:^{\
        INFO(@"Expiration Task",name);\
        if (bgTaskId != UIBackgroundTaskInvalid) {\
            [[UIApplication sharedApplication] endBackgroundTask:bgTaskId];\
        }\
    }];\
    do{ \
        body \
    }while(0);\
    INFO(@"End Task",name);\
    if (bgTaskId != UIBackgroundTaskInvalid) {\
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskId];\
        bgTaskId = UIBackgroundTaskInvalid;\
    }\
}while(0);

/**
 *  系统Application入口覆盖
 *  配合工程模版可导入基础代码
 */
@interface HMUIApplication : UIResponder <UIApplicationDelegate>

AS_NOTIFICATION( LAUNCHOPTIONS )
AS_NOTIFICATION( LAUNCHED )		// did launched notifi.object key: LaunchNotificationUrlKey AND LaunchNotificationSourceKey
AS_NOTIFICATION( LOCAL_NOTIFICATION )//APSNotificationUserInfoKey AND APSNotificationInAppKey
AS_NOTIFICATION( REMOTE_NOTIFICATION )//APSNotificationUserInfoKey AND APSNotificationInAppKey

AS_NOTIFICATION( APS_REGISTERED )//APSNotificationTokenStringKey AND APSNotificationTokenDataKey
AS_NOTIFICATION( APS_ERROR )

AS_NOTIFICATION( WILL_INACTION )	// state changed
AS_NOTIFICATION( DID_ACTION )	// state changed

AS_NOTIFICATION( DID_LONGTIMEINACTION )	// state changed
AS_NOTIFICATION( DID_ENTERBACKGROUND )

//@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) BOOL inBackground;

@property (nonatomic) BOOL enableLongtimeNotif;
/**
 *  default 5 minutes
 */
@property (nonatomic) NSTimeInterval longtimeInterval;

@property (nonatomic,HM_STRONG) NSDictionary* options;
@property (nonatomic,HM_WEAK) UIApplication *application;

+ (HMUIApplication *)sharedInstance;

- (void)load;//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 中调用
- (void)unload;
/**
 *  UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound
 */
- (void)enableDefaultAPNS;
+ (void)enableDefaultAPNS;
- (void)enableDefaultAPNSType:(NSUInteger)type;
+ (void)enableDefaultAPNSType:(NSUInteger)type;

- (void)disableDefaultAPNS;
+ (void)disableDefaultAPNS;

@end

extern UIInterfaceOrientation InterfaceOrientation();

#undef APSNotificationTokenUserIdKey
#define APSNotificationTokenUserIdKey @"tokenUserId"

#undef APSNotificationTokenAppIdKey
#define APSNotificationTokenAppIdKey @"tokenAppId"

#undef APSNotificationTokenChannelIdKey
#define APSNotificationTokenChannelIdKey @"tokenChannelId"

#undef APSNotificationTokenStringKey
#define APSNotificationTokenStringKey @"tokenString"

#undef APSNotificationTokenDataKey
#define APSNotificationTokenDataKey @"tokenData"

#undef APSNotificationUserInfoKey
#define APSNotificationUserInfoKey @"userInfo"

#undef APSNotificationInAppKey
#define APSNotificationInAppKey @"inApp"

#undef LaunchNotificationUrlKey
#define LaunchNotificationUrlKey @"url"

#undef LaunchNotificationCannotOpenUrlKey
#define LaunchNotificationCannotOpenUrlKey @"CannotOpenUrlKey"

#undef LaunchNotificationSourceKey
#define LaunchNotificationSourceKey @"source"
