//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//
@interface WebAPIResult : NSObject

@property (nonatomic, copy)  NSString *      message;

@property (nonatomic, HM_STRONG)  NSNumber *     success;
@property (nonatomic, HM_STRONG)  NSNumber *     error_code;
@property (nonatomic, HM_STRONG)  NSObject * result;

@property (nonatomic, assign) Class         resultClass;
@property (nonatomic, HM_STRONG) id         resultObject;
@property (nonatomic, assign, readonly)  BOOL     successI;
@property (nonatomic, assign, readonly)  NSInteger     error_codeI;

@end

@interface ___FILEBASENAME___ : Bean
/**
 *  bean对象声明
 *
 *  @return 命令字与数据对象映射表
 */
+ (NSDictionary*)classNames;

/**
 *  开启网络数据结构代码打印
 *  运行程序后将在log栏打印出相关数据接口的model数据结构、presenter请求代码、请按需拷贝
 */
+ (void)logModel;
@end
