//
//  UserCenter.h
//  GLuckyTransport
//
//  Created by mac on 15/7/20.
//  Copyright (c) 2015年 mac. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface UserCenter : NSObject
AS_SINGLETON(UserCenter)

@property (copy, nonatomic) NSString *userName;
@property (copy, nonatomic) NSString *passWord;

-(void)setPassWord:(NSString *)passWord store:(BOOL)store;
-(void)setUserName:(NSString *)userName store:(BOOL)store;

@property (assign, nonatomic,getter=isautoLogin)   BOOL autoLogin;
@property (assign, nonatomic,getter=isloginOut)   BOOL loginOut;
@property (assign, nonatomic,getter=ismarkPassWord)   BOOL markPassWord;
@property (HM_STRONG, nonatomic)   NSMutableDictionary *users;

//runtime
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *appUrl;
@property (copy, nonatomic) NSString *userid_token;
@property (copy, nonatomic) NSString *channelid_token;

@property (assign, nonatomic) NSInteger role;
@end