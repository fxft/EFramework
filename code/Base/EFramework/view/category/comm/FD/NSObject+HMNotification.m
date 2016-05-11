//
//  NSObject+HMNotification.m
//  CarAssistant
//
//  Created by Eric on 14-3-2.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSObject+HMNotification.h"


#pragma mark -

@implementation NSNotification(HMNotification)

- (BOOL)is:(NSString *)name
{
	return [self.name isEqualToString:name];
}

- (BOOL)isKindOf:(NSString *)prefix
{
	return [self.name hasPrefix:prefix];
}

@end

#pragma mark -

@implementation NSObject(HMNotification)

+ (NSString *)NOTIFICATION
{
	return [self NOTIFICATION_TYPE];
}

+ (NSString *)NOTIFICATION_TYPE
{
	return [NSString stringWithFormat:@"notify.%@.", [self description]];
}

- (void)handleNotification:(NSNotification *)notification
{
}

- (void)observeNotification:(NSString *)notificationName
{
	NSArray * array = [notificationName componentsSeparatedByString:@"."];
	if ( array && array.count > 1 )
	{
        //		NSString * prefix = (NSString *)[array objectAtIndex:0];
		NSString * clazz = (NSString *)[array objectAtIndex:1];
		NSString * name = (NSString *)[array objectAtIndex:2];
        
		{
			NSString * selectorName;
			SEL selector;
            
			selectorName = [NSString stringWithFormat:@"handleNotification_%@_%@:", clazz, name];
			selector = NSSelectorFromString(selectorName);
			
			if ( ![self respondsToSelector:selector] )
			{
                selectorName = [NSString stringWithFormat:@"handleNotification_%@:", clazz];
                selector = NSSelectorFromString(selectorName);
			}
			
			if ( [self respondsToSelector:selector] )
			{
				[[NSNotificationCenter defaultCenter] addObserver:self
														 selector:selector
															 name:notificationName
														   object:nil];
				return;
			}
		}

	}
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNotification:)
												 name:notificationName
											   object:nil];
}

- (void)unobserveNotification:(NSString *)name
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:name
												  object:nil];
}

- (void)unobserveAllNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (BOOL)postNotification:(NSString *)name
{
	
	return [NSObject postNotification:name withObject:nil];

}

+ (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object
{
//    CC( @"Notif",@"%@", name );
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
	return YES;
}

- (BOOL)postNotification:(NSString *)name
{
	return [NSObject postNotification:name];
}

- (BOOL)postNotification:(NSString *)name withObject:(NSObject *)object
{
	return [NSObject postNotification:name withObject:object];
}

@end

