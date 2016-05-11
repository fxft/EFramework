
#import "HMMacros.h"
#import "HMPerformance.h"
#import "NSString+HMExtension.h"
#import "NSObject+HMNotification.h"

#pragma mark -

@class FMDatabase;
@class HMDatabase;

typedef HMDatabase *	(^HMDatabaseBlockI)( NSInteger val );
typedef HMDatabase *	(^HMDatabaseBlockU)( NSUInteger val );
typedef HMDatabase *	(^HMDatabaseBlockN)( id key, ... );
typedef HMDatabase *	(^HMDatabaseBlockB)( BOOL flag );
typedef HMDatabase *	(^HMDatabaseBlock)( void );
typedef NSArray *		(^HMDatabaseArrayBlock)( void );
typedef NSArray *		(^HMDatabaseArrayBlockU)( NSUInteger val );
typedef NSArray *		(^HMDatabaseArrayBlockUN)( NSUInteger val, ... );
typedef id				(^HMDatabaseObjectBlock)( void );
typedef id				(^HMDatabaseObjectBlockN)( id key, ... );
typedef BOOL			(^HMDatabaseBoolBlock)( void );

#pragma mark -

/**
 *  FMDatabase快速工具
 */
@interface HMDatabase : NSObject

AS_NOTIFICATION( SHARED_DB_OPEN )
AS_NOTIFICATION( SHARED_DB_CLOSE )

@property (nonatomic) BOOL					autoOptimize;	// TO BE DONE
@property (nonatomic, HM_STRONG) NSString *			filePath;
@property (nonatomic, readonly) NSString *			fullFilePath;

@property (nonatomic) BOOL					shadow;
@property (nonatomic, HM_STRONG) FMDatabase *			database;

@property (nonatomic, readonly) NSUInteger			total;
@property (nonatomic, readonly) BOOL				ready;
@property (nonatomic, readonly) NSUInteger			identifier;

/**
 *  表属性操作
 */
@property (nonatomic, readonly) HMDatabaseBlockN	TABLE;
@property (nonatomic, readonly) HMDatabaseBlockN	FIELD;
@property (nonatomic, readonly) HMDatabaseBlockN	FIELD_WITH_SIZE;
@property (nonatomic, readonly) HMDatabaseBlock	UNSIGNED;
@property (nonatomic, readonly) HMDatabaseBlock	NOT_NULL;
@property (nonatomic, readonly) HMDatabaseBlock	PRIMARY_KEY;
@property (nonatomic, readonly) HMDatabaseBlock	AUTO_INREMENT;
@property (nonatomic, readonly) HMDatabaseBlock	DEFAULT_ZERO;
@property (nonatomic, readonly) HMDatabaseBlock	DEFAULT_NULL;
@property (nonatomic, readonly) HMDatabaseBlockN	DEFAULT;
@property (nonatomic, readonly) HMDatabaseBlock	UNIQUE;
@property (nonatomic, readonly) HMDatabaseBlock	CREATE_IF_NOT_EXISTS;

@property (nonatomic, readonly) HMDatabaseBlockN	INDEX_ON;
/**
 *  select操作
 */
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT;
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT_MAX;
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT_MAX_ALIAS;
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT_MIN;
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT_MIN_ALIAS;
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT_AVG;
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT_AVG_ALIAS;
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT_SUM;
@property (nonatomic, readonly) HMDatabaseBlockN	SELECT_SUM_ALIAS;

/**
 *  选择方式操作
 */
@property (nonatomic, readonly) HMDatabaseBlock	DISTINCT;
@property (nonatomic, readonly) HMDatabaseBlockN	FROM;

@property (nonatomic, readonly) HMDatabaseBlockN	WHERE;
@property (nonatomic, readonly) HMDatabaseBlockN	OR_WHERE;

@property (nonatomic, readonly) HMDatabaseBlockN	WHERE_OPERATOR;
@property (nonatomic, readonly) HMDatabaseBlockN	OR_WHERE_OPERATOR;

@property (nonatomic, readonly) HMDatabaseBlockN	WHERE_IN;
@property (nonatomic, readonly) HMDatabaseBlockN	OR_WHERE_IN;
@property (nonatomic, readonly) HMDatabaseBlockN	WHERE_NOT_IN;
@property (nonatomic, readonly) HMDatabaseBlockN	OR_WHERE_NOT_IN;

@property (nonatomic, readonly) HMDatabaseBlockN	LIKE;
@property (nonatomic, readonly) HMDatabaseBlockN	NOT_LIKE;
@property (nonatomic, readonly) HMDatabaseBlockN	OR_LIKE;
@property (nonatomic, readonly) HMDatabaseBlockN	OR_NOT_LIKE;

/**
 *  排序
 */
@property (nonatomic, readonly) HMDatabaseBlockN	GROUP_BY;

@property (nonatomic, readonly) HMDatabaseBlockN	HAVING;
@property (nonatomic, readonly) HMDatabaseBlockN	OR_HAVING;

@property (nonatomic, readonly) HMDatabaseBlockN	ORDER_ASC_BY;
@property (nonatomic, readonly) HMDatabaseBlockN	ORDER_DESC_BY;
@property (nonatomic, readonly) HMDatabaseBlockN	ORDER_RAND_BY;
@property (nonatomic, readonly) HMDatabaseBlockN	ORDER_BY;

@property (nonatomic, readonly) HMDatabaseBlockU	LIMIT;
@property (nonatomic, readonly) HMDatabaseBlockU	OFFSET;

/**
 *  执行动作
 */
@property (nonatomic, readonly) HMDatabaseBlockN	SET;
@property (nonatomic, readonly) HMDatabaseBlockN	SET_NULL;

@property (nonatomic, readonly) HMDatabaseBlock	GET;
@property (nonatomic, readonly) HMDatabaseBlock	COUNT;

@property (nonatomic, readonly) HMDatabaseBlock	INSERT;
@property (nonatomic, readonly) HMDatabaseBlock	REPLACE;
@property (nonatomic, readonly) HMDatabaseBlock	UPDATE;
@property (nonatomic, readonly) HMDatabaseBlock	EMPTYTABLE;
@property (nonatomic, readonly) HMDatabaseBlock	TRUNCATE;
@property (nonatomic, readonly) HMDatabaseBlock	DELETE;

@property (nonatomic, readonly) HMDatabaseBlock	BATCH_BEGIN;
@property (nonatomic, readonly) HMDatabaseBlock	BATCH_END;

@property (nonatomic, readonly) HMDatabaseBlockN	CLASS_TYPE;	// for activeRecord
@property (nonatomic, readonly) HMDatabaseBlockN	ASSOCIATE;	// for activeRecord
@property (nonatomic, readonly) HMDatabaseBlockN	BELONG_TO;	// for activeRecord
@property (nonatomic, readonly) HMDatabaseBlockN	HAS;		// for activeRecord

@property (nonatomic, readonly) NSArray *			resultArray;///结果数据
@property (nonatomic, readonly) NSUInteger			resultCount;
@property (nonatomic, readonly) NSInteger			insertID;
@property (nonatomic, readonly) BOOL				succeed;///执行结果

@property (nonatomic, readonly) NSTimeInterval		lastQuery;
@property (nonatomic, readonly) NSTimeInterval		lastUpdate;

+ (BOOL)openSharedDatabase:(NSString *)path;
+ (BOOL)existsSharedDatabase:(NSString *)path;
+ (void)closeSharedDatabase;

+ (void)setSharedDatabase:(HMDatabase *)db;
+ (HMDatabase *)sharedDatabase;

+ (void)scopeEnter;
+ (void)scopeLeave;

- (id)initWithPath:(NSString *)path;
- (id)initWithDatabase:(FMDatabase *)db;

+ (BOOL)exists:(NSString *)path;
- (BOOL)open:(NSString *)path;
- (void)close;
- (void)clearState;

+ (NSString *)fieldNameForIdentifier:(NSString *)identifier;
+ (NSString *)tableNameForClass:(Class)clazz;

- (Class)classType;

- (NSArray *)associateObjects;
- (NSArray *)associateObjectsFor:(Class)clazz;

- (NSArray *)hasObjects;
- (NSArray *)hasObjectsFor:(Class)clazz;

// internal user only
- (void)__internalResetCreate;
- (void)__internalResetSelect;
- (void)__internalResetWrite;
- (void)__internalResetResult;
- (void)__internalSetResult:(NSArray *)array;

@end
