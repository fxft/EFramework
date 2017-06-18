//
//  HMTicker.m
//  CarAssistant
//
//  Created by Eric on 14-3-29.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMTicker.h"
#import "HMFoundation.h"

#pragma mark -

@implementation NSObject(BeeTicker)

- (void)observeTick
{
    [[HMTicker sharedInstance] addReceiver:self];
}

- (void)unobserveTick
{
    [[HMTicker sharedInstance] removeReceiver:self];
}

- (void)handleTick:(NSTimeInterval)elapsed
{
}

- (void)delay:(NSTimeInterval)inter invoke:(void (^)(void))invoke{
    if (inter<=0.f) {
        if (invoke) invoke();
    }else if (invoke) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(inter * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void){
            invoke();
        });
    }
}

- (void)delayInMain:(NSTimeInterval)inter invoke:(void (^)(void))invoke{
    if (inter<=0.f) {
        if (invoke) invoke();
    }else if (invoke) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(inter * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            invoke();
        });
    }
}

@end


@interface HMTicker()
{
    CADisplayLink *			_timer;
    NSTimeInterval		_lastTick;
    NSMutableArray *	_receivers;
}

- (void)performTick;

@end

#pragma mark -

@implementation HMTicker{
    NSTimeInterval _frequency;
}

@synthesize timer = _timer;
@synthesize lastTick = _lastTick;
@synthesize frequency = _frequency;

DEF_SINGLETON( HMTicker )

- (id)init
{
    self = [super init];
    if ( self )
    {
        
#if  __has_feature(objc_arc)
        _receivers = [NSMutableArray array];
#else
         _receivers = [[NSMutableArray array] retain];
#endif
        _frequency = (1.0f / 60.0f);
    }
    
    return self;
}

- (void)addReceiver:(NSObject *)obj
{
    @synchronized(_receivers){
        if ( NO == [_receivers containsObject:obj] )
        {
            [_receivers addObject:obj];
            
            if ( nil == _timer )
            {
                _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(performTick)];
                [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
                
                _lastTick = [NSDate timeIntervalSinceReferenceDate];
            }
        }
    }
}

- (void)removeReceiver:(NSObject *)obj
{
    @synchronized(_receivers){
        [_receivers removeObject:obj];
        
        if ( 0 == _receivers.count )
        {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

- (void)performTick
{
    NSTimeInterval tick = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = tick - _lastTick;
    
    if ( elapsed >= _frequency )
    {
        @synchronized(_receivers){
            NSArray * array = [NSArray arrayWithArray:_receivers];
            
            for ( NSObject * obj in array )
            {
                if ( [obj respondsToSelector:@selector(handleTick:)] )
                {
                    [obj handleTick:elapsed];
                }
            }
        }
        _lastTick = tick;
    }
    
}

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
    
    [_receivers removeAllObjects];
    
#if  __has_feature(objc_arc)
    _receivers =  nil;
#else
    [_receivers release];
#endif
    
    HM_SUPER_DEALLOC();
}

@end
