//
//  HMTicker.h
//  CarAssistant
//
//  Created by Eric on 14-3-29.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMMacros.h"

//elapsed = 1.0f/60.f

#define ON_Tick(elapsed) - (void)handleTick:(NSTimeInterval)elapsed

@protocol ON_Tick_handle <NSObject>

ON_Tick(elapsed);

@end

@interface NSObject(HMTicker)
//内部使用
- (void)observeTick;
- (void)unobserveTick;
- (void)handleTick:(NSTimeInterval)elapsed;

/**
 *  延迟执行,非主线程,不能取消
 *
 *   inter  延迟时间
 *   invoke   代码块
 */
- (void)delay:(NSTimeInterval)inter invoke:(void (^)(void))invoke;
/**
 *  延迟执行,主线程,不能取消
 *
 *   inter  延迟时间
 *   invoke   代码块
 */
- (void)delayInMain:(NSTimeInterval)inter invoke:(void (^)(void))invoke;
@end

/**
 *  公用定时器，请使用ON_Tick()监听,对象释放时请记得removeReceiver()
 */
@interface HMTicker : NSObject
@property (nonatomic, readonly)	CADisplayLink *			timer;
@property (nonatomic, readonly)	NSTimeInterval		lastTick;//最后一次的时间戳
@property (nonatomic)   NSTimeInterval frequency;//更新频率，默认 1/60 秒

AS_SINGLETON( HMTicker )

- (void)addReceiver:(NSObject *)obj;
- (void)removeReceiver:(NSObject *)obj;

@end
