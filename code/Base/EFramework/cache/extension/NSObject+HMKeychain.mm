

#import "NSObject+HMKeychain.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject(HMKeychain)

+ (NSString *)keychainRead:(NSString *)key
{
	return [HMKeychain readValueForKey:key andDomain:nil];
}

+ (void)keychainWrite:(NSString *)value forKey:(NSString *)key
{
	[HMKeychain writeValue:value forKey:key andDomain:nil];
}

+ (void)keychainDelete:(NSString *)key
{
	[HMKeychain deleteValueForKey:key andDomain:nil];
}

- (NSString *)keychainRead:(NSString *)key
{
	return [HMKeychain readValueForKey:key andDomain:nil];
}

- (void)keychainWrite:(NSString *)value forKey:(NSString *)key
{
	[HMKeychain writeValue:value forKey:key andDomain:nil];
}

- (void)keychainDelete:(NSString *)key
{
	[HMKeychain deleteValueForKey:key andDomain:nil];
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if defined(__HM_UNITTEST__) && __HM_UNITTEST__

TEST_CASE( NSObject_HMKeychain )
{
	// TODO:
}
TEST_CASE_END

#endif	// #if defined(__HM_UNITTEST__) && __HM_UNITTEST__
