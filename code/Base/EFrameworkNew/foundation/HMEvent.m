//
//  HMEvent.m
//  CarAssistant
//
//  Created by Eric on 14-3-9.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMEvent.h"
#import "HMFoundation.h"

#pragma mark -
#undef	__USE_FOREIGN__
#define __USE_FOREIGN__	(1)

@interface HMEvent()
{
	BOOL				_foreign;
	NSObject __weak_type*_foreignSource;
	
	BOOL				_dead;
	BOOL				_reach;
	NSUInteger			_jump;
	id	__weak_type		_source;
	id	__weak_type     _target;
	NSString *			_name;
	NSString *			_namePrefix;
	NSObject *			_object;
	NSObject *			_returnValue;
	NSString *			_preSelector;
	
	NSTimeInterval		_initTimeStamp;
	NSTimeInterval		_sendTimeStamp;
	NSTimeInterval		_reachTimeStamp;
	
	NSMutableString *	_callPath;
}

- (void)routes;

@end

@implementation HMEvent
@synthesize foreign = _foreign;
@synthesize foreignSource = _foreignSource;

@synthesize dead = _dead;
@synthesize reach = _reach;
@synthesize jump = _jump;
@synthesize source = _source;
@synthesize target = _target;
@synthesize name = _name;
@synthesize namePrefix = _namePrefix;
@synthesize object = _object;
@synthesize returnValue = _returnValue;
@synthesize preSelector = _preSelector;

@synthesize initTimeStamp = _initTimeStamp;
@synthesize sendTimeStamp = _sendTimeStamp;
@synthesize reachTimeStamp = _reachTimeStamp;

@synthesize timeElapsed;
@synthesize timeCostPending;
@synthesize timeCostExecution;

@synthesize callPath = _callPath;

DEF_STATIC_PROPERTY( YES_VALUE );
DEF_STATIC_PROPERTY( NO_VALUE );

- (id)init
{
	self = [super init];
	if ( self )
	{
		[self clear];
	}
	return self;
}

- (void)dealloc
{
#if  __has_feature(objc_arc)
    
#else
#if (__ON__ == __HM_DEVELOPMENT__)
    [_callPath release];
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
    
    [_name release];
    [_namePrefix release];
    
    [_object release];
    [_returnValue release];
    [_preSelector release];
#endif

    
	HM_SUPER_DEALLOC();
}

- (NSString *)description
{
	if ( _callPath.length )
	{
		return [NSString stringWithFormat:@"%@ > %@", _name, _callPath];
	}
	else
	{
		return [NSString stringWithFormat:@"%@", _name];
	}
}

- (BOOL)is:(NSString *)name
{
	return [_name isEqualToString:name];
}

- (BOOL)isKindOf:(NSString *)prefix
{
	return [_name hasPrefix:prefix];
}

- (BOOL)isSentFrom:(id)source
{
	return (self.source == source) ? YES : NO;
}

+ (BOOL)perfrom:(NSString *)_name from:(id)_source  target:(NSObject*)targetObject withObject:(HMSignal*)object{
    BOOL perfrom = NO;
    NSString * selectorName;
    SEL selector;
//    NSString * sourceClassName = nil;
    NSString * clazz = nil;
    NSString * method = nil;
    NSString * tagString = nil;
    
    NSArray * nameComponents = [_name componentsSeparatedByString:@"."];
	if ( nameComponents.count > 2 && [[nameComponents objectAtIndex:0] isEqualToString:@"signal"] )
	{
//		sourceClassName = [[_source class] description];
		clazz = [nameComponents objectAtIndex:1];
        method = (NSString *)[nameComponents objectAtIndex:2];
        
	}else{
        tagString = [_name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    }
    
    selectorName = [NSString stringWithFormat:@"handleSignal_%@_%@:", clazz, method];
    selector = NSSelectorFromString(selectorName);
    
    if ( selector && [targetObject respondsToSelector:selector] )
    {
        [targetObject performSelector:selector withObject:object];
        perfrom = YES;
    }
    
    /*如果发送的name是不规则的*/
    if (!perfrom&&tagString) {
        
        selectorName = [NSString stringWithFormat:@"handleSignal_%@:",tagString];
        selector = NSSelectorFromString(selectorName);
        
        if ( selector && [targetObject respondsToSelector:selector] )
        {
            [targetObject performSelector:selector withObject:object];
            perfrom = YES;
        }
        
        selectorName = [NSString stringWithFormat:@"handleSignal_%@_%@_%@:", clazz, method,tagString];
        selector = NSSelectorFromString(selectorName);
        
        if ( selector && [targetObject respondsToSelector:selector] )
        {
            [targetObject performSelector:selector withObject:object];
            perfrom = YES;
        }
        
    }
    
    selectorName = [NSString stringWithFormat:@"handleSignal_%@:", clazz];
    selector = NSSelectorFromString(selectorName);
    
    if (!perfrom && selector && [targetObject respondsToSelector:selector] )
    {
        [targetObject performSelector:selector withObject:object];
        perfrom = YES;
    }
    return perfrom;
}

+ (BOOL)sendOneWaySignal:(NSString *)_name from:(id)_source withObject:(HMSignal*)object to:(id)_target
{
    BOOL _reach = NO;
	NSString * sourceClassName = nil;
//    NSString * clazz = nil;
//    NSString * method = nil;
//    NSString * tagString = nil;
    NSObject * targetObject = _target;
	if ( nil == targetObject )
		return NO;
    BOOL selfLife = NO;
    if ([_target isKindOfClass:[NSObject class]]&&!![(NSObject*)_target eventReceiver]) {
        targetObject = [(NSObject*)_target eventReceiver];
        selfLife = YES;
    }
    
	NSArray * nameComponents = [_name componentsSeparatedByString:@"."];
	if ( nameComponents.count > 2 && [[nameComponents objectAtIndex:0] isEqualToString:@"signal"] )
	{
		sourceClassName = [[_source class] description];
//		clazz = [nameComponents objectAtIndex:1];
//        method = (NSString *)[nameComponents objectAtIndex:2];
        
	}else{
//        tagString = [_name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    }
    
//    NSString * selectorName;
//    SEL selector;
    BOOL perfrom = NO;
    //试一下它自己有没有响应事件
    if ([sourceClassName is:[[_target class] description]]) {
        
        perfrom = [HMEvent perfrom:_name from:_source target:_target withObject:object];
        
    }
    
    //根据perfrom和object.forward进行判断
    //是否已被执行过，如果没有或被执行过但它说还想往上传递，则进入下一轮回；这个很关键
    if (!perfrom || (perfrom&&object.forward)){
    
        //如果对象是视图
        if (![targetObject isKindOfClass:[UIViewController class]]&& [targetObject respondsToSelector:@selector(viewController)]&&!selfLife) {
            
            UIViewController * viewController = [(UIView *)targetObject viewController];
            if ( viewController )
            {
                targetObject = viewController;
                
            }
            
        }
        object.forward = NO;
        if (targetObject!=_target) {
            perfrom = [HMEvent perfrom:_name from:_source target:targetObject withObject:object];
        }
        
    }
//    if (!perfrom || (perfrom&&object.forward)){
//        object.forward = NO;
//        perfrom = [HMEvent perfrom:_name from:_source target:targetObject withObject:object];
//        
//    }
    
#if (__ON__ == __HM_DEVELOPMENT__)
        [object.callPath appendFormat:@" > %@", [[targetObject class] description]];
        
        if ( perfrom )
        {
            [object.callPath appendFormat:object.forward?@" > [NEXT]":@"  > [DONE]"];
        }
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        
    if (perfrom && !object.forward) {
        return YES;
    }
    //传递到父视图
    object.forward = NO;
    //该情况属于从uiviewcontroller发出的信号
    if (targetObject==_target&&[targetObject isKindOfClass:[UIViewController class]]) {
        _target = [(UIViewController*)_target view];
    }
    if ([_target isKindOfClass:[UIView class]]) {
        
        _reach = [HMEvent sendOneWaySignal:_name from:_source withObject:object to:[_target superview]];
    }
    
    return _reach;
}

- (BOOL)send
{
	if ( _dead )
		return NO;
	
	NSArray * nameComponents = [_name componentsSeparatedByString:@"."];
	if ( nameComponents.count > 2 && [[nameComponents objectAtIndex:0] isEqualToString:@"event"] )
	{
		NSString * sourceClassName = [[_source class] description];
		NSString * namePrefix = [nameComponents objectAtIndex:1];
        
		if ( [sourceClassName isEqualToString:namePrefix] )
		{
			self.foreign = NO;
		}
		else
		{
			self.foreign = YES;
			self.foreignSource = self.source;
		}
        self.namePrefix = namePrefix;
	}
	else
	{
		self.foreign = NO;
	}
	
    
	_sendTimeStamp = [NSDate timeIntervalSinceReferenceDate];
	
#if (__ON__ == __HM_DEVELOPMENT__)
    
	if ( _source == _target )
	{
		[_callPath appendFormat:@"%@", [[_source class] description]];
	}
	else
	{
		[_callPath appendFormat:@"%@ > %@", [[_source class] description], [[_target class] description]];
	}
    
	if ( _reach )
	{
		[_callPath appendFormat:@" > [DONE]"];
	}
	
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
    
	if ( [_target isKindOfClass:[UIView class]] || [_target isKindOfClass:[UIViewController class]] )
	{
		_jump = 1;
		
		[self routes];
	}
	else
	{
        NSString *	selectorName = [NSString stringWithFormat:@"handleEvent_%@:", self.namePrefix];
		SEL			selector = NSSelectorFromString(selectorName);
        
		if ( selector && [_target respondsToSelector:selector] )
		{
			[_target performSelector:selector withObject:self];
		}else{
           
#if (__ON__ == __HM_DEVELOPMENT__)
                CC( @"Event",@"Uncatch :[%@] > %@", self.name, self.callPath );
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
            
        }
        
		_reachTimeStamp = [NSDate timeIntervalSinceReferenceDate];
		_reach = YES;
	}
    
	return _reach;
}

- (BOOL)forward
{
	if ( nil == _target )
		return NO;
	
	if ( [_target isKindOfClass:[UIView class]] )
	{
		UIView * targetView = ((UIView *)_target).superview;
		if ( targetView )
		{
			[self forward:targetView];
		}
		else
		{
			self.reach = YES;
		}
	}
	else if ( [_target isKindOfClass:[UIViewController class]] )
	{
		self.reach = YES;
	}
    
#if (__ON__ == __HM_DEVELOPMENT__)
	
	if ( self.reach )
	{
		
		INFO( @"[%@] > %@", self.name, self.callPath );
        
	}
	
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
    
	return YES;
}

- (BOOL)forward:(id)target
{
	if ( _dead )
		return NO;
    
#if (__ON__ == __HM_DEVELOPMENT__)
	
	if ( [target isKindOfClass:[UIView class]] && [((UIView *)target) tagString] )
	{
		[_callPath appendFormat:@" > %@(%@)", [[target class] description], [((UIView *)target) tagString]];
	}
	else
	{
		[_callPath appendFormat:@" > %@", [[target class] description]];
	}
	
	if ( _reach )
	{
		[_callPath appendFormat:@" > [DONE]"];
	}
	
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
    
#if defined(__USE_FOREIGN__) && __USE_FOREIGN__
	
	if ( _foreign )
	{
		if ( self.source == self.foreignSource )
		{
			NSString * targetClassName = [[target class] description];
			if ( [targetClassName isEqualToString:self.namePrefix] )
			{
				self.source = target;
			}
            
		}
	}
	
#endif	// #if defined(__USE_FOREIGN__) && __USE_FOREIGN__
    
	if ( [_target isKindOfClass:[UIView class]] || [_target isKindOfClass:[UIViewController class]] )
	{
		_jump += 1;
        
		_target = target;
		
		[self routes];
	}
	else
	{
		_reachTimeStamp = [NSDate timeIntervalSinceReferenceDate];
		_reach = YES;
	}
    
	return _reach;
}

- (void)routes
{
	NSObject * targetObject = _target;
	if ( nil == targetObject )
		return;
	
	if ( [_target isKindOfClass:[UIView class]] )
	{
		UIViewController * viewController = [(UIView *)_target viewController];
		if ( viewController )
		{
			targetObject = viewController;
		}
	}

    // then guess signal handler
	
	NSArray * array = [_name componentsSeparatedByString:@"."];
	if ( array && array.count > 1 )
	{
        //		NSString * prefix = (NSString *)[array objectAtIndex:0];
		NSString * clazz = (NSString *)[array objectAtIndex:1];
		NSString * method = (NSString *)[array objectAtIndex:2];
		
        NSString * selectorName;
        SEL selector;
        
        selectorName = [NSString stringWithFormat:@"handleEvent_%@_%@:", clazz, method];
        selector = NSSelectorFromString(selectorName);
        
        if ( selector && [targetObject respondsToSelector:selector] )
        {
            [targetObject performSelector:selector withObject:self];
            return;
        }
        
        selectorName = [NSString stringWithFormat:@"handleEvent_%@:", clazz];
        selector = NSSelectorFromString(selectorName);
        
        if ( selector && [targetObject respondsToSelector:selector] )
        {
            [targetObject performSelector:selector withObject:self];
            return;
        }
		
    }

	{
		NSString *	selectorName = nil;
		SEL			selector = nil;
		
		if ( [self.source isKindOfClass:[UIViewController class]] )
		{
			UIViewController * controller = (UIViewController *)self.source;
			
			selectorName = [NSString stringWithFormat:@"handleEvent_%@:", [[controller class] description]];
		}
		else if ( [self.source isKindOfClass:[UIView class]] )
		{
			UIView *	view = (UIView *)self.source;
			NSString *	tagString = view.tagString;
			
			if ( tagString && tagString.length )
			{
				selectorName = [NSString stringWithFormat:@"handleEvent_%@_%@:", [[view class] description], tagString];
			}
			else
			{
				selectorName = [NSString stringWithFormat:@"handleEvent_%@:", [[view class] description]];
			}
		}
		
		selector = NSSelectorFromString(selectorName);
		if ( selector && [targetObject respondsToSelector:selector] )
		{
			[targetObject performSelector:selector withObject:self];
			return;
		}
	}
    // final test the targetObject can handle superclass's event(handle##__ClassName)
	Class rtti = [_source class];
	for ( ;; )
	{
		if ( nil == rtti )
			break;
		
		NSString *	selectorName = [NSString stringWithFormat:@"handle%@:", [rtti description]];
		SEL			selector = NSSelectorFromString(selectorName);
        
		if ( selector && [targetObject respondsToSelector:selector] )
		{
			[targetObject performSelector:selector withObject:self];
			break;
		}
        
		rtti = class_getSuperclass( rtti );
		if ( rtti == [UIResponder class] )
		{
			rtti = nil;
			break;
		}
	}
    
	if ( nil == rtti )//forward
	{
		if ( [targetObject respondsToSelector:@selector(handleEvent:)] )
		{
			[targetObject performSelector:@selector(handleEvent:) withObject:self];
		}
	}
}

- (NSTimeInterval)timeElapsed
{
	return _reachTimeStamp - _initTimeStamp;
}

- (NSTimeInterval)timeCostPending
{
	return _sendTimeStamp - _initTimeStamp;
}

- (NSTimeInterval)timeCostExecution
{
	return _reachTimeStamp - _sendTimeStamp;
}

- (void)clear
{
	self.dead = NO;
	self.reach = NO;
	self.jump = 0;
	self.source = nil;
	self.target = nil;
	self.name = @"event.nil.nil";
	self.object = nil;
	self.returnValue = nil;
	
	_initTimeStamp = [NSDate timeIntervalSinceReferenceDate];
	_sendTimeStamp = _initTimeStamp;
	_reachTimeStamp = _initTimeStamp;
    
#if (__ON__ == __HM_DEVELOPMENT__)
	self.callPath = [NSMutableString string];
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
}

- (BOOL)boolValue
{
	if ( self.returnValue == HMEvent.YES_VALUE )
	{
		return YES;
	}
	else if ( self.returnValue == HMEvent.NO_VALUE )
	{
		return NO;
	}
	
	return NO;
}

- (void)returnYES
{
	self.returnValue = HMEvent.YES_VALUE;
}

- (void)returnNO
{
	self.returnValue = HMEvent.NO_VALUE;
}
@end

#pragma mark -
@implementation HMSignal

@synthesize name=_name;
@synthesize forward;
@synthesize source;
@synthesize returnValue;
@synthesize inputValue;
#if (__ON__ == __HM_DEVELOPMENT__)
@synthesize callPath = _callPath;
#endif
+ (instancetype)spawn{
    
    
#if  __has_feature(objc_arc)
    return [[self alloc]init];
#else
    return [[[self alloc]init]autorelease];
#endif
    
}

+ (HMSignal *)sendSignal:(NSString *)name from:(id)source withObject:(id)object{
    HMSignal *signal = [HMSignal spawn];
    signal.name = name;
    signal.inputValue = object;
    signal.source = source;
    
    BOOL _reach = [HMEvent sendOneWaySignal:name from:source withObject:signal to:source];
    
    if (!_reach) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"Signal",@"%@ %@", _reach?@"":@"Uncatch",signal );
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    
    return signal;
}
- (id)init
{
    self = [super init];
    if (self) {
#if (__ON__ == __HM_DEVELOPMENT__)
        self.callPath = [NSMutableString string];
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
    }
    return self;
}

- (BOOL)is:(NSString *)name
{
	return [_name isEqualToString:name];
}

- (BOOL)boolValue
{
	if ( self.returnValue == HMEvent.YES_VALUE )
	{
		return YES;
	}
	else if ( self.returnValue == HMEvent.NO_VALUE )
	{
		return NO;
	}
	
	return NO;
}

- (void)returnYES
{
	self.returnValue = HMEvent.YES_VALUE;
}

- (void)returnNO
{
	self.returnValue = HMEvent.NO_VALUE;
}


- (void)dealloc
{
    self.inputValue = nil;
    self.returnValue = nil;
    self.source = nil;
    self.name = nil;
#if (__ON__ == __HM_DEVELOPMENT__)
    self.callPath = nil;
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
    HM_SUPER_DEALLOC();
}
- (NSString *)description{
#if (__ON__ == __HM_DEVELOPMENT__)
    return [NSString stringWithFormat:@"'%@'%@",self.name,self.callPath];
#else
    return [NSString stringWithFormat:@"%@",self.name];
#endif	// #if (__ON__ == __HM_DEVELOPMENT__)
    
}

@end


@implementation NSObject (HMEvent)


@dynamic eventReceiver;

static int KEY_SIGNAL_RECEIVER;
- (id)eventReceiver
{
	return objc_getAssociatedObject( self, &KEY_SIGNAL_RECEIVER );
}

- (void)setEventReceiver:(id)receiver
{
	objc_setAssociatedObject( self, &KEY_SIGNAL_RECEIVER, receiver, OBJC_ASSOCIATION_ASSIGN );
}

- (HMSignal *)sendSignal:(NSString *)name{
    
    return [self sendSignal:name withObject:nil];
    
}

- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object{
    
    return [self sendSignal:name withObject:object from:self];
    
}

- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object from:(id)source{
    return  [HMSignal sendSignal:name from:source withObject:object];
}
@end

#pragma mark -

@implementation UIView (HMEvent)

- (void)handleEvent:(HMEvent *)signal
{
	id receiver = self.eventReceiver;
	
	if ( nil == receiver )
	{
		receiver = self.superview;
	}
	
	if ( receiver )
	{
		[signal forward:receiver];
	}
	else
	{
		signal.reach = YES;
	}
}

- (HMEvent *)sendEvent:(NSString *)name
{
	return [self sendEvent:name withObject:nil from:self];
}

- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object
{
	return [self sendEvent:name withObject:object from:self];
}

- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object from:(id)source
{
	return [self sendEvent:name withObject:object to:self from:source];
}

- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object to:(id)target
{
	return [self sendEvent:name withObject:object to:target from:self];
}

- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object to:(id)target from:(id)source
{
	HMEvent * signal = [[[HMEvent alloc] init] autorelease];
	if ( signal )
	{
		signal.source = source ? source : self;
		signal.target = target ? target : self;
		signal.name = name;
		signal.object = object;
        
		[signal send];
	}
	return signal;
}



//- (HMSignal *)sendSignal:(NSString *)name{
//    
//    return [self sendSignal:name withObject:nil];
//    
//}
//
//- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object{
//    
//    return [self sendSignal:name withObject:object from:self];
//    
//}
//
//- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object from:(id)source{
//    return  [HMSignal sendSignal:name from:source withObject:object];
//}
@end


@implementation UIViewController (HMEvent)

- (void)handleEvent:(HMEvent *)signal
{
	signal.reach = YES;
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"Event",@"Reach V:[%@] > %@", signal.name, signal.callPath );
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}

- (HMEvent *)sendEvent:(NSString *)name
{
	return [self sendEvent:name withObject:nil from:self];
}

- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object
{
	return [self sendEvent:name withObject:object from:self];
}

- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object from:(id)source
{
	return [self sendEvent:name withObject:object to:self from:source];
}

- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object to:(id)target
{
	return [self sendEvent:name withObject:object to:target from:self];
}

- (HMEvent *)sendEvent:(NSString *)name withObject:(NSObject *)object to:(id)target from:(id)source
{
#if  __has_feature(objc_arc)
    HMEvent * signal = [[HMEvent alloc] init];
#else
    HMEvent * signal = [[[HMEvent alloc] init] autorelease];
#endif
	if ( signal )
	{
		signal.source = source ? source : self;
		signal.target = target ? target : self;
		signal.name = name;
		signal.object = object;
        
		[signal send];
	}
	return signal;
}

//- (HMSignal *)sendSignal:(NSString *)name{
//    return [self sendSignal:name withObject:nil];
//}
//
//- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object{
//    
//    return [self sendSignal:name withObject:object from:self];
//    
//}
//
//- (HMSignal *)sendSignal:(NSString *)name withObject:(id)object from:(id)source{
//    return  [HMSignal sendSignal:name from:source withObject:object];
//}

@end
