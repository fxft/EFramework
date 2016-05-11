//
//  NSArray+HMExtension.m
//  CarAssistant
//
//  Created by Eric on 14-2-23.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSArray+HMExtension.h"
#import "HMMacros.h"
// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSArray(HMExtension)

@dynamic APPEND;
@dynamic mutableArray;

- (NSArrayAppendBlock)APPEND
{
	NSArrayAppendBlock block = ^ NSMutableArray * ( id obj )
	{
		NSMutableArray * array = [NSMutableArray arrayWithArray:self];
		[array addObject:obj];
		return array;
	};
	
	return [[block copy] autorelease];
}

- (NSArray *)head:(NSUInteger)count
{
	if ( [self count] < count )
	{
		return self;
	}
	else
	{
		NSMutableArray * tempFeeds = [NSMutableArray array];
		for ( NSObject * elem in self )
		{
			[tempFeeds addObject:elem];
			if ( [tempFeeds count] >= count )
				break;
		}
		return tempFeeds;
	}
}

- (NSArray *)tail:(NSUInteger)count
{
    //	if ( [self count] < count )
    //	{
    //		return self;
    //	}
    //	else
    //	{
    //        NSMutableArray * tempFeeds = [NSMutableArray array];
    //
    //        for ( NSUInteger i = 0; i < count; i++ )
    //		{
    //            [tempFeeds insertObject:[self objectAtIndex:[self count] - i] atIndex:0];
    //        }
    //
    //		return tempFeeds;
    //	}
    
    // thansk @lancy, changed: NSArray tail: count
    
	NSRange range = NSMakeRange( self.count - count, count );
	return [self subarrayWithRange:range];
}

- (id)safeObjectAtIndex:(NSInteger)index
{
	if ( index < 0 )
		return nil;
	
	if ( index >= self.count )
		return nil;
    
	return [self objectAtIndex:index];
}

- (NSArray *)safeSubarrayWithRange:(NSRange)range
{
	if ( 0 == self.count )
		return nil;
    
	if ( range.location >= self.count )
		return nil;
    
	if ( range.location + range.length >= self.count )
		return nil;
	
	return [self subarrayWithRange:NSMakeRange(range.location, range.length)];
}

- (NSMutableArray *)mutableArray
{
	return [NSMutableArray arrayWithArray:self];
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
        CC( @"JSON",error);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    return data;
    
}

- (NSString *)JSONString{
    NSString *jsonS = [[[NSString alloc]initWithData:[self JSONData] encoding:NSUTF8StringEncoding]autorelease];
    return [jsonS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (NSArray *)distinctUnionOfObjectsForKey:(NSString*)key{
    return [self valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@",key]];
}

- (NSArray *)unionOfObjectsForKey:(NSString*)key{
    return [self valueForKeyPath:[NSString stringWithFormat:@"@unionOfObjects.%@",key]];
}

- (NSArray *)filterWithFormat:(NSString *)format,...{
    va_list args;
    NSString *formatS = nil;
    NSPredicate *predicateString=nil;
    va_start( args, format );
    formatS = [[[NSString alloc]initWithFormat:format arguments:args]autorelease];
    predicateString = [NSPredicate predicateWithFormat:formatS];
    va_end(args);
    if (formatS==nil) {
        return nil;
    }
    
    return [self filteredArrayUsingPredicate:predicateString];
}

@end

#pragma mark -

// No-ops for non-retaining objects.
static const void *	__TTRetainNoOp( CFAllocatorRef allocator, const void * value ) { return value; }
static void			__TTReleaseNoOp( CFAllocatorRef allocator, const void * value ) { }

#pragma mark -

@implementation NSMutableArray(HMExtension)

@dynamic APPEND;

- (NSMutableArrayAppendBlock)APPEND
{
	NSMutableArrayAppendBlock block = ^ NSMutableArray * ( id obj )
	{
		[self addObject:obj];
		return self;
	};
	
	return [[block copy] autorelease];
}

+ (NSMutableArray *)nonRetainingArray	// copy from Three20
{
	CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
	callbacks.retain = __TTRetainNoOp;
	callbacks.release = __TTReleaseNoOp;
	return (NSMutableArray *)CFBridgingRelease(CFArrayCreateMutable( nil, 0, &callbacks ));
}

- (NSMutableArray *)pushHead:(NSObject *)obj
{
	if ( obj )
	{
		[self insertObject:obj atIndex:0];
	}
	
	return self;
}

- (NSMutableArray *)pushHeadN:(NSArray *)all
{
	if ( [all count] )
	{
		for ( NSUInteger i = [all count]; i > 0; --i )
		{
			[self insertObject:[all objectAtIndex:i - 1] atIndex:0];
		}
	}
	
	return self;
}

- (NSMutableArray *)popTail
{
	if ( [self count] > 0 )
	{
		[self removeObjectAtIndex:[self count] - 1];
	}
	
	return self;
}

- (NSMutableArray *)popTailN:(NSUInteger)n
{
	if ( [self count] > 0 )
	{
		if ( n >= [self count] )
		{
			[self removeAllObjects];
		}
		else
		{
			NSRange range;
			range.location = n;
			range.length = [self count] - n;
			
			[self removeObjectsInRange:range];
		}
	}
	
	return self;
}

- (NSMutableArray *)pushTail:(NSObject *)obj
{
	if ( obj )
	{
		[self addObject:obj];
	}
	
	return self;
}

- (NSMutableArray *)pushTailN:(NSArray *)all
{
	if ( [all count] )
	{
		[self addObjectsFromArray:all];
	}
	
	return self;
}

- (NSMutableArray *)popHead
{
	if ( [self count] )
	{
		[self removeLastObject];
	}
	
	return self;
}

- (NSMutableArray *)popHeadN:(NSUInteger)n
{
	if ( [self count] > 0 )
	{
		if ( n >= [self count] )
		{
			[self removeAllObjects];
		}
		else
		{
			NSRange range;
			range.location = 0;
			range.length = n;
			
			[self removeObjectsInRange:range];
		}
	}
	
	return self;
}

- (NSMutableArray *)keepHead:(NSUInteger)n
{
	if ( [self count] > n )
	{
		NSRange range;
		range.location = n;
		range.length = [self count] - n;
		
		[self removeObjectsInRange:range];
	}
	
	return self;
}

- (NSMutableArray *)keepTail:(NSUInteger)n
{
	if ( [self count] > n )
	{
		NSRange range;
		range.location = 0;
		range.length = [self count] - n;
		
		[self removeObjectsInRange:range];
	}
	
	return self;
}

- (void)insertObjectNoRetain:(id)object atIndex:(NSUInteger)index
{
	[self insertObject:object atIndex:index];

    [object release];
}

- (void)addObjectNoRetain:(NSObject *)object
{
	[self addObject:object];
	[object release];
}

- (void)removeObjectNoRelease:(NSObject *)object
{
    [object retain];
	[self removeObject:object];
}

- (void)removeAllObjectsNoRelease
{
	for ( NSObject * object in self )
	{
        [object retain];
	}	
	
	[self removeAllObjects];
}

@end