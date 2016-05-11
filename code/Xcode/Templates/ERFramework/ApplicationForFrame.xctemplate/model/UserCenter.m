//
//  UserCenter.m
//  GLuckyTransport
//
//  Created by mac on 15/7/20.
//  Copyright (c) 2015年 mac. All rights reserved.
//


#import "UserCenter.h"

@implementation UserCenter
DEF_SINGLETON_AUTOLOAD(UserCenter)

@synthesize userName=_userName,passWord=_passWord,autoLogin=_autoLogin,markPassWord=_markPassWord,loginOut=_loginOut;
@synthesize token=_token,appUrl=_appUrl;
@synthesize userid_token=_userid_token,channelid_token=_channelid_token;
@synthesize users=_users;
@synthesize role;

- (id)init
{
    self = [super init];
    if (self) {

        self.token = @"";
        
        NSDictionary * userss =  [[NSUserDefaults standardUserDefaults] objectForKey:@"UserCenter_Users"];
       _users = [NSMutableDictionary dictionaryWithDictionary:userss];
        _userName = self.userName;
        
    }
    return self;
}

- (void)dealloc
{
    SAFE_RELEASE(_appUrl);
    SAFE_RELEASE(_userName);
    SAFE_RELEASE(_passWord);
    SAFE_RELEASE(_userid_token);
    SAFE_RELEASE(_channelid_token);
    SAFE_RELEASE(_users);
    self.token = nil;
    HM_SUPER_DEALLOC();
}



-(void)setUserid_token:(NSString *)userid_token{
//    [_userid_token  release];
    _userid_token = [userid_token copy];
}
-(NSString *)userid_token{
    if (_userid_token==nil) {
        _userid_token = @"";
    }
    return _userid_token;
}
-(void)setChannelid_token:(NSString *)channelid_token{
//    [_channelid_token  release];
    _channelid_token = [channelid_token copy];
}
-(NSString *)channelid_token{
    if (_channelid_token==nil) {
        _channelid_token = @"";
    }
    return _channelid_token;
}
-(void)setPassWord:(NSString *)passWord{
    [self setPassWord:passWord store:YES];
    
}
-(void)setPassWord:(NSString *)passWord store:(BOOL)store{
//    if (_passWord) {
//        [_passWord releaseARC];
//    }
    _passWord = [passWord copy];
    
    if (store) {
        if (_userName.length) {
            if (!self.ismarkPassWord) {
                [self.users removeObjectForKey:_userName];
            }else{
                [self.users setValue:_passWord forKey:_userName];
            }
            [[NSUserDefaults standardUserDefaults] setValue:_users forKey:@"UserCenter_Users"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    
}
-(NSString *)passWord{
    if (_passWord) {
        return _passWord;
    }else{
        if (_userName==nil || [[self.users valueForKey:_userName] length]==0) {
            return @"";
        }
        return [self.users valueForKey:_userName];
    }
}

-(void)setUserName:(NSString *)userName{
    [self setUserName:userName store:YES];
}

-(void)setUserName:(NSString *)userName store:(BOOL)store{
//    if (_userName) {
//        [_userName releaseARC];
//    }
    _userName = [userName copy];
    
    if (store) {
        if (_passWord.length>0 && _userName.length>0) {
            [self.users setValue:_passWord forKey:_userName];
            [[NSUserDefaults standardUserDefaults] setValue:_users forKey:@"UserCenter_Users"];
        }
        [[NSUserDefaults standardUserDefaults] setValue:_userName forKey:@"UserCenter_UserName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

-(NSString *)userName{
    if (_userName) {
        return _userName;
    }else{
        NSString *name =[[NSUserDefaults standardUserDefaults] valueForKey:@"UserCenter_UserName"];
        return name.length==0?@"":name;
    }
}

-(void)setAutoLogin:(BOOL)autoLogin{
    _autoLogin = autoLogin;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:_autoLogin] forKey:@"UserCenter_AutoLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isautoLogin{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserCenter_AutoLogin"]boolValue];
}
-(void)setLoginOut:(BOOL)loginOut{
    _loginOut = loginOut;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:loginOut] forKey:@"UserCenter_LoginOut"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isloginOut{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserCenter_LoginOut"]boolValue];
}

-(void)setMarkPassWord:(BOOL)markPassWord{
    _markPassWord = markPassWord;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:_markPassWord] forKey:@"UserCenter_MarkPassWord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)ismarkPassWord{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:@"UserCenter_MarkPassWord"]boolValue];
}

@end