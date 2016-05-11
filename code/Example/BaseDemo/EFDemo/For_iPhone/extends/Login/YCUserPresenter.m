//
//  UserPresenter.m
//  JJICar
//
//  Created by mac on 15/12/2.
//  Copyright © 2015年 mac. All rights reserved.
//

#import "YCUserPresenter.h"
#import "Model.h"
#import "ModelApi.h"
#define userTask(str) [@"ApiService/Public/Api/?service=" stringByAppendingString:str]
@interface YCUserPresenter ()<APICallBackProtocol>

@property (nonatomic,strong) ModelApi *api;
@end

@implementation YCUserPresenter

@synthesize api;



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
        self.api = [ModelApi api];
        self.api.delegate = self;
    }
    return self;
}


- (void)fillThem:(NSArray *)attributeBinded forSomething:(NSString *)something{

    NSString *sec = [NSString stringWithFormat:@"doReset%@Attributes:",something];
    SEL sel = NSSelectorFromString(sec);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:attributeBinded];
    }
}

- (BOOL)verityThem:(NSArray *)attributeBinded forSomething:(NSString *)something{
    
    NSString *sec = [NSString stringWithFormat:@"doVerity%@Attributes:",something];
    SEL sel = NSSelectorFromString(sec);
    if ([self respondsToSelector:sel]) {
        return [self performSelector:sel withObject:attributeBinded];
    }
    return YES;
}

- (id)doSomething:(NSString *)something attributes:(NSArray *)attributeBinded{
    NSDictionary *dic = [attributeBinded firstObject];
  
    NSString *sec = [NSString stringWithFormat:@"do%@Attributes:",something];
    SEL sel = NSSelectorFromString(sec);
    if ([self respondsToSelector:sel]) {
        return [self performSelector:sel withObject:dic];
    }
    
    return nil;
}
//- (id)dologinAttributes:(NSDictionary *)attributeBinded


- (id)doReStore:(NSString *)something{
    id objc = [super doReStore:something];
    return objc==nil?@"":objc;
}

- (void)api:(API *)api doSome:(NSString *)something bean:(WebAPIResult*)bean state:(APIProcess)state userinfo:(id)userinfo error:(NSError *)error{
    NSLog(@"%@",userinfo);
    //登录
    if ([something is:[self login]]) {
        if (state==APIProcessSucced) {
            NSDictionary *dic = (NSDictionary *)bean.result;
            [UserCenter sharedInstance].token = [dic objectForKey:@"token"];
//            AppUser *userModel = [AppUser appUserModelWithDic:[dic objectForKey:@"user"]];
//            [[UserCenter sharedInstance] configUserModel:userModel];
            [UserCenter sharedInstance].autoLogin = YES;
        }else if (state==APIProcessLoading) {
            [self showMessageTip:nil detail:@"正在登录..." timeOut:30.f];
        }else{
//            [ShowTips showTips:bean.message andTime:2.f];
        }
    }
    //短信登录
    if([something is:[self smsLogin]]){
        if (state==APIProcessSucced) {
            NSDictionary *dic = (NSDictionary *)bean.result;
            [UserCenter sharedInstance].token = [dic objectForKey:@"token"];
//            AppUser *userModel = [AppUser appUserModelWithDic:[dic objectForKey:@"user"]];
//            [[UserCenter sharedInstance] configUserModel:userModel];
            [UserCenter sharedInstance].autoLogin = YES;
        }else if (state==APIProcessLoading) {
            [self showMessageTip:nil detail:@"正在登录..." timeOut:30.f];
        }else{
//            [ShowTips showTips:bean.message andTime:2.f];
            NSLog(@"%@",bean.message);
        }
    }
    //发送验证码
    if([something is:[self sendRegSmsCode]]){
        if(state == APIProcessSucced){
//            [ShowTips showTips:[bean.message notEmpty]?bean.message:@"发送成功" andTime:2.f];
        }else if (state==APIProcessFailed) {
//            [ShowTips showTips:bean.message andTime:2.f];
        }
    }
    //注册
    if([something is:[self regist]]){
        if(state == APIProcessSucced){
            NSDictionary *dic = (NSDictionary *)bean.result;
            [UserCenter sharedInstance].token = [dic objectForKey:@"token"];
//            AppUser *userModel = [AppUser appUserModelWithDic:[dic objectForKey:@"user"]];
//            [[UserCenter sharedInstance] configUserModel:userModel];
            [UserCenter sharedInstance].autoLogin = YES;
        }else if (state==APIProcessFailed) {
//            [self showMessageTip:nil detail:bean.message timeOut:2.f];
            [ShowTips showTips:bean.message andTime:2.f];
        }
    }
    //忘记密码
    if([something is:[self forgetPassword]]){
        if(state == APIProcessSucced){
//            [ShowTips showTips:[bean.message notEmpty]?bean.message:@"密码修改成功" andTime:2.f];
        }else if (state==APIProcessFailed) {
//            [ShowTips showTips:bean.message andTime:2.f];
        }
    }
    //用户信息
    if([something is:[self getProfile]]){
        if(state == APIProcessSucced){
            NSDictionary *dic = (NSDictionary *)bean.result;
            [UserCenter sharedInstance].token = [dic objectForKey:@"token"];
//            AppUser *userModel = [AppUser appUserModelWithDic:[dic objectForKey:@"user"]];
//            [[UserCenter sharedInstance] configUserModel:userModel];
            [UserCenter sharedInstance].autoLogin = YES;
        }else if (state == APIProcessFailed){
            [UserCenter sharedInstance].autoLogin = NO;
//            [ShowTips showTips:bean.message andTime:2.f];
        }
    }
    //门店历史纪录
    if([something is:[self getMerchantList]]){
        if(state == APIProcessSucced){
//            NSDictionary *dic = (NSDictionary *)bean.result;
//            NSLog(@"门店列表信息:%@",dic);
        }else if (state == APIProcessFailed){
//            NSLog(@"门店列表信息错误:%@",bean.result);
//            [ShowTips showTips:bean.message andTime:2.f];
        }
    }
    
    //门店详情
    if([something is:[self getMerchantInfo]]){
        if(state == APIProcessSucced){
            NSDictionary *dic = (NSDictionary *)bean.result;
            NSLog(@"门店详情信息:%@",dic);
        }else if (state == APIProcessFailed){
//            [ShowTips showTips:bean.message andTime:2.f];
        }
    }
    
    //套餐详情
    if([something is:[self packageDetailInfo]]){
        if(state == APIProcessSucced){
            NSDictionary *dic = (NSDictionary *)bean.result;
            NSLog(@"套餐详情信息:%@",dic);
        }else if (state == APIProcessFailed){
//            [ShowTips showTips:bean.message andTime:2.f];
        }
    }
    
    /*
    //获取用户邀请码信息
    if([something is:[self getInviteInfo]]){
        if(state == APIProcessSucced){
            NSDictionary *dic = (NSDictionary *)bean.result;
            NSDictionary *inviteDic = [dic objectForKey:@"invited_info"];
//            [[UserCenter sharedInstance] setMyInviteCode:[inviteDic objectForKey:@"code"]];
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    
    if([something is:[self getInComeInfo]]){
        if(state == APIProcessSucced){
            NSDictionary *dic = (NSDictionary *)bean.result;
            NSDictionary *incomeDic = [dic objectForKey:@"income_info"];
//            [[UserCenter sharedInstance] setJjCoin:[self numberToString:[incomeDic objectForKey:@"current_income"]]];
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    
    
    
    //修改昵称
    if([something is:[self changeNickname]]){
        if(state == APIProcessSucced){
//            NSString *str = [self extractWithKey:@"newnickname"];
//            [[UserCenter sharedInstance] setUserNickName:str];
            [self showMessageTip:nil detail:(NSString *)bean.result timeOut:2.f];
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    
    //修改密码
    if([something is:[self changeUserPSW]]){
        if(state == APIProcessSucced){
            [self showMessageTip:nil detail:@"密码修改成功" timeOut:2.f];
//            [[UserCenter sharedInstance] setPassWord:[self extractWithKey:@"newpassword"]];
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    
    //更改头像
    if ([something is:[self uploadHeadImage]]) {
        if(state == APIProcessSucced){
            [self showMessageTip:nil detail:@"头像上传成功" timeOut:2.f];
            NSDictionary *dic = (NSDictionary *)bean.result;
//            [[UserCenter sharedInstance] setHeadImg:[dic objectForKey:@"userHeadImageUrl"]];
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }else if (state == APIProcessLoading){
            [self showMessageTip:nil detail:@"正在上传头像" timeOut:20.f];
        }
    }
    
    //
    if ([something is:[self getMessage]]) {
        if(state == APIProcessSucced){
            NSArray *ary = (NSArray *)bean.result;
            if(ary.count>0){
                [self showMessageTip:nil detail:@"消息获取成功" timeOut:2.f];
            }else{
                [self showMessageTip:nil detail:@"亲，没有更多的内容" timeOut:2.f];
            }
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    
    if([something is:[self getGoldOperationList]]){
        if(state == APIProcessSucced){
            [self showMessageTip:nil detail:@"消息获取成功" timeOut:2.f];
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    
    if([something is:[self getIntegralOperationList]]){
        if(state == APIProcessSucced){
            [self showMessageTip:nil detail:@"消息获取成功" timeOut:2.f];
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    
    
    if([something is:[self getComsumptionVolums]]){
        if(state == APIProcessSucced){
            
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    
    if([something is:[self cancelVolume]]){
        if(state == APIProcessSucced){
            
        }else if (state == APIProcessFailed){
            [self showMessageTip:nil detail:bean.message timeOut:2.f];
        }
    }
    */
    //代理方法
    if ([self.delegate respondsToSelector:@selector(presenter:doSome:bean:state:error:)]) {
        [self.delegate presenter:self doSome:something bean:bean state:(PresenterProcess)state error:error];
    }
}


#pragma mark -

#pragma mark login
DEF_STRING(login,@"login")

#pragma mark login
- (id)dologinAttributes:(NSDictionary *)attributeBinded{
    
    NSString *telephone = [attributeBinded objectForKey:@"telephone"];
    NSString *password = [attributeBinded objectForKey:@"password"];
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          @"version":APPVersion,
                          @"username":telephone,
                          @"password":[password.MD5String lowercaseString],
                          @"uuid":APPUUID
                          };
    [self.api postOrGet:NO paras:dic to:userTask(@"User.Login") alias:[self login] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark -
#pragma mark regist
DEF_STRING(regist,@"regist")
#pragma mark regist

-(id)doregistAttributes:(NSDictionary *)attributeBinded{
    
    NSString *telephone = [attributeBinded objectForKey:@"telephone"];
    NSString *password = [attributeBinded objectForKey:@"password"];
    NSString *smscode = [attributeBinded objectForKey:@"smscode"];
    NSString *invitecode = [attributeBinded objectForKey:@"invitecode"];
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          @"version":APPVersion,
                          @"username":telephone,
                          @"password":[password.MD5String lowercaseString],
                          @"smsCode":smscode,
                          @"inviteCode":invitecode,
                          @"uuid":APPUUID
                          };
    [self.api postOrGet:NO paras:dic to:userTask(@"User.Register") alias:[self regist] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark -
#pragma mark sendRegSmsCode
DEF_STRING(sendRegSmsCode,@"sendRegSmsCode")
#pragma mark sendRegSmsCode
-(id)dosendRegSmsCodeAttributes:(NSDictionary *)attributeBinded{
    NSString *telephone = [attributeBinded objectForKey:@"telephone"];
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          @"version":APPVersion,
                          @"phone":telephone
                          };
    [self.api postOrGet:NO paras:dic to:userTask(@"User.SendRegSmsCode") alias:[self sendRegSmsCode] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark -
#pragma mark forgetPassword
DEF_STRING(forgetPassword,@"forgetPassword")
#pragma mark forgetPassword
-(id)doforgetPasswordAttributes:(NSDictionary *)attributeBinded{
    
    NSString *telephone = [attributeBinded objectForKey:@"telephone"];
    NSString *smscode = [attributeBinded objectForKey:@"smscode"];
    NSString *password = [attributeBinded objectForKey:@"password"];
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          @"version":APPVersion,
                          @"username":telephone,
                          @"smsCode":smscode,
                          @"password":[password.MD5String lowercaseString]
                          };
    [self.api postOrGet:YES paras:dic to:userTask(@"User.ForgetPassword") alias:[self forgetPassword] encrypt:NO asData:dataTypeAsPara form:self];
    
    return nil;
}

#pragma mark -
#pragma mark smsLogin
DEF_STRING(smsLogin,@"smsLogin")
#pragma mark smsLogin
-(id)dosmsLoginAttributes:(NSDictionary *)attributeBinded{
    
    NSString *telephone = [attributeBinded objectForKey:@"telephone"];
    NSString *smscode = [attributeBinded objectForKey:@"smscode"];
    
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          @"version":APPVersion,
                          @"username":telephone,
                          @"smsCode":smscode,
                          @"uuid":APPUUID
                          };
    [self.api postOrGet:YES paras:dic to:userTask(@"User.SmsLogin") alias:[self smsLogin] encrypt:NO asData:dataTypeAsPara form:self];
    
    return nil;
}

#pragma mark -
#pragma mark getProfile
DEF_STRING(getProfile,@"getProfile")
#pragma mark getProfile
-(id)dogetProfileAttributes:(NSDictionary *)attributeBinded{
    
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          @"version":APPVersion,
                          @"username":[UserCenter sharedInstance].userName,
                          @"token":[UserCenter sharedInstance].token
                          };
    [self.api postOrGet:NO paras:dic to:userTask(@"User.GetProfile") alias:[self getProfile] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark -
#pragma mark getMerchantList
DEF_STRING(getMerchantList,@"getMerchantList")
#pragma mark getMerchantList
-(id)dogetMerchantListAttributes:(NSDictionary *)attributeBinded{
    
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          @"version":APPVersion,
                          @"username":[UserCenter sharedInstance].userName,
                          @"token":[UserCenter sharedInstance].token
                          };
    [self.api postOrGet:NO paras:dic to:userTask(@"User.GetMerchantList") alias:[self getMerchantList] encrypt:NO asData:dataTypeAsPara form:self];
    //User.MerchantBrowseHistory
    return nil;
}

#pragma mark -
#pragma mark getMerchantInfo
DEF_STRING(getMerchantInfo,@"getMerchantInfo")
#pragma mark getMerchantInfo
-(id)dogetMerchantInfoAttributes:(NSDictionary *)attributeBinded{
    NSString *num = [attributeBinded objectForKey:@"merchant_no"];
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          @"version":APPVersion,
                          @"username":[UserCenter sharedInstance].userName,
                          @"token":[UserCenter sharedInstance].token,
                          @"merchant_no":num
                          };
    [self.api postOrGet:NO paras:dic to:userTask(@"User.GetMerchantInfo") alias:[self getMerchantInfo] encrypt:NO asData:dataTypeAsPara form:self];
    //User.MerchantBrowseHistory
    return nil;
}

#pragma mark -
#pragma mark packageDetailInfo
DEF_STRING(packageDetailInfo,@"packageDetailInfo")
#pragma mark packageDetailInfo
-(id)dopackageDetailInfoAttributes:(NSDictionary *)attributeBinded{
    NSString *productNum = [attributeBinded objectForKey:@"product_number"];
    NSString *merchantNum = [attributeBinded objectForKey:@"merchant_number"];
    
    NSDictionary *dic = @{
                          @"appkey":APPKey,
                          
                          @"product_number":productNum,
                          @"merchant_number":merchantNum
                          };
    [self.api postOrGet:NO paras:dic to:userTask(@"http://zsf.tjsjls.com/Mall/Public/Client/?service=Package.PackageDetail&version=1.0") alias:[self getMerchantInfo] encrypt:NO asData:dataTypeAsPara form:self];
    //User.MerchantBrowseHistory
    return nil;
}



























#pragma mark -
#pragma mark automationLogin
DEF_STRING(automationLogin,@"automationLogin")
#pragma mark automationLogin
-(id)doautomationLoginAttributes:(NSDictionary *)attributeBinded{
    
//    NSString *telephoneStr = [[UserCenter sharedInstance].userName notEmpty]?[UserCenter sharedInstance].userName:@"";
//    NSString *passwordStr = [[UserCenter sharedInstance].passWord notEmpty]?[UserCenter sharedInstance].passWord:@"";
//    if([UserCenter sharedInstance].isautoLogin){
//        if([telephoneStr is:@""]||[passwordStr is:@""]){
//            [[UserCenter sharedInstance] setAutoLogin:NO];
//        }
//    }else{
//        telephoneStr = @"";
//        passwordStr = @"";
//    }
//    NSDictionary *dic = @{
//                          @"phoneNumber":telephoneStr,
//                          @"password":[passwordStr.MD5String lowercaseString]
//                          };
//    [self.api postOrGet:NO paras:dic to:userTask(@"login") alias:[self login] encrypt:NO asData:dataTypeAsPara form:self];
    
    return nil;
}

#pragma mark -
#pragma mark getInviteInfo
DEF_STRING(getInviteInfo,@"getInviteInfo")
#pragma mark getInviteInfo
-(id)dogetInviteInfoAttributes:(NSDictionary *)attributeBinded{
    
//    NSDictionary *dic = @{@"token":[UserCenter sharedInstance].token};
//    
//    [self.api postOrGet:NO paras:dic to:userTask(@"getInviteInfo") alias:[self getInviteInfo] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}



#pragma mark -
#pragma mark changeNickname
DEF_STRING(changeNickname,@"changeNickname")
DEF_STRING(changeNicknameIO_newNickname,@"changeNicknameIO_newNickname")
#pragma mark changeNickname
-(id)dochangeNicknameAttributes:(NSDictionary *)attributeBinded{
    
//    HMUITextField *nickname = [self getInput:self.changeNicknameIO_newNickname];
//    NSDictionary *dic = @{
//                          @"uid":[UserCenter sharedInstance].userid_token,
//                          @"newNickname":nickname.text
//                          };
//    [self saveKey:@"newnickname" withObject:nickname.text];
//    
//    [self.api postOrGet:YES paras:dic to:userTask(@"changeNickname") alias:[self changeNickname] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark -
#pragma mark changeUserPSW
DEF_STRING(changeUserPSW,@"changeUserPSW")
DEF_STRING(changePasswordIO_newPassword,@"changePasswordIO_newPassword")
DEF_STRING(changePasswordIO_renewPassword,@"changePasswordIO_renewPassword")
DEF_STRING(changePasswordIO_oldPassword,@"changePasswordIO_oldPassword")
#pragma mark changeUserPSW
-(id)dochangeUserPSWAttributes:(NSDictionary *)attributeBinded{
    
    HMUITextField *oldpassword = [self getInput:self.changePasswordIO_oldPassword];
    HMUITextField *newpassword = [self getInput:self.changePasswordIO_newPassword];
    HMUITextField *renewpassword = [self getInput:self.changePasswordIO_renewPassword];
    
    if([oldpassword.text is:newpassword.text]){
        [self showMessageTip:nil detail:@"新旧密码不能一样" timeOut:2.f];
        return nil;
    }
    
    if(![newpassword.text is:renewpassword.text]){
        [self showMessageTip:nil detail:@"密码与确认密码不一致" timeOut:2.f];
        return nil;
    }
    
    NSDictionary *dic = @{
                          @"currentPsw":[oldpassword.text.MD5String lowercaseString],
                          @"newPsw":[newpassword.text.MD5String lowercaseString]
                          };
    [self saveKey:@"newpassword" withObject:newpassword.text];
    [self.api postOrGet:YES paras:dic to:userTask(@"changeUserPSW") alias:[self changeUserPSW] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark -
#pragma mark uploadHeadImage
DEF_STRING(uploadHeadImage,@"uploadHeadImage")
#pragma mark uploadHeadImage
-(id)douploadHeadImageAttributes:(NSDictionary *)attributeBinded{
    
    NSMutableString *imgpath=[[NSMutableString alloc]init];
    [imgpath appendString:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    [imgpath appendString:@"/"];
    [imgpath appendString:[attributeBinded objectForKey:@"imgpath"]];
    
    
    [self.api postOrGet:YES paras:imgpath to:userTask(@"uploadHeadImage") alias:[self uploadHeadImage] encrypt:NO asData:dataTypeAsForm form:self];
    
    
    return nil;
}

#pragma mark -
#pragma mark getInComeInfo
DEF_STRING(getInComeInfo,@"getInComeInfo")
#pragma mark getInComeInfo
-(id)dogetInComeInfoAttributes:(NSDictionary *)attributeBinded{
    
//    NSDictionary *dic = @{@"token":[UserCenter sharedInstance].token};
//    
//    [self.api postOrGet:NO paras:dic to:userTask(@"getInComeInfo") alias:[self getInComeInfo] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark - ===========prit===========   getMessage
#pragma mark getMessage
DEF_STRING(getMessage,@"getMessage")
#pragma mark getMessage
-(id)dogetMessageAttributes:(NSDictionary *)attributeBinded{
    
    NSString *index = [attributeBinded objectForKey:@"index"];
    NSDictionary *dic = @{
                          @"limit":@20,
                          @"index":index
                          };
    [self.api postOrGet:YES paras:dic to:userTask(@"getMessage") alias:[self getMessage] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}


#pragma mark - ===========prit===========
#pragma mark getIntegralOperationList
DEF_STRING(getIntegralOperationList,@"getIntegralOperationList")
#pragma mark getIntegralOperationList
-(id)dogetIntegralOperationListAttributes:(NSDictionary *)attributeBinded{
    
//    NSString *index = [attributeBinded objectForKey:@"index"];
//    NSDictionary *dic = @{
//                          @"token":[UserCenter sharedInstance].token,
//                          @"limit":@20,
//                          @"index":index
//                          };
//    [self.api postOrGet:NO paras:dic to:userTask(@"getIntegralOperationList") alias:[self getIntegralOperationList] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark - ===========prit===========
#pragma mark getGoldOperationList
DEF_STRING(getGoldOperationList,@"getGoldOperationList")
#pragma mark getGoldOperationList
-(id)dogetGoldOperationListAttributes:(NSDictionary *)attributeBinded{
    
//    NSString *index = [attributeBinded objectForKey:@"index"];
//    NSDictionary *dic = @{
//                          @"token":[UserCenter sharedInstance].token,
//                          @"limit":@20,
//                          @"index":index
//                          };
//    [self.api postOrGet:NO paras:dic to:userTask(@"getGoldOperationList") alias:[self getGoldOperationList] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark - ===========prit===========
#pragma mark  getComsumptionVolums
DEF_STRING(getComsumptionVolums,@"getComsumptionVolums")
#pragma mark  getComsumptionVolums
-(id)dogetComsumptionVolumsAttributes:(NSDictionary *)attributeBinded{
    
//    NSString *index = [attributeBinded objectForKey:@"index"];
//    NSDictionary *dic = @{
//                          @"userid":[UserCenter sharedInstance].userid_token,
//                          @"limit":@40,
//                          @"index":index
//                          };
//    [self.api postOrGet:YES paras:dic to:userTask(@"getComsumptionVolums") alias:[self getComsumptionVolums] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark - ===========prit===========    getCouponVolumes
#pragma mark getCouponVolumes
DEF_STRING(getCouponVolumes,@"getCouponVolumes")
#pragma mark getCouponVolumes
-(id)dogetCouponVolumesAttributes:(NSDictionary *)attributeBinded{
    
    NSString *index = [attributeBinded objectForKey:@"index"];
    NSDictionary *dic = @{
                          @"limit":@40,
                          @"index":index
                          };
    [self.api postOrGet:YES paras:dic to:userTask(@"getCouponVolumes") alias:[self getCouponVolumes] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark - ===========prit===========    cancelVolume
#pragma mark cancelVolume
DEF_STRING(cancelVolume,@"cancelVolume")
#pragma mark cancelVolume
-(id)docancelVolumeAttributes:(NSDictionary *)attributeBinded{
    
    NSString *volumeId = [attributeBinded objectForKey:@"volumeId"];
    NSDictionary *dic = @{
                          @"volumeId":volumeId
                          };
    [self.api postOrGet:YES paras:dic to:userTask(@"cancelVolume") alias:[self cancelVolume] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark - ===========prit===========    getOrderList
#pragma mark getOrderList
DEF_STRING(getOrderList,@"getOrderList")
#pragma mark getOrderList
-(id)dogetOrderListAttributes:(NSDictionary *)attributeBinded{
    
    NSString *index = [attributeBinded objectForKey:@"index"];
    NSString *orderState = [attributeBinded objectForKey:@"orderState"];
    NSDictionary *dic = @{
                          @"limit":@40,
                          @"index":index,
                          @"orderState":orderState,
                          @"type":@1
                          };
    [self.api postOrGet:YES paras:dic to:userTask(@"getOrderList") alias:[self getOrderList] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}

#pragma mark - ===========prit===========    getPackageList
#pragma mark getPackageList
DEF_STRING(getPackageList,@"getPackageList")
#pragma mark getPackageList
-(id)dogetPackageListAttributes:(NSDictionary *)attributeBinded{
    
    NSString *index = [attributeBinded objectForKey:@"index"];
    NSDictionary *dic = @{
                          @"limit":@40,
                          @"index":index
                          };
    [self.api postOrGet:YES paras:dic to:userTask(@"getPackageList") alias:[self getPackageList] encrypt:NO asData:dataTypeAsPara form:self];
    return nil;
}



#pragma mark -通用的
#pragma mark 判断手机号是否正确的
- (BOOL)checkTelePhone:(NSString *)telePhone{
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,2-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [pred evaluateWithObject:telePhone];
    if (!isValid) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入正确的手机号码" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

#pragma mark 存储数据的 doStore和doReStore无法存储成功
-(void)saveKey:(NSString *)key withObject:(id)object{
    [[NSUserDefaults standardUserDefaults]setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(id)extractWithKey:(NSString *)key{
    id obj = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    return obj == nil?@"":obj;
}

#pragma mark 判断数据有效性
-(NSString *)strIsEnpty:(NSString *)str{
    if(![str isKindOfClass:[NSNull class]]){
        if ([str notEmpty]) {
            return str;
        }
        return @"";
    }else{
        return @"";
    }
}

-(NSString *)numberToString:(NSNumber *)obj{
    INFO(obj)
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSString *str = [numberFormatter stringFromNumber:obj];
    INFO(str)
    return str;
}

@end
