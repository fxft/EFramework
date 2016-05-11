//
//  Presenter.h
//  EFExtend
//
//  Created by mac on 15/3/27.
//  Copyright (c) 2015年 Eric. All rights reserved.
//
/**
 *  MVPC开发模式
 *  ViewController控制器(C):负责UI控制、用户交互、基础数据选择
 *  Model模型(M):数据获取、通道逻辑
 *  Presenter 表示器(P):业务逻辑、数据处理、数据有效性筛选
 *  View视图(V):视图展现、动效处理
 *
 *  开发中涉及到的父类分别为Presenter:表示器基础能力，API:模型基础能力，Bean:数据结构基础能力
 *  创建P、A、B文件时,可以使用模版中的PresenterApiModel父类，模版将导入基础能力代码
 */

#import <Foundation/Foundation.h>
#import "API.h"
#import "Bean.h"


typedef NS_ENUM(NSUInteger, PresenterProcess) {
    PresenterProcessNone,//什么都没做
    PresenterProcessLoading,//开始获取
    PresenterProcessSucced,//获取成功
    PresenterProcessOldData,//获取到旧数据，部分业务不需要更新界面
    PresenterProcessTimeOut,//超时
    PresenterProcessFailed,//失败
    PresenterProcessDataAppending,//会返回加载进度－具体看设置的对象参数
    PresenterProcessStep,//用户自定义
};

@class Presenter;

//typedef void(^PresenterCALLBACK)(Presenter* presenter, NSString* something,id bean, PresenterProcess state, NSError *error);

@protocol PresenterCallBackProtocol <NSObject>

- (void)presenter:(Presenter*)presenter doSome:(NSString*)something bean:(id)bean state:(PresenterProcess)state error:(NSError *)error;


@end

@protocol PresenterProtocol <NSObject>

@property (nonatomic,HM_WEAK)id<PresenterCallBackProtocol> delegate;

// U do,you may set the IO's tagString for easy mark
/**
 *  输入输出的绑定
 *
 *  @param IO   输入输出的视图对象
 *  @param attribute 对象属性别名
 */
- (void)bindInputOutput:(UIView*)IOput forAttribute:(NSString*)attribute;
- (void)bindInput:(UIView*)Input forAttribute:(NSString*)attribute;
- (void)bindOutput:(UIView*)Output forAttribute:(NSString*)attribute;

// I may do
/**
 *  绑定试图后告诉适配器填充默认值
 *
 *  @param attributeBinded 需要填充的属性别名
 *  @param something       需要填充的业务名
 */
- (void)fillThem:(NSArray*)attributeBinded forSomething:(NSString*)something;

// I may do
/**
 *  校验
 *
 *  @param attributeBinded 需要填充的属性别名
 *  @param something       需要填充的业务名
 */
- (BOOL)verityThem:(NSArray*)attributeBinded forSomething:(NSString*)something;

// I can do
/**
 *  能力接口
 *
 *  @param something       双方约定的关键字规则
 *  @param attributeBinded 需要获取数据时告诉我需要使用的IO属性,或者直接传入参数,可为空；需要根据相应的事务进行约定
 *  @param callback        数据返回，过程反馈 请设置delegate
 *  @param return        同步获取时可以马上数据返回
 */

- (id)doSomething:(NSString*)something attributes:(NSArray*)attributeBinded;
//- (id)doSomething:(NSString*)something attributes:(NSArray*)attributeBinded callback:(PresenterCALLBACK)callback;

/**
 *  能力接口
 *
 *  @param something       双方约定的关键字规则
 *  @param attributeBinded 存储的数据
 *  @param return        数据返回
 */

- (void)doStore:(NSString*)something attributes:(id)attributeBinded;
- (id)doReStore:(NSString*)something;

@end

@interface Presenter : NSObject<PresenterProtocol>

+ (instancetype)presenter;

- (id)getOutput:(NSString*)attribute;
- (id)getInput:(NSString*)attribute;

- (void)unbindOutput:(NSString*)attribute;
- (void)unbindIutput:(NSString*)attribute;
- (void)unbindInputOutput:(NSString*)attribute;
- (void)unbindAll;

@end

