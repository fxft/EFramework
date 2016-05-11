//
//  API.h
//  EFExtend
//
//  Created by mac on 15/3/27.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, APIProcess) {
    APIProcessNone,//什么都没做
    APIProcessLoading,//开始获取
    APIProcessSucced,//获取成功
    APIProcessOldData,//获取到旧数据，部分业务不需要更新界面
    APIProcessTimeOut,//超时
    APIProcessFailed,//失败
    APIProcessDataAppending,//会返回加载进度－具体看设置的对象参数
    APIProcessStep,//用户自定义
};

@class API;

@protocol APICallBackProtocol <NSObject>

- (void)api:(API*)api doSome:(NSString*)something bean:(id)bean state:(APIProcess)state userinfo:(id)userinfo error:(NSError *)error;

@end
@interface API : NSObject
@property (nonatomic, HM_WEAK) id<APICallBackProtocol> delegate;

+ (instancetype)api;

- (void)registerClassName:(Class)clazz forCommand:(NSString *)command;
- (Class)classForCommand:(NSString*)command;

- (void)observeListener:(id<APICallBackProtocol>)Listener forCommand:(NSString*)command;
- (void)unobserveListener:(id<APICallBackProtocol>)Listener forCommand:(NSString*)command;

- (NSArray*)observeListenersForCommand:(NSString*)command;
- (void)unobserveListenersForCommand:(NSString*)command;

- (void)callbackListenter:(NSString*)command bean:(id)bean state:(APIProcess)state error:(NSError *)error;
- (void)callbackListenter:(NSString*)command bean:(id)bean state:(APIProcess)state userinfo:(id)userinfo error:(NSError *)error;
@end
