//
//  HMEvent.h
//  CarAssistant
//
//  Created by Eric on 14-3-9.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMMacros.h"
#import "HMDialogue.h"
#import "UIView+HMExtension.h"

#undef	AS_EVENT
#define AS_EVENT( __name )	AS_STATIC_PROPERTY( __name )

#undef	DEF_EVENT
#define DEF_EVENT( __name )	DEF_STATIC_PROPERTY3( __name, @"event", [[self class] description] )

#undef	ON_EVENT
#define ON_EVENT( event ) \
- (void)handleEvent:(HMEvent *)event

#undef	ON_EVENT2
#define ON_EVENT2( __class, event ) \
- (void)handleEvent_##__class:(HMEvent *)event

#undef	ON_EVENT3
#define ON_EVENT3( __class, __name, event ) \
- (void)handleEvent_##__class##_##__name:(HMEvent *)event


/*信号两主要为需要单向发送事件给 父视图时用到，没有中间件 处理函数带参数 withObject:(NSObject *)object*/
#undef	AS_SIGNAL
#define AS_SIGNAL( __name )	AS_STATIC_PROPERTY( __name )

#undef	DEF_SIGNAL
#define DEF_SIGNAL( __name )	DEF_STATIC_PROPERTY3( __name, @"signal", [[self class] description] )

#undef	DEF_SIGNAL2
#define DEF_SIGNAL2( __name ,__class)	DEF_STATIC_PROPERTY3( __name, @"signal", [__class description] )

#undef	ON_SIGNAL
#define ON_SIGNAL(signal) \
- (void)handleSignal:(HMSignal *)signal

#undef	ON_SIGNAL2
#define ON_SIGNAL2( __class, signal) \
- (void)handleSignal_##__class:(HMSignal *)signal

#undef	ON_SIGNAL3
#define ON_SIGNAL3( __class, __name, signal) \
- (void)handleSignal_##__class##_##__name:(HMSignal *)signal


#undef	ON_SIGNAL5
#define ON_SIGNAL5( __tagString,signal) \
- (void)handleSignal_##__tagString:(HMSignal *)signal

@class HMSignal;


@protocol ON_SIGNAL_handle <NSObject>

@optional
ON_SIGNAL(signal);
ON_SIGNAL2( __class, signal);
ON_SIGNAL3( __class, __name, signal);
ON_SIGNAL5( __tagString,signal);

@end


@interface HMEvent : NSObject

AS_STATIC_PROPERTY( YES_VALUE );
AS_STATIC_PROPERTY( NO_VALUE );

@property (nonatomic) BOOL                      foreign;
@property (nonatomic, HM_WEAK) id				foreignSource;

@property (nonatomic) BOOL                      dead;			// 杀死SIGNAL
@property (nonatomic) BOOL                      reach;			// 是否触达顶级ViewController
@property (nonatomic) NSUInteger                jump;			// 转发次数
@property (nonatomic, HM_WEAK) id				source;			// 发送来源
@property (nonatomic, HM_WEAK) id				target;			// 转发目标
@property (nonatomic, HM_STRONG) NSString *		name;			// Signal名字
@property (nonatomic, HM_STRONG) NSString *		namePrefix;		// Signal前辍
@property (nonatomic, HM_STRONG) NSObject *		object;			// 附带参数
@property (nonatomic, HM_STRONG) NSObject *		returnValue;	// 返回值，默认为空
@property (nonatomic, HM_STRONG) NSString *		preSelector;	// 返回值，默认为空

@property (nonatomic) NSTimeInterval	initTimeStamp;
@property (nonatomic) NSTimeInterval	sendTimeStamp;
@property (nonatomic) NSTimeInterval	reachTimeStamp;

@property (nonatomic, readonly) NSTimeInterval	timeElapsed;		// 整体耗时
@property (nonatomic, readonly) NSTimeInterval	timeCostPending;	// 等待耗时
@property (nonatomic, readonly) NSTimeInterval	timeCostExecution;	// 处理耗时

@property (nonatomic, HM_STRONG) NSMutableString *	callPath;

- (BOOL)is:(NSString *)name;
- (BOOL)isKindOf:(NSString *)prefix;
- (BOOL)isSentFrom:(id)source;

- (BOOL)send;
- (BOOL)forward;
- (BOOL)forward:(id)target;

- (void)clear;

- (BOOL)boolValue;
- (void)returnYES;
- (void)returnNO;

+ (BOOL)sendOneWaySignal:(NSString *)_name from:(id)_source withObject:(HMSignal*)object to:(id)_target;

@end

@interface HMSignal : NSObject

@property (nonatomic, HM_STRONG) id             inputValue;     // 附带参数
@property (nonatomic, HM_STRONG) id             returnValue;    // 返回值，默认为空
@property (nonatomic, HM_STRONG) NSString *		name;			// Signal名字
@property (nonatomic, HM_WEAK) id				source;			// 发送来源
@property (nonatomic) BOOL                      forward;		//控制继续往上传递信号

#if (__ON__ == __HM_DEVELOPMENT__)
@property (nonatomic, HM_STRONG) NSMutableString *	callPath;
#endif

- (BOOL)is:(NSString *)name;
- (BOOL)boolValue;
- (void)returnYES;
- (void)returnNO;

+ (instancetype)spawn;

+ (HMSignal*)sendSignal:(NSString*)name from:(id)source withObject:(id)object;


@end

@interface NSObject (HMEvent)
/*
 很重要的一个属性，当设计的对象的事件相应链不能满足需求时 通过设置该值为需要接受该事件的接受者
 */
@property (nonatomic, HM_WEAK) id	eventReceiver;

- (HMSignal *)sendSignal:(NSString *)name;
- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object;
- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object  from:(id)source;

@end

@interface UIView (HMEvent)


- (void)handleEvent:(HMEvent *)signal;

- (HMEvent *)sendEvent:(NSString *)name;
- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object;
- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object from:(id)source;
- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object to:(id)target;
- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object to:(id)target from:(id)source;

//- (HMSignal *)sendSignal:(NSString *)name;
//- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object;
//- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object  from:(id)source;
@end

@interface UIViewController (HMEvent)

- (void)handleEvent:(HMEvent *)signal;

- (HMEvent *)sendEvent:(NSString *)name;
- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object;
- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object from:(id)source;
- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object to:(id)target;
- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object to:(id)target from:(id)source;

//- (HMSignal *)sendSignal:(NSString *)name;
//- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object;
//- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object  from:(id)source;
@end

