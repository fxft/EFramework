

#import "HMKeychain.h"
#import "HMSystemInfo.h"
#import "HMMacros.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

#undef	DEFAULT_DOMAIN
#define DEFAULT_DOMAIN	@"BeeKeychain"

@implementation HMKeychain

static NSString * __defaultDomain = nil;

+ (void)setDefaultDomain:(NSString *)domain
{
	
#if  __has_feature(objc_arc)

#else
    [domain retain];
    [__defaultDomain release];
    
#endif
    __defaultDomain = domain;
}

+ (NSString *)readValueForKey:(NSString *)key
{
	return [HMKeychain readValueForKey:key andDomain:__defaultDomain];
}

+ (NSString *)readValueForKey:(NSString *)key andDomain:(NSString *)domain
{
	if ( nil == key )
		return nil;
	
	if ( nil == domain )
	{
		domain = __defaultDomain;
		if ( nil == domain )
		{
			domain = DEFAULT_DOMAIN;
		}
	}
	
	domain = [domain stringByAppendingString:[HMSystemInfo appIdentifier]];

	NSArray * keys = [[[NSArray alloc] initWithObjects: (__bridge_type NSString *) kSecClass, kSecAttrAccount, kSecAttrService, nil] autorelease];
    
	NSArray * objects = [[[NSArray alloc] initWithObjects: (__bridge_type NSString *) kSecClassGenericPassword, key, domain, nil] autorelease];
    
	NSMutableDictionary * query = [[[NSMutableDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];
    
	NSMutableDictionary * attributeQuery = [query mutableCopy];
	[attributeQuery setObject: (id) kCFBooleanTrue forKey:(__bridge_type id) kSecReturnAttributes];
	
	NSDictionary * attributeResult = NULL;
	OSStatus status = SecItemCopyMatching( (CFDictionaryRef)attributeQuery, (CFTypeRef *)&attributeResult );
	
#if  __has_feature(objc_arc)
    
#else
    [attributeResult release];
    [attributeQuery release];
#endif
	
	if ( noErr != status )
		return nil;
	
	NSMutableDictionary * passwordQuery = [query mutableCopy];
	[passwordQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_type id)kSecReturnData];
	
	NSData * resultData = nil;
	status = SecItemCopyMatching( (CFDictionaryRef)passwordQuery, (CFTypeRef *)&resultData );
#if  __has_feature(objc_arc)
    
#else
    [resultData autorelease];
    [passwordQuery autorelease];
#endif
    
    
	if ( noErr != status )
		return nil;
	
	if ( nil == resultData )
		return nil;
	
	NSString * password = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];	
#if  __has_feature(objc_arc)
    return password;
#else
    return [password autorelease];
#endif
}

+ (void)writeValue:(NSString *)value forKey:(NSString *)key
{
	[HMKeychain writeValue:value forKey:key andDomain:__defaultDomain];
}

+ (void)writeValue:(NSString *)value forKey:(NSString *)key andDomain:(NSString *)domain
{
	if ( nil == key )
		return;
	
	if ( nil == value )
	{
		value = @"";
	}

	if ( nil == domain )
	{
		domain = __defaultDomain;
		if ( nil == domain )
		{
			domain = DEFAULT_DOMAIN;
		}
	}
	
	OSStatus status = 0;
	
	NSString * password = [HMKeychain readValueForKey:key andDomain:domain];
    
    domain = [domain stringByAppendingString:[HMSystemInfo appIdentifier]];
	if ( password ) 
	{
		if ( [password isEqualToString:value] )
			return;

		NSArray * keys = [[[NSArray alloc] initWithObjects:(__bridge_type NSString *)kSecClass, kSecAttrService, kSecAttrLabel, kSecAttrAccount, nil] autorelease];
		NSArray * objects = [[[NSArray alloc] initWithObjects:(__bridge_type NSString *)kSecClassGenericPassword, domain, domain, key, nil] autorelease];
       
		NSDictionary * query = [[[NSDictionary alloc] initWithObjects:objects forKeys:keys] autorelease];
        
		status = SecItemUpdate( (__bridge_type CFDictionaryRef)query, (__bridge_type CFDictionaryRef)[NSDictionary dictionaryWithObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge_type NSString *)kSecValueData] );
	}
	else 
	{
		NSArray * keys = [[[NSArray alloc] initWithObjects:(__bridge_type NSString *)kSecClass, kSecAttrService, kSecAttrLabel, kSecAttrAccount, kSecValueData, nil] autorelease];
        
		NSArray * objects = [[[NSArray alloc] initWithObjects:(__bridge_type NSString *)kSecClassGenericPassword, domain, domain, key, [value dataUsingEncoding:NSUTF8StringEncoding], nil] autorelease];
		
		NSDictionary * query = [[[NSDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];
        
		status = SecItemAdd( (__bridge_type CFDictionaryRef)query, NULL);
	}
	
	if ( noErr != status )
	{
		ERROR( @"writeValue, status = %d", status );
	}
}

+ (void)deleteValueForKey:(NSString *)key
{
	[HMKeychain deleteValueForKey:key andDomain:__defaultDomain];
}

+ (void)deleteValueForKey:(NSString *)key andDomain:(NSString *)domain
{
	if ( nil == key )
		return;
	
	if ( nil == domain )
	{
		domain = __defaultDomain;
		if ( nil == domain )
		{
			domain = DEFAULT_DOMAIN;
		}
	}
	
	domain = [domain stringByAppendingString:[HMSystemInfo appIdentifier]];

	NSArray * keys = [NSArray arrayWithObjects:(__bridge_type NSString *)kSecClass, kSecAttrAccount, kSecAttrService, kSecReturnAttributes, nil];

	NSArray * objects = [NSArray arrayWithObjects:(__bridge_type NSString *)kSecClassGenericPassword, key, domain, kCFBooleanTrue, nil];
	
    NSDictionary * query = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
	SecItemDelete( (__bridge_type CFDictionaryRef)query );
}

@end
