//
//  UserPresenter.m
//  EFExtend
//
//  Created by mac on 16/3/24.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "UserPresenter.h"
#import "UserApi.h"

@interface UserPresenter ()<APICallBackProtocol>

@property (nonatomic,strong) UserApi *api;

@end

@implementation UserPresenter

@synthesize api=_api;


- (void)dealloc
{
    self.api.delegate = nil;
    self.api = nil;
    INFO(@"%@>>>>>>>>>>>>>>>>>>>>out",[self class]);
    HM_SUPER_DEALLOC();
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.api = [UserApi api];
        
    }
    return self;
}

//如果需要设置数据获取默认值可覆盖以下方法
//- (id)doReStore:(NSString *)something{
//    id objc = [super doReStore:something];
//    return objc==nil?@"":objc;
//}

typedef void (*__doFill)(id,SEL, NSArray *);

/**
 *  实现 fillThem:forSomething:方法；初始化数据、填充绑定的视图；
 *  需要实现doReset+xxx+Attributes:的方法
 *
 *  @param attributeBinded 操作数据成员数组
 *  @param something       操作别名 eg. login
 */
- (void)fillThem:(NSArray *)attributeBinded forSomething:(NSString *)something{
    
    NSString *sec = [NSString stringWithFormat:@"doReset%@Attributes:",something];
    SEL sel = NSSelectorFromString(sec);
    if ([self respondsToSelector:sel]) {
        Method method = class_getInstanceMethod( [self class], sel );
        __doFill  _doFill = (__doFill)method_getImplementation( method );
        _doFill(self,sel,attributeBinded);
    }
}

typedef BOOL (*__doVerity)(id,SEL, NSArray *);

/**
 *  实现 verityThem:forSomething:方法；验证数据有效性；
 *  需要实现doVerity+xxx+Attributes:的方法,xxx表示每个something参数值
 *
 *  @param attributeBinded 操作数据成员数组
 *  @param something       操作别名 eg. login
 *
 *  @return 成功或失败
 */
- (BOOL)verityThem:(NSArray *)attributeBinded forSomething:(NSString *)something{
    
    NSString *sec = [NSString stringWithFormat:@"doVerity%@Attributes:",something];
    SEL sel = NSSelectorFromString(sec);
    if ([self respondsToSelector:sel]) {
        Method method = class_getInstanceMethod( [self class], sel );
        __doVerity  _doVerity = (__doVerity)method_getImplementation( method );
        return _doVerity(self,sel,attributeBinded);
    }
    return YES;
}

typedef id (*__doSomething)(id,SEL, NSDictionary *);

/**
 *  实现 doSomething:attributes:方法；业务逻辑处理；
 *  需要实现do+xxx+Attributes:的方法,xxx表示每个something参数值
 *
 *  @param something       操作别名 eg. login
 *  @param attributeBinded 操作数据对象成员字典，外层用数组包一层
 *
 *  @return 实际对象
 */
- (id)doSomething:(NSString *)something attributes:(NSArray *)attributeBinded{
    NSDictionary *dic = [attributeBinded firstObject];
    
    NSString *sec = [NSString stringWithFormat:@"do%@Attributes:",something];
    SEL sel = NSSelectorFromString(sec);
    if ([self respondsToSelector:sel]) {
        Method method = class_getInstanceMethod( [self class], sel );
        __doSomething  _doSomething = (__doSomething)method_getImplementation( method );
        return _doSomething(self,sel,dic);
    }
    
    return nil;
}


typedef BOOL (*__doApi)(id,SEL, API * , NSString *, id, APIProcess, id, NSError *);

/**
 *  model层api数据的<APICallBackProtocol>协议回调；
 *  需要实现do+xxx+Api:doSome:bean:state:userinfo:error:的方法,xxx表示每个something参数值
 *
 *  @param api       实例化API子类
 *  @param something 操作别名 eg. login
 *  @param bean      网络数据实例化后的对象，详见Bean定义
 *  @param state     处理过程状态
 *  @param userinfo  附带用户信息
 *  @param error     错误
 */
- (void)api:(API *)api doSome:(NSString *)something bean:(WebAPIResult*)bean state:(APIProcess)state userinfo:(id)userinfo error:(NSError *)error{
    
    BOOL respondtoController = YES;
    NSString *sec = [NSString stringWithFormat:@"do%@Api:doSome:bean:state:userinfo:error:",something];
    SEL sel = NSSelectorFromString(sec);
    if ([self respondsToSelector:sel]) {
        Method method = class_getInstanceMethod( [self class], sel );
        __doApi  _doApi = (__doApi)method_getImplementation( method );
        
       respondtoController = _doApi(self,sel,api,something,bean,state,userinfo,error);
        
    }
    
    if (respondtoController&&[self.delegate respondsToSelector:@selector(presenter:doSome:bean:state:error:)]) {
        [self.delegate presenter:self doSome:something bean:bean state:(PresenterProcess)state error:error];
    }
}

#pragma mark -

#pragma mark login
DEF_STRING(login,@"login")
DEF_STRING(loginIO_username,@"loginIO_username")
DEF_STRING(loginIO_password,@"loginIO_password")
DEF_STRING(loginIO_force,@"loginIO_force")
DEF_STRING(loginIO_app,@"loginIO_app")
DEF_STRING(loginIO_uuid,@"loginIO_uuid")
DEF_STRING(loginIO_platform,@"loginIO_platform")
#pragma mark login

- (void)doResetloginAttributes:(NSArray *)attributeBinded{
    
    UITextField *userTF = [attributeBinded containsObject:self.loginIO_username]?[self getInput:self.loginIO_username]:nil;
    
    UITextField *passwdTF = [self getInput:self.loginIO_password];
    
    UIButten *forceBt = [self getInput:self.loginIO_force];
    
    /*从历史数据中获取到最后一个用户信息*/
    NSString *username = @"123";
    NSString *password = @"";
    BOOL  rememberPW = YES;
    /*判断一下是否需要进行密码设置*/
    if (rememberPW) {
        passwdTF.text = password;
    }
    /*初始化数据*/
    userTF.text = username;
    forceBt.selected = rememberPW;
    
}

- (BOOL)doVerityloginAttributes:(NSArray*)attributeBinded{
    NSString *  username = [self doReStore:self.loginIO_username];
    NSString *  password = [self doReStore:self.loginIO_password];
    if (![username notEmpty]&&[attributeBinded containsObject:self.loginIO_username]) {
        [self showMessageTip:nil detail:@"请输入用户名" timeOut:1.5f];
        return NO;
    }
    if (![password notEmpty]&&[attributeBinded containsObject:self.loginIO_password]) {
        [self showMessageTip:nil detail:@"请填写密码" timeOut:1.5f];
        return NO;
    }
    return YES;
}

- (id)dologinAttributes:(NSDictionary *)attributeBinded{
    
    NSString *  username = [self doReStore:self.loginIO_username];
    NSString *  username2 = [attributeBinded valueForKey:self.loginIO_username];
    NSString *  username3 = [(UITextField*)[self getInput:self.loginIO_username] text];
    
    NSString *  password = [self doReStore:self.loginIO_password];
    NSString *  force = [self doReStore:self.loginIO_force];
    NSString *  app = [self doReStore:self.loginIO_app];
    NSString *  uuid = [self doReStore:self.loginIO_uuid];
    NSString *  platform = [self doReStore:self.loginIO_platform];
    
#ifdef DEBUG
    username = @"13489188888";
    password = @"xxxx";
    force = @"0";
    app = @"driver";
    uuid = @"adkalsjdfl";
    platform = @"android";
    
#endif
    NSDictionary *dic = @{
                          @"username":username,
                          @"password":password,
                          @"force":force,
                          @"app":app,
                          @"uuid":uuid,
                          @"platform":platform,
                          };
    return [self.api postOrGet:YES paras:dic to:@"api.do?login" alias:[self login] encrypt:NO asData:dataTypeAsPara form:self];
}

- (BOOL)dologinApi:(API *)api doSome:(NSString *)something bean:(UserWebAPIResult*)bean state:(APIProcess)state userinfo:(id)userinfo error:(NSError *)error{
    
    if (state == APIProcessSucced||state == APIProcessOldData) {
        
        /*如果用户需要记住密码*/
        if ([self doReStore:self.loginIO_force]) {
            [self userDefaultsWrite:[self doReStore:self.loginIO_password] forKey:@"+__+"];
        }
//        login *loginData =  bean.resultObject;
        
        [self showMessageTip:nil detail:@"登陆成功" timeOut:1.5f];
        
    }else if (state == APIProcessLoading) {
        [self showMessageTip:nil detail:@"正在登陆..." timeOut:30.f];
    }else if (state == APIProcessTimeOut) {
        [self showMessageTip:nil detail:@"超时" timeOut:1.5];
    }else if (state == APIProcessFailed) {
        [self showMessageTip:nil detail:@"失败" timeOut:1.5f];
    }else{
        [self showMessageTip:nil detail:bean.message timeOut:1.5f];
    }
    return YES;
}



#pragma mark -  download

DEF_STRING(DownVideo,@"DownVideo")
DEF_STRING(DownVideoIO_url,@"DownVideoIO_url")
- (id)doDownVideoAttributes:(NSDictionary *)attributeBinded{
    
    NSString *  url = [self doReStore:self.DownVideoIO_url];

   
    HMDialogue *dalogue =  [self.api postOrGet:NO paras:nil to:url alias:[self DownVideo] encrypt:NO asData:dataTypeAsPara form:self];
    [dalogue setWebListenProcess];
    [dalogue setWebDataFromNetwrokElseCache];
    
    return dalogue;
}

- (BOOL)doDownVideoApi:(API *)api doSome:(NSString *)something bean:(UserWebAPIResult*)bean state:(APIProcess)state userinfo:(id)userinfo error:(NSError *)error{
    
    if (state == APIProcessSucced||state == APIProcessOldData) {
        
        /*如果用户需要记住密码*/
        if ([self doReStore:self.loginIO_force]) {
            [self userDefaultsWrite:[self doReStore:self.loginIO_password] forKey:@"+__+"];
        }
        //        login *loginData =  bean.resultObject;
        
        [self showMessageTip:nil detail:@"登陆成功" timeOut:1.5f];
        
    }else if (state == APIProcessLoading) {
        [self showMessageTip:nil detail:@"正在下载..." timeOut:30.f];
        
    }else if (state == APIProcessTimeOut) {
        [self showMessageTip:nil detail:@"超时" timeOut:1.5];
    }else if (state == APIProcessFailed) {
        [self showMessageTip:nil detail:@"失败" timeOut:1.5f];
    }else if (state == APIProcessDataAppending) {
//        INFO(bean);
        HMMBProgressHUD * hud = [self showModeTip:nil detail:[bean description] custom:nil mode:MBProgressHUDModeDeterminate timeOut:-1 touchNavigatorRange:TouchRange_All];
        hud.progress = [(NSNumber *)bean floatValue];
        
    }else{
        [self showMessageTip:nil detail:bean.message timeOut:1.5f];
    }
    return YES;
}
@end
