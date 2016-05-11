//
//  HMApp.h
//  GPSService
//
//  Created by Eric on 14-4-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMMacros.h"

#undef trackVersionKEY_Url
#define trackVersionKEY_Url @"trackViewUrl"

#undef trackVersionKEY_CurrentNotes
#define trackVersionKEY_CurrentNotes @"releaseNotesCurrent"

#undef trackVersionKEY_Update
#define trackVersionKEY_Update @"trackVersionKEY_Update"

#undef trackVersionKEY_description
#define trackVersionKEY_description @"trackVersionKEY_description"

#undef trackVersionKEY_Results
#define trackVersionKEY_Results @"trackVersionKEY_Results"

/**
 *  App升级检测
 */
@interface HMApp : NSObject
AS_SINGLETON(HMApp)

@property (nonatomic,assign) BOOL canUpdate;
@property (nonatomic,copy) NSString *updateUrl;
@property (nonatomic,copy) NSString *updateDescription;

+ (void)setAPPID:(NSString*)appId;
+ (void)setMustUpate:(BOOL)update;//必须更新
+ (void)setUpateNextVersion:(BOOL)next;//是否显示可以忽略本版本


/**
 *  检测有没有升级
 *
 *  @param yes     如果已是最新是否需要弹出提示
 *  @param loading 显示正在检测
 */
+ (void)checkAPPVersionAlertIfNew:(BOOL)yes showLoading:(BOOL)loading;
+ (void)starAPP;

/**
 *  新版本调用有效，可以通过 updateNewInstall更新状态
 *
 *  @return 新安装返回 YES 否则 NO；
 */
+ (BOOL)isNewInstall;
+ (void)updateNewInstall;

/**
 *  新版本调用有效，可以通过 updateNewVersion更新状态
 *
 *  @return 新版本返回 YES 否则 NO；
 */
+ (BOOL)isNewVersion;
+ (void)updateNewVersion;

/**
 *  新版本调用有效，可以通过 updateNewKey更新状态
 *
 *  @return 新返回 YES 否则 NO；
 */
+ (BOOL)isNewKey:(NSString*)key value:(NSString*)value;
+ (void)updateNewKey:(NSString*)key value:(NSString*)value;

/**
 *  调度启动一个本地通知
 *
 *  @param theDate      未来的时间
 *  @param soundName    可为空
 *  @param alertBody    提示的信息
 *  @param cancelOthers 是否取消之前所有本地通知
 */
+ (void)scheduleAlarmForDate:(NSDate*)theDate soundName:(NSString*)soundName alertBody:(NSString*)alertBody cancelOthers:(BOOL)cancelOthers;

@end

#define ON_NOTIFI_App(__notification) ON_NOTIFICATION2(HMApp, __notification)
#define ON_NOTIFI_App2(__filter,__notification) ON_NOTIFICATION3(HMApp, __filter, __notification)

@protocol ON_App_handle <NSObject>

@optional
ON_NOTIFI_App(__notification);
ON_NOTIFI_App2(__filter,__notification);

@end

#undef kCTCallStateDialing
#define kCTCallStateDialing @"CTCallStateDialing"

#undef kCTCallStateIncoming
#define kCTCallStateIncoming @"CTCallStateIncoming"

#undef kCTCallStateConnected
#define kCTCallStateConnected @"CTCallStateConnected"

#undef kCTCallStateDisconnected
#define kCTCallStateDisconnected @"CTCallStateDisconnected"

@interface HMCall : NSObject

@property (nonatomic,copy) NSString *callId;//电话纪录ID
@property (nonatomic,copy) NSString *callState;//电话状态
@property (nonatomic) NSTimeInterval duration;//通话时长
@property (nonatomic) BOOL callIn;  //是否呼入
@property (nonatomic,HM_STRONG) NSDate *startDate;//响铃开始
@property (nonatomic,HM_STRONG) NSDate *connectDate;//接通时间
@property (nonatomic,HM_STRONG) NSDate *endDate;//挂断时间

@end
/**
 *  打电话状态监听 返回 HMCall 对象
 */
@interface HMApp (CallCenter)
AS_NOTIFICATION(APPCALLCENTERSTATECHANGED)
- (void)startCallCenterService;
- (void)stopCallCenterService;
@end

