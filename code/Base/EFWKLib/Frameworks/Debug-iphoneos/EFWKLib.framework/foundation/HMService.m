//
//  HMService.m
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMService.h"

@implementation HMService{
    NSString *				_prefix;
}
static NSMutableArray * __subControllers = nil;
@synthesize prefix = _prefix;

DEF_SINGLETON(HMService)

+(BOOL)autoLoad{
    
    NSArray * availableClasses = [HMRuntime allSubClassesOf:[self class]];
	
	for ( Class classType in availableClasses )
	{
		[self prepareInstanceForClass:classType];
		
        
        PROGRESS( [classType description], @"OK" );
        
	}
    return YES;
}
+ (HMService *)prepareInstanceForClass:(Class)rtti
{
	
#if  __has_feature(objc_arc)
    HMService * Service = [[rtti alloc] init];
#else
    HMService * Service = [[[rtti alloc] init] autorelease];
#endif
	if ( Service )
	{
		if ( NO == [__subControllers containsObject:Service] )
		{
			[__subControllers addObject:Service];
		}
	}
	
	return Service;
}
+ (HMService *)routes:(NSString *)order
{
	HMService * controller = nil;
    
	if ( __subControllers.count )
	{
		for ( HMService * subController in __subControllers )
		{
			if ( [order hasPrefix:subController.prefix] )
			{
				controller = subController;
				break;
			}
		}
	}
    
	if ( nil == controller )
	{
		NSArray * array = [order componentsSeparatedByString:@"."];
		if ( array && array.count > 1 )
		{
            //			NSString * prefix = (NSString *)[array objectAtIndex:0];
			NSString * clazz = (NSString *)[array objectAtIndex:1];
            
			Class rtti = NSClassFromString( clazz );
			if ( rtti )
			{
				controller = [self prepareInstanceForClass:rtti];
				if ( controller )
				{
					NSAssert( [order hasPrefix:controller.prefix], @"wrong prefix" );
				}
			}
		}
	}
	
	if ( nil == controller )
	{
		controller = [HMService sharedInstance];
	}
	
	return controller;
}

-(void)route:(HMDialogue *)dial
{
	
    BOOL flag = [self prehandle:dial];
    if ( flag )
    {
        BOOL handled = NO;
        
        NSArray * parts = [dial.order componentsSeparatedByString:@"."];
        if ( parts && parts.count )
        {
            NSString * methodName = parts.lastObject;
            if ( methodName && methodName.length )
            {
                NSString *	selectorName = [methodName stringByAppendingString:@":"];
                SEL			selector = NSSelectorFromString(selectorName);
                
                if ( [self respondsToSelector:selector] )
                {
                    [self performSelector:selector withObject:dial];
                    handled = YES;
                }
            }
        }
        
        if ( NO == handled )
        {
            [self index:dial];
        }
        
        [self posthandle:dial];
    }
}
- (void)load
{
}

- (void)unload
{
}

-(BOOL)prehandle:(HMDialogue *)dial
{
	return YES;
}
-(void)posthandle:(HMDialogue *)dial{
    
}

- (void)index:(HMDialogue *)dial
{
	ERROR( @"unknown message '%@'", dial.order );
    
	[dial setLastError:HMDialogue.ERROR_CODE_ROUTES
			   domain:HMDialogue.ERROR_DOMAIN_UNKNOWN
				 desc:@"No routes"];
}

+ (NSArray *)allServices
{
	return __subControllers;
}

#pragma mark -

- (id)init
{
	self = [super init];
	if ( self )
	{
		if ( nil == __subControllers )
		{
			__subControllers = [[NSMutableArray alloc] init];
		}
        
        //		self.mapping = [NSMutableDictionary dictionary];
		self.prefix = [NSString stringWithFormat:@"%@.%@", [HMDialogue DIALOGUE_SERVICE] , [[self class] description]];
        
		[self load];
        
		if ( NO == [__subControllers containsObject:self] )
		{
			[__subControllers addObject:self];
		}
	}
	
	return self;
}

- (void)dealloc
{
	if ( [__subControllers containsObject:self] )
	{
		[__subControllers removeObject:self];
	}
    
	[self unload];
    
    //	self.mapping = nil;
	self.prefix = nil;
	HM_SUPER_DEALLOC();

}
@end
