//
//  HMDialogue.h
//  CarAssistant
//
//  Created by Eric on 14-2-22.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMMacros.h"

typedef void (^UploadDataBlock)(id  formData);
typedef NSURLRequest * (^RedirectResponseBlock)(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse);

@class HMDialogue;
@class HMHTTPRequestOperation;

typedef void			(^HMDialogueBlock)( HMDialogue * msg );

@protocol HMDialogueExecutor<NSObject>

@optional
- (void)index:(HMDialogue *)dial;
- (void)route:(HMDialogue *)dial;
- (BOOL)prehandle:(HMDialogue *)dial;
- (void)posthandle:(HMDialogue *)dial;

@end

@interface HMDialogue : NSObject

AS_STRING( DIALOGUE_SERVICE ) 

AS_STRING( ERROR_DOMAIN_UNKNOWN )
AS_STRING( ERROR_DOMAIN_SERVER )
AS_STRING( ERROR_DOMAIN_CLIENT )
AS_STRING( ERROR_DOMAIN_NETWORK )

AS_INT( ERROR_CODE_OK )			// OK
AS_INT( ERROR_CODE_UNKNOWN )	// 非知错误
AS_INT( ERROR_CODE_TIMEOUT )	// 超时
AS_INT( ERROR_CODE_PARAMS )		// 参数错误
AS_INT( ERROR_CODE_ROUTES )		// 路由错误

AS_INT( STATE_CREATED )			// 对话被创建
AS_INT( STATE_SENDING )			// 对话正在发送
AS_INT( STATE_WAITING )			// 对话正在等待回应
AS_INT( STATE_SUCCEED )			// 对话处理成功（本地或网络）
AS_INT( STATE_FAILED )			// 对话处理失败（本地或网络）
AS_INT( STATE_CANCELLED )		// 对话被取消了

@property (nonatomic, HM_WEAK) id                           source;			// 发送来源
@property (nonatomic, HM_STRONG) NSMutableArray*           otherResponders;
@property (nonatomic, HM_WEAK) id                           target;			// 转发目标
@property (nonatomic, HM_WEAK) id<HMDialogueExecutor>       executer;
@property (nonatomic, HM_STRONG) NSObject *                 object;			// 附带参数

@property (nonatomic, HM_STRONG) NSString *                 order;
@property (nonatomic, HM_STRONG) NSString *                 name;			// 名字
@property (nonatomic, HM_STRONG) NSString *                 command;			// 命令
@property (nonatomic, HM_STRONG) NSString *                 mock;			// 名字

@property (nonatomic) BOOL                          oneDirection;	// 是否单方向发送
@property (nonatomic) BOOL                          unique;			// 是否同时只能发一个
@property (nonatomic) NSTimeInterval                seconds;
@property (nonatomic) BOOL                          timeout;		// 是否超时了
@property (nonatomic) NSInteger                     state;
@property (nonatomic) NSInteger                     nextState;
@property (nonatomic) BOOL                          disabled;		// 是否被禁止回调

@property (nonatomic, HM_STRONG) NSMutableDictionary *		input;
@property (nonatomic, HM_STRONG) NSMutableDictionary *		output;
@property (nonatomic,copy) UploadDataBlock block;
@property (nonatomic,copy) RedirectResponseBlock redirect;

@property (nonatomic) BOOL                         created;
@property (nonatomic) BOOL                         arrived;
@property (nonatomic) BOOL                         sending;
@property (nonatomic) BOOL                         waiting;
@property (nonatomic) BOOL                         succeed;
@property (nonatomic) BOOL                         failed;
@property (nonatomic) BOOL                         cancelled;
@property (nonatomic) BOOL                         progressed;

@property (nonatomic, HM_STRONG) NSString *                 errorDomain;
@property (nonatomic) NSInteger                             errorCode;
@property (nonatomic, HM_STRONG) NSString *                 errorDesc;

@property (nonatomic, copy) HMDialogueBlock				whenUpdate;

- (BOOL)is:(NSString *)order;
- (BOOL)isName:(NSString *)name;
- (BOOL)isKindOf:(NSString *)prefix;
- (BOOL)isTwinWith:(HMDialogue *)dial;	// 与某消息同属于一个发起源，相同name

- (HMDialogue *)input:(id)first, ...;
- (HMDialogue *)output:(id)first, ...;

- (void)setLastError;
- (void)setLastError:(NSInteger)code;
- (void)setLastError:(NSInteger)code domain:(NSString *)domain;
- (void)setLastError:(NSInteger)code domain:(NSString *)domain desc:(NSString *)desc;

- (void)runloop;

- (BOOL)send;
- (void)cancel;

- (void)internalNotifyProgressUpdated;
- (HMHTTPRequestOperation *)ownRequest;

@end

@interface HMDialogueQueue : NSObject

AS_SINGLETON(HMDialogueQueue)

@property (nonatomic, readonly) NSArray *	allDialogues;
@property (nonatomic, readonly) NSArray *	pendingDialogues;
@property (nonatomic, readonly) NSArray *	sendingDialogues;
@property (nonatomic, readonly) NSArray *	finishedDialogues;

- (NSArray *)dialogues:(NSString *)msgName;
- (NSArray *)dialoguesInSet:(NSArray *)msgNames;

- (BOOL)addDialogue:(HMDialogue *)dial;
- (void)removeDialogue:(HMDialogue *)dial;
- (void)cancelDialogues;

- (void)cancelDialogue:(NSString *)dial;
- (void)cancelDialogueByResponder:(id)responder;
- (void)cancelDialogue:(NSString *)dial name:(NSString*)name;
- (void)cancelDialogue:(NSString *)dial byResponder:(id)responder;
- (void)cancelDialogue:(NSString *)dial name:(NSString*)name byResponder:(id)responder;

+ (void)cancelDialogue:(NSString *)dial;
+ (void)cancelDialogueByResponder:(id)responder;
+ (void)cancelDialogue:(NSString *)dial name:(NSString*)name;
+ (void)cancelDialogue:(NSString *)dial byResponder:(id)responder;
+ (void)cancelDialogue:(NSString *)dial name:(NSString*)name byResponder:(id)responder;

+ (BOOL)sending:(NSString *)dial;
+ (BOOL)sending:(NSString *)dial name:(NSString *)name;
+ (BOOL)sending:(NSString *)dial byResponder:(id)responder;
+ (BOOL)sending:(NSString *)dial name:(NSString *)name byResponder:(id)responder;
+ (BOOL)sending:(NSString *)dial name:(NSString *)name byResponder:(id)responder append:(BOOL)append;

- (BOOL)sending:(NSString *)dial;
- (BOOL)sending:(NSString *)dial name:(NSString *)name;
- (BOOL)sending:(NSString *)dial byResponder:(id)responder;
- (BOOL)sending:(NSString *)dial name:(NSString *)name byResponder:(id)responder;
- (BOOL)sending:(NSString *)dial name:(NSString *)name byResponder:(id)responder append:(BOOL)append;

+ (void)enableResponder:(id)responder;
+ (void)disableResponder:(id)responder;

- (void)enableResponder:(id)responder;
- (void)disableResponder:(id)responder;

@end

@interface NSObject (HMDialogue)

- (BOOL)prehandleDialogue:(HMDialogue *)dial;
- (void)posthandleDialogue:(HMDialogue *)dial;
- (void)handleDialogue:(HMDialogue *)dial;

+ (id)routes:(NSString *)order;

#pragma mark -

- (HMDialogue*)dealWith:(NSString *)order timeout:(NSTimeInterval)seconds;

- (BOOL)isSending:(NSString *)dial;
- (BOOL)isSending:(NSString *)dial name:(NSString *)name;
- (BOOL)isSending:(NSString *)dial byResponder:(id)responder;
- (BOOL)isSending:(NSString *)dial name:(NSString *)name byResponder:(id)responder;
- (BOOL)isSending:(NSString *)dial name:(NSString *)name byResponder:(id)responder append:(BOOL)append;

- (void)cancelDial:(NSString *)dial;
- (void)cancelDialByResponder:(id)responder;
- (void)cancelDial:(NSString *)dial name:(NSString*)name;
- (void)cancelDial:(NSString *)dial byResponder:(id)responder;
- (void)cancelDial:(NSString *)dial name:(NSString*)name byResponder:(id)responder;

- (void)cancelAndDisableDial:(NSString *)dial byResponder:(id)responder;

@end
