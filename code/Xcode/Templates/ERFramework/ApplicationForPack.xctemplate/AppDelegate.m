//
//  AppDelegate.m
//  GLuckyTransport
//
//  Created by mac on 15/7/20.
//  Copyright (c) 2015年 mac. All rights reserved.
//

/*
 
 **
 ******************* copy to xxx-Prefix.pch
 
 #import <Availability.h>
 
 #ifndef __IPHONE_5_0
 #warning "This project uses features only available in iOS SDK 5.0 and later."
 #endif
 
 #ifdef __OBJC__
 #import <EFMWK/HMExtension.h>
 #import "UserCenter.h"
 #endif
 *******************  -Prefix.pch
 
 make sure 
 precompile prefix header is YES

 setting prefix header has value of $(PROJECT_NAME)/$(PROJECT_NAME)-Prefix.pch
 
 modity settings
 
 Gerneral>Development Info>Main interface 删除 storyboard
 
 *******************for EFramework
 
 引用EFMWK.EFramework
 
 ////////////////确认选项//////////////////////////
 添加：Framework search Paths $(SRCROOT)/../../comm/EF/EFMWKLib
 
 Header Search Paths
 $(SRCROOT)/../../comm/EF/EFMWKLib/Pods/Headers/Public
 
 Library Search Paths
 $(SRCROOT)/../../comm/EF/EFMWKLib/Debug$(EFFECTIVE_PLATFORM_NAME)
 /////////////////////////////////////////
 *******************for EFramework
 
 *****************************for setting 下面部分是其他功能**************************
 添加以下两个key,ios8定位支持
 <key>NSLocationWhenInUseDescription</key>
	<string>位置定位时会使用到该服务</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>位置定位时会使用到该服务</string>
 
 **for external
 
 baidu地图：
 
 other linker flags
 -lbaidumapapi -Objc
 
 library search paths
 $(SRCROOT)/../../comm/map/baidu/BaiduMap_IOSSDK_v2.3.0_All/BaiduMap_IOSSDK_v2.3.0_Lib/Release$(EFFECTIVE_PLATFORM_NAME)
 
 **拖动其他第三方模块到external目录，请选择引用方式
 **library search paths 如果包含$(SRCROOT)/../../comm/external,请删除重复的子目录项
 **请将包含external中有.plist文件重复，请删除被引用的那个
 
 And make sure  library\framework\header search paths has “relative to project”,like "$(SRCROOT)/../../comm/...."
 
 ** 一般情况下以上设置完编译能成功，否则请按其他第三方的集成方式请看各自的文档
 
 */


#import "AppDelegate.h"

@implementation AppDelegate

- (void)load{
    
    [HMWebAPI shareAutoLoad].baseUrl = [NSURL URLWithString:@"http://<#url#>"];
    [HMWebAPI shareAutoLoad].useCookiePersistence = YES;
    
    //在Info.plist中设置UIViewControllerBasedStatusBarAppearance 为NO
    [HMUIConfig sharedInstance].statusBarStyle = UIStatusBarStyleLightContent;
    [HMUIConfig sharedInstance].interfaceMode = HMUIInterfaceMode_iOS6;
    //    [HMUIConfig sharedInstance].allowControlerGestureBack = YES;
    [HMUINavigationBar setTitleColor:[UIColor whiteColor]];
    //    [HMUINavigationBar setBackgroundImage:[UIImage imageNamed:@"title_back.png"]];
    [HMUINavigationBar setBackgroundOriginalColor:[UIColor flatGreenSeaColor]];

    [HMURLMap map:@"*" URL:URLFOR_controller(@"HMBaseNavigator")];
    HMUIBoard *mainBoard =  [HMURLMap boardForMap:@"*"];
    
    [HMURLMap map:@"HelpPage" bindto:@"*" URL:URLFOR_controller(@"AppBoard_iPhone")];

    
    [HMURLMap map:@"MainPage" bindto:@"*" URL:URLFOR_controllerWithNav(@"Main.MainBoard")];
    
    [mainBoard open:@"MainPage" animate:NO];

#ifdef DEBUG
    [HMDEBUGWindow sharedInstance];
    [HMLog showTimeAhead:YES];
#endif
    [self observeNotifi];
    
    [HMApp setAPPID:@"707972697"];
    [HMApp checkAPPVersionAlertIfNew:NO showLoading:NO];
    
    [self enableDefaultAPNS];
    [UMExt startWithKey:UMKey launchOptions:self.options push:YES];
    [UMExt checkUpdate];
    
}

-(void)observeNotifi{
    [self observeNotification:HMUIApplication.APS_REGISTERED];
    [self observeNotification:HMUIApplication.APS_ERROR];
    [self observeNotification:HMUIApplication.LAUNCHED];
    [self observeNotification:HMUIApplication.REMOTE_NOTIFICATION];
    [self observeNotification:HMUIApplication.LOCAL_NOTIFICATION];
}


#pragma mark - Remote notification

ON_NOTIFICATION3(HMUIApplication, APS_REGISTERED, __notification){
    
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"APNS",@"my device Token is: %@",__notification.object);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    
    NSString *token = [__notification.object valueForKey:APSNotificationTokenStringKey];
    NSString *appid = [__notification.object valueForKey:APSNotificationTokenAppIdKey];
    NSString *userid = [__notification.object valueForKey:APSNotificationTokenUserIdKey];
    NSString *channelid = [__notification.object valueForKey:APSNotificationTokenChannelIdKey];
    if (appid) {
        [UserCenter sharedInstance].userid_token = userid;
        [UserCenter sharedInstance].channelid_token = channelid;
    }
    if (token) {
        [UserCenter sharedInstance].token =  token;
    }
}

ON_NOTIFICATION3(HMUIApplication, APS_ERROR, __notification){
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"APNS",@"my device Token error : %@",__notification.object);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    
}

ON_NOTIFICATION3(HMUIApplication, REMOTE_NOTIFICATION, __notification){
    
    NSDictionary *dic = __notification.object;
    BOOL isInApp = [[dic objectForKey:@"inApp"] boolValue];
    if (isInApp) {
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
        SystemSoundID soundId ;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ping" ofType:@"caf"];
        if (path) {
            AudioServicesCreateSystemSoundID((__bridge_type CFURLRef)[NSURL fileURLWithPath:path],&soundId);
            AudioServicesPlaySystemSound(soundId);
        }
        
    }
}

#pragma mark - local notification

ON_NOTIFICATION3(HMUIApplication, LOCAL_NOTIFICATION, __notification){
    
    
}

@end
