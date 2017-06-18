//
//  HMUIApplication.m
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIApplication.h"
#import "HMMacros.h"
#import "HMFoundation.h"
@interface HMUIApplication ()
{
    UIWindow *      _window;
}
@property (nonatomic) NSTimeInterval lastTimeInterval;

@end
static HMUIApplication *__shareApp = nil;

@implementation HMUIApplication

DEF_NOTIFICATION2( LAUNCHOPTIONS ,HMUIApplication)		// did launched
DEF_NOTIFICATION2( LAUNCHED ,HMUIApplication)		// did launched
DEF_NOTIFICATION2( LOCAL_NOTIFICATION ,HMUIApplication)
DEF_NOTIFICATION2( REMOTE_NOTIFICATION ,HMUIApplication)

DEF_NOTIFICATION2( APS_REGISTERED ,HMUIApplication)
DEF_NOTIFICATION2( APS_ERROR ,HMUIApplication)

DEF_NOTIFICATION2( WILL_INACTION ,HMUIApplication)	// state changed
DEF_NOTIFICATION2( DID_ACTION ,HMUIApplication)	// state changed
DEF_NOTIFICATION2( DID_LONGTIMEINACTION ,HMUIApplication)

DEF_NOTIFICATION2( DID_ENTERBACKGROUND ,HMUIApplication)	// state changed


@synthesize window = _window;
@synthesize enableLongtimeNotif;
@synthesize longtimeInterval;
@synthesize lastTimeInterval;
@synthesize options=_options;
@synthesize application=_application;

+ (HMUIApplication *)sharedInstance{
    return __shareApp;
    
}

-(void)load{
    
}

-(void)unload{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        __shareApp = self;
    }
    return self;
}

- (void)dealloc
{
    [self unload];
    [_window release];
    self.options = nil;
    HM_SUPER_DEALLOC();
}

- (void)initWindow
{
    if (self.window==nil) {
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
//        self.window.windowLevel = 10;
//        [self.window makeKeyWindow];
        [self.window makeKeyAndVisible];
    }else{
        INFO(@"****Has set the Main Interface.****");
        Class clazz = NSClassFromString(@"HMBaseNavigator");
        if (clazz&&[self.window.rootViewController isKindOfClass:clazz]) {
            
        }
    }
	
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+ (void)enableDefaultAPNS{
    if (!TARGET_IPHONE_SIMULATOR) {
        NSString *sys = [[UIDevice currentDevice] systemVersion] ;
        NSString *fi = [sys componentsSeparatedByString:@"."].firstObject;
        
        INFO(@( [fi compare:@"8"] != NSOrderedDescending),@([fi compare:@"8"]),@( [fi integerValue]>=8));
        
        if (IOS8_OR_LATER) {
            
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            }else {
                
                UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
            }
            
        }else{
            [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];
        }
    }
}
#pragma clang diagnostic pop

- (void)enableDefaultAPNS{
    [[self class] enableDefaultAPNS];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    self.application = application;
    
    [self initWindow];
    
    self.longtimeInterval = 5*60.f;
    
    self.options = launchOptions;
    
    [self LaunchingWithOptions:launchOptions];
    
    [self load];

//    if ( self.window.rootViewController )
//	{
//		UIView * rootView = self.window.rootViewController.view;
//		if ( rootView )
//		{
//            [self.window makeKeyWindow];
//			[self.window makeKeyAndVisible];
//		}
//	}
//    [self.window makeKeyWindow];
//    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if (self.enableLongtimeNotif) {
        self.lastTimeInterval = [[NSDate date] timeIntervalSince1970];
    }else{
        self.lastTimeInterval = 0;
    }
    [self postNotification:[HMUIApplication WILL_INACTION]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self postNotification:[HMUIApplication DID_ENTERBACKGROUND]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self postNotification:[HMUIApplication DID_ACTION]];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber>0) {
        [self postNotification:[HMUIApplication REMOTE_NOTIFICATION]];
    }
    
    if (self.enableLongtimeNotif) {
        NSTimeInterval interval = [[NSDate date]timeIntervalSince1970] - self.lastTimeInterval>=self.longtimeInterval;
        CC(@"Application",@(interval).description,@"longtime",@(self.longtimeInterval).description,@"lastTime",[NSDate dateWithTimeIntervalSince1970:self.lastTimeInterval]);
        if (self.longtimeInterval>0.f&&interval&&self.lastTimeInterval) {
            [self postNotification:[HMUIApplication DID_LONGTIMEINACTION]];
        }
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}
#pragma mark -

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
}

// one of these will be called after calling -registerForRemoteNotifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSString * token = [deviceToken description];
	token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
	token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:token, APSNotificationTokenStringKey, deviceToken, APSNotificationTokenDataKey, nil];
	[self postNotification:HMUIApplication.APS_REGISTERED withObject:dict];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	[self postNotification:HMUIApplication.APS_ERROR withObject:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	UIApplicationState state = [UIApplication sharedApplication].applicationState;
	if ( UIApplicationStateInactive == state || UIApplicationStateBackground == state )
	{
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo, APSNotificationUserInfoKey, [NSNumber numberWithBool:NO], APSNotificationInAppKey, nil];
		[self postNotification:HMUIApplication.REMOTE_NOTIFICATION withObject:dict];
	}
	else
	{
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo, APSNotificationUserInfoKey, [NSNumber numberWithBool:YES], APSNotificationInAppKey, nil];
		[self postNotification:HMUIApplication.REMOTE_NOTIFICATION withObject:dict];
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	UIApplicationState state = [UIApplication sharedApplication].applicationState;
	if ( UIApplicationStateInactive == state || UIApplicationStateBackground == state )
	{
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:notification.userInfo, APSNotificationUserInfoKey, [NSNumber numberWithBool:NO], APSNotificationInAppKey, nil];
		[self postNotification:HMUIApplication.LOCAL_NOTIFICATION withObject:dict];
	}
	else
	{
		NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:notification.userInfo, APSNotificationUserInfoKey, [NSNumber numberWithBool:YES], APSNotificationInAppKey, nil];
		[self postNotification:HMUIApplication.LOCAL_NOTIFICATION withObject:dict];
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [self application:application openURL:url sourceApplication:nil annotation:nil];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options{
    return  [self application:app openURL:url sourceApplication:[options valueForKey:@"UIApplicationOpenURLOptionsSourceApplicationKey"] annotation:[options valueForKey:@"UIApplicationOpenURLOptionsAnnotationKey"]];
}
// no equiv. notification. return NO if the application can't open for some reason
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	if ( url || sourceApplication )
	{
		NSMutableDictionary * params = [NSMutableDictionary dictionary];
		params.APPEND( LaunchNotificationUrlKey, url );
        params.APPEND( LaunchNotificationSourceKey, sourceApplication );
        
		[self postNotification:HMUIApplication.LAUNCHED withObject:params];
        
        return ![[params valueForKey:LaunchNotificationCannotOpenUrlKey] boolValue];
	}
	else
	{
		[self postNotification:HMUIApplication.LAUNCHED];
	}
    
	return YES;
}

#pragma mark -

- (BOOL)inBackground{
    return ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)?YES:NO;
}

#pragma mark - notification

- (void)LaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [self postNotification:HMUIApplication.LAUNCHOPTIONS withObject:launchOptions];
    
    if ( nil != launchOptions ) // 从通知启动
	{
		NSURL *		url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
		NSString *	bundleID = [launchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey];
        
		if ( url || bundleID )
		{
			NSMutableDictionary * params = [NSMutableDictionary dictionary];
			params.APPEND( LaunchNotificationUrlKey, url );
			params.APPEND( LaunchNotificationSourceKey, bundleID );
            
			[self postNotification:HMUIApplication.LAUNCHED withObject:params];
		}
		else
		{
			[self postNotification:HMUIApplication.LAUNCHED];
		}
        
		UILocalNotification * localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
		if ( localNotification )
		{
			NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:localNotification.userInfo, APSNotificationUserInfoKey, [NSNumber numberWithBool:NO], APSNotificationInAppKey, nil];
			[self postNotification:HMUIApplication.LOCAL_NOTIFICATION withObject:dict];
		}
        
		NSDictionary * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if ( remoteNotification )
		{
			NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:remoteNotification, APSNotificationUserInfoKey, [NSNumber numberWithBool:NO], APSNotificationInAppKey, nil];
			[self postNotification:HMUIApplication.REMOTE_NOTIFICATION withObject:dict];
		}
	}
	else
	{
		[self postNotification:HMUIApplication.LAUNCHED];
	}

}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
UIInterfaceOrientation InterfaceOrientation() {
    
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    if (UIDeviceOrientationUnknown == orient) {
        UIWindow *window = nil;
        if (![HMUIApplication sharedInstance].window) {
            window = [UIApplication sharedApplication].keyWindow;
        }else{
            window = [HMUIApplication sharedInstance].window;
        }
    
        UIViewController *base = window.rootViewController;//[HMUIApplication sharedInstance].window.rootViewController;
        if ([base isKindOfClass:[HMBaseNavigator class]]||[base isKindOfClass:[UINavigationController class]]) {
            return [(UINavigationController*)base visableViewController].interfaceOrientation;
        }
    }
    
    return orient;
}
