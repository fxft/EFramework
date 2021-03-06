
#import "HMDatabase.h"
#import "FMDatabase.h"
#import "HMActiveProtocol.h"
#import "HMFoundation.h"
// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@interface HMDatabase()
{
	BOOL					_autoOptimize;	// TO BE DONE
	BOOL					_batch;
	NSUInteger				_identifier;
	NSString *				_filePath;
	
	BOOL					_shadow;
	FMDatabase *			_database;
	
	NSMutableArray *		_select;
	BOOL					_distinct;
	NSMutableArray *		_from;
	NSMutableArray *		_where;
	NSMutableArray *		_like;
	NSMutableArray *		_groupby;
	NSMutableArray *		_having;
	NSMutableArray *		_keys;
	NSUInteger				_limit;
	NSUInteger				_offset;
	NSMutableArray *		_orderby;
	NSMutableDictionary *	_set;
	
	NSMutableArray *		_resultArray;
	NSUInteger				_resultCount;
	NSInteger				_lastInsertID;
	BOOL					_lastSucceed;
	
	NSMutableArray *		_table;
	NSMutableArray *		_field;
	NSMutableArray *		_index;
	
	NSMutableArray *		_classType;
	NSMutableArray *		_associate;
	NSMutableArray *		_has;
	
	NSTimeInterval			_lastQuery;
	NSTimeInterval			_lastUpdate;
}

+ (NSString *)fieldNameForIdentifier:(NSString *)identifier;
+ (NSString *)tableNameForIdentifier:(NSString *)identifier;

- (void)initSelf;
- (NSString *)internalCreateAliasFromTable:(NSString *)name;
- (void)internalGroupBy:(NSString *)by;
- (void)internalSelect:(NSString *)select alias:(NSString *)alias type:(NSString *)type;
- (void)internalWhere:(NSString *)key expr:(NSString *)expr value:(NSObject *)value type:(NSString *)type;
- (void)internalLike:(NSString *)field match:(NSObject *)match type:(NSString *)type side:(NSString *)side invert:(BOOL)invert;
- (void)internalHaving:(NSString *)key value:(NSObject *)value type:(NSString *)type;
- (void)internalOrderBy:(NSString *)by direction:(NSString *)direction;

- (NSString *)internalCompileInsert:(NSString *)table values:(NSMutableArray *)values;
- (NSString *)internalCompileReplace:(NSString *)table values:(NSMutableArray *)allValues;
- (NSString *)internalCompileUpdate:(NSString *)table values:(NSMutableArray *)values;
- (NSString *)internalCompileSelect:(NSString *)override;
- (NSString *)internalCompileCreate:(NSString *)table;
- (NSString *)internalCompileDelete:(NSString *)table;
- (NSString *)internalCompileEmpty:(NSString *)table;
- (NSString *)internalCompileTrunc:(NSString *)table;
- (NSString *)internalCompileIndex:(NSString *)table;
- (NSString *)internalCompileExist:(NSString *)table as:(NSString *)value;

// create

- (HMDatabase *)table:(NSString *)name;
- (HMDatabase *)field:(NSString *)name type:(NSString *)type size:(NSUInteger)size;
- (HMDatabase *)unsignedType;
- (HMDatabase *)notNull;
- (HMDatabase *)primaryKey;
- (HMDatabase *)autoIncrement;
- (HMDatabase *)defaultZero;
- (HMDatabase *)defaultNull;
- (HMDatabase *)defaultValue:(id)value;
- (HMDatabase *)unique;
- (BOOL)createTableIfNotExists;
- (BOOL)createTableIfNotExists:(NSString *)table;
- (BOOL)indexTable:(NSString *)table on:(NSArray *)fields;
- (BOOL)existsTable:(NSString *)table;

// select

- (HMDatabase *)select:(NSString *)select;
- (HMDatabase *)selectMax:(NSString *)select;
- (HMDatabase *)selectMax:(NSString *)select alias:(NSString *)alias;
- (HMDatabase *)selectMin:(NSString *)select;
- (HMDatabase *)selectMin:(NSString *)select alias:(NSString *)alias;
- (HMDatabase *)selectAvg:(NSString *)select;
- (HMDatabase *)selectAvg:(NSString *)select alias:(NSString *)alias;
- (HMDatabase *)selectSum:(NSString *)select;
- (HMDatabase *)selectSum:(NSString *)select alias:(NSString *)alias;

- (HMDatabase *)distinct:(BOOL)flag;
- (HMDatabase *)from:(NSString *)from;

- (HMDatabase *)where:(NSString *)key value:(id)value;
- (HMDatabase *)orWhere:(NSString *)key value:(id)value;
- (HMDatabase *)where:(NSString *)key expr:(NSString *)expr value:(id)value;
- (HMDatabase *)orWhere:(NSString *)key expr:(NSString *)expr value:(id)value;

- (HMDatabase *)whereIn:(NSString *)key values:(NSArray *)values;
- (HMDatabase *)orWhereIn:(NSString *)key values:(NSArray *)values;
- (HMDatabase *)whereNotIn:(NSString *)key values:(NSArray *)values;
- (HMDatabase *)orWhereNotIn:(NSString *)key values:(NSArray *)values;

- (HMDatabase *)like:(NSString *)field match:(id)value;
- (HMDatabase *)notLike:(NSString *)field match:(id)value;
- (HMDatabase *)orLike:(NSString *)field match:(id)value;
- (HMDatabase *)orNotLike:(NSString *)field match:(id)value;

- (HMDatabase *)groupBy:(NSString *)by;

- (HMDatabase *)having:(NSString *)key value:(id)value;
- (HMDatabase *)orHaving:(NSString *)key value:(id)value;

- (HMDatabase *)orderAscendBy:(NSString *)by;
- (HMDatabase *)orderDescendBy:(NSString *)by;
- (HMDatabase *)orderRandomBy:(NSString *)by;
- (HMDatabase *)orderBy:(NSString *)by direction:(NSString *)direction;

- (HMDatabase *)limit:(NSUInteger)limit;
- (HMDatabase *)offset:(NSUInteger)offset;

- (HMDatabase *)classInfo:(id)obj;

// write

- (HMDatabase *)set:(NSString *)key;
- (HMDatabase *)set:(NSString *)key value:(id)value;

- (NSArray *)get;
- (NSArray *)get:(NSString *)table;
- (NSArray *)get:(NSString *)table limit:(NSUInteger)limit;
- (NSArray *)get:(NSString *)table limit:(NSUInteger)limit offset:(NSUInteger)offset;

- (NSUInteger)count;
- (NSUInteger)count:(NSString *)table;

- (NSInteger)insert;
- (NSInteger)insert:(NSString *)table;

- (BOOL)replace;
- (BOOL)replace:(NSString *)table;

- (BOOL)update;
- (BOOL)update:(NSString *)table;

- (BOOL)empty;
- (BOOL)empty:(NSString *)table;

- (BOOL)truncate;
- (BOOL)truncate:(NSString *)table;

- (BOOL)delete;
- (BOOL)delete:(NSString *)table;

// active record

- (void)classType:(Class)clazz;
- (void)associate:(NSObject *)obj;
- (void)has:(NSObject *)obj;

@end

#pragma mark -

@implementation HMDatabase

@dynamic autoOptimize;
@dynamic ready;
@dynamic total;
@synthesize shadow = _shadow;
@synthesize database = _database;
@synthesize filePath = _filePath;
@synthesize identifier = _identifier;

@dynamic TABLE;
@dynamic FIELD;
@dynamic FIELD_WITH_SIZE;
@dynamic UNSIGNED;
@dynamic NOT_NULL;
@dynamic PRIMARY_KEY;
@dynamic AUTO_INREMENT;
@dynamic DEFAULT_ZERO;
@dynamic DEFAULT_NULL;
@dynamic DEFAULT;
@dynamic UNIQUE;
@dynamic CREATE_IF_NOT_EXISTS;
@dynamic INDEX_ON;

@dynamic SELECT;
@dynamic SELECT_MAX;
@dynamic SELECT_MAX_ALIAS;
@dynamic SELECT_MIN;
@dynamic SELECT_MIN_ALIAS;
@dynamic SELECT_AVG;
@dynamic SELECT_AVG_ALIAS;
@dynamic SELECT_SUM;
@dynamic SELECT_SUM_ALIAS;

@dynamic DISTINCT;
@dynamic FROM;

@dynamic WHERE;
@dynamic OR_WHERE;

@dynamic WHERE_OPERATOR;
@dynamic OR_WHERE_OPERATOR;

@dynamic WHERE_IN;
@dynamic OR_WHERE_IN;
@dynamic WHERE_NOT_IN;
@dynamic OR_WHERE_NOT_IN;

@dynamic LIKE;
@dynamic NOT_LIKE;
@dynamic OR_LIKE;
@dynamic OR_NOT_LIKE;

@dynamic GROUP_BY;

@dynamic HAVING;
@dynamic OR_HAVING;

@dynamic ORDER_ASC_BY;
@dynamic ORDER_DESC_BY;
@dynamic ORDER_RAND_BY;
@dynamic ORDER_BY;

@dynamic LIMIT;
@dynamic OFFSET;

@dynamic SET;
@dynamic SET_NULL;

@dynamic GET;
@dynamic COUNT;

@dynamic INSERT;
@dynamic UPDATE;
@dynamic EMPTYTABLE;
@dynamic TRUNCATE;
@dynamic DELETE;

@dynamic BATCH_BEGIN;
@dynamic BATCH_END;

@dynamic CLASS_TYPE;
@dynamic ASSOCIATE;
@dynamic HAS;

@dynamic resultArray;
@dynamic resultCount;
@dynamic insertID;
@dynamic succeed;

@synthesize lastQuery = _lastQuery;
@synthesize lastUpdate = _lastUpdate;

DEF_NOTIFICATION( SHARED_DB_OPEN )
DEF_NOTIFICATION( SHARED_DB_CLOSE )

static NSMutableArray *	__shadowDBs = nil;
static HMDatabase *	__sharedDB = nil;
static NSUInteger		__identSeed = 1;

#pragma mark -

- (NSArray *)resultArray
{
	[self __internalResetSelect];
	[self __internalResetWrite];
	[self __internalResetCreate];
    
    //	[self __internalResetResult];
    
	return [[[NSMutableArray alloc] initWithArray:_resultArray] autorelease];
}

- (NSUInteger)resultCount
{
	[self __internalResetSelect];
	[self __internalResetWrite];
	[self __internalResetCreate];
	
	return _resultCount;
}

- (NSInteger)insertID
{
	[self __internalResetSelect];
	[self __internalResetWrite];
	[self __internalResetCreate];

	return _lastInsertID;
}

- (BOOL)succeed
{
	[self __internalResetSelect];
	[self __internalResetWrite];
	[self __internalResetCreate];

	return _lastSucceed;
}

- (NSUInteger)total
{
	NSUInteger count = [self count];
	
	[self __internalResetSelect];
	[self __internalResetWrite];
	[self __internalResetCreate];

	return count;
}

#pragma mark -

+ (BOOL)openSharedDatabase:(NSString *)path
{
	if ( __sharedDB.ready && [__sharedDB.filePath isEqualToString:path] )
		return YES;

	[self closeSharedDatabase];

	__sharedDB = [[[self class] alloc] initWithPath:path];
	if ( __sharedDB )
	{
		if ( NO == __sharedDB.ready )
		{
            [__sharedDB release];
            __sharedDB = nil;
		}
	}

	BOOL succeed = (__sharedDB && __sharedDB.ready) ? YES : NO;
	if ( succeed )
	{
		[self postNotification:self.SHARED_DB_OPEN];
	}
	return succeed;
}

+ (BOOL)existsSharedDatabase:(NSString *)path
{
	return [HMDatabase exists:path];
}

+ (void)closeSharedDatabase
{
	if ( __shadowDBs )
	{
		for ( HMDatabase * db in __shadowDBs )
		{
			[db close];
		}
		
		[__shadowDBs removeAllObjects];
        [__shadowDBs release];
        __shadowDBs = nil;
	}

	[__sharedDB close];
    [__sharedDB release];
    __sharedDB = nil;
    
	[self postNotification:self.SHARED_DB_CLOSE];
}

+ (void)setSharedDatabase:(HMDatabase *)db
{
	if ( db != __sharedDB )
	{
		[self postNotification:self.SHARED_DB_CLOSE];

        [db retain];
		if ( __shadowDBs )
		{
			for ( HMDatabase * db in __shadowDBs )
			{
				[db close];
			}
			
			[__shadowDBs removeAllObjects];
            [__shadowDBs release];
            __shadowDBs=nil;
		}
		
		[__sharedDB close];
        [__sharedDB release];
		__sharedDB = db;

		[self postNotification:self.SHARED_DB_OPEN];
	}
}

+ (HMDatabase *)sharedDatabase
{
	if ( __shadowDBs.count )
	{
		return (HMDatabase *)__shadowDBs.lastObject;
	}

	return __sharedDB;
}

+ (void)scopeEnter
{
	if ( __sharedDB )
	{
		HMDatabase * db = [[HMDatabase alloc] initWithDatabase:__sharedDB.database];
		if ( db )
		{
			db.shadow = YES;
			
			if ( nil == __shadowDBs )
			{
				__shadowDBs = [[NSMutableArray alloc] init];
			}
			
			[__shadowDBs addObject:db];
			
            [db release];
		}
	}
}

+ (void)scopeLeave
{
	if ( __shadowDBs && __shadowDBs.count )
	{
		[__shadowDBs removeObject:__shadowDBs.lastObject];		
	}
}

#pragma mark -

- (void)initSelf
{
    _logable = YES;
	_select = [[NSMutableArray alloc] init];
	_distinct = NO;
	_from = [[NSMutableArray alloc] init];
	_where = [[NSMutableArray alloc] init];
	_like = [[NSMutableArray alloc] init];
	_groupby = [[NSMutableArray alloc] init];
	_having = [[NSMutableArray alloc] init];
	_keys = [[NSMutableArray alloc] init];
	_limit = 0;
	_offset = 0;
	_orderby = [[NSMutableArray alloc] init];
	_set = [[NSMutableDictionary alloc] init];
	_classType = [[NSMutableArray alloc] init];
	
	_associate = [[NSMutableArray nonRetainingArray] retain];
    _has = [[NSMutableArray nonRetainingArray] retain];
	
	_table = [[NSMutableArray alloc] init];
	_field = [[NSMutableArray alloc] init];
	_index = [[NSMutableArray alloc] init];
	
	_resultArray = [[NSMutableArray alloc] init];
	_resultCount = 0;
	
	_identifier = __identSeed++;
	
	_lastQuery = [NSDate timeIntervalSinceReferenceDate];
	_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
}

- (NSString *)fullFilePath{
    return self.database.databasePath;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
		[self initSelf];
	}
	return self;
}

- (id)initWithDatabase:(FMDatabase *)db
{
	self = [super init];
	if ( self )
	{
		[self initSelf];
//#if (__ON__ == __HM_LOG_DATABASE__)
//		if(self.logable)CC(@"DB",@" open shadow '%p'", db );
//#endif
		self.database = db;
		self.filePath = db.databasePath;
	}
	return self;
}

- (id)initWithPath:(NSString *)path
{
	self = [super init];
	if ( self )
	{
		[self initSelf];
		[self open:path];
	}
	return self;
}

- (void)dealloc
{
	[self close];
	
	[_database release];
    
	[_filePath release];
    
	[_select removeAllObjects];
    [_select release];
    
	[_from removeAllObjects];
    [_from release];
	
	[_where removeAllObjects];
    [_where release];
	
	[_like removeAllObjects];
    [_like release];
	
	[_groupby removeAllObjects];
    [_groupby release];
	
	[_having removeAllObjects];
    [_having release];
	
	[_keys removeAllObjects];
    [_keys release];
    
	[_orderby removeAllObjects];
    [_orderby release];
	
	[_set removeAllObjects];
    [_set release];
	
	[_field removeAllObjects];
    [_field release];
	
	[_table removeAllObjects];
    [_table release];
	
	[_index removeAllObjects];
    [_index release];
	
	[_resultArray removeAllObjects];
    [_resultArray release];
	
	[_classType removeAllObjects];
    [_classType release];
	
	[_associate removeAllObjects];
    [_associate release];
	
	[_has removeAllObjects];
    [_has release];
    
	HM_SUPER_DEALLOC();
}

#pragma mark -

+ (NSString *)sqliteFileName:(NSString *)path
{
	BOOL isFullPath = [path rangeOfString:@"/"].length > 0 ? YES : NO;
    if ( isFullPath )
	{
		return path;
	}
	else
	{
		NSString * fullPath = [NSString stringWithFormat:@"%@/Database/", [HMSandbox docPath]];
		if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:NULL] )
		{
			BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath
												 withIntermediateDirectories:YES
																  attributes:nil
																	   error:nil];
			if ( NO == ret )
				return nil;
		}
		
		return [fullPath stringByAppendingPathComponent:path];
    }
}

+ (BOOL)exists:(NSString *)path;
{
	NSString * fullName = [HMDatabase sqliteFileName:path];
	if ( nil == fullName )
		return NO;
	
	BOOL isDirectory = NO;
	BOOL returnValue = [[NSFileManager defaultManager] fileExistsAtPath:fullName isDirectory:&isDirectory];
	if ( NO == returnValue || YES == isDirectory )
		return NO;
	
	return YES;
}

- (BOOL)ready
{
	if ( nil == _database )
		return NO;
	
	return _database.open;
}

- (BOOL)open:(NSString *)path
{
	if ( _filePath && [_filePath isEqualToString:path] )
		return YES;
	
	[self close];
	
	NSString * fullName = [HMDatabase sqliteFileName:path];
	if ( nil == fullName )
		return NO;
	
#if (__ON__ == __HM_LOG_DATABASE__)
    if(self.logable)CC( @"DB",@"open '%@'", fullName);
#endif	// #if (__ON__ == __HM_LOG_DATABASE__)
	
	_database = [[FMDatabase alloc] initWithPath:fullName];
    if ( nil == _database )
		return NO;
	
	BOOL ret = [_database open];
	if ( NO == ret )
	{
		[_database release];
        _database = nil;
	}
	else
	{
#if defined(__HM_LOG_DATABASE__) && __HM_LOG_DATABASE__
//		[_database setShouldCacheStatements:YES];
//		_database.crashOnErrors = YES;
		_database.traceExecution = YES;
		_database.logsErrors = YES;
#endif	// #if defined(__HM_LOG_DATABASE__) && __HM_LOG_DATABASE__
		
		self.filePath = path;
	}
	
	return ret;
}

- (void)close
{
	if ( _database )
	{
		if ( NO == _shadow )
		{

#if (__ON__ == __HM_LOG_DATABASE__)
            if(self.logable)CC( @"DB",@"close '%p'", _database );
#endif	// #if (__ON__ == __HM_LOG_DATABASE__)
			[_database close];
		}
//		else
//		{
//#if (__ON__ == __HM_LOG_DATABASE__)
//			if(self.logable)CC(@"DB",@" close shadow '%p'", _database );
//#endif
//		}
		
		[_database release];
        _database = nil;

	}
	
	_lastQuery = [NSDate timeIntervalSinceReferenceDate];
	_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
}

- (void)clearState
{
	[self __internalResetCreate];
	[self __internalResetWrite];
	[self __internalResetSelect];
}

#pragma mark -

- (HMDatabase *)table:(NSString *)name
{
	if ( nil == _database )
		return self;

	if ( nil == name )
		return self;
    
	name = [HMDatabase tableNameForIdentifier:name];
	
	for ( NSString * table in _table )
	{
		if ( NSOrderedSame == [table compare:name options:NSCaseInsensitiveSearch] )
			return self;
	}
    
	[_table addObject:name];
	return self;
}

- (HMDatabase *)field:(NSString *)name type:(NSString *)type size:(NSUInteger)size
{
	if ( nil == _database )
		return self;

	BOOL found = NO;

	for ( NSMutableDictionary * dict in _field )
	{
		NSString * existName = [dict objectForKey:@"name"];
		if ( NSOrderedSame == [existName compare:name options:NSCaseInsensitiveSearch] )
		{
			if ( type )
			{
				[dict setObject:type forKey:@"type"];
			}

			if ( size )
			{
				[dict setObject:[NSNumber numberWithUnsignedLongLong:size] forKey:@"size"];
			}

			found = YES;
			break;
		}
	}

	if ( NO == found )
	{
		NSMutableDictionary * dict = [NSMutableDictionary dictionary];
		[dict setObject:name forKey:@"name"];
		[dict setObject:(type ? type : @"INT") forKey:@"type"];
		[dict setObject:[NSNumber numberWithUnsignedLongLong:size] forKey:@"size"];
		[_field addObject:dict];
	}
	
	return self;
}

- (HMDatabase *)unsignedType
{
	if ( nil == _database )
		return self;
    
	NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
	if ( nil == dict )
		return self;
	
	[dict setObject:__INT(1) forKey:@"unsigned"];
	return self;
}

- (HMDatabase *)notNull
{
	if ( nil == _database )
		return self;
    
	NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
	if ( nil == dict )
		return self;
	
	[dict setObject:__INT(1) forKey:@"notNull"];
	return self;
}

- (HMDatabase *)primaryKey
{
	if ( nil == _database )
		return self;
    
	NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
	if ( nil == dict )
		return self;
	
	[dict setObject:__INT(1) forKey:@"primaryKey"];
	return self;
}

- (HMDatabase *)autoIncrement
{
	if ( nil == _database )
		return self;
	
	NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
	if ( nil == dict )
		return self;
	
	[dict setObject:__INT(1) forKey:@"autoIncrement"];
	return self;
}

- (HMDatabase *)defaultZero
{
	return [self defaultValue:__INT(0)];
}

- (HMDatabase *)defaultNull
{
	return [self defaultValue:[NSNull null]];
}

- (HMDatabase *)defaultValue:(id)value
{
	if ( nil == _database )
		return self;
    
	NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
	if ( nil == dict )
        return self;
    
	[dict setObject:value forKey:@"default"];
	return self;
}

- (HMDatabase *)unique
{
	if ( nil == _database )
		return self;
	
	NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
	if ( nil == dict )
		return self;
	
	[dict setObject:__INT(1) forKey:@"unique"];
	return self;
}

#pragma mark -

- (BOOL)createTableIfNotExists
{
	return [self createTableIfNotExists:nil];
}

- (BOOL)createTableIfNotExists:(NSString *)table
{
	[self __internalResetResult];
	
	if ( nil == _database )
		return NO;
    
	if ( nil == table )
	{
		if ( 0 == _table.count )
			return NO;

		table = (NSString *)_table.lastObject;
	}
	else
	{
		table = [HMDatabase tableNameForIdentifier:table];
	}

	if ( nil == table || 0 == table.length )
		return NO;
	
	if ( 0 == _field.count )
		return NO;
    
	PERF_MARK(a);
	
	NSString * sql = [self internalCompileCreate:table];
	[self __internalResetCreate];
	
	BOOL ret = [_database executeUpdate:sql];
	if ( ret )
	{
		_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
		_lastSucceed = YES;
	}
	
	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC( @"DB" ,@"%s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return ret;
}

#pragma mark -

- (BOOL)indexTable:(NSString *)table on:(NSArray *)fields
{
	[self __internalResetResult];
	
	if ( nil == _database )
		return NO;
    
	if ( nil == fields || 0 == fields.count )
		return NO;
    
	if ( nil == table )
	{
		if ( 0 == _table.count )
			return NO;

		table = (NSString *)_table.lastObject;
	}
	else
	{
		table = [HMDatabase tableNameForIdentifier:table];
	}

	if ( nil == table || 0 == table.length )
		return NO;
	
	for ( NSString * field in fields )
	{
		[_index addObject:field];
	}
    
	if ( 0 == _index.count )
		return NO;
	
	PERF_MARK(a);
	
	NSString * sql = [self internalCompileIndex:table];
	[self __internalResetCreate];
	
	BOOL ret = [_database executeUpdate:sql];
	if ( ret )
	{
		_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
		_lastSucceed = YES;
	}
	
	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC( @"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return ret;
}

#pragma mark -

- (BOOL)existsTable:(NSString *)table
{
	if ( nil == table )
		return NO;
	
	BOOL succeed = NO;
	BOOL exists = NO;

	if ( nil == table )
	{
		if ( 0 == _table.count )
			return NO;
		
		table = (NSString *)_table.lastObject;
	}
	else
	{
		table = [HMDatabase tableNameForIdentifier:table];
	}

	if ( nil == table || 0 == table.length )
		return NO;
	
	PERF_MARK(a);
	
	NSString * sql = [self internalCompileExist:table as:@"numrows"];

	FMResultSet * result = [_database executeQuery:sql];
	if ( result )
	{
		succeed = [result next];
		if ( succeed )
		{
			NSDictionary * dict = nil;
			
			if ( [result respondsToSelector:@selector(resultDictionary)] )
			{
				dict = [result resultDictionary];
			}
			else if ( [result respondsToSelector:@selector(resultDict)] )
			{
				dict = [result performSelector:@selector(resultDict)];
			}

			if ( dict )
			{
				NSNumber * numrows = [dict objectForKey:@"numrows"];
				if ( numrows )
				{
					exists = numrows.intValue ? YES : NO;
				}
			}
		}
		
		if ( succeed )
		{
			_lastQuery = [NSDate timeIntervalSinceReferenceDate];
		}
	}
	
	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return exists;
}

#pragma mark -

- (HMDatabase *)select:(NSString *)select
{
	if ( nil == _database )
		return self;
    
	if ( nil == select )
		return self;
	
	[self internalSelect:select alias:nil type:nil];
	return self;
}

- (HMDatabase *)selectMax:(NSString *)select
{
	return [self selectMax:select alias:nil];
}

- (HMDatabase *)selectMax:(NSString *)select alias:(NSString *)alias
{
	if ( nil == _database )
		return self;
    
	[self internalSelect:select alias:alias type:@"MAX"];
	return self;
}

- (HMDatabase *)selectMin:(NSString *)select
{
	return [self selectMin:select alias:nil];
}

- (HMDatabase *)selectMin:(NSString *)select alias:(NSString *)alias
{
	if ( nil == _database )
		return self;
    
	[self internalSelect:select alias:alias type:@"MIN"];
	return self;
}

- (HMDatabase *)selectAvg:(NSString *)select
{
	return [self selectAvg:select alias:nil];
}

- (HMDatabase *)selectAvg:(NSString *)select alias:(NSString *)alias
{
	if ( nil == _database )
		return self;
    
	[self internalSelect:select alias:alias type:@"AVG"];
	return self;
}

- (HMDatabase *)selectSum:(NSString *)select
{
	return [self selectSum:select alias:nil];
}

- (HMDatabase *)selectSum:(NSString *)select alias:(NSString *)alias
{
	if ( nil == _database )
		return self;
    
	[self internalSelect:select alias:alias type:@"SUM"];
	return self;
}

#pragma mark -

- (HMDatabase *)distinct:(BOOL)flag
{
	if ( nil == _database )
		return self;
    
	_distinct = flag;
	return self;
}

#pragma mark -

- (HMDatabase *)from:(NSString *)from
{
	if ( nil == _database )
		return self;
    
	if ( nil == from )
		return self;
    
	from = [HMDatabase tableNameForIdentifier:from];
	
	for ( NSString * table in _from )
	{
		if ( NSOrderedSame == [table compare:from options:NSCaseInsensitiveSearch] )
			return self;
	}

	[_from addObject:from];
	return self;
}

#pragma mark -

- (HMDatabase *)where:(NSString *)key value:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalWhere:key expr:@"=" value:value type:@"AND"];
	return self;
}

- (HMDatabase *)orWhere:(NSString *)key value:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalWhere:key expr:@"=" value:value type:@"OR"];
	return self;
}

- (HMDatabase *)where:(NSString *)key expr:(NSString *)expr value:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalWhere:key expr:expr value:value type:@"AND"];
	return self;
}

- (HMDatabase *)orWhere:(NSString *)key expr:(NSString *)expr value:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalWhere:key expr:expr value:value type:@"OR"];
	return self;	
}

- (HMDatabase *)whereIn:(NSString *)key values:(NSArray *)values
{
	if ( nil == _database )
		return self;
    
	[self internalWhereIn:key values:values invert:NO type:@"AND"];
	return self;
}

- (HMDatabase *)orWhereIn:(NSString *)key values:(NSArray *)values
{
	if ( nil == _database )
		return self;
    
	[self internalWhereIn:key values:values invert:NO type:@"OR"];
	return self;
}

- (HMDatabase *)whereNotIn:(NSString *)key values:(NSArray *)values
{
	if ( nil == _database )
		return self;
    
	[self internalWhereIn:key values:values invert:YES type:@"AND"];
	return self;
}

- (HMDatabase *)orWhereNotIn:(NSString *)key values:(NSArray *)values
{
	if ( nil == _database )
		return self;
    
	[self internalWhereIn:key values:values invert:YES type:@"OR"];
	return self;
}

#pragma mark -

- (HMDatabase *)like:(NSString *)field match:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalLike:field match:value type:@"AND" side:@"both" invert:NO];
	return self;
}

- (HMDatabase *)notLike:(NSString *)field match:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalLike:field match:value type:@"AND" side:@"both" invert:YES];
	return self;
}

- (HMDatabase *)orLike:(NSString *)field match:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalLike:field match:value type:@"OR" side:@"both" invert:NO];
	return self;
}

- (HMDatabase *)orNotLike:(NSString *)field match:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalLike:field match:value type:@"OR" side:@"both" invert:YES];
	return self;
}

#pragma mark -

- (HMDatabase *)groupBy:(NSString *)by
{
	if ( nil == _database )
		return self;

	[self internalGroupBy:by];
	return self;
}

#pragma mark -

- (HMDatabase *)having:(NSString *)key value:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalHaving:key value:value type:@"AND"];
	return self;
}

- (HMDatabase *)orHaving:(NSString *)key value:(id)value
{
	if ( nil == _database )
		return self;
    
	[self internalHaving:key value:value type:@"OR"];
	return self;
}

#pragma mark -

- (HMDatabase *)orderAscendBy:(NSString *)by
{
	return [self orderBy:by direction:@"ASC"];
}

- (HMDatabase *)orderDescendBy:(NSString *)by
{
	return [self orderBy:by direction:@"DESC"];
}

- (HMDatabase *)orderRandomBy:(NSString *)by
{
	return [self orderBy:by direction:@"RAND()"];
}

- (HMDatabase *)orderBy:(NSString *)by direction:(NSString *)direction
{
	if ( nil == _database )
		return self;
    
	if ( nil == by )
		return self;
    
	[self internalOrderBy:by direction:direction];
	return self;
}

#pragma mark -

- (HMDatabase *)limit:(NSUInteger)limit
{
	if ( nil == _database )
		return self;
    
	_limit = limit;
	return self;
}

- (HMDatabase *)offset:(NSUInteger)offset
{
	if ( nil == _database )
		return self;
    
	_offset = offset;
	return self;
}

- (HMDatabase *)classInfo:(id)obj
{
	if ( nil == obj )
		return self;
	
	[_classType addObject:obj];
	return self;
}

#pragma mark -

- (HMDatabase *)set:(NSString *)key
{
	return [self set:key value:nil];
}

- (HMDatabase *)set:(NSString *)key value:(id)value
{
	if ( nil == _database )
		return self;
    
	if ( nil == key || nil == value )
		return self;

	[_set setObject:value forKey:key];
	return self;
}

#pragma mark -

- (NSArray *)get
{
	return [self get:nil limit:0 offset:0];
}

- (NSArray *)get:(NSString *)table
{
	return [self get:table limit:0 offset:0];
}

- (NSArray *)get:(NSString *)table limit:(NSUInteger)limit
{
	return [self get:table limit:limit offset:0];
}

- (NSArray *)get:(NSString *)table limit:(NSUInteger)limit offset:(NSUInteger)offset
{
	[self __internalResetResult];
    
	if ( nil == _database )
		return nil;
    
	if ( table )
	{
		[self from:table];
	}
    
	if ( limit )
	{
		[self limit:limit];
	}
	
	if ( offset )
	{
		[self offset:offset];
	}
	
	NSString * sql = [self internalCompileSelect:nil];
	
	[self __internalResetSelect];
    
	PERF_MARK(a);
	
	FMResultSet * result = [_database executeQuery:sql];
	if ( result )
	{
		while ( [result next] )
		{
			NSDictionary * dict = nil;
			
			if ( [result respondsToSelector:@selector(resultDictionary)] )
			{
				dict = [result resultDictionary];
			}
			else if ( [result respondsToSelector:@selector(resultDict)] )
			{
				dict = [result performSelector:@selector(resultDict)];
			}

			if ( dict )
			{
				[_resultArray addObject:dict];
			}
		}

		_resultCount = _resultArray.count;
		
		_lastQuery = [NSDate timeIntervalSinceReferenceDate];
		_lastSucceed = YES;
	}
	
	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return _resultArray;
}

#pragma mark -

- (NSUInteger)count
{
	return [self count:nil];
}

- (NSUInteger)count:(NSString *)table
{
	[self __internalResetResult];
    
	if ( nil == _database )
		return 0;
    
	if ( table )
	{
		[self from:table];
	}
	
	NSString * sql = [self internalCompileSelect:@"SELECT COUNT(*) AS numrows"];
	[self __internalResetSelect];
	
	BOOL succeed = NO;
	
	PERF_MARK(a);
	
	FMResultSet * result = [_database executeQuery:sql];
	if ( result )
	{
		succeed = [result next];
		if ( succeed )
		{
			_resultCount = (NSUInteger)[result unsignedLongLongIntForColumn:@"numrows"];
			
			_lastQuery = [NSDate timeIntervalSinceReferenceDate];
			_lastSucceed = YES;
		}
	}
	
	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return _resultCount;
}

#pragma mark -

- (NSInteger)insert
{
	return [self insert:nil];
}

- (NSInteger)insert:(NSString *)table
{
	[self __internalResetResult];
    
	if ( nil == _database )
		return -1;
    
	if ( 0 == _set.count )
		return -1;
    
	if ( nil == table )
	{
		if ( 0 == _from.count )
			return -1;
		
		table = [_from objectAtIndex:0];
	}

	PERF_MARK(a);
	
	NSMutableArray * allValues = [NSMutableArray array];
	NSString * sql = [self internalCompileInsert:table values:allValues];

	[self __internalResetWrite];

	BOOL ret = [_database executeUpdate:sql withArgumentsInArray:allValues];
	if ( ret )
	{
		_lastInsertID = (NSInteger)_database.lastInsertRowId;

		_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
		_lastSucceed = YES;
	}

	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return _lastInsertID;
}

#pragma mark -

- (BOOL)replace
{
    return [self replace:nil];
}

- (BOOL)replace:(NSString *)table
{
    [self __internalResetResult];
#if (__ON__ == __HM_LOG_DATABASE__)
    if(self.logable)CC(@"DB",@" replace called ",@"%@%@%@%@",_database,table,_set,_from);
#endif
    if ( nil == _database )
        return -1;
    
    if ( 0 == _set.count )
        return -1;
    
    if ( nil == table )
    {
        if ( 0 == _from.count )
            return -1;
        
        table = [_from objectAtIndex:0];
    }
    
    PERF_MARK(a);
    
    NSMutableArray * allValues = [NSMutableArray array];
    NSString * sql = [self internalCompileReplace:table values:allValues];
    
    [self __internalResetWrite];
    
    BOOL ret = [_database executeUpdate:sql withArgumentsInArray:allValues];
    if ( ret )
    {
        _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
        _lastSucceed = YES;
    }
    
    PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
    if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
    return ret;
}

#pragma mark -

- (BOOL)update
{
	return [self update:nil];
}

- (BOOL)update:(NSString *)table
{
	[self __internalResetResult];
    
	if ( nil == _database )
		return NO;
	
	if ( 0 == _set.count )
		return NO;
	
	if ( nil == table )
	{
		if ( 0 == _from.count )
			return NO;
		
		table = [_from objectAtIndex:0];
	}
    
	PERF_MARK(a);

	NSMutableArray * allValues = [NSMutableArray array];
	NSString * sql = [self internalCompileUpdate:table values:allValues];

	[self __internalResetWrite];

	BOOL ret = [_database executeUpdate:sql withArgumentsInArray:allValues];
	if ( ret )
	{
		_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
		_lastSucceed = YES;

		// TODO: ...
	}
	
	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return ret;
}

#pragma mark -

- (BOOL)empty
{
	return [self empty:nil];
}

- (BOOL)empty:(NSString *)table
{
	[self __internalResetResult];
	
	if ( nil == _database )
		return NO;
    
	if ( nil == table )
	{
		if ( 0 == _from.count )
			return NO;
		
		table = [_from objectAtIndex:0];
	}
	else
	{
		table = [HMDatabase tableNameForIdentifier:table];
	}
	
	PERF_MARK(a);
	
	NSString * sql = [self internalCompileEmpty:table];

	[self __internalResetWrite];

	BOOL ret = [_database executeUpdate:sql];
	if ( ret )
	{
		_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
		_lastSucceed = YES;
		
		// TODO: ...
	}

	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return ret;
}

#pragma mark -

- (BOOL)delete
{
	return [self delete:nil];
}

- (BOOL)delete:(NSString *)table
{
	[self __internalResetResult];
	
	if ( nil == _database )
		return NO;
    
	if ( nil == table )
	{
		if ( 0 == _from.count )
			return NO;
		
		table = [_from objectAtIndex:0];
	}
	
	if ( 0 == _where.count && 0 == _like.count )
		return NO;
	
	PERF_MARK(a);
	
	NSString * sql = [self internalCompileDelete:table];
	
	[self __internalResetWrite];
	
	BOOL ret = [_database executeUpdate:sql];
	if ( ret )
	{
		_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
		_lastSucceed = YES;
		
		// TODO: ...
	}
	
	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return ret;
}

#pragma mark -

- (BOOL)truncate
{
	return [self truncate:nil];
}

- (BOOL)truncate:(NSString *)table
{
	[self __internalResetResult];
	
	if ( nil == _database )
		return NO;
    
	if ( nil == table )
	{
		if ( 0 == _from.count )
			return NO;
		
		table = [_from objectAtIndex:0];
	}
	else
	{
		table = [HMDatabase tableNameForIdentifier:table];
	}

	PERF_MARK(a);
	
	NSString * sql = [self internalCompileTrunc:table];
    
	[self __internalResetWrite];
	
	BOOL ret = [_database executeUpdate:sql];
	if ( ret )
	{
		_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
		_lastSucceed = YES;
		
		// TODO: ...
	}
	
	PERF_MARK(b);
#if (__ON__ == __HM_LOG_DATABASE__)
	if(self.logable)CC(@"DB",@" %s = %.0f(ms)", __PRETTY_FUNCTION__, PERF_TIME(a, b) * 1000.0f );
#endif
	return ret;
}

#pragma mark -

- (void)__internalResetCreate
{
	[_field removeAllObjects];
	[_table removeAllObjects];
	[_index removeAllObjects];
	
	if ( NO == _batch )
	{
		[_classType removeAllObjects];
		[_associate removeAllObjects];
		[_has removeAllObjects];
	}
}

- (void)__internalResetSelect
{
	[_select removeAllObjects];
	[_from removeAllObjects];
	[_where removeAllObjects];
	[_like removeAllObjects];
	[_groupby removeAllObjects];
	[_having removeAllObjects];
	[_orderby removeAllObjects];
	
	if ( NO == _batch )
	{
		[_classType removeAllObjects];
		[_associate removeAllObjects];
		[_has removeAllObjects];
	}
	
	_distinct = NO;
	_limit = 0;
	_offset = 0;
}

- (void)__internalResetWrite
{
	[_set removeAllObjects];
	[_from removeAllObjects];
	[_where removeAllObjects];
	[_like removeAllObjects];
	[_orderby removeAllObjects];
	[_keys removeAllObjects];
	
	if ( NO == _batch )
	{
		[_classType removeAllObjects];
		[_associate removeAllObjects];
		[_has removeAllObjects];
	}
	
	_limit = 0;
}

- (void)__internalResetResult
{
	[_resultArray removeAllObjects];
	
	_resultCount = 0;
	_lastInsertID = -1;
	_lastSucceed = NO;
}

- (void)__internalSetResult:(NSArray *)array
{
	if ( nil == array )
	{
		[_resultArray removeAllObjects];

		_resultCount = 0;
	}
	else
	{
		[_resultArray removeAllObjects];
		[_resultArray addObjectsFromArray:array];
		
		_resultCount = array.count;
	}
}

#pragma mark -

- (void)internalGroupBy:(NSString *)by
{
	if ( nil == by )
		return;

	[_groupby addObject:by];
}

- (void)internalSelect:(NSString *)select alias:(NSString *)alias type:(NSString *)type
{
	if ( nil == select )
		return;

	NSArray * fieldNames = [select componentsSeparatedByString:@","];
	if ( fieldNames.count > 0 )
	{
		for ( NSString __strong_type* field in fieldNames )
		{
			field = [HMDatabase fieldNameForIdentifier:field];

			if ( field && field.length )
			{
				[_select addObject:field];
			}
		}
	}
	else
	{
		NSMutableString * sql = [NSMutableString string];
		
		if ( type && type.length )
		{
			[sql appendFormat:@"%@(%@)", type, [HMDatabase fieldNameForIdentifier:select]];
		}
		else
		{
			[sql appendFormat:@"%@", [HMDatabase fieldNameForIdentifier:select]];
		}

		if ( nil == alias || 0 == alias.length )
		{
			alias = [self internalCreateAliasFromTable:alias];
		}

		if ( alias )
		{
			alias = [HMDatabase fieldNameForIdentifier:alias];
			[sql appendFormat:@" AS %@", alias];
		}
		
		[_select addObject:sql];
	}
}

- (NSString *)internalCreateAliasFromTable:(NSString *)name
{
	NSRange range = [name rangeOfString:@"."];
	if ( range.length )
	{
		NSArray * array = [name componentsSeparatedByString:@"."];
		if ( array && array.count )
		{
			return array.lastObject;
		}
	}

	return name;
}

- (void)internalWhere:(NSString *)key expr:(NSString *)expr value:(NSObject *)value type:(NSString *)type
{
	key = [HMDatabase fieldNameForIdentifier:key];

	NSString *			prefix = (0 == _where.count) ? @"" : type;
	NSMutableString *	sql = [NSMutableString string];

	if ( nil == value || [value isKindOfClass:[NSNull class]] )
	{
		[sql appendFormat:@"%@ %@ IS NULL", prefix, key];
	}
	else
	{
		if ( [value isKindOfClass:[NSNumber class]] )
		{
			sql = [NSMutableString stringWithFormat:@"%@ %@ %@ %@", prefix, key, expr, value];
		}
		else
		{
			sql = [NSMutableString stringWithFormat:@"%@ %@ %@ '%@'", prefix, key, expr, value];
		}
	}
	
	[_where addObject:sql];
}

- (void)internalWhereIn:(NSString *)key values:(NSArray *)values invert:(BOOL)invert type:(NSString *)type
{
	if ( nil == key || nil == values || 0 == values.count )
		return;
    
	NSMutableString * sql = [NSMutableString string];
	
	if ( _where.count )
	{
		[sql appendFormat:@"%@ ", type];
	}
    
	key = [HMDatabase fieldNameForIdentifier:key];
	[sql appendFormat:@"%@", key];
	
	if ( invert )
	{
		[sql appendString:@" NOT"];
	}
    
	[sql appendString:@" IN ("];
	
	for ( NSInteger i = 0; i < values.count; ++i )
	{
		NSObject * value = [values objectAtIndex:i];
		
		if ( i > 0 )
		{
			[sql appendFormat:@", "];
		}
        
		if ( [value isKindOfClass:[NSNumber class]] )
		{
			[sql appendFormat:@"%@", value];
		}
		else
		{
			[sql appendFormat:@"'%@'", value];
		}
	}
	
	[sql appendString:@")"];
    
	[_where addObject:sql];
}

- (void)internalLike:(NSString *)field match:(NSObject *)match type:(NSString *)type side:(NSString *)side invert:(BOOL)invert
{
	if ( nil == field || nil == match )
		return;
    	
	NSString * value = nil;
	
	if ( [side isEqualToString:@"before"] )
	{
		value = [NSString stringWithFormat:@"%%%@", match];
	}
	else if ( [side isEqualToString:@"after"] )
	{
		value = [NSString stringWithFormat:@"%@%%", match];
	}
	else
	{
		value = [NSString stringWithFormat:@"%%%@%%", match];
	}
    
	NSMutableString * sql = [NSMutableString string];
	
	if ( _like.count )
	{
		[sql appendString:type];
	}
    
	field = [HMDatabase fieldNameForIdentifier:field];
	[sql appendFormat:@" %@", field];
	
	if ( invert )
	{
		[sql appendString:@" NOT"];
	}
	
	[sql appendFormat:@" LIKE '%@'", value];
    
	[_like addObject:sql];
}

- (void)internalHaving:(NSString *)key value:(NSObject *)value type:(NSString *)type
{
	if ( nil == key || nil == value )
		return;

	[_having addObject:[NSArray arrayWithObjects:key, value, type, nil]];
}

- (void)internalOrderBy:(NSString *)by direction:(NSString *)direction
{
	if ( nil == by || nil == direction )
		return;

	[_orderby addObject:[NSArray arrayWithObjects:by, direction, nil]];
}

#pragma mark -

- (NSString *)internalCompileSelect:(NSString *)override
{
	NSMutableString * sql = [NSMutableString string];
	
	if ( override )
	{
		[sql appendString:override];
	}
	else
	{
		if ( _distinct )
		{
			[sql appendString:@"SELECT DISTINCT "];
		}
		else
		{
			[sql appendString:@"SELECT "];
		}
        
		if ( _select.count )
		{
			[_select sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				NSString * left = (NSString *)obj1;
				NSString * right = (NSString *)obj2;
				return [left compare:right options:NSCaseInsensitiveSearch];
			}];
			
			for ( NSInteger i = 0; i < _select.count; ++i )
			{
				NSString * select = [_select objectAtIndex:i];
				
				if ( 0 == i )
				{
					[sql appendFormat:@"%@", select];
				}
				else
				{
					[sql appendFormat:@", %@", select];
				}
			}
		}
		else
		{
			[sql appendString:@"*"];
		}
	}
	
	if ( _from.count )
	{
		[sql appendString:@" FROM "];
		
		for ( NSInteger i = 0; i < _from.count; ++i )
		{
			NSString * from = [_from objectAtIndex:i];
			
			if ( 0 == i )
			{
				[sql appendString:from];
			}
			else
			{
				[sql appendFormat:@", %@", from];
			}
		}
	}
    
	if ( _where.count || _like.count )
	{
		[sql appendString:@" WHERE"];
	}
    
	if ( _where.count )
	{
		for ( NSString * where in _where )
		{
			[sql appendFormat:@" %@ ", where];
		}
	}
	
	if ( _like.count )
	{
		if ( _where.count )
		{
			[sql appendString:@" AND "];
		}
        
		for ( NSString * like in _like )
		{
			[sql appendFormat:@" %@ ", like];
		}
	}
    
	if ( _groupby.count )
	{
		[sql appendString:@" GROUP BY "];
		
		for ( NSInteger i = 0; i < _groupby.count; ++i )
		{
			NSString * by = [_groupby objectAtIndex:i];
			
			if ( 0 == i )
			{
				[sql appendFormat:@"%@", by];
			}
			else
			{
				[sql appendFormat:@", %@", by];
			}
		}
	}
    
	if ( _having.count )
	{
		[sql appendString:@" HAVING "];
		
		for ( NSInteger i = 0; i < _having.count; ++i )
		{
			NSArray *	array = [_orderby objectAtIndex:i];
			NSString *	key = [array safeObjectAtIndex:0];
			NSString *	value = [array safeObjectAtIndex:1];
			NSString *	type = [array safeObjectAtIndex:2];
			
			if ( type )
			{
				[sql appendFormat:@"%@ ", type];
			}

			if ( [value isKindOfClass:[NSNull class]] )
			{
				[sql appendFormat:@"%@ IS NULL ", key];
			}
			else if ( [value isKindOfClass:[NSNumber class]] )
			{
				[sql appendFormat:@"%@ = %@ ", key, value];
			}
			else if ( [value isKindOfClass:[NSString class]] )
			{
				[sql appendFormat:@"%@ = '%@' ", key, value];
			}
			else
			{
				[sql appendFormat:@"%@ = '%@' ", key, value];
			}
		}
	}
    
	if ( _orderby.count )
	{
		[sql appendString:@" ORDER BY "];
        
		for ( NSInteger i = 0; i < _orderby.count; ++i )
		{
			NSArray *	array = [_orderby objectAtIndex:i];
			NSString *	by = [array safeObjectAtIndex:0];
			NSString *	dir = [array safeObjectAtIndex:1];

			if ( 0 == i )
			{
				[sql appendFormat:@"%@ %@", by, dir];
			}
			else
			{
				[sql appendFormat:@", %@ %@", by, dir];
			}
		}
	}
    
	if ( _limit )
	{
		if ( _offset )
		{
			[sql appendFormat:@" LIMIT %llu, %llu", (unsigned long long)_offset, (unsigned long long)_limit];
		}
		else
		{
			[sql appendFormat:@" LIMIT %llu", (unsigned long long)_limit];
		}
	}
    
	return sql;
}

- (NSString *)internalCompileInsert:(NSString *)table values:(NSMutableArray *)allValues
{
	NSMutableString *	sql = [NSMutableString string];
	NSMutableArray *	allKeys = [NSMutableArray arrayWithArray:_set.allKeys];
    
	NSString *			field = nil;
	NSObject *			value = nil;
    
	[allKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString * left = (NSString *)obj1;
		NSString * right = (NSString *)obj2;
		return [left compare:right options:NSCaseInsensitiveSearch];
	}];
	
	[sql appendFormat:@"INSERT INTO %@ (", table];
    
	for ( NSInteger i = 0; i < allKeys.count; ++i )
	{
        NSString * key = [allKeys objectAtIndex:i];
        
        value = [_set objectForKey:key];
        if (value==nil) {
            continue;
        }
        
		if ( 0 != i )
		{
			[sql appendString:@", "];
		}
		
		[sql appendString:@"\n"];
		
		field = [HMDatabase fieldNameForIdentifier:key];
		
		[sql appendString:field];
		[allValues addObject:value];
	}
	
	[sql appendString:@") VALUES ("];
    
	for ( NSInteger i = 0; i < allValues.count; ++i )
	{
		if ( 0 != i )
		{
			[sql appendString:@", "];
		}
		
		[sql appendString:@"\n"];
		[sql appendString:@"?"];
	}
	
	[sql appendString:@")"];
    
	return sql;
}

- (NSString *)internalCompileReplace:(NSString *)table values:(NSMutableArray *)allValues
{
    NSMutableString *	sql = [NSMutableString string];
    NSMutableArray *	allKeys = [NSMutableArray arrayWithArray:_set.allKeys];
    
    NSString *			field = nil;
    NSObject *			value = nil;
    
    [allKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * left = (NSString *)obj1;
        NSString * right = (NSString *)obj2;
        return [left compare:right options:NSCaseInsensitiveSearch];
    }];
    
    [sql appendFormat:@"REPLACE INTO %@ (", table];
    
    for ( NSInteger i = 0; i < allKeys.count; ++i )
    {
        NSString * key = [allKeys objectAtIndex:i];
        
        value = [_set objectForKey:key];
        if (value==nil) {
            continue;
        }
        
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        
        [sql appendString:@"\n"];
        
        field = [HMDatabase fieldNameForIdentifier:key];
        [sql appendString:field];
        [allValues addObject:value];
    }
        
    
    [sql appendString:@") VALUES ("];
    
    for ( NSInteger i = 0; i < allValues.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        
        [sql appendString:@"\n"];
        [sql appendString:@"?"];
    }
    
    [sql appendString:@")"];
    
    return sql;
}

- (NSString *)internalCompileUpdate:(NSString *)table values:(NSMutableArray *)allValues
{
	NSMutableString *	sql = [NSMutableString string];
	NSMutableArray *	allKeys = [NSMutableArray arrayWithArray:_set.allKeys];
	
	NSString *			field = nil;
	NSString *			key = nil;
	NSObject *			value = nil;
    
	[allKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString * left = (NSString *)obj1;
		NSString * right = (NSString *)obj2;
		return [left compare:right options:NSCaseInsensitiveSearch];
	}];
	
	[sql appendFormat:@"UPDATE %@ SET ", table];
    
	for ( NSInteger i = 0; i < allKeys.count; ++i )
	{
        key = [allKeys objectAtIndex:i];
        
        value = [_set objectForKey:key];
        if (value==nil) {
            continue;
        }
        
		if ( 0 != i )
		{
			[sql appendString:@", "];
		}
		
		[sql appendString:@"\n"];
		
        field = [HMDatabase fieldNameForIdentifier:key];
		
		[sql appendFormat:@"%@ = ?", field];
		[allValues addObject:value];
	}
    
	if ( _where.count )
	{
		[sql appendString:@"\n"];
		[sql appendString:@" WHERE"];
		
		for ( NSString * where in _where )
		{
			[sql appendFormat:@" %@", where];
		}
	}
	
	if ( _orderby.count )
	{
		[sql appendString:@"\n"];
		[sql appendString:@" ORDER BY "];
		
		for ( NSInteger i = 0; i < _orderby.count; ++i )
		{
			NSString * by = [_orderby objectAtIndex:i];
			
			if ( 0 == i )
			{
				[sql appendString:by];
			}
			else
			{
				[sql appendFormat:@", %@", by];
			}
		}
	}
    
	if ( _limit )
	{
		[sql appendString:@"\n"];
		[sql appendFormat:@" LIMIT %lu", (unsigned long)_limit];
	}
	
	return sql;
}

- (NSString *)internalCompileCreate:(NSString *)table
{
	NSMutableString * sql = [NSMutableString string];
    
	[sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ ( ", table];
    
	[_field sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString * left = (NSString *)[(NSDictionary *)obj1 objectForKey:@"name"];
		NSString * right = (NSString *)[(NSDictionary *)obj2 objectForKey:@"name"];
		return [left compare:right options:NSCaseInsensitiveSearch];
	}];
	
	for ( NSInteger i = 0; i < _field.count; ++i )
	{
		if ( 0 != i )
		{
			[sql appendString:@", "];
		}
		
		[sql appendString:@"\n"];
		
		NSDictionary * dict = [_field objectAtIndex:i];
		
		NSString * name = (NSString *)[dict objectForKey:@"name"];
		NSString * type = (NSString *)[dict objectForKey:@"type"];
		NSNumber * size = (NSNumber *)[dict objectForKey:@"size"];
		NSNumber * PK = (NSNumber *)[dict objectForKey:@"primaryKey"];
		NSNumber * AI = (NSNumber *)[dict objectForKey:@"autoIncrement"];
		NSNumber * UN = (NSNumber *)[dict objectForKey:@"unique"];
		NSNumber * NN = (NSNumber *)[dict objectForKey:@"notNull"];
        
		NSObject * defaultValue = [dict objectForKey:@"default"];
        
		[sql appendFormat:@"%@", name];
        
		if ( type )
		{
			[sql appendFormat:@" %@", type];
		}
		
		if ( size && size.intValue )
		{
			[sql appendFormat:@"(%@)", size];
		}
		
		if ( PK && PK.intValue )
		{
			[sql appendString:@" PRIMARY KEY"];
		}
		
		if ( AI && AI.intValue )
		{
			[sql appendString:@" AUTOINCREMENT"];
		}
        
		if ( UN && UN.intValue )
		{
			[sql appendString:@" UNIQUE"];
		}
        
		if ( NN && NN.intValue )
		{
			[sql appendString:@" NOT NULL"];
		}
		
		if ( defaultValue )
		{
			if ( [defaultValue isKindOfClass:[NSNull class]] )
			{
				[sql appendString:@" DEFAULT NULL"];
			}
			else if ( [defaultValue isKindOfClass:[NSNumber class]] )
			{
				[sql appendFormat:@" DEFAULT %@", defaultValue];
			}
			else if ( [defaultValue isKindOfClass:[NSString class]] )
			{
				[sql appendFormat:@" DEFAULT '%@'", defaultValue];
			}
			else
			{
				[sql appendFormat:@" DEFAULT '%@'", defaultValue];
			}
		}
	}
	
	[sql appendString:@" )\n"];
    
	return sql;
}

- (NSString *)internalCompileEmpty:(NSString *)table
{
	NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", table];
	return sql;
}

- (NSString *)internalCompileDelete:(NSString *)table
{
	NSMutableString * sql = [NSMutableString string];
	
	[sql appendFormat:@"DELETE FROM %@", table];
    
	if ( _where.count || _like.count )
	{
		[sql appendString:@" WHERE "];
		
		if ( _where.count )
		{
			for ( NSString * where in _where )
			{
				[sql appendFormat:@" %@ ", where];
			}
		}
        
		if ( _like.count )
		{
			if ( _where.count )
			{
				[sql appendString:@" AND "];
			}
			
			for ( NSString * like in _like )
			{
				[sql appendFormat:@" %@ ", like];
			}
		}
	}
	
	if ( _limit )
	{
		[sql appendFormat:@" LIMIT %lu", (unsigned long)_limit];
	}
	
	return sql;
}

- (NSString *)internalCompileTrunc:(NSString *)table
{
	NSString * sql = [NSString stringWithFormat:@"TRUNCATE %@", table];
	return sql;
}

- (NSString *)internalCompileIndex:(NSString *)table
{
	NSMutableString * sql = [NSMutableString string];
    
	[sql appendFormat:@"CREATE INDEX IF NOT EXISTS index_%@ ON %@ ( ", table, table];
	
	for ( NSInteger i = 0; i < _index.count; ++i )
	{
		NSString * field = [_index objectAtIndex:i];
		
		if ( 0 == i )
		{
			[sql appendFormat:@"%@", field];
		}
		else
		{
			[sql appendFormat:@", %@", field];
		}
	}
	
	[sql appendString:@" )"];
	
	return sql;
}

- (NSString *)internalCompileExist:(NSString *)table as:(NSString *)value
{
	NSMutableString * sql = [NSMutableString string];
    
	[sql appendFormat:@"SELECT COUNT(*) as '%@'\n", value];
	[sql appendFormat:@"FROM sqlite_master\n"];
	[sql appendFormat:@"WHERE type ='table' AND name = %@", table];
	
	return sql;
}

#pragma mark -

+ (NSString *)fieldNameForIdentifier:(NSString *)identifier
{
	NSString * name = identifier.trim.unwrap;
	name = [name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
	name = [name stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	return name;
}

+ (NSString *)tableNameForIdentifier:(NSString *)identifier
{
	NSString * name = identifier.trim.unwrap;
	name = [name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
	name = [name stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	return name;
}

+ (NSString *)tableNameForClass:(Class)clazz
{
	if ( [clazz respondsToSelector:NSSelectorFromString(@"mapTableName")] )
	{
		return [clazz performSelector:NSSelectorFromString(@"mapTableName")];
	}

	return [NSString stringWithFormat:@"table_%@", [clazz description]];
}

- (Class)classType
{
	NSString * className = _classType.lastObject;
	if ( nil == className || 0 == className.length )
		return NULL;
	
	Class classType = NSClassFromString( className );
	if ( nil == classType || NO == [classType conformsToProtocol:@protocol(HMActiveProtocol)] )
		return NULL;
    
	return classType;
}

- (NSArray *)associateObjects
{
	return _associate;
}

- (NSArray *)associateObjectsFor:(Class)clazz
{
	NSMutableArray * array = [NSMutableArray array];
	
	for ( NSObject * obj in _associate )
	{
		if ( [obj isKindOfClass:clazz] )
		{
			[array addObject:obj];
		}
	}
    
	return array;
}

- (NSArray *)hasObjects
{
	return _has;
}

- (NSArray *)hasObjectsFor:(Class)clazz
{
	NSMutableArray * array = [NSMutableArray array];
    
	for ( NSObject * obj in _has )
	{
		if ( [obj isKindOfClass:clazz] )
		{
			[array addObject:obj];
		}
	}
    
	return array;
}

- (void)classType:(Class)clazz
{
	if ( nil == clazz )
		return;
	
	[_classType addObject:[clazz description]];
    
	[self from:[HMDatabase tableNameForClass:clazz]];
}

- (void)associate:(NSObject *)obj
{
	if ( nil == obj )
		return;
    
	[_associate addObject:obj];
}

- (void)has:(NSObject *)obj
{
	if ( nil == obj )
		return;
    
	[_has addObject:obj];
}

#pragma mark -

- (HMDatabaseBlockN)TABLE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self table:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)FIELD
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
        
		NSString *	field = (NSString *)first;
		NSString *	type = va_arg( args, NSString * );
        
		va_end( args );
		
		return [self field:field type:type size:0];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)FIELD_WITH_SIZE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString *	field = (NSString *)first;
		NSString *	type = va_arg( args, NSString * );
		NSUInteger	size = va_arg( args, NSUInteger );
		
        va_end( args );
        
		return [self field:field type:type size:size];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)UNSIGNED
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self unsignedType];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)NOT_NULL
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self notNull];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)PRIMARY_KEY
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self primaryKey];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)AUTO_INREMENT
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self autoIncrement];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)DEFAULT_ZERO
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self defaultZero];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)DEFAULT_NULL
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self defaultNull];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)DEFAULT
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self defaultValue:first];
	};
    
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)UNIQUE
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self unique];
	};
    
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)CREATE_IF_NOT_EXISTS
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self createTableIfNotExists] ? self : nil;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)INDEX_ON
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id field, ... )
	{
		va_list args;
		va_start( args, field );
		
		NSMutableArray * array = [NSMutableArray array];
		
		for ( ;; field = nil )
		{
			NSObject * name = field ? field : va_arg( args, NSObject * );
			if ( nil == name || NO == [name isKindOfClass:[NSString class]] )
				break;
			
			[array addObject:(NSString *)name];
		}
		
		va_end(args);
		
		return [self indexTable:nil on:array] ? self : nil;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self select:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT_MAX
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self selectMax:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT_MAX_ALIAS
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * field = (NSString *)first;
		NSString * alias = (NSString *)va_arg( args, NSString * );
		va_end( args );
		return [self selectMax:field alias:alias];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT_MIN
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self selectMin:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT_MIN_ALIAS
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * field = (NSString *)first;
		NSString * alias = (NSString *)va_arg( args, NSString * );
		va_end(args);
		return [self selectMin:field alias:alias];
	};
    
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT_AVG
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self selectAvg:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT_AVG_ALIAS
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * field = (NSString *)first;
		NSString * alias = (NSString *)va_arg( args, NSString * );
		va_end( args );
		return [self selectAvg:field alias:alias];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT_SUM
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self selectSum:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SELECT_SUM_ALIAS
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * field = (NSString *)first;
		NSString * alias = (NSString *)va_arg( args, NSString * );
		
		va_end( args );
		
		return [self selectSum:field alias:alias];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)DISTINCT
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		return [self distinct:YES];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)FROM
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self from:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)WHERE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		va_end( args );
		return [self where:key value:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)OR_WHERE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		va_end( args );
		return [self orWhere:key value:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)WHERE_OPERATOR
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSString * expr = (NSString *)va_arg( args, NSString * );
		NSObject * value = (NSObject *)va_arg( args, NSObject * );

		va_end( args );

		return [self where:key expr:expr value:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)OR_WHERE_OPERATOR
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSString * expr = (NSString *)va_arg( args, NSString * );
		NSObject * value = (NSObject *)va_arg( args, NSObject * );

		va_end( args );
		
		return [self orWhere:key expr:expr value:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)WHERE_IN
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id field, ... )
	{
		va_list args;
		va_start( args, field );
		
		NSString * key = (NSString *)field;

		NSMutableArray * array = [NSMutableArray array];
		for ( ;; )
		{
			NSObject * value = va_arg( args, NSObject * );
			if ( nil == value )
				break;

			if ( [value isKindOfClass:[NSArray class]] )
			{
                [array addObjectsFromArray:(id)value];
			}
            else
			{
			    [array addObject:(NSString *)value];
			}
		}
        va_end( args );
		return [self whereIn:key values:array];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)OR_WHERE_IN
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id field, ... )
	{
		va_list args;
		va_start( args, field );
		
		NSString * key = (NSString *)field;
		
		NSMutableArray * array = [NSMutableArray array];
		for ( ;; )
		{
			NSObject * value = va_arg( args, NSObject * );
			if ( nil == value )
				break;
			
			if ( [value isKindOfClass:[NSArray class]] )
			{
                [array addObjectsFromArray:(id)value];
			}
            else
			{
			    [array addObject:(NSString *)value];
			}
		}
        va_end( args );
		return [self orWhereIn:key values:array];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)WHERE_NOT_IN
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id field, ... )
	{
		va_list args;
		va_start( args, field );
		
		NSString * key = (NSString *)field;
		
		NSMutableArray * array = [NSMutableArray array];
		for ( ;; )
		{
			NSObject * value = va_arg( args, NSObject * );
			if ( nil == value )
				break;
			
			if ( [value isKindOfClass:[NSArray class]] )
			{
                [array addObjectsFromArray:(id)value];
			}
            else
			{
			    [array addObject:(NSString *)value];
			}
		}
		va_end( args );
		return [self whereNotIn:key values:array];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)OR_WHERE_NOT_IN
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id field, ... )
	{
		va_list args;
		va_start( args, field );
		
		NSString * key = (NSString *)field;
		
		NSMutableArray * array = [NSMutableArray array];
		for ( ;; )
		{
			NSObject * value = va_arg( args, NSObject * );
			if ( nil == value )
				break;
			
			if ( [value isKindOfClass:[NSArray class]] )
			{
                [array addObjectsFromArray:(id)value];
			}
            else
			{
			    [array addObject:(NSString *)value];
			}
		}
        va_end( args );
		return [self orWhereNotIn:key values:array];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)LIKE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		va_end( args );
		return [self like:key match:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)NOT_LIKE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		
		return [self notLike:key match:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)OR_LIKE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		va_end( args );
		return [self orLike:key match:value];
	};

	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)OR_NOT_LIKE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		va_end( args );
		return [self orNotLike:key match:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)GROUP_BY
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self groupBy:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)HAVING
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		va_end( args );
		return [self having:key value:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)OR_HAVING
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		va_end( args );
		return [self orHaving:key value:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)ORDER_ASC_BY
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self orderAscendBy:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)ORDER_DESC_BY
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self orderDescendBy:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)ORDER_RAND_BY
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self orderRandomBy:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)ORDER_BY
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * by = (NSString *)first;
		NSString * direction = (NSString *)va_arg( args, NSString * );
		va_end( args );
		return [self orderBy:by direction:direction];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockU)LIMIT
{
	HMDatabaseBlockU block = ^ HMDatabase * ( NSUInteger value )
	{
		return [self limit:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockU)OFFSET
{
	HMDatabaseBlockU block = ^ HMDatabase * ( NSUInteger value )
	{
		return [self offset:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SET_NULL
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		return [self set:(NSString *)first];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)SET
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		va_list args;
		va_start( args, first );
		
		NSString * key = (NSString *)first;
		NSObject * value = (NSObject *)va_arg( args, NSObject * );
		va_end( args );
		return [self set:key value:value];
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)GET
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		[self get];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)COUNT
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		[self count];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)INSERT
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		[self insert];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)REPLACE
{
    HMDatabaseBlock block = ^ HMDatabase * ( void )
    {
        [self replace];
        return self;
    };
    
    return [[block copy] autorelease];
}


- (HMDatabaseBlock)UPDATE
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		[self update];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)EMPTYTABLE
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		[self empty];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)TRUNCATE
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		[self truncate];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)DELETE
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		[self delete];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)CLASS_TYPE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		[self classType:(Class)first];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)ASSOCIATE
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		[self associate:first];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)BELONG_TO
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		[self associate:first];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlockN)HAS
{
	HMDatabaseBlockN block = ^ HMDatabase * ( id first, ... )
	{
		[self has:first];
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)BATCH_BEGIN
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		_batch = YES;
		return self;
	};
	
	return [[block copy] autorelease];
}

- (HMDatabaseBlock)BATCH_END
{
	HMDatabaseBlock block = ^ HMDatabase * ( void )
	{
		_batch = NO;
		return self;
	};
	
	return [[block copy] autorelease];
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if defined(__HM_UNITTEST__) && __HM_UNITTEST__

TEST_CASE( HMDatabase )
{
	TIMES( 3 )
	{
		HERE( "open and close DB", {
			[HMDatabase closeSharedDatabase];
			EXPECTED( nil == [HMDatabase sharedDatabase] );
			
			[HMDatabase openSharedDatabase:@"test"];
			EXPECTED( [HMDatabase sharedDatabase] );
		});
	}
	
	TIMES( 0 )
	{
		HERE( "create table", {
			self
			.DB
			.TABLE( @"blogs" )
			.FIELD( @"id", @"INTEGER" ).PRIMARY_KEY().AUTO_INREMENT()
			.FIELD( @"type", @"TEXT" )
			.FIELD( @"date", @"TEXT" )
			.FIELD( @"content", @"TEXT" )
			.CREATE_IF_NOT_EXISTS();

			EXPECTED( self.DB.succeed );
		});
		
		HERE( "index table", {
			self
			.DB
			.TABLE( @"blogs" )
			.INDEX_ON( @"id", nil );
			
			EXPECTED( self.DB.succeed );
		});
		
		HERE( "empty", {
			self
			.DB
			.FROM( @"blogs" )
			.EMPTYTABLE();
			
			EXPECTED( self.DB.succeed );
		});
		
		HERE( "insert", {
			self
			.DB
			.FROM( @"blogs" )
			.SET( @"type", @"Test" )
			.SET( @"date", [[NSDate date] description] )
			.SET( @"content", @"Hello, world!" )
			.INSERT();	// write once
			
			EXPECTED( self.DB.succeed );
		});
		
		HERE( "delete", {
			self
			.DB
			.FROM( @"blogs" )
			.WHERE( @"id", __INT(self.DB.insertID) )
			.DELETE();
			
			EXPECTED( self.DB.succeed );
		});
		
		HERE( "count", {
			self
			.DB
			.FROM( @"blogs" )
			.COUNT();
			
			EXPECTED( self.DB.succeed );
			EXPECTED( self.DB.resultCount == 0 );
		});
		
		HERE( "insert 30 rows", {
			for ( NSUInteger i = 0; i < 30; ++i )
			{
				self
				.DB
				.FROM( @"blogs" )
				.SET( @"date", [[NSDate date] description] )
				.SET( @"content", [NSString stringWithFormat:@"Some content %u", i] );
				
				if ( 0 == (i % 3) )
				{
					self.DB.SET( @"type", @"A" );
				}
				else if ( 1 == (i % 3) )
				{
					self.DB.SET( @"type", @"B" );
				}
				else if ( 2 == (i % 3) )
				{
					self.DB.SET( @"type", @"C" );
				}
				
				self.DB.INSERT();
				
				EXPECTED( self.DB.succeed );
				EXPECTED( self.DB.insertID > 0 );
			}
		});
		
		HERE( "count all", {
			self
			.DB
			.FROM( @"blogs" )
			.COUNT();
			
			EXPECTED( self.DB.succeed );
			EXPECTED( self.DB.resultCount == 30 );
		});
		
		HERE( "count 'A'", {
			self
			.DB
			.FROM( @"blogs" )
			.WHERE( @"type", @"A" )
			.COUNT();
			
			EXPECTED( self.DB.succeed );
			EXPECTED( self.DB.resultCount == 10 );
		});

		HERE( "query", {
			for ( NSUInteger i = 0; i < 3; ++i )
			{
				self
				.DB
				.FROM( @"blogs" )
				.OFFSET( 10 * i )
				.LIMIT( 10 )
				.GET();
				
				EXPECTED( self.DB.succeed );
				EXPECTED( self.DB.resultCount > 0 );
				EXPECTED( self.DB.resultCount == self.DB.resultArray.count );
			}
		});

		HERE( "close", {
			[HMDatabase closeSharedDatabase];
		});
	}
}
TEST_CASE_END

#endif	// #if defined(__HM_UNITTEST__) && __HM_UNITTEST__
