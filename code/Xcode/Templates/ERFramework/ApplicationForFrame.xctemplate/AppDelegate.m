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
 
 #ifndef PrefixHeader_pch
 #define PrefixHeader_pch
 
 #import <EFWKLib/EFWKLib.h>
 
 #import "UserCenter.h"
 
 // Include any system framework and library headers here that should be included in all compilation units.
 // You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.
 
 #endif
 
 *******************  -Prefix.pch
 
 make sure
 precompile prefix header is YES
 
 setting prefix header has value of $(PROJECT_NAME)/$(PROJECT_NAME)-Prefix.pch
 
 setting allow non-modular to YES
 
 modity settings
 
 Gerneral>Development Info>Main interface 删除 storyboard
 
 *******************for EFramework
 
 引用EFWK.EFramework
 
 ////////////////确认选项//////////////////////////
  添加：Framework search Paths
 $(SRCROOT)/../../../comm/EFNew/Frameworks/Public
 "$(SRCROOT)/../../../../projects/comm/external/umeng/share/umeng_5.0.1/UMSocial_Sdk_Extra_Frameworks/TencentOpenAPI"
 
 Header Search Paths
 $(SRCROOT)/../../../comm/EFNew/Frameworks/Public
 
 Library Search Paths
 $(inherited) "$(SRCROOT)/../../../../projects/comm/external/umeng/share/UMSocial_Sdk_Extra_Frameworks/Sina" "$(SRCROOT)/../../../../projects/comm/external/umeng/share/UMSocial_Sdk_Extra_Frameworks/SinaSSO" "$(SRCROOT)/../../../../projects/comm/external/umeng/share/UMSocial_Sdk_Extra_Frameworks/TencentOpenAPI" "$(SRCROOT)/../../../../projects/comm/external/umeng/share/UMSocial_Sdk_Extra_Frameworks/Wechat" "$(SRCROOT)/../../../../projects/comm/external/umeng/share/UMSocial_Sdk_4.2.2" "$(SRCROOT)/../../../../projects/comm/external/umeng/push" "$(SRCROOT)/../../../../projects/comm/external/umeng/feedback" "$(SRCROOT)/../../../../projects/comm/external/umeng/stat" "$(SRCROOT)/../../../../projects/comm/external/umeng/feedback/UMOpus"
 /////////////////////////////////////////
 *******************for EFramework
 
 *****************************for setting 下面部分是其他功能**************************
 添加以下两个key,ios8定位支持
 <key>NSLocationWhenInUseDescription</key>
	<string>位置定位时会使用到该服务</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>位置定位时会使用到该服务</string>
 
 <key>NSAppTransportSecurity</key>
	<dict>
 <key>NSAllowsArbitraryLoads</key>
 <true/>
	</dict>
 
 **for external
 
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
    //    [UMExt startWithKey:UMKey launchOptions:self.options push:YES];
    //    [UMExt checkUpdate:UMKey];
    
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
