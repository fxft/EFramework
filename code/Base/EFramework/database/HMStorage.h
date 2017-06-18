
/**
 *  sqlite
 *
 *   HMDatabase
 *
 *   return
 */
#import "HMDatabase.h"


@interface NSObject(HMDatabase)
/**
 *  全局默认数据库
 */
@property (nonatomic, readonly) HMDatabase * DB;

+ (HMDatabase *)DB;

- (NSString *)tableName;
+ (NSString *)tableName;

@end
