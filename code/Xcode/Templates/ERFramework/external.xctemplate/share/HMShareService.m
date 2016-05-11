//
//  HMShareService.m
//  CarAssistant
//
//  Created by Eric on 14-4-28.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMShareService.h"
#import "HMServiceWeChat.h"

#pragma mark -

@interface shareConfigObject : NSObject

@property (nonatomic, HM_STRONG) NSString                *appid;
@property (nonatomic, HM_STRONG) NSString                *className;
@property (nonatomic, HM_STRONG) NSNumber           *enable;
@property (nonatomic, assign,readonly) BOOL         enableB;
@property (nonatomic, HM_STRONG) NSString           *redirectURI;
@property (nonatomic, HM_STRONG) NSString           *appSecret;
@end


@implementation shareConfigObject

@synthesize appid;
@synthesize className;
@synthesize enable;
@synthesize redirectURI;
@synthesize appSecret;

- (BOOL)enableB{
    return [self.enable boolValue];
}

- (void)dealloc
{
    self.appid = nil;
    self.className = nil;
    self.enable = nil;
    self.redirectURI = nil;
    self.appSecret = nil;
    HM_SUPER_DEALLOC();
}
@end

#pragma mark -

@implementation HMShareServiceResult
@synthesize type;
@synthesize state;
@synthesize statusInfo;
@synthesize errorCode;

+ (instancetype)spawnWith:(HMShareType)shareType state:(HMPublishContentState)contentState statusInfo:(id)info errorCode:(HMErrCode)code{
    HMShareServiceResult *result = [[[HMShareServiceResult alloc]init]autoreleaseARC];
    result.type = shareType;
    result.state = contentState;
    result.statusInfo = info;
    result.errorCode = code;
    return result;
}

- (void)dealloc
{
    self.statusInfo = nil;
    HM_SUPER_DEALLOC();
}

- (NSString *)description{
    if (self.state==HMPublishContentStateBegan) {
        return @"发送中...";
    }
    switch (errorCode) {
        case HMSuccess:
            return @"分享成功!";
            break;
        case HMAuthOK:
            return @"授权成功!";
            break;
        case HMErrCodeUserCancel:
            return @"取消发送!";
            break;
        case HMErrCodeSentFail:
            return @"发送失败!";
            break;
        case HMErrCodeAuthDeny:
            return @"授权失败!";
            break;
        case HMErrCodeUnsupport:
            return @"客户端不支持!";
            break;
        case HMErrCodeUninstalled:
            return @"没安装客户端!";
            break;
        default:
            return @"发生错误";
            break;
    }
}

@end

#pragma mark -

@implementation HMShareItemObject

@synthesize title;
@synthesize description;
@synthesize thumb;
@synthesize media;
@synthesize mediaType;
@synthesize subType;
@synthesize sendType;
@synthesize shareType;
@synthesize scheme;
@synthesize redirectURI;
@synthesize appSecret;
@synthesize appid;
@synthesize replensih;
@synthesize rootController;

+ (instancetype)spawn{
    return [[[self alloc]init]autoreleaseARC];
}

- (void)dealloc
{
    self.title = nil;
    self.description = nil;
    self.thumb = nil;
    self.media = nil;
    self.scheme = nil;
    self.redirectURI = nil;
    self.appSecret = nil;
    self.appid = nil;
    self.replensih = nil;
    self.rootController = nil;
    HM_SUPER_DEALLOC();
}
@end

#pragma mark -


@implementation HMShareService{
    NSArray *shareConfig;
    UIWindow        *_window;
}
@synthesize result;
DEF_SINGLETON_AUTOLOAD(HMShareService)
DEF_NOTIFICATION(HMShareServiceRespone)

- (id)init
{
    self = [super init];
    if (self) {
        NSData *data = [NSData dataWithContentsOfFile:[HMSandbox pathWithbundleName:nil fileName:@"ShareConfig.plist"]];
        NSPropertyListFormat format;
        NSArray *dic = [NSPropertyListSerialization propertyListWithData:data options:0 format:&format error:nil];
        shareConfig = [[shareConfigObject objectsFromArray:dic]retainARC];
        
        [self observeNotification:[HMShareService HMShareServiceRespone]];
        
        [self registerShares];
    }
    return self;
}

- (void)dealloc
{
    [self unobserveNotification:[HMShareService HMShareServiceRespone]];
    self.result = nil;
    [shareConfig releaseARC];
    HM_SUPER_DEALLOC();
}

- (void)registerShares{
    for (shareConfigObject *object in shareConfig) {
        if (object.enableB) {
            Class clazz = NSClassFromString(object.className);
            if (clazz) {
                if(class_conformsToProtocol(clazz, @protocol(HMShareServiceProtocol))){
                    Method method = class_getClassMethod(clazz, @selector(registerApp:));
                    method_invoke(clazz, method,object.appid);
                }
            }
        }
    }
}

- (shareConfigObject *)classForShareType:(HMShareType)type{
    NSString *className = nil;
    switch (type) {
        case HMShareTypeWeChat:
            className = @"HMServiceWeChat";
            break;
        case HMShareTypeSinaWeibo:
            className = @"HMServiceSinaWB";
            break;
        case HMShareTypeTencentWeibo:
            className = @"HMServiceTencentWB";
            break;
        case HMShareTypeSMS:
            className = @"HMServiceSMS";
            break;
        case HMShareTypeEmail:
            className = @"HMServiceEmail";
            break;

        default:
            break;
    }
    for (shareConfigObject *object in shareConfig) {
        if ([object.className isEqualToString:className]) {
            if (object.enableB) {
                
                return object;
                
            }else{
                NSAssert(NO, @"share service :you must enable setting in shareConfig.plist for %@",className);
            }
        }
        
    }
    return nil;
}

+ (HMShareMediaType)appShareType:(HMShareType)type{
    switch (type) {
        case HMShareTypeWeChat:
            return HMShareMediaType_WXWebpage;
            break;
        case HMShareTypeSinaWeibo:
            return HMShareMediaType_SLWebpage;
            break;
        default:
            return HMShareMediaType_WXWebpage;
            break;
    }
}

+ (void)shareApp:(HMShareType)shareType thumb:(UIImage*)thumb url:(NSString*)url description:(NSString *)description{
    HMShareItemObject *item = [HMShareItemObject spawn];
    item.description = description;
    item.title = [HMSystemInfo appName];
    item.thumb = thumb==nil?[UIImage imageNamed:@"Icon.png"]:thumb;
    item.media = url==nil?[self userDefaultsRead:trackVersionKEY_Url]:url;
    item.mediaType = [self appShareType:shareType];
    [self share:shareType shareBody:item];
}

+ (void)shareApp:(HMShareType)shareType description:(NSString *)description{

    [self shareApp:shareType thumb:nil url:nil description:description];
}
- (UIWindow *)window
{
    if ( nil == _window )
    {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.hidden = YES;
        _window.rootViewController = [HMUIBoard board];
    }
    
    return _window;
}

+ (void)presentController:(UIViewController *)c{
    if ([HMShareService sharedInstance].window.hidden) {
        [HMShareService sharedInstance].window.hidden = NO;
    }
    [[HMShareService sharedInstance].window.rootViewController.view addSubview:c.view];
    [[HMShareService sharedInstance].window.rootViewController addChildViewController:c];
//    [[HMShareService sharedInstance].window.rootViewController presentViewController:c animated:YES completion:nil];
}

+ (void)dismiss{
    if (![HMShareService sharedInstance].window.hidden) {
        [HMShareService sharedInstance].window.hidden = YES;
    }
}

+ (void)share:(HMShareItemObject *)item{
    [HMShareService share:item.shareType shareBody:item];
}

+ (void)share:(HMShareType)shareType shareBody:(HMShareItemObject *)item{
     shareConfigObject * object = [[HMShareService sharedInstance] classForShareType:shareType];
    item.redirectURI = object.redirectURI;
    item.appSecret = object.appSecret;
    item.appid = object.appid;
    
    Class clazz =  NSClassFromString(object.className);
    if (clazz) {
        if(class_conformsToProtocol(clazz, @protocol(HMShareServiceProtocol))){
            
            Method instance = class_getClassMethod(clazz, @selector(sharedInstance));
            id target = method_invoke(clazz, instance);
            Method method = class_getInstanceMethod(clazz, @selector(shareBody:));
            
            method_invoke(target, method,item);
        }
    }
}

- (UIWindow*)keyWindow{
    static UIWindow *keyWindow=nil;
    if (keyWindow==nil) {
        keyWindow = [[UIWindow alloc]init];
        keyWindow.frame = CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 20);
        keyWindow.windowLevel = UIWindowLevelStatusBar+33;
        self.keyWindow.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.5];
    }
    return keyWindow;
}

- (UILabel*)tipLabel{
    static UILabel *tipLabel=nil;
    if (tipLabel==nil) {
        tipLabel = [[UILabel spawn]retainARC];
        tipLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-200, 0, 200, 20);
        [self.keyWindow addSubview:tipLabel];
    }
    return tipLabel;
}

- (void)show{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [UIView animateWithDuration:.25f animations:^{
                self.keyWindow.y = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.25f delay:1.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.keyWindow.y = -20;
                } completion:^(BOOL finished) {
                    self.keyWindow.hidden = YES;
                }];
            }];
        }
    });
    
}

ON_NOTIFICATION3(HMShareService, HMShareServiceRespone, notif){
    HMShareServiceResult *resultObject = notif.object;
    self.tipLabel.text = [resultObject description];
    [self.tipLabel sizeToFit];
    self.tipLabel.origin = CGPointMake(self.keyWindow.width-self.tipLabel.width, 0);
    self.keyWindow.hidden = NO;
    self.keyWindow.y = -20;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:self];
    [self performSelector:@selector(show) withObject:self afterDelay:1.f];
    if (self.result) {
        //(HMShareType type, HMPublishContentState state, id statusInfo, enum HMErrCode error)
        result(resultObject.type,resultObject.state,resultObject.statusInfo,resultObject.errorCode);
    }
    
}
@end
