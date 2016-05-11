
#import "HMStorage.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSObject(HMDatabase)

+ (HMDatabase *)DB
{
	HMDatabase * db = [HMDatabase sharedDatabase];
	if ( nil == db )
	{
		NSBundle * bundle = [NSBundle mainBundle];
		NSString * bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
		if ( nil == bundleName )
		{
			bundleName = @"default";
		}
        
		NSString * dbName = [NSString stringWithFormat:@"%@.sqlite", bundleName];
		BOOL succeed = [HMDatabase openSharedDatabase:dbName];
		if ( succeed )
		{
			db = [HMDatabase sharedDatabase];
		}
        
		if ( db )
		{
			[db clearState];
		}
	}
	return db;
}

- (HMDatabase *)DB
{
	return [NSObject DB];
}

- (NSString *)tableName
{
	return [[self class] tableName];
}

+ (NSString *)tableName
{
	return [HMDatabase tableNameForClass:self];
}

@end
