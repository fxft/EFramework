//
//  HMDialogue.m
//  CarAssistant
//
//  Created by Eric on 14-2-22.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMDialogue.h"
#import "HMHTTPRequestOperationManager.h"
#import "HMFoundation.h"

#define USERTIMERFOR_RUNLOOP 1

static inline NSString *descForState(NSInteger sate){
    NSString *ret = @"unknown";
    if (sate == [HMDialogue STATE_CREATED]) {
     ret = @"CREATED";
    }else if (sate == [HMDialogue STATE_SENDING]) {
        ret = @"SENDING";
    }else if (sate == [HMDialogue STATE_SUCCEED]) {
        ret = @"SUCCEED";
    }else if (sate == [HMDialogue STATE_FAILED]) {
        ret = @"FAILED";
    }else if (sate == [HMDialogue STATE_CANCELLED]) {
        ret = @"CANCELLED";
    }else if (sate == [HMDialogue STATE_WAITING]) {
        ret = @"STATE_WAITING";
    }
    return ret;
}

@implementation HMDialogue{
    
    NSTimer *					_timer;			// 计时器，消息可以单独设置超时
	NSTimeInterval				_seconds;		// 超时时长（秒）
    BOOL						_timeout;		// 是否为超时？
    NSInteger					_state;			// 消息状态
    NSInteger					_nextState;     // 消息状态
	BOOL						_arrived;		// 是否达到
    BOOL						_progressed;	// 是否达到
    
    BOOL						_oneDirection;	// 单向消息，Controller收到即算成功

    NSMutableDictionary *		_input;			// 输入参数字典
	NSMutableDictionary *		_output;		// 输出数据字典
    
    NSString *					_order;         // 消息名字，格式: @"xxx.yyy"
    
    id    __weak_type           _source;        // 源目标/回调对象
	id    __weak_type           _target;        // 目标
    id<HMDialogueExecutor>__weak_type	_executer;		// 所负责处理该消息的Controller
	NSString *                  _name;          // 对话名称
	NSObject *                  _object;        // 对话附带参数
    
    NSString *					_errorDomain;	// 错误域
	NSInteger					_errorCode;		// 错误码
	NSString *					_errorDesc;		// 错误描述
    
    NSTimeInterval				_initTimeStamp;
	NSTimeInterval				_sendTimeStamp;
	NSTimeInterval				_recvTimeStamp;
}

DEF_STRING( DIALOGUE_SERVICE,	@"service" )

DEF_STRING( ERROR_DOMAIN_UNKNOWN,	@"domain.unknown" )
DEF_STRING( ERROR_DOMAIN_SERVER,	@"domain.server" )
DEF_STRING( ERROR_DOMAIN_CLIENT,	@"domain.client" )
DEF_STRING( ERROR_DOMAIN_NETWORK,	@"domain.network" )

DEF_INT( ERROR_CODE_OK,			0 )
DEF_INT( ERROR_CODE_UNKNOWN,	-1 )
DEF_INT( ERROR_CODE_TIMEOUT,	-2 )
DEF_INT( ERROR_CODE_PARAMS,		-3 )
DEF_INT( ERROR_CODE_ROUTES,		-4 )


DEF_INT( STATE_CREATED,		0 )
DEF_INT( STATE_SENDING,		1 )
DEF_INT( STATE_SUCCEED,		2 )
DEF_INT( STATE_FAILED,		3 )
DEF_INT( STATE_CANCELLED,	4 )
DEF_INT( STATE_WAITING,		5 )
DEF_INT( STATE_PREPARE,		6 )

@synthesize order=_order;

@synthesize source = _source;
@synthesize target = _target;
@synthesize executer = _executer;
@synthesize name = _name;
@synthesize command = _command;
@synthesize mock;
@synthesize object = _object;
@synthesize block;
@synthesize redirect;

@synthesize oneDirection = _oneDirection;

@synthesize input=_input;
@synthesize output=_output;
@synthesize seconds=_seconds;
@synthesize timeout = _timeout;
@synthesize state = _state;
@synthesize nextState = _nextState;

@synthesize errorDomain = _errorDomain;
@synthesize errorCode = _errorCode;
@synthesize errorDesc = _errorDesc;

@synthesize created;
@synthesize arrived = _arrived;
@synthesize sending;
@synthesize waiting;
@synthesize succeed;
@synthesize failed;
@synthesize cancelled;
@synthesize progressed = _progressed;

@synthesize whenUpdate = _whenUpdate;
@synthesize otherResponders;

#pragma mark -

-(void)load{
    _state = -1;
    _input = [[NSMutableDictionary alloc] init];
    _output = [[NSMutableDictionary alloc] init];
    _executer = nil;
    self.otherResponders = [NSMutableArray array];
}

-(void)unload{
    self.source = nil;
    self.target = nil;
    self.order = nil;
    self.name = nil;
    self.command = nil;
    self.object = nil;
    self.block = nil;
    self.input = nil;
    self.output = nil;
    [self.otherResponders removeAllObjects];
    self.otherResponders = nil;
    [_timer invalidate];
    _timer = nil;
    self.errorDesc = nil;
    self.errorDomain = nil;
    self.whenUpdate = nil;
    self.redirect = nil;
}


- (id)init
{
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

- (void)dealloc
{
    [self unload];
    HM_SUPER_DEALLOC();
}


-(NSString *)description{
    NSString *superf = [super description];
    return [NSString stringWithFormat:@"%@'%@'",superf,self.order];
}

#pragma mark -


- (void)internalStartTimer
{
    
	[_timer invalidate];
	_timer = nil;
    
	if ( _seconds > 0.0f )
	{
		_timer = [NSTimer scheduledTimerWithTimeInterval:_seconds
												  target:self
												selector:@selector(didMessageTimeout)
												userInfo:nil
												 repeats:NO];
       
	}
    
}

- (void)internalStopTimer
{

	[_timer invalidate];
	_timer = nil;

}

-(void)setTimeout:(BOOL)timeout{
    _timeout = timeout;
    if (_timeout) {
        [self internalStopTimer];
    }
}

- (void)didMessageTimeout
{
	_timer = nil;
	_timeout = YES;
	
	self.errorCode = self.ERROR_CODE_TIMEOUT;
	self.errorDomain = self.ERROR_DOMAIN_NETWORK;
    if (self.failed) {
        return;
    }

    [self setFailed:YES];
}
- (void)internalNotifySending
{
	_sendTimeStamp = [NSDate timeIntervalSinceReferenceDate];
	_recvTimeStamp = _sendTimeStamp;
	
	if ( NO == self.disabled )
	{
		if ( self.whenUpdate )
		{
			self.whenUpdate( self );
		}
        
		[self callResponder];
	}
	
}

- (void)internalNotifySucceed
{
	
	_recvTimeStamp = [NSDate timeIntervalSinceReferenceDate];
	
	if ( NO == self.disabled )
	{
		if ( self.whenUpdate )
		{
			self.whenUpdate( self );
		}
		
		[self callResponder];
	}
}

- (void)internalNotifyFailed
{
#if (__ON__ == __HM_DEVELOPMENT__)
	CC( @"Dialogue",@"\t'%@' failed %@", _name ,self.timeout?@"timeout":@"");
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
    
	_recvTimeStamp = [NSDate timeIntervalSinceReferenceDate];
	
	if ( NO == self.disabled )
	{
		if ( self.whenUpdate )
		{
			self.whenUpdate( self );
		}
        
		[self callResponder];
	}
}

- (void)internalNotifyCancelled
{
#if (__ON__ == __HM_DEVELOPMENT__)
	CC( @"Dialogue",@"\t'%@' cancelled", _name );
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
	
	_recvTimeStamp = [NSDate timeIntervalSinceReferenceDate];
	
	if ( NO == self.disabled )
	{
		if ( self.whenUpdate )
		{
			self.whenUpdate( self );
		}
        
		[self callResponder];
	}
}

- (void)internalNotifyProgressUpdated
{

    self.waiting = YES;
	_progressed = YES;
	if ( NO == self.disabled )
	{
		if ( self.whenUpdate )
		{
			self.whenUpdate( self );
		}
        
		[self callResponder];
	}
	_progressed = NO;
}
- (HMHTTPRequestOperation *)ownRequest{
    if ([self.object isKindOfClass:[HMHTTPRequestOperation class]]) {
        return (id)self.object;
    }
    return nil;
}
- (void)callResponder
{
	[self forwardResponder:self.source];
    @synchronized(self.otherResponders){
        if (self.otherResponders.count) {
            for (NSObject*obj in self.otherResponders) {
                [self forwardResponder:obj];
            }
        }
    }
}

- (void)forwardResponder:(NSObject *)obj
{
	if ( nil == obj )
		return;
    if ([self disabled]) {
        return;
    }
	if ( [obj respondsToSelector:@selector(prehandleDialogue:)] )
	{
		BOOL flag = [obj prehandleDialogue:self];
		if ( NO == flag )
			return;
	}
    
	BOOL handled = NO;
	
	if ( _order && _order.length )
	{
		NSArray * array = [_order componentsSeparatedByString:@"."];
		if ( array && array.count > 2 )
		{
            NSString * category = (NSString *)[array objectAtIndex:0];
			NSString * clazz = (NSString *)[array objectAtIndex:1];
			NSString * name = (NSString *)[array objectAtIndex:2];
            /*
             - (void)handle_service:(HMService *)__msg
             
             - (void)handle_service_##__filter:(HMService *)__msg
             
             - (void)handle_service_##__class##__name:(HMService *)__msg
             */
            if ( NO == handled )
			{
				NSString *	selectorName = [NSString stringWithFormat:@"handle_%@_%@_%@:",category, clazz, name];
				SEL			selector = NSSelectorFromString(selectorName);
				
				if ( [obj respondsToSelector:selector] )
				{
					[obj performSelector:selector withObject:self];
                    
					handled = YES;
//                    goto END;
				}
			}
            if ( NO == handled )
			{
				NSString *	selectorName = [NSString stringWithFormat:@"handle_%@_%@:",category, clazz];
				SEL			selector = NSSelectorFromString(selectorName);
				
				if ( [obj respondsToSelector:selector] )
				{
					[obj performSelector:selector withObject:self];
					
					handled = YES;
//                    goto END;
				}
			}
            
            if ( NO == handled )
			{
				NSString *	selectorName = [NSString stringWithFormat:@"handle_%@:",category];
				SEL			selector = NSSelectorFromString(selectorName);
				
				if ( [obj respondsToSelector:selector] )
				{
					[obj performSelector:selector withObject:self];
					
					handled = YES;
//                    goto END;
				}
			}
		}
	}
	
//END:
    if ( handled == NO )
    {
        if ( obj && [obj respondsToSelector:@selector(handleDialogue:)] )
        {
            [obj performSelector:@selector(handleDialogue:) withObject:self];
        }
    }
	if ( [obj respondsToSelector:@selector(posthandleDialogue:)] )
	{
		[obj posthandleDialogue:self];
	}
    
}

-(Class)dialogueForCategory{
    if ( _order && _order.length )
	{
		NSArray * array = [_order componentsSeparatedByString:@"."];
		if ( array && array.count > 2 )
		{
			NSString * clazz = (NSString *)[array objectAtIndex:1];
            Class classType = NSClassFromString(clazz);
            return classType;
        }
    }
    return nil;
}

-(BOOL)send{
    //service
    if(![[HMDialogueQueue sharedInstance]addDialogue:self]){
        return NO;
    }
    return YES;
}
-(void)cancel{
    [self changeState:HMDialogue.STATE_CANCELLED];
}
- (void)runloop
{
    
	if ( _nextState != _state )
	{
		[self changeStateDelay];
	}
    
}
-(void)changeState:(NSInteger)newState{
    if (newState==_nextState) {
        return;
    }
    _nextState = newState;
}

-(void)changeStateDelay{
    if (_nextState==_state) {
        return;
    }
    BOOL shouldRemove = NO;
    _state = _nextState;
    
    
    if ( HMDialogue.STATE_CREATED != _state )
	{
		if ( NO == _arrived )
		{
			// TODO:
			_arrived = YES;
		}
	}
    if ( nil == _executer )
    {
        Class classType = [self dialogueForCategory];
        _executer = [classType routes:_order];
    }
    
    if ( [_executer respondsToSelector:@selector(route:)] )
    {
        
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"Dialogue",@"\t'%@' [%@]routing state: %@",_name,[_executer class],descForState(self.state));
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        
        [_executer route:self];

    }
    else
    {
        [_executer index:self];
    }
    
    
    if ( HMDialogue.STATE_CREATED == _state )
	{
		// TODO: nothing to do
        [self internalStartTimer];
	}
	else if ( HMDialogue.STATE_SENDING == _state )
	{
		if ( self.oneDirection )
		{
			[self internalStopTimer];
			[self internalNotifySucceed];
			
			shouldRemove = YES;
		}
		else
		{
			[self internalStartTimer];
			[self internalNotifySending];
		}
	}
	else if ( HMDialogue.STATE_WAITING == _state )
	{
		// TODO: nothing to do
	}
	else if ( HMDialogue.STATE_SUCCEED == _state )
	{
		if ( _nextState == _state )
        {
			[self internalStopTimer];
			[self internalNotifySucceed];
			
			if ( _nextState == _state )
			{
				[self cancelRequest];//for network
				
				shouldRemove = YES;
			}
		}
	}
	else if ( HMDialogue.STATE_FAILED == _state )
	{
		
        if ( _nextState == _state )
        {
			[self internalStopTimer];
			[self internalNotifyFailed];
            
			if ( _nextState == _state )
			{
				[self cancelRequest];//for network
                
				shouldRemove = YES;
			}
		}
		
	}
	else if ( HMDialogue.STATE_CANCELLED == _state )
	{
        
        if ( _nextState == _state )
        {
			[self internalStopTimer];
			[self internalNotifyCancelled];
            
			if ( _nextState == _state )
			{
				[self cancelRequest];
                
				shouldRemove = YES;
			}
		}
		
	}
    
    if ( shouldRemove )
	{
		[[HMDialogueQueue sharedInstance] removeDialogue:self];
	}
}

- (BOOL)created
{
	return HMDialogue.STATE_CREATED == _state ? YES : NO;
}

- (void)setCreated:(BOOL)flag
{
	if ( flag )
	{
		_nextState = HMDialogue.STATE_CREATED;
        [self changeStateDelay];
	}
}

- (BOOL)sending
{
	return HMDialogue.STATE_SENDING == _state ? YES : NO;
}

- (void)setSending:(BOOL)flag
{
	if ( flag )
	{
		[self changeState:HMDialogue.STATE_SENDING];
	}
}

- (BOOL)waiting
{
	return HMDialogue.STATE_WAITING == _state ? YES : NO;
}

- (void)setWaiting:(BOOL)flag
{
	if ( flag )
	{
		[self changeState:HMDialogue.STATE_WAITING];
	}
}

- (BOOL)succeed
{
	return HMDialogue.STATE_SUCCEED == _state ? YES : NO;
}

- (void)setSucceed:(BOOL)flag
{
	if ( flag )
	{
        [self changeState:HMDialogue.STATE_SUCCEED];
	}
	else
	{
		[self changeState:HMDialogue.STATE_FAILED];
	}
}

- (BOOL)failed
{
	return HMDialogue.STATE_FAILED == _state ? YES : NO;
}

- (void)setFailed:(BOOL)flag
{
	if ( flag )
	{
		[self changeState:HMDialogue.STATE_FAILED];
	}
}

- (BOOL)cancelled
{
	return HMDialogue.STATE_CANCELLED == _state ? YES : NO;
}

- (void)setCancelled:(BOOL)flag
{
	if ( flag )
	{
		[self changeState:HMDialogue.STATE_CANCELLED];
	}
}


- (BOOL)is:(NSString *)order
{
	return [_order isEqualToString:order];
}

- (BOOL)isName:(NSString *)name
{
	return [_name isEqualToString:name];
}

- (BOOL)isKindOf:(NSString *)prefix
{
	return [_order hasPrefix:prefix];
}

- (BOOL)isTwinWith:(HMDialogue *)dial
{
	if ( self == dial )
	{
		return YES;
	}
    
	if ( [_name isEqualToString:dial.name] && _source == dial.source )
	{
		return YES;
	}
	else
	{
		return NO;
	}
}


- (HMDialogue *)input:(id)first, ...
{
	va_list args;
	va_start( args, first );
	
	for ( ;; )
	{
		NSObject<NSCopying> * key = [self.input count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
		
		[self.input setObject:value forKey:key];
	}
	
	va_end( args );
	return self;
}

- (HMDialogue *)output:(id)first, ...
{
	va_list args;
	va_start( args, first );
	
	for ( ;; )
	{
		NSObject<NSCopying> * key = [self.output count] ? va_arg( args, NSObject * ) : first;
		if ( nil == key )
			break;
		
		NSObject * value = va_arg( args, NSObject * );
		if ( nil == value )
			break;
		
		[self.output setObject:value forKey:key];
	}
	
	va_end( args );
	return self;
}

- (void)setLastError
{
	self.errorCode = HMDialogue.ERROR_CODE_UNKNOWN;
	self.errorDomain = HMDialogue.ERROR_DOMAIN_UNKNOWN;
	self.errorDesc = @"unknown";
}

- (void)setLastError:(NSInteger)code
{
	self.errorCode = code;
	self.errorDomain = HMDialogue.ERROR_DOMAIN_UNKNOWN;
	self.errorDesc = @"unknown";
}

- (void)setLastError:(NSInteger)code domain:(NSString *)domain
{
	self.errorCode = code;
	self.errorDomain = domain;
	self.errorDesc = @"";
}

- (void)setLastError:(NSInteger)code domain:(NSString *)domain desc:(NSString *)desc
{
	self.errorCode = code;
	self.errorDomain = domain;
	self.errorDesc = desc ? desc : @"";
}

@end

#pragma mark -
#pragma mark HMDialogueQueue
#pragma mark -

@interface HMDialogueQueue ()
@property(nonatomic,HM_STRONG) NSTimer *timer;
//@property(nonatomic,HM_STRONG) CADisplayLink *timer;
@end

@implementation HMDialogueQueue{
    NSTimer *_timer;
//    CADisplayLink *_timer;
    BOOL _pause;
}
@synthesize timer=_timer;
static NSMutableArray * __sharedQueue = nil;

DEF_SINGLETON_AUTOLOAD(HMDialogueQueue)


- (NSArray *)allDialogues
{
	return __sharedQueue;
}

- (NSArray *)pendingDialogues
{
	NSMutableArray * array = [NSMutableArray array];
	
    NSArray * queued = [[NSArray alloc] initWithArray:__sharedQueue];
    
	for ( HMDialogue * bmsg in queued )
	{
		if ( bmsg.created )
		{
			[array addObject:bmsg];
		}
	}
    
    [queued release];
	
	return array;
}

- (NSArray *)sendingDialogues
{
	NSMutableArray * array = [NSMutableArray array];
	
    NSArray * queued = [[NSArray alloc] initWithArray:__sharedQueue];
    
	for ( HMDialogue * msg in queued )
	{
		if ( msg.sending )
		{
			[array addObject:msg];
		}
	}
    
    [queued release];
	
	return array;
}

- (NSArray *)finishedDialogues
{
	NSMutableArray * array = [NSMutableArray array];
	
    NSArray * queued = [[NSArray alloc] initWithArray:__sharedQueue];
    
	for ( HMDialogue * bmsg in queued )
	{
		if ( bmsg.succeed || bmsg.failed || bmsg.cancelled )
		{
			[array addObject:bmsg];
		}
	}
    
    [queued release];
    
	return array;
}

- (NSArray *)dialogues:(NSString *)msgName
{
	if ( nil == msgName )
	{
		return __sharedQueue;
	}
	else
	{
		NSMutableArray * array = [NSMutableArray array];
        
        NSArray * queued = [[NSArray alloc] initWithArray:__sharedQueue];
        
		for ( HMDialogue * msg in queued )
		{
			if ( [msg.order isEqual:msgName] )
			{
				[array addObject:msg];
			}
		}
        
#if  __has_feature(objc_arc)
        
#else
        [queued release];
#endif
		return array;
	}
}

- (NSArray *)dialoguesInSet:(NSArray *)msgNames
{
	NSMutableArray * array = [NSMutableArray array];
	
    NSArray * queued = [[NSArray alloc] initWithArray:__sharedQueue];
    
	for ( HMDialogue * msg in queued )
	{
		for ( NSString * msgName in msgNames )
		{
			if ( [msg.order isEqual:msgName] )
			{
				[array addObject:msg];
				break;
			}
		}
	}
    
#if  __has_feature(objc_arc)
    
#else
    [queued release];
#endif
	
	return array;
}

- (BOOL)addDialogue:(HMDialogue *)dial
{
	if ( [__sharedQueue containsObject:dial] )
		return NO;
    
	if ( dial.unique )
	{
		for ( HMDialogue * inqueue in __sharedQueue )
		{
			if ( [inqueue isTwinWith:dial] ){
#if (__ON__ == __HM_DEVELOPMENT__)
                CC( @"Dialogue",@"isTwinWithName %@",dial.name);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
                return NO;
            }
		}
	}
    dial.sending = YES;
    _pause = NO;
    
	[__sharedQueue addObject:dial];
	return YES;
}

- (void)removeDialogue:(HMDialogue *)dial
{
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"Dialogue",@"remove %@ for %@",dial.name,dial);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
	[__sharedQueue removeObject:dial];
    _pause = !!!__sharedQueue.count;
}

+ (void)cancelDialogue:(NSString *)dial{
    [[HMDialogueQueue sharedInstance]cancelDialogue:dial];
}

- (void)cancelDialogue:(NSString *)dial
{
	[self cancelDialogue:dial byResponder:nil];
}

+ (void)cancelDialogueByResponder:(id)responder{
    [[HMDialogueQueue sharedInstance]cancelDialogueByResponder:responder];
}

- (void)cancelDialogueByResponder:(id)responder
{
	[self cancelDialogue:nil byResponder:responder];
}

+ (void)cancelDialogue:(NSString *)dial byResponder:(id)responder{
    [[HMDialogueQueue sharedInstance]cancelDialogue:dial byResponder:responder];
}

- (void)cancelDialogue:(NSString *)msg byResponder:(id)responder{
    [self cancelDialogue:msg name:nil byResponder:responder];
}

+ (void)cancelDialogue:(NSString *)dial name:(NSString *)name{
    [[HMDialogueQueue sharedInstance]cancelDialogue:dial name:name];
}

- (void)cancelDialogue:(NSString *)dial name:(NSString *)name{
    [self cancelDialogue:dial name:name byResponder:nil];
}

+ (void)cancelDialogue:(NSString *)dial name:(NSString*)name byResponder:(id)responder{
    [[HMDialogueQueue sharedInstance]cancelDialogue:dial name:name byResponder:responder];
}

- (void)cancelDialogue:(NSString *)dial name:(NSString*)name byResponder:(id)responder
{
    if (dial==nil&&responder==nil) {
        return;
    }
	NSUInteger		count = [__sharedQueue count];
	HMDialogue *	bmsg;
	
	for ( NSUInteger i = count; i > 0; --i )
	{
		bmsg = [__sharedQueue safeObjectAtIndex:(i - 1)];
		if ( responder ){
            if ( bmsg.source != responder) {
                continue;
            }
        }
		
		if ( dial ){
            if (NO == [dial isEqualToString:bmsg.order]) {
                continue;
            }
        }
		
        if ( name ){
            if (NO == [name isEqualToString:bmsg.name]) {
                continue;
            }
        }
		[bmsg cancel];
	}
}

- (void)cancelDialogues
{
	[__sharedQueue removeAllObjects];
}

+ (BOOL)sending:(NSString *)dial{
    return [[HMDialogueQueue sharedInstance]sending:dial];
}

- (BOOL)sending:(NSString *)dial
{
	return [self sending:dial name:nil byResponder:nil];
}

+ (BOOL)sending:(NSString *)dial name:(NSString *)name{
    return [[HMDialogueQueue sharedInstance]sending:dial name:name];
}

- (BOOL)sending:(NSString *)dial name:(NSString *)name{
    return [self sending:dial name:name byResponder:nil];
}

+ (BOOL)sending:(NSString *)dial byResponder:(id)responder{
    return [[HMDialogueQueue sharedInstance]sending:dial byResponder:responder];
}

- (BOOL)sending:(NSString *)dial byResponder:(id)responder{
    return [self sending:dial name:nil byResponder:responder];
}

+ (BOOL)sending:(NSString *)dial name:(NSString *)name byResponder:(id)responder{
    return [[HMDialogueQueue sharedInstance]sending:dial name:name byResponder:responder];
}

+ (BOOL)sending:(NSString *)dial name:(NSString *)name byResponder:(id)responder append:(BOOL)append{
    return [[HMDialogueQueue sharedInstance]sending:dial name:name byResponder:responder append:append];
}


- (BOOL)sending:(NSString *)dial name:(NSString *)name byResponder:(id)responder{
    return [self sending:dial name:name byResponder:responder append:NO];
}

- (BOOL)sending:(NSString *)dial name:(NSString *)name byResponder:(id)responder append:(BOOL)append
{
    if ( nil == dial )
	{
		return ([__sharedQueue count] > 0) ? YES : NO;
	}
	HMDialogue * bmsg = nil;
	
	NSUInteger count = [__sharedQueue count];
	for ( NSUInteger i = count; i > 0; --i )
	{
		bmsg = [__sharedQueue safeObjectAtIndex:(i - 1)];
		if ( responder ){
            if (bmsg.source != responder) {
                continue;
            }
        }
			     
		if ( [dial isEqualToString:bmsg.order] && (name==nil?YES:[name isEqualToString:bmsg.name]))
		{
			if ( bmsg.created || bmsg.sending || bmsg.waiting )
			{
                if (append&&responder) {
                    @synchronized(bmsg.otherResponders){
                        if (![bmsg.otherResponders containsObject:responder]) {
                            [bmsg.otherResponders addObject:responder];
                        }
                    }
                }
				return YES;
			}
			else
			{
				return NO;
			}
		}
	}
	
	return NO;
}
+ (void)enableResponder:(id)responder{
    [[HMDialogueQueue sharedInstance]enableResponder:responder];
}
- (void)enableResponder:(id)responder
{
	NSUInteger		count = [__sharedQueue count];
	HMDialogue *	bmsg;
	
	for ( NSUInteger i = count; i > 0; --i )
	{
		bmsg = [__sharedQueue safeObjectAtIndex:(i - 1)];
        
		if ( responder && bmsg.source != responder )
			continue;
		
		bmsg.disabled = NO;
	}
}
+ (void)disableResponder:(id)responder{
    [[HMDialogueQueue sharedInstance]disableResponder:responder];
}

- (void)disableResponder:(id)responder
{
	NSUInteger		count = [__sharedQueue count];
	HMDialogue *	bmsg;
	
	for ( NSUInteger i = count; i > 0; --i )
	{
		bmsg = [__sharedQueue safeObjectAtIndex:(i - 1)];
        @synchronized(bmsg.otherResponders){
            if ([bmsg.otherResponders containsObject:responder]) {
                [bmsg.otherResponders removeObject:responder];
            }
        }
		if ( responder && bmsg.source != responder )
			continue;
		
		bmsg.disabled = YES;
	}
}


- (id)init
{
	self = [super init];
	if ( self )
	{
		if ( nil == __sharedQueue )
		{
			__sharedQueue = [[NSMutableArray alloc] init];
		}
        
        if ( nil == self.timer )
		{

            self.timer = [NSTimer timerWithTimeInterval:.05f target:self selector:@selector(runloop) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer
                                         forMode:NSRunLoopCommonModes];
		}
	}
	
	return self;
}
- (void)runInbackground{
    while (1) {
        sleep(1);
        [self runloop];
    }
}

- (void)runloop
{
	if ( _pause )
		return;
	
    NSArray * queued = [[NSArray alloc] initWithArray:__sharedQueue];
    
	for ( HMDialogue * bmsg in queued )
	{
		[bmsg runloop];
	}
    
#if  __has_feature(objc_arc)
    
#else
    [queued release];
#endif
}

- (void)dealloc
{
	
	HM_SUPER_DEALLOC();
}


@end

#pragma mark -
#pragma mark NSObject (HMDialogue)
#pragma mark -

#undef	DEFAULT_TIMEOUT_SECONDS
#define	DEFAULT_TIMEOUT_SECONDS		(10.0f)

@implementation NSObject (HMDialogue)


- (BOOL)prehandleDialogue:(HMDialogue *)dial
{
	return YES;
}

- (void)posthandleDialogue:(HMDialogue *)dial
{
	
}

- (void)handleDialogue:(HMDialogue *)dial
{
    WARN(@"Dialogue:",dial,@"does not be processed");
}

+(id)routes:(NSString *)order{
    return nil;
}

#pragma mark -

- (HMDialogue *)spawnAdialogue:(NSString *)order withObject:(NSObject *)object from:(id)source timeout:(NSTimeInterval)seconds{
    
#if  __has_feature(objc_arc)
    HMDialogue * dialogue = [[HMDialogue alloc] init];
#else
    HMDialogue * dialogue = [[[HMDialogue alloc] init] autorelease];
#endif
    
	if ( dialogue )
	{
        dialogue.source = source ? source : self;
        dialogue.target = self;
        dialogue.order = order;//靠order识别目标
        dialogue.name = order;
        dialogue.object = object;
        dialogue.seconds = seconds ? seconds : DEFAULT_TIMEOUT_SECONDS;
        dialogue.created = YES;

	}
    return dialogue;
}

- (HMDialogue*)dealWith:(NSString *)order timeout:(NSTimeInterval)seconds{
    
    return [self spawnAdialogue:order withObject:nil from:self timeout:seconds];

}

- (BOOL)isSending:(NSString *)dial{
    return [HMDialogueQueue sending:dial name:nil byResponder:nil];
}

- (BOOL)isSending:(NSString *)dial byResponder:(id)responder{
    return [HMDialogueQueue sending:dial name:nil byResponder:responder];
}

- (BOOL)isSending:(NSString *)dial name:(NSString *)name{
    return [HMDialogueQueue sending:dial name:name byResponder:nil];
}

- (BOOL)isSending:(NSString *)dial name:(NSString *)name byResponder:(id)responder{
     return [HMDialogueQueue sending:dial name:name byResponder:responder];
}

- (BOOL)isSending:(NSString *)dial name:(NSString *)name byResponder:(id)responder append:(BOOL)append{
    return [HMDialogueQueue sending:dial name:name byResponder:responder append:append];
}

- (void)cancelDial:(NSString *)dial{
    [HMDialogueQueue cancelDialogue:dial name:nil byResponder:nil];
}

- (void)cancelDialByResponder:(id)responder{
    [HMDialogueQueue cancelDialogue:nil name:nil byResponder:responder];
}

- (void)cancelDial:(NSString *)dial byResponder:(id)responder{
    [HMDialogueQueue cancelDialogue:dial name:nil byResponder:responder];
}

- (void)cancelAndDisableDial:(NSString *)dial byResponder:(id)responder{
    [HMDialogueQueue disableResponder:responder];
    [self cancelDial:[HMWebAPI WebAPI] byResponder:responder];
}

- (void)cancelDial:(NSString *)dial name:(NSString *)name{
    [HMDialogueQueue cancelDialogue:dial name:name byResponder:nil];
}

- (void)cancelDial:(NSString *)dial name:(NSString *)name byResponder:(id)responder{
    [HMDialogueQueue cancelDialogue:dial name:name byResponder:responder];
}


@end