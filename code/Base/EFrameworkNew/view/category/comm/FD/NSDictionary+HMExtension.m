//
//  NSDictionary+HMExtension.m
//  GPSService
//
//  Created by Eric on 14-4-3.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSDictionary+HMExtension.h"
#import "HMMacros.h"

@implementation NSDictionary (HMExtension)

@dynamic APPEND;

- (NSDictionaryAppendBlock)APPEND
{
	NSDictionaryAppendBlock block = ^ NSDictionary * ( NSString * key, id value )
	{
		if ( key && value )
		{
			NSString * className = [[self class] description];
            
			if ( [self isKindOfClass:[NSMutableDictionary class]] || [className isEqualToString:@"NSMutableDictionary"] || [className isEqualToString:@"__NSDictionaryM"] )
			{
				[(NSMutableDictionary *)self setObject:value forKey:key];
				return self;
			}
			else
			{
				NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self];
				[dict setObject:value forKey:key];
				return dict;
			}
		}
		
		return self;
	};
	
	return [[block copy] autorelease];
}

- (NSData *)JSONData{
    if (![NSJSONSerialization isValidJSONObject:self]) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"JSON",@"is not valid json object:: %@",self);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"JSON-NSDictionary",error,self);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    return data;
    
}

- (NSString *)JSONString{
    NSString *jsonS = [[[NSString alloc]initWithData:[self JSONData] encoding:NSUTF8StringEncoding]autorelease];
    return [jsonS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

@end

#pragma mark -

// No-ops for non-retaining objects.
static const void *	__TTRetainNoOp( CFAllocatorRef allocator, const void * value ) { return value; }
static void			__TTReleaseNoOp( CFAllocatorRef allocator, const void * value ) {};

#pragma mark -

@implementation NSMutableDictionary(HMExtension)

@dynamic APPEND;

- (NSDictionaryAppendBlock)APPEND
{
	NSDictionaryAppendBlock block = ^ NSDictionary * ( NSString * key, id value )
	{
		if ( key && value )
		{
			[self setObject:value forKey:key];
		}
		
		return self;
	};
	
	return [[block copy] autorelease];
}

+ (NSMutableDictionary *)nonRetainingDictionary
{
	CFDictionaryValueCallBacks callbacks = kCFTypeDictionaryValueCallBacks;
	callbacks.retain = __TTRetainNoOp;
	callbacks.release = __TTReleaseNoOp;
	return [(NSMutableDictionary *)CFDictionaryCreateMutable( NULL, 0, &kCFTypeDictionaryKeyCallBacks, &callbacks ) autorelease];
}

@end
