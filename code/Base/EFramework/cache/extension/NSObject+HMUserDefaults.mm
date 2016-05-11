

#import "NSObject+HMUserDefaults.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject(HMUserDefaults)

+ (NSString *)persistenceKey:(NSString *)key
{
	key = [key stringByReplacingOccurrencesOfString:@"." withString:@"_"];
	key = [key stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
	key = [key stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	
	return key.uppercaseString;
}

+ (id)userDefaultsRead:(NSString *)key
{
	if ( nil == key )
		return nil;

	key = [self persistenceKey:key];
	
	id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	return value;
}

- (id)userDefaultsRead:(NSString *)key
{
	return [[self class] userDefaultsRead:key];
}

+ (void)userDefaultsWrite:(id)value forKey:(NSString *)key
{
	if ( nil == key || nil == value )
		return;
	
	key = [self persistenceKey:key];
	
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)userDefaultsWrite:(id)value forKey:(NSString *)key
{
	[[self class] userDefaultsWrite:value forKey:key];
}

+ (void)userDefaultsRemove:(NSString *)key
{
	if ( nil == key )
		return;

	key = [self persistenceKey:key];
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)userDefaultsRemove:(NSString *)key
{
	if ( nil == key )
		return;

	[[self class] userDefaultsRemove:key];
    
}

+ (id)readObject
{
	return [self readObjectForKey:nil];
}

+ (id)readObjectForKey:(NSString *)key
{
	key = [self persistenceKey:key];
	
	NSObject * value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if ( value )
	{
		return [self objectFromAny:value];
	}

	return nil;
}

+ (void)saveObject:(id)obj
{
	[self saveObject:obj forKey:nil];
}

+ (void)saveObject:(id)obj forKey:(NSString *)key
{
	if ( nil == obj )
		return;
	
	key = [self persistenceKey:key];
	
	NSString * value = [obj objectToString];
	if ( value && value.length )
	{
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
}

+ (void)removeObject
{
	[self removeObjectForKey:nil];
}

+ (void)removeObjectForKey:(NSString *)key
{
	key = [self persistenceKey:key];
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)readFromUserDefaults:(NSString *)key
{
	if ( nil == key )
		return nil;
	
	NSString * jsonString = [self userDefaultsRead:key];
	if ( nil == jsonString || NO == [jsonString isKindOfClass:[NSString class]] )
		return nil;

	NSString * decodedObject = [jsonString objectToString];
	if ( nil == decodedObject )
		return nil;
	
	return [self objectFromAny:decodedObject];
}

- (void)saveToUserDefaults:(NSString *)key
{
	if ( nil == key )
		return;
	
	NSString * jsonString = [self objectToString];
	if ( nil == jsonString || 0 == jsonString.length )
		return;

	[self userDefaultsWrite:jsonString forKey:key];
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if defined(__BEE_UNITTEST__) && __BEE_UNITTEST__

TEST_CASE( NSObject_BeeUserDefaults )
{
	[self userDefaultsWrite:@"value" forKey:@"key"];
	
	NSString * value = [self userDefaultsRead:@"key"];
	ASSERT( nil != value && [value isEqualToString:@"value"] );

	[self userDefaultsRemove:@"key"];

	NSString * value2 = [self userDefaultsRead:@"key"];
	ASSERT( nil == value2 );
}
TEST_CASE_END

#endif	// #if defined(__BEE_UNITTEST__) && __BEE_UNITTEST__
