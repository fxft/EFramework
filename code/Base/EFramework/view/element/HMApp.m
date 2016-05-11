//
//  HMApp.m
//  GPSService
//
//  Created by Eric on 14-4-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMApp.h"
#import "HMMacros.h"
#import "HMFoundation.h"
#import "HMUIAlertView.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#define APP_URL(appID) [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appID]

#define trackVersionKEY_Name @"trackName"
#define trackVersionKEY_Version @"version"

#define trackVersionKEY_Notes @"releaseNotes"


static NSString *  APPIDDEFAULT = @"";
static BOOL  MUSTUPDATE = NO;
static BOOL  UPDATENEXTVERSION = NO;

@interface HMApp ()<UIAlertViewDelegate>

@end

@implementation HMApp{
    BOOL _canUpdate;
}

DEF_SINGLETON(HMApp)
@synthesize canUpdate=_canUpdate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.updateUrl = [self userDefaultsRead:trackVersionKEY_Url];
    }
    return self;
}

//关闭 buttonIndex==0  更新 MUSTUPDATE==0  !MUSTUPDATE==1 UPDATENEXTVERSION==1  忽略版本 ==2
- (void)alertView:(HMUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    CC([self class],@(buttonIndex));
//    return;
    if ([alertView.tagString isEqualToString:trackVersionKEY_Url]&&buttonIndex==(MUSTUPDATE?0:1)) {
        NSString *url = [self userDefaultsRead:trackVersionKEY_Url];
        if (url) {
           
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            
        }
    }else if (UPDATENEXTVERSION&&buttonIndex==2){
        NSDictionary *releaseInfo = [self userDefaultsRead:trackVersionKEY_Results];
        [self userDefaultsWrite:[releaseInfo objectForKey:@"version"] forKey:trackVersionKEY_Version];
    }
}

+ (void)setAPPID:(NSString*)appId{
    APPIDDEFAULT = appId;
}

+ (void)setMustUpate:(BOOL)update{
    MUSTUPDATE = update;
    
    if (update) {
        [self setUpateNextVersion:NO];
    }
    
}

+ (void)setUpateNextVersion:(BOOL)next{
    
    if (next) {
        [HMApp setMustUpate:NO];
    }
    
    UPDATENEXTVERSION = next;
}

+ (NSDictionary*)onCheckVersionWithData:(NSData *)recervedData
{
    if (recervedData==nil) {
        return nil;
    }
    
    NSMutableDictionary *track =nil;
    
    NSDictionary *dic = [recervedData objectFromJson];
    NSArray *infoArray = [dic objectForKey:@"results"];
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],dic);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    NSString *localVersion = [self userDefaultsRead:trackVersionKEY_Version];
    if (!localVersion) {
        localVersion = [HMSystemInfo appShortVersion];
    }
    
    if ([infoArray count]) {
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        NSString *lastVersion = [releaseInfo objectForKey:@"version"];
        if (releaseInfo) {
            [self userDefaultsWrite:releaseInfo forKey:trackVersionKEY_Results];
        }
        track = [NSMutableDictionary dictionaryWithObjectsAndKeys:[releaseInfo objectForKey:@"trackViewUrl"],trackVersionKEY_Url,[releaseInfo objectForKey:@"trackName"],trackVersionKEY_Name, nil];
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( [self.class description],track);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        [track setValue:lastVersion forKey:trackVersionKEY_Version];
        [track setValue:[releaseInfo objectForKey:@"releaseNotes"] forKey:trackVersionKEY_Notes];
        
        if (![lastVersion isEqualToString:localVersion]) {
            NSArray *last=[lastVersion componentsSeparatedByString:@"."];
            NSArray *local=[localVersion componentsSeparatedByString:@"."];
            [track setValue:@"NO" forKey:trackVersionKEY_Update];
            for (int i=0;i<[last count]&&i<[local count];i++) {
                NSInteger lastI=[[last objectAtIndex:i]integerValue];
                NSInteger localI=[[local objectAtIndex:i]integerValue];
                if (lastI>localI) {
                    [self userDefaultsWrite:@"YES" forKey:trackVersionKEY_Update];
                    [track setValue:@"YES" forKey:trackVersionKEY_Update];
                    break;
                }else if (lastI<localI) {
                    [self userDefaultsRemove:trackVersionKEY_Update];
                    [self userDefaultsWrite:[releaseInfo valueForKey:@"description"] forKey:trackVersionKEY_description];
                    [track setValue:localVersion forKey:trackVersionKEY_Version];
                    break;
                }
            }
            
        }else{
            [self userDefaultsWrite:[releaseInfo valueForKey:@"description"] forKey:trackVersionKEY_description];
            [self userDefaultsRemove:trackVersionKEY_Update];
            [track setValue:@"NO" forKey:trackVersionKEY_Update];
        }
    }else if (infoArray){
        track = [NSMutableDictionary dictionaryWithCapacity:0];
        [track setValue:localVersion forKey:trackVersionKEY_Version];
        [track setValue:@"NO" forKey:trackVersionKEY_Update];
        [self userDefaultsRemove:trackVersionKEY_Update];
    }
    return track;
}
+ (void)checkAPPVersionAlertIfNew:(BOOL)yes showLoading:(BOOL)loading{
    [HMApp checkAPPVersion:APPIDDEFAULT alertIfNew:yes showLoading:loading];
}

+ (void)starAPP{
     [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",APPIDDEFAULT]]];
}

+ (void)checkAPPVersion:(NSString *)appid alertIfNew:(BOOL)yes showLoading:(BOOL)loading{
    
    NSURL *url=[NSURL URLWithString:APP_URL(appid)];
    
    if (loading) {
        [[HMApp sharedInstance] showLoaddingTip:@"正在检测...." timeOut:60.f];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *fileData =nil;
        @try {
            fileData = [NSData dataWithContentsOfURL:url];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
            fileData = nil;
        }
        @finally {
            
        }
        
        if ([fileData length]) {
            
            NSString *message=nil;
            NSString *otherButton=nil;
            NSString *title = nil;
            NSDictionary *trackVersion = [self onCheckVersionWithData:fileData];
            
            if (trackVersion) {
                NSString *url = [trackVersion objectForKey:trackVersionKEY_Url];
                
                [HMApp sharedInstance].updateUrl = url;
                [HMApp sharedInstance].updateDescription = [trackVersion objectForKey:trackVersionKEY_Notes];
                
                [self userDefaultsWrite:url forKey:trackVersionKEY_Url];
                
                NSString *isUpdate =[trackVersion valueForKey:trackVersionKEY_Update];
                if ([isUpdate isEqualToString:@"YES"]) {
                    title = [NSString stringWithFormat:@"新版本%@是否前往更新？",[trackVersion valueForKey:trackVersionKEY_Version]];
                    otherButton = @"更新";
                    message = [trackVersion valueForKey:trackVersionKEY_Notes];
                }else{
                    title = @"此版本已是最新!";
                    message = [trackVersion valueForKey:trackVersionKEY_Version];
                    [self userDefaultsWrite:[trackVersion valueForKey:trackVersionKEY_Notes] forKey:trackVersionKEY_CurrentNotes];
                    if (!yes) {
                        if (loading) {
                            [[HMApp sharedInstance] tipsDismiss];
                        }
                        return ;
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (loading) {
                        [[HMApp sharedInstance] tipsDismiss];
                    }
                    HMUIAlertView *alert = [HMUIAlertView alertViewWithTitle:title message:message];
                    
                    if (!MUSTUPDATE) {
                        
                        [alert addCancelTitle:@"关闭"];
                        
                    }
                    
                    [alert onClicked:^(HMUIAlertView *alert, NSInteger index) {
                        [[HMApp sharedInstance] alertView:alert clickedButtonAtIndex:index];
                    }];
                    if (otherButton) {
                        [alert addButtonWithTitle:otherButton];
                        alert.tagString = trackVersionKEY_Url;
                        alert.delegate = [HMApp sharedInstance];
                    }
                    
                    if (!MUSTUPDATE) {
                        if (UPDATENEXTVERSION) {
                            [alert addButtonWithTitle:@"忽略该版本"];
                        }
                        
                    }
                    
                    [alert show];
                });
            }
        }else{
            if (yes) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (loading) {
                        [[HMApp sharedInstance] tipsDismiss];
                    }
                   
                    HMUIAlertView *alert = [HMUIAlertView alertViewWithTitle:@"提示" message:@"网络超时！"];
                    [alert addCancelTitle:@"关闭"];
                    [alert onClicked:^(HMUIAlertView *alert, NSInteger index) {
                        [[HMApp sharedInstance] alertView:alert clickedButtonAtIndex:index];
                    }];
                    [alert show];
                });
            }
        }
        
    });
}

+ (BOOL)isNewInstall{
    return [self isNewKey:@"__OldInstall" value:@"YES"];
}

+ (void)updateNewInstall{
    [self updateNewKey:@"__OldInstall" value:@"YES"];
}

+ (BOOL)isNewVersion{
    return [self isNewKey:@"__OldVerson" value:[HMSystemInfo appVersion]];
}

+ (void)updateNewVersion{
    [self updateNewKey:@"__OldVerson" value:[HMSystemInfo appVersion]];
}

+ (BOOL)isNewKey:(NSString*)key value:(NSString*)value{
    BOOL newVersion = NO;
    NSString *verson = [[NSUserDefaults standardUserDefaults]valueForKey:key];
    if (verson&&[verson isEqualToString:value]) {
        
    }else{
        newVersion = YES;
    }
    
    return newVersion;
}
+ (void)updateNewKey:(NSString*)key value:(NSString*)value{
    [[NSUserDefaults standardUserDefaults]setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


+ (void)scheduleAlarmForDate:(NSDate*)theDate soundName:(NSString*)soundName alertBody:(NSString*)alertBody cancelOthers:(BOOL)cancelOthers
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0&&cancelOthers)
        [app cancelAllLocalNotifications];
    
    // Create a new notification.
    UILocalNotification* alarm = [[[UILocalNotification alloc] init]autorelease];
    if (alarm)
    {
        alarm.fireDate = theDate;
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        alarm.soundName = [soundName notEmpty]?soundName:UILocalNotificationDefaultSoundName ;
        alarm.alertBody = alertBody;
        
        [app scheduleLocalNotification:alarm];
    }
}

@end

@implementation HMCall
@synthesize callState;
@synthesize callId;
@synthesize duration;
@synthesize startDate;
@synthesize endDate;
@synthesize connectDate;
@synthesize callIn;

- (void)dealloc
{
    self.callId = nil;
    self.callState = nil;
    self.startDate = nil;
    self.connectDate = nil;
    self.endDate = nil;
    HM_SUPER_DEALLOC();
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Call: ID[%@] state[%@] duration[%.2f] \nfrom[%@]connect[%@]endAt[%@]", callId,callState,duration,[startDate stringWithDateFormat:nil],[connectDate stringWithDateFormat:nil],[endDate stringWithDateFormat:nil]];
}
@end


@implementation HMApp (CallCenter)
DEF_NOTIFICATION(APPCALLCENTERSTATECHANGED)

- (NSMutableDictionary *)mycalls{
    static dispatch_once_t once;
    static NSMutableDictionary *calls = nil;
    dispatch_once( &once, ^{
        calls = [[NSMutableDictionary alloc] init];
    } );
    return calls;
}

- (CTCallCenter *)callCenter{
    static dispatch_once_t once;
    static CTCallCenter *_callCenter = nil;
    dispatch_once( &once, ^{
        _callCenter = [[CTCallCenter alloc] init];
    } );
    return _callCenter;
}

- (void)startCallCenterService{
    if (self.callCenter.callEventHandler!=nil) {
        return;
    }
    self.callCenter.callEventHandler = ^(CTCall *call) {
        
        HMCall *nowCall = [self.mycalls valueForKey:call.callID];
        if (nowCall==nil) {
            nowCall = [[[HMCall alloc]init]autorelease];
            [self.mycalls setValue:nowCall forKey:call.callID];
        }
        nowCall.callState = call.callState;
        nowCall.callId = call.callID;
        
        if ([call.callState is:CTCallStateDialing]){
            nowCall.startDate = [NSDate date];
            nowCall.callIn = NO;
        }else if ([call.callState is:CTCallStateIncoming]){
            nowCall.callIn = YES;
        }
        if ([call.callState is:CTCallStateDisconnected]) {
            nowCall.endDate = [NSDate date];
            
            if (nowCall.connectDate==nil) {
                nowCall.connectDate = nowCall.endDate;
            }
            
            nowCall.duration = [nowCall.endDate timeIntervalSinceDate:nowCall.connectDate];
            
        }else if ([call.callState is:CTCallStateConnected]){
            nowCall.connectDate = [NSDate date];
        }
        
        [self postNotification:self.APPCALLCENTERSTATECHANGED withObject:nowCall];
        
        INFO(nowCall);
        
        if ([nowCall.callState is:CTCallStateDisconnected]) {
            [self.mycalls removeObjectForKey:nowCall.callId];
        }
        
    };
}
- (void)stopCallCenterService{
    self.callCenter.callEventHandler = nil;
}

@end

