//
//  HMRuntime.m
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMRuntime.h"


#pragma mark -

@implementation HMTypeEncoding

DEF_INT( UNKNOWN,		0 )
DEF_INT( OBJECT,		1 )
DEF_INT( NSNUMBER,		2 )
DEF_INT( NSSTRING,		3 )
DEF_INT( NSARRAY,		4 )
DEF_INT( NSDICTIONARY,	5 )
DEF_INT( NSDATE,		6 )
DEF_INT( RLMARRAY,		7 )

+ (NSUInteger)typeOf:(const char *)attr
{
	if ( attr[0] != 'T' )
		return HMTypeEncoding.UNKNOWN;
	
	const char * type = &attr[1];
	if ( type[0] == '@' )
	{
		if ( type[1] != '"' )
			return HMTypeEncoding.UNKNOWN;
		
		char typeClazz[128] = { 0 };
		
		const char * clazz = &type[2];
		const char * clazzEnd = strchr( clazz, '"' );
		
		if ( clazzEnd && clazz != clazzEnd )
		{
			unsigned int size = (unsigned int)(clazzEnd - clazz);
			strncpy( &typeClazz[0], clazz, size );
		}
		
		if ( 0 == strncmp((const char *)typeClazz, "NSNumber",8) )
		{
			return HMTypeEncoding.NSNUMBER;
		}
		else if ( 0 == strncmp((const char *)typeClazz, "NSString",8) || 0 == strncmp((const char *)typeClazz, "NSMutableString",15))
		{
			return HMTypeEncoding.NSSTRING;
		}
		else if ( 0 == strncmp((const char *)typeClazz, "NSDate",6) )
		{
			return HMTypeEncoding.NSDATE;
		}
		else if ( 0 == strncmp((const char *)typeClazz, "NSArray",7) || 0 == strncmp((const char *)typeClazz, "NSMutableArray",14))
		{
			return HMTypeEncoding.NSARRAY;
		}
		else if ( 0 == strncmp((const char *)typeClazz, "NSDictionary",12) || 0 == strncmp((const char *)typeClazz, "NSMutableDictionary",19))
		{
			return HMTypeEncoding.NSDICTIONARY;
		}
        else if ( 0 == strncmp((const char *)typeClazz, "RLMArray",8) )
        {
            return HMTypeEncoding.RLMARRAY;
        }
		else
		{
			return HMTypeEncoding.OBJECT;
		}
	}
	else if ( type[0] == '[' )
	{
		return HMTypeEncoding.UNKNOWN;
	}
	else if ( type[0] == '{' )
	{
		return HMTypeEncoding.UNKNOWN;
	}
	else
	{
		if ( type[0] == 'c' || type[0] == 'C' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == 'i' || type[0] == 's' || type[0] == 'l' || type[0] == 'q' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == 'I' || type[0] == 'S' || type[0] == 'L' || type[0] == 'Q' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == 'f' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == 'd' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == 'B' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == 'v' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == '*' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == ':' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( 0 == strcmp(type, "bnum") )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == '^' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else if ( type[0] == '?' )
		{
			return HMTypeEncoding.UNKNOWN;
		}
		else
		{
			return HMTypeEncoding.UNKNOWN;
		}
	}
	
	return HMTypeEncoding.UNKNOWN;
}

+ (NSUInteger)typeOfAttribute:(const char *)attr
{
	return [self typeOf:attr];
}

+ (NSUInteger)typeOfObject:(id)obj
{
	if ( nil == obj )
		return HMTypeEncoding.UNKNOWN;
	
	if ( [obj isKindOfClass:[NSNumber class]] )
	{
		return HMTypeEncoding.NSNUMBER;
	}
	else if ( [obj isKindOfClass:[NSString class]] )
	{
		return HMTypeEncoding.NSSTRING;
	}
	else if ( [obj isKindOfClass:[NSArray class]] )
	{
		return HMTypeEncoding.NSARRAY;
	}
	else if ( [obj isKindOfClass:[NSDictionary class]] )
	{
		return HMTypeEncoding.NSDICTIONARY;
	}
	else if ( [obj isKindOfClass:[NSDate class]] )
	{
		return HMTypeEncoding.NSDATE;
	}
    else if ( [obj isKindOfClass:NSClassFromString(@"RLMArray")] )
    {
        return HMTypeEncoding.RLMARRAY;
    }
	else if ( [obj isKindOfClass:[NSObject class]] )
	{
		return HMTypeEncoding.OBJECT;
	}
	
	return HMTypeEncoding.UNKNOWN;
}

+ (NSString *)classNameOf:(const char *)attr
{
	if ( attr[0] != 'T' )
		return nil;
	
	const char * type = &attr[1];
	if ( type[0] == '@' )
	{
		if ( type[1] != '"' )
			return nil;
		
		char typeClazz[128] = { 0 };
		
		const char * clazz = &type[2];
		const char * clazzEnd = strchr( clazz, '"' );
		
		if ( clazzEnd && clazz != clazzEnd )
		{
			unsigned int size = (unsigned int)(clazzEnd - clazz);
			strncpy( &typeClazz[0], clazz, size );
		}
		
		return [NSString stringWithUTF8String:typeClazz];
	}
	
	return nil;
}

+ (NSString *)classNameOfAttribute:(const char *)attr
{
	return [self classNameOf:attr];
}

+ (Class)classOfAttribute:(const char *)attr
{
	NSString * className = [self classNameOf:attr];
	if ( nil == className )
		return nil;
	
	return NSClassFromString( className );
}

+ (BOOL)isAtomClass:(Class)clazz
{
	if ( clazz == [NSArray class] || [[clazz description] isEqualToString:@"__NSCFArray"] )
		return YES;
	if ( clazz == [NSData class] )
		return YES;
	if ( clazz == [NSDate class] )
		return YES;
	if ( clazz == [NSDictionary class] )
		return YES;
	if ( clazz == [NSNull class] )
		return YES;
	if ( clazz == [NSNumber class] || [[clazz description] isEqualToString:@"__NSCFNumber"] )
		return YES;
	if ( clazz == [NSObject class] )
		return YES;
	if ( clazz == [NSString class] )
		return YES;
	if ( clazz == [NSURL class] )
		return YES;
	if ( clazz == [NSValue class] )
		return YES;
	
	return NO;
}

@end

#pragma mark -

@implementation HMRuntime

+(BOOL)clazz:(Class)clazz isSubclassOfClass:(Class)superClass{
    register Class cls;
    for (cls = clazz; cls; cls = class_getSuperclass(cls))
		if (cls == (Class)superClass)
			return YES;
    return NO;
}

+ (NSArray *)allClasses
{
	static NSMutableArray * __allClasses = nil;
	
	if ( nil == __allClasses )
	{
		__allClasses = [[NSMutableArray alloc] init];
	}
	
	if ( 0 == __allClasses.count )
	{
		unsigned int	classesCount = 0;
		Class *			classes = objc_copyClassList( &classesCount );
		
		for ( unsigned int i = 0; i < classesCount; ++i )
		{
			Class classType = classes[i];
            
            //			if ( NO == class_conformsToProtocol( classType, @protocol(NSObject)) )
            //				continue;
			if ( NO == class_respondsToSelector( classType, @selector(doesNotRecognizeSelector:) ) )
				continue;
			if ( NO == class_respondsToSelector( classType, @selector(methodSignatureForSelector:) ) )
				continue;
            //			if ( NO == [classType isSubclassOfClass:[NSObject class]] )
            //				continue;
            
            const char *name = class_getName(classType);
            NSString *className = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
			[__allClasses addObject:className];
		}
		
		free( classes );
	}
	
	return __allClasses;
}

+ (NSArray *)allSubClassesOf:(Class)superClass
{
	
#if  __has_feature(objc_arc)
    NSMutableArray * results = [[NSMutableArray alloc] init];
#else
    NSMutableArray * results = [[[NSMutableArray alloc] init] autorelease];
#endif
	for ( NSString *name in [self allClasses] )
	{
        Class classType = objc_getClass([name UTF8String]);
		if ( classType == superClass )
			continue;
		if ( ![HMRuntime clazz:classType isSubclassOfClass:superClass] )
			continue;
        
		[results addObject:classType];
	}
	
	return results;
}
+ (NSArray *)allMethodOf:(Class)clazz
{
#if  __has_feature(objc_arc)
    NSMutableArray * results = [[NSMutableArray alloc] init];
#else
    NSMutableArray * results = [[[NSMutableArray alloc] init] autorelease];
#endif
    
    Class currentClass=clazz;
    while (currentClass) {
        unsigned int methodCount;
        Method *methodList = class_copyMethodList(currentClass, &methodCount);
        unsigned int i = 0;
        for (; i < methodCount; i++) {
            [results addObject:[NSString stringWithCString:sel_getName(method_getName(methodList[i])) encoding:NSUTF8StringEncoding]];
            NSLog(@"%@ - %@", [NSString stringWithCString:class_getName(currentClass) encoding:NSUTF8StringEncoding], [NSString stringWithCString:sel_getName(method_getName(methodList[i])) encoding:NSUTF8StringEncoding]);
        }
        
        free(methodList);
        break;
//        currentClass = class_getSuperclass(currentClass);
    }
    return results;
}
@end


#pragma mark -

@implementation NSObject(HMRuntime)

- (NSNumber *)asNSNumber
{
	if ( [self isKindOfClass:[NSNumber class]] )
	{
		return (NSNumber *)self;
	}
	else if ( [self isKindOfClass:[NSString class]] )
	{
		return [NSNumber numberWithInteger:[(NSString *)self integerValue]];
	}
	else if ( [self isKindOfClass:[NSDate class]] )
	{
		return [NSNumber numberWithDouble:[(NSDate *)self timeIntervalSince1970]];
	}
	else if ( [self isKindOfClass:[NSNull class]] )
	{
		return [NSNumber numberWithInteger:0];
	}
    
	return nil;
}

- (NSString *)asNSString
{
	if ( [self isKindOfClass:[NSNull class]] )
		return nil;
    
	if ( [self isKindOfClass:[NSString class]] )
	{
		return (NSString *)self;
	}
	else if ( [self isKindOfClass:[NSData class]] )
	{
		NSData * data = (NSData *)self;
		
#if  __has_feature(objc_arc)
        return [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
#else
        return [[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding] autorelease];
#endif
	}
	else
	{
		return [NSString stringWithFormat:@"%@", self];
	}
}

- (NSDate *)asNSDate
{
	if ( [self isKindOfClass:[NSDate class]] )
	{
		return (NSDate *)self;
	}
	else if ( [self isKindOfClass:[NSString class]] )
	{
		NSDate * date = nil;
        
		if ( nil == date )
		{
			NSString * format = @"yyyy-MM-dd HH:mm:ss z";
			
#if  __has_feature(objc_arc)
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
#else
            NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
#endif
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy/MM/dd HH:mm:ss z";
#if  __has_feature(objc_arc)
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
#else
            NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
#endif
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy-MM-dd HH:mm:ss";
#if  __has_feature(objc_arc)
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
#else
            NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
#endif
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		if ( nil == date )
		{
			NSString * format = @"yyyy/MM/dd HH:mm:ss";
#if  __has_feature(objc_arc)
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
#else
            NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
#endif
			[formatter setDateFormat:format];
			[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
			
			date = [formatter dateFromString:(NSString *)self];
		}
        
		return date;
        
        //		NSTimeZone * local = [NSTimeZone localTimeZone];
        //		return [NSDate dateWithTimeInterval:(3600 + [local secondsFromGMT])
        //								  sinceDate:[dateFormatter dateFromString:text]];
	}
	else
	{
		return [NSDate dateWithTimeIntervalSince1970:[self asNSNumber].doubleValue];
	}
	
	return nil;
}

- (NSData *)asNSData
{
    if ([self isKindOfClass:[NSString class]]&&[(NSString*)self notEmpty]) {
        const char * str = [(NSString *)self UTF8String];
        return [NSData dataWithBytes:str length:strlen(str)];
    }
	return nil;
}

- (NSArray *)asNSArray
{
	if ( [self isKindOfClass:[NSArray class]] )
	{
		return (NSArray *)self;
	}
	else
	{
		return [NSArray arrayWithObject:self];
	}
}

- (NSArray *)asNSArrayWithClass:(Class)clazz
{
	if ( [self isKindOfClass:[NSArray class]] )
	{
		NSMutableArray * results = [NSMutableArray array];
        
		for ( NSObject * elem in (NSArray *)self )
		{
			if ( [elem isKindOfClass:[NSDictionary class]] )
			{
				NSObject * obj = [[self class] objectFromDictionary:elem];
				[results addObject:obj];
			}
		}
		
		return results;
	}
    
	return nil;
}

- (NSMutableArray *)asNSMutableArray
{
	if ( [self isKindOfClass:[NSMutableArray class]] )
	{
		return (NSMutableArray *)self;
	}
	
	return nil;
}

- (NSMutableArray *)asNSMutableArrayWithClass:(Class)clazz
{
	NSArray * array = [self asNSArrayWithClass:clazz];
	if ( nil == array )
		return nil;
    
	return [NSMutableArray arrayWithArray:array];
}

- (NSDictionary *)asNSDictionary
{
	if ( [self isKindOfClass:[NSDictionary class]] )
	{
		return (NSDictionary *)self;
	}
    
	return nil;
}

- (NSMutableDictionary *)asNSMutableDictionary
{
	if ( [self isKindOfClass:[NSMutableDictionary class]] )
	{
		return (NSMutableDictionary *)self;
	}
	
	NSDictionary * dict = [self asNSDictionary];
	if ( nil == dict )
		return nil;
    
	return [NSMutableDictionary dictionaryWithDictionary:dict];
}

- (id)objectToDictionary
{
	return [self objectToDictionaryUntilRootClass:nil];
}

- (id)objectToArray{
    NSMutableArray *result = [NSMutableArray array];
    if ([self isKindOfClass:[NSArray class]]) {
        for (NSObject *obj in (NSArray*)self) {
            [result addObject:[obj objectToDictionary]];
        }
    }
    return result;
}

- (id)objectToDictionaryUntilRootClass:(Class)rootClass
{
	NSMutableDictionary * result = [NSMutableDictionary dictionary];
	
	if ( [self isKindOfClass:[NSDictionary class]] )
	{
		NSDictionary * dict = (NSDictionary *)self;
        
		for ( NSString * key in dict.allKeys )
		{
			NSObject * obj = [dict objectForKey:key];
			if ( obj )
			{
				NSUInteger propertyType = [HMTypeEncoding typeOfObject:obj];
				if ( HMTypeEncoding.NSNUMBER == propertyType )
				{
					[result setObject:obj forKey:key];
				}
				else if ( HMTypeEncoding.NSSTRING == propertyType )
				{
					[result setObject:obj forKey:key];
				}
				else if ( HMTypeEncoding.NSARRAY == propertyType )
				{
					NSMutableArray * array = [NSMutableArray array];
					
					for ( NSObject * elem in (NSArray *)obj )
					{
						NSDictionary * dict = [elem objectToDictionaryUntilRootClass:rootClass];
						if ( dict )
						{
							[array addObject:dict];
						}
						else
						{
							if ( [HMTypeEncoding isAtomClass:[elem class]] )
							{
								[array addObject:elem];
							}
						}
					}
					
					[result setObject:array forKey:key];
				}
				else if ( HMTypeEncoding.NSDICTIONARY == propertyType )
				{
					NSMutableDictionary * dict = [NSMutableDictionary dictionary];
					
					for ( NSString * key in ((NSDictionary *)obj).allKeys )
					{
						NSObject * val = [(NSDictionary *)obj objectForKey:key];
						if ( val )
						{
							NSDictionary * subresult = [val objectToDictionaryUntilRootClass:rootClass];
							if ( subresult )
							{
								[dict setObject:subresult forKey:key];
							}
							else
							{
								if ( [HMTypeEncoding isAtomClass:[val class]] )
								{
									[dict setObject:val forKey:key];
								}
							}
						}
					}
					
					[result setObject:dict forKey:key];
				}
				else if ( HMTypeEncoding.NSDATE == propertyType )
				{
					[result setObject:[obj description] forKey:key];
				}
				else
				{
					obj = [obj objectToDictionaryUntilRootClass:rootClass];
					if ( obj )
					{
						[result setObject:obj forKey:key];
					}
					else
					{
						[result setObject:[NSDictionary dictionary] forKey:key];
					}
				}
			}
            //			else
            //			{
            //				[result setObject:[NSNull null] forKey:key];
            //			}
		}
	}
	else
	{
		for ( Class clazzType = [self class];; )
		{
			if ( rootClass )
			{
				if ( clazzType == rootClass )
					break;
			}
			else
			{
				if ( [HMTypeEncoding isAtomClass:clazzType] )
					break;
			}
            
			unsigned int		propertyCount = 0;
			objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
			
			for ( NSUInteger i = 0; i < propertyCount; i++ )
			{
				const char *	name = property_getName(properties[i]);
				const char *	attr = property_getAttributes(properties[i]);
				
				NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
				NSUInteger		propertyType = [HMTypeEncoding typeOf:attr];
                if ([@[@"superclass",@"isa",@"hash",@"debugDescription",@"description"] containsObject:propertyName]) {
                    continue;
                }
				NSObject * obj = [self valueForKey:propertyName];
				if ( obj )
				{
					if ( HMTypeEncoding.NSNUMBER == propertyType )
					{
						[result setObject:obj forKey:propertyName];
					}
					else if ( HMTypeEncoding.NSSTRING == propertyType )
					{
						[result setObject:obj forKey:propertyName];
					}
					else if ( HMTypeEncoding.NSARRAY == propertyType )
					{
						NSMutableArray * array = [NSMutableArray array];
						
						for ( NSObject * elem in (NSArray *)obj )
						{
							NSUInteger elemType = [HMTypeEncoding typeOfObject:elem];
							
							if ( HMTypeEncoding.NSNUMBER == elemType )
							{
								[array addObject:elem];
							}
							else if ( HMTypeEncoding.NSSTRING == elemType )
							{
								[array addObject:elem];
							}
							else
							{
								NSDictionary * dict = [elem objectToDictionaryUntilRootClass:rootClass];
								if ( dict )
								{
									[array addObject:dict];
								}
								else
								{
									if ( [HMTypeEncoding isAtomClass:[elem class]] )
									{
										[array addObject:elem];
									}
								}
							}
						}
						
						[result setObject:array forKey:propertyName];
					}
					else if ( HMTypeEncoding.NSDICTIONARY == propertyType )
					{
						NSMutableDictionary * dict = [NSMutableDictionary dictionary];
						
						for ( NSString * key in ((NSDictionary *)obj).allKeys )
						{
							NSObject * val = [(NSDictionary *)obj objectForKey:key];
							if ( val )
							{
								NSDictionary * subresult = [val objectToDictionaryUntilRootClass:rootClass];
								if ( subresult )
								{
									[dict setObject:subresult forKey:key];
								}
								else
								{
									if ( [HMTypeEncoding isAtomClass:[val class]] )
									{
										[dict setObject:val forKey:key];
									}
								}
							}
						}
						
						[result setObject:dict forKey:propertyName];
					}
					else if ( HMTypeEncoding.NSDATE == propertyType )
					{
						[result setObject:[obj description] forKey:propertyName];
					}
                    else if ( HMTypeEncoding.RLMARRAY == propertyType )
                    {
                        NSMutableArray * array = [NSMutableArray array];
                        NSArray *objA = (NSArray *)obj;
                        
                        for ( int a=0; a<objA.count;a++ )
                        {
                            NSObject * elem = [objA objectAtIndex:a];
                            
                            NSUInteger elemType = [HMTypeEncoding typeOfObject:elem];
                            
                            if ( HMTypeEncoding.NSNUMBER == elemType )
                            {
                                [array addObject:elem];
                            }
                            else if ( HMTypeEncoding.NSSTRING == elemType )
                            {
                                [array addObject:elem];
                            }
                            else
                            {
                                NSDictionary * dict = [elem objectToDictionaryUntilRootClass:rootClass];
                                if ( dict )
                                {
                                    [array addObject:dict];
                                }
                                else
                                {
                                    if ( [HMTypeEncoding isAtomClass:[elem class]] )
                                    {
                                        [array addObject:elem];
                                    }
                                }
                            }
                        }
                        
                        [result setObject:array forKey:propertyName];
                    }
					else
					{
						obj = [obj objectToDictionaryUntilRootClass:rootClass];
						if ( obj )
						{
							[result setObject:obj forKey:propertyName];
						}
						else
						{
							[result setObject:[NSDictionary dictionary] forKey:propertyName];
						}
					}
				}
                //				else
                //				{
                //					[result setObject:[NSNull null] forKey:propertyName];
                //				}
			}
			
			free( properties );
            
			clazzType = class_getSuperclass( clazzType );
			if ( nil == clazzType || clazzType == NSClassFromString(@"RLMObject"))
				break;
		}
	}
	
	return result.count ? result : nil;
}

- (id)objectToString
{
	return [self objectToStringUntilRootClass:nil];
}

- (id)objectToStringUntilRootClass:(Class)rootClass
{
	NSString *	json = nil;
	NSUInteger	propertyType = [HMTypeEncoding typeOfObject:self];
	
	if ( HMTypeEncoding.NSNUMBER == propertyType )
	{
		json = [self asNSString];
	}
	else if ( HMTypeEncoding.NSSTRING == propertyType )
	{
		json = [self asNSString];
	}
	else if ( HMTypeEncoding.NSARRAY == propertyType )
	{
		NSMutableArray * array = [NSMutableArray array];
        
		for ( NSObject * elem in (NSArray *)self )
		{
			NSDictionary * dict = [elem objectToDictionaryUntilRootClass:rootClass];
			if ( dict )
			{
				[array addObject:dict];
			}
			else
			{
				if ( [HMTypeEncoding isAtomClass:[elem class]] )
				{
					[array addObject:elem];
				}
			}
		}
        NSError *error ;
        NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
		json = [data asNSString];
	}
	else if ( HMTypeEncoding.NSDICTIONARY == propertyType )
	{
		NSDictionary * dict = [self objectToDictionaryUntilRootClass:rootClass];
		if ( dict )
		{
			NSError *error ;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
            json = [data asNSString];
		}
	}
	else if ( HMTypeEncoding.NSDATE == propertyType )
	{
		json = [self description];
	}
	else
	{
		NSDictionary * dict = [self objectToDictionaryUntilRootClass:rootClass];
		if ( dict )
		{
			NSError *error ;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
            json = [data asNSString];
		}
	}
    
	if ( nil == json || 0 == json.length )
		return nil;
	
	return [NSMutableString stringWithString:json];
}

- (id)objectToData
{
	return [self objectToDataUntilRootClass:nil];
}

- (id)objectToDataUntilRootClass:(Class)rootClass
{
	NSString * string = [self objectToStringUntilRootClass:rootClass];
	if ( nil == string )
		return nil;
    
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end
#pragma mark -

@implementation NSObject(HMRuntimeFormDict)

+ (id)objectFromAny:(id)any
{
	if ( [any isKindOfClass:[NSArray class]] )
	{
		return [self objectsFromArray:any];
	}
	else if ( [any isKindOfClass:[NSDictionary class]] )
	{
		return [self objectFromDictionary:any];
	}
	else if ( [any isKindOfClass:[NSString class]] )
	{
		return [self objectFromString:any];
	}
	else if ( [any isKindOfClass:[NSData class]] )
	{
		return [self objectFromData:any];
	}
	
	return any;
}
+ (id)objectFromString:(id)str
{
	if ( nil == str )
	{
		return nil;
	}
	
	if ( NO == [str isKindOfClass:[NSString class]] )
	{
		return nil;
	}
    
    if ( YES == [str isKindOfClass:[NSString class]] && [(NSString*)str length]==0)
    {
        return nil;
    }
    
    NSObject * obj = [NSJSONSerialization JSONObjectWithData:[str asNSData] options:0 error:nil];
	if ( nil == obj )
	{
		return nil;
	}
	
	if ( [obj isKindOfClass:[NSDictionary class]] )
	{
        if ([self class]==[NSDictionary class]) {
            return obj;
        }
		return [(NSDictionary *)obj objectForClass:[self class]];
	}
	else if ( [obj isKindOfClass:[NSArray class]] )
	{
		NSMutableArray * array = [NSMutableArray array];
		
		for ( NSObject * elem in (NSArray *)obj )
		{
			if ( [elem isKindOfClass:[NSDictionary class]] )
			{
				NSObject * result = [(NSDictionary *)elem objectForClass:[self class]];
				if ( result )
				{
					[array addObject:result];
				}
			}
		}
		
		return array;
	}
	else if ( [HMTypeEncoding isAtomClass:[obj class]] )
	{
		return obj;
	}
	
	return nil;
}

+ (id)objectFromData:(id)data
{
	if ( nil == data )
	{
		return nil;
	}
	
	if ( NO == [data isKindOfClass:[NSData class]] )
	{
		return nil;
	}
    
	NSObject * obj = [NSJSONSerialization isValidJSONObject:data]?[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]:nil;
	if ( obj && [obj isKindOfClass:[NSDictionary class]] )
	{
		return [(NSDictionary *)obj objectForClass:[self class]];
	}
	
	return nil;
}
+ (id)objectsFromArray:(id)arr
{
	if ( nil == arr )
		return nil;
	
	if ( NO == [arr isKindOfClass:[NSArray class]] )
		return nil;
    
	NSMutableArray * results = [NSMutableArray array];
    
	for ( NSObject __strong_type* obj in (NSArray *)arr )
	{
		if ( [obj isKindOfClass:[NSDictionary class]] )
		{
			obj = [self objectFromDictionary:obj];
			if ( obj )
			{
				[results addObject:obj];
			}
		}
		else
		{
			[results addObject:obj];
		}
	}
    
	return results;
}

+ (id)objectFromDictionary:(id)dict
{
	if ( nil == dict )
	{
		return nil;
	}
    
	if ( NO == [dict isKindOfClass:[NSDictionary class]] )
	{
		return nil;
	}
	
	return [(NSDictionary *)dict objectForClass:[self class]];
}

+ (void)pritfClassMethod{
    Class cls = [self class];
    CC(@"CLASS",@"%@>>>%s",cls,class_getName( class_getSuperclass(cls)));
    
    unsigned int outCount = 0;
    Method * methods = class_copyMethodList(cls, &outCount);
    for (int a=0; a<outCount; a++) {
        SEL sel = method_getName(methods[a]);
        CC(@"CLASS",@"%s",sel_getName(sel));
    }
}

@end

#pragma mark -

@implementation NSDictionary (HMRuntimeForClass)

- (BOOL)pritfMemberForClassName:(NSString*)name coding:(BOOL)coding numberAnalysis:(BOOL)analysis{
#if (__ON__ == __HM_DEVELOPMENT__)
    
    NSMutableString *deallocBody = [[NSMutableString alloc]init];
    NSMutableString *synthesizeBody = [[NSMutableString alloc]init];
    NSMutableString *propertyBody = [[NSMutableString alloc]init];
    NSMutableString *numberProBody = [[NSMutableString alloc]init];
    NSMutableString *numberSynBody = [[NSMutableString alloc]init];
    NSMutableString *codingBody = [[NSMutableString alloc]init];
    NSMutableString *encodingBody = [[NSMutableString alloc]init];
    if (coding) {
        [codingBody appendString:@"\n- (id)initWithCoder:(NSCoder *)decoder{\n\tif ((self = [super init])){\n"];
        [encodingBody appendString:@"\n- (void)encodeWithCoder:(NSCoder *)coder {\n"];
    }
    for (NSString *key in self.allKeys) {
        [synthesizeBody appendFormat:@"@synthesize %@;\n",key];
        [deallocBody appendFormat:@"\tself.%@=nil;\n",key];
        
        if (coding) {
            [codingBody appendFormat:@"\t\tself.%@ = [decoder decodeObjectForKey:NSStringFromSelector(@selector(%@))];\n",key,key];
            [encodingBody appendFormat:@"\t[coder encodeObject:self.%@ forKey:NSStringFromSelector(@selector(%@))];\n",key,key];
        }
        NSObject *object = [self objectForKey:key];
        
        NSString *semanteme = @"HM_STRONG";
        NSString *className = @"NSObject";
        BOOL isArray = NO;
        if ([object isKindOfClass:[NSArray class]]) {
            object = [(NSArray*)[self objectForKey:key] firstObject];
            className = @"NSArray";
            isArray = YES;
        }else if ([object isKindOfClass:[NSString class]]){
            semanteme = @"copy";
            className = @"NSString";
        }else if ([object isKindOfClass:[NSNumber class]]){
            className = @"NSNumber";
            if (analysis) {
                NSString *classType = @"";
                NSString *classTypeSuf = @"";
                NSString *classMethod = @"";
               
                const char * pObjCType = [((NSNumber*)object) objCType];
                if (strcmp(pObjCType, @encode(NSInteger))  == 0) {
                    classType = @"NSInteger";
                    classMethod = @"integerValue";
                    classTypeSuf = @"I";
                }else if (strcmp(pObjCType, @encode(NSUInteger))  == 0) {
                    classType = @"NSUInteger";
                    classMethod = @"unsignedIntegerValue";
                    classTypeSuf = @"UI";
                }else if (strcmp(pObjCType, @encode(int)) == 0) {
                    classType = @"int";
                    classMethod = @"intValue";
                    classTypeSuf = @"I";
                }else if (strcmp(pObjCType, @encode(unsigned int)) == 0) {
                    classType = @"unsigned int";
                    classMethod = @"unsignedIntValue";
                    classTypeSuf = @"UI";
                }else if (strcmp(pObjCType, @encode(long long)) == 0) {
                    classType = @"long long";
                    classMethod = @"longLongValue";
                    classTypeSuf = @"L";
                }else if (strcmp(pObjCType, @encode(float)) == 0) {
                    classType = @"CGFloat";
                    classMethod = @"floatValue";
                    classTypeSuf = @"F";
                }else if (strcmp(pObjCType, @encode(double))  == 0) {
                    classType = @"double";
                    classMethod = @"doubleValue";
                    classTypeSuf = @"D";
                }else if (strcmp(pObjCType, @encode(BOOL)) == 0) {
                    classType = @"BOOL";
                    classMethod = @"boolValue";
                    classTypeSuf = @"B";
                }
                [numberProBody appendFormat:@"@property (nonatomic, assign)  %@ \t\t%@%@;\n",classType,key,classTypeSuf];
                [numberSynBody appendFormat:@"\n@synthesize %@%@ = _%@%@;\n- (%@)%@%@{\n\t_%@%@=[self.%@ %@];\n\treturn _%@%@;\n}\n",key,classTypeSuf,key,classTypeSuf,classType,key,classTypeSuf,key,classTypeSuf,key,classMethod,key,classTypeSuf];
            }
        }else if ([object isKindOfClass:[NSNull class]]){
            className = @"<#null#>";
        }
        if ([object isKindOfClass:[NSDictionary class]]){
            [synthesizeBody appendFormat:@"DEF_CONVERTPROPERTY_2_CLASS(%@, [%@ class])\n",key,key];
            if (!isArray) {
                className = key;
            }
            
        }
        [propertyBody appendFormat:@"@property (nonatomic,%@)  %@ *\t\t%@;\n",semanteme,className,key];
        if ([object isKindOfClass:[NSDictionary class]]) {
            
            [(NSDictionary*)object pritfMemberForClassName:key coding:coding numberAnalysis:analysis];
            
        }
    }
    if (coding) {
        [codingBody appendString:@"\n\t}\n\treturn self;\n}\n"];
        [encodingBody appendString:@"\n}\n"];
    }
    
    CC( @"ClassPrintf",
       @"\n#pragma mark - %@\n@interface %@ : NSObject %@\n%@%@\n@end\n\n#pragma mark - %@\n@implementation %@\n%@\n- (void)dealloc\n{\n%@\n\tHM_SUPER_DEALLOC();\n}\n%@%@%@\n@end",name,
       name,coding?@"<NSCoding>":@"",propertyBody,analysis?numberProBody:@"",
       name,name,synthesizeBody,
       deallocBody,
       analysis?numberSynBody:@"",coding?codingBody:@"",coding?encodingBody:@"");
    
    
#if  __has_feature(objc_arc)
    
#else
    [deallocBody release];
    [synthesizeBody release];
    [propertyBody release];
    [codingBody release];
    [encodingBody release];
    [numberProBody release];
    [numberSynBody release];
#endif
    
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    return YES;
}



// thanks to @ilikeido
- (id)objectForClass:(Class)clazz
{
    if ( [clazz respondsToSelector:NSSelectorFromString(@"initFromDictionary:")] )
	{
        return [clazz performSelector:NSSelectorFromString(@"initFromDictionary:") withObject:self];
    }
    
	if ( [clazz respondsToSelector:NSSelectorFromString(@"fromDictionary:")] )
	{
        return [clazz performSelector:NSSelectorFromString(@"fromDictionary:") withObject:self];
    }
    
    id object = [[clazz alloc] init];
	if ( nil == object )
		return nil;
    
	for ( Class clazzType = clazz; clazzType != [NSObject class]; )
	{
		unsigned int		propertyCount = 0;
		objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
		
		for ( NSUInteger i = 0; i < propertyCount; i++ )
		{
            /*获取对象属性名*/
			const char *	name = property_getName(properties[i]);
			NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
			const char *	attr = property_getAttributes(properties[i]);
            /*获取属性类型*/
			NSUInteger		type = [HMTypeEncoding typeOf:attr];
//            NSRange alias = [propertyName rangeOfString:@"__as"];
            NSString *property = propertyName;
            
            /*如果类中存在需要别名的属性，而且需要转化的数据中没有与类别名同样的属性，则进行别名匹配*/
//            if (alias.location!=NSNotFound&&![self.allKeys containsObject:property]) {
//                property = [propertyName substringToIndex:alias.location];
//            }else if (alias.location!=NSNotFound){
//                
//            }
            
            /*获取是否需要名称重定向*/
            SEL redirectSelector = NSSelectorFromString( [NSString stringWithFormat:@"redirectPropertyAliasFor_%@", property] );
            if ( [object respondsToSelector:redirectSelector] )
            {
                NSArray *propertys = [object performSelector:redirectSelector];
                for (NSString *kk in propertys) {
                    if ([self.allKeys containsObject:kk]&&![self.allKeys containsObject:property]) {
                        property = kk;
                        break;
                    }
                }
            }
            
            /*获取是否需要名称强制重定向*/
            SEL redirectForceSelector = NSSelectorFromString( [NSString stringWithFormat:@"redirectPropertyAliasForceFor_%@", property] );
            if ( [object respondsToSelector:redirectForceSelector] )
            {
                NSArray *propertys = [object performSelector:redirectForceSelector];
                for (NSString *kk in propertys) {
                    if ([self.allKeys containsObject:kk]) {
                        property = kk;
                        break;
                    }
                }
            }
            
			NSObject *	tempValue = [self objectForKey:property];
			NSObject *	value = nil;
			
			if ( tempValue )
			{
				if ( HMTypeEncoding.NSNUMBER == type )
				{
					value = [tempValue asNSNumber];
				}
				else if ( HMTypeEncoding.NSSTRING == type )
				{
					value = [tempValue asNSString];
				}
				else if ( HMTypeEncoding.NSDATE == type )
				{
					value = [tempValue asNSDate];
				}
				else if ( HMTypeEncoding.NSARRAY == type )
				{
                    /**
                     *  有可能数组被转译成字符串存放在json中
                     */
                    if ([tempValue isKindOfClass:[NSString class]]) {
                        NSArray *dic = [NSArray objectFromString:tempValue];
                        if (dic) {
                            tempValue = dic;
                        }
                    }
					if ( [tempValue isKindOfClass:[NSArray class]] )
					{
						SEL convertSelector = NSSelectorFromString( [NSString stringWithFormat:@"convertPropertyClassFor_%@", propertyName] );
						if ( [object respondsToSelector:convertSelector] )
						{
							Class convertClass = [object performSelector:convertSelector];
							if ( convertClass )
							{
								NSMutableArray * arrayTemp = [NSMutableArray array];
                                
								for ( NSObject * tempObject in (NSArray *)tempValue )
								{
									if ( [tempObject isKindOfClass:[NSDictionary class]] )
									{
										[arrayTemp addObject:[(NSDictionary *)tempObject objectForClass:convertClass]];
									}
								}
								
								value = arrayTemp;
							}
							else
							{
								value = tempValue;
							}
						}
						else
						{
							value = tempValue;
						}
					}
				}
				else if ( HMTypeEncoding.NSDICTIONARY == type )
				{
                    /**
                     *  有可能对象被转译成字符串存放在json中
                     */
                    if ([tempValue isKindOfClass:[NSString class]]) {
                        NSDictionary *dic = [NSDictionary objectFromString:tempValue];
                        if (dic) {
                            tempValue = dic;
                        }
                    }
					if ( [tempValue isKindOfClass:[NSDictionary class]] )
					{
						SEL convertSelector = NSSelectorFromString( [NSString stringWithFormat:@"convertPropertyClassFor_%@", propertyName] );
						if ( [object respondsToSelector:convertSelector] )
						{
							Class convertClass = [object performSelector:convertSelector];
							if ( convertClass )
							{
								value = [(NSDictionary *)tempValue objectForClass:convertClass];
							}
							else
							{
								value = tempValue;
							}
						}
						else
						{
							value = tempValue;
						}
					}
                }else if ( HMTypeEncoding.RLMARRAY == type )
                {
                    SEL convertSelector = NSSelectorFromString( [NSString stringWithFormat:@"convertPropertyClassFor_%@", propertyName] );
                    if ( [object respondsToSelector:convertSelector] )
                    {
                        Class convertClass = [object performSelector:convertSelector];
                        if ( convertClass )
                        {
                            NSMutableArray * arrayTemp = [object performSelector:NSSelectorFromString(propertyName)];//[NSMutableArray array];
                            
                            for ( NSObject * tempObject in (NSArray *)tempValue )
                            {
                                if ( [tempObject isKindOfClass:[NSDictionary class]] )
                                {
                                    [arrayTemp addObject:[(NSDictionary *)tempObject objectForClass:convertClass]];
                                }
                            }
                            
//                            value = arrayTemp;
                        }
                        else
                        {
                            value = tempValue;
                        }
                    }
                    else
                    {
                        value = tempValue;
                    }
                }
				else if ( HMTypeEncoding.OBJECT == type )
				{
                    /**
                     *  获取属性声明的类名
                     */
					NSString * className = [HMTypeEncoding classNameOfAttribute:attr];
					if ( [tempValue isKindOfClass:NSClassFromString(className)] )
					{
						value = tempValue;
                        
                    }else {
                        
                        if ([tempValue isKindOfClass:[NSString class]]){
                            
                            NSDictionary *dic = [NSDictionary objectFromString:tempValue];
                            if (dic) {
//                                CC(@"Runtime",dic);
                                tempValue = dic;
                            }
                        }
                        
                        if ( [tempValue isKindOfClass:[NSDictionary class]] )
                        {
                            value = [(NSDictionary *)tempValue objectForClass:NSClassFromString(className)];
//                            CC(@"Runtime",NSClassFromString(className),@"is",[value class]);
                        }
                    }
				}
			}
            if (value) {
                [object setValue:value forKey:propertyName];
            }
		}
		
		free( properties );
        
		clazzType = class_getSuperclass( clazzType );
		if ( nil == clazzType)
			break;
	}
    
    
#if  __has_feature(objc_arc)
    return object;
#else
    return [object autorelease];
#endif
}


@end
