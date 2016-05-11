
#import "HMDatabase.h"

#pragma mark -

@protocol HMActiveProtocol<NSObject>

@property (nonatomic, readonly) HMDatabaseBoolBlock	EXISTS;		// COUNT WHERE '<your primary key>' = id
@property (nonatomic, readonly) HMDatabaseBoolBlock	LOAD;		// GET
@property (nonatomic, readonly) HMDatabaseBoolBlock	SAVE;		// INSERT if failed to UPDATE
@property (nonatomic, readonly) HMDatabaseBoolBlock	INSERT;
@property (nonatomic, readonly) HMDatabaseBoolBlock	UPDATE;
@property (nonatomic, readonly) HMDatabaseBoolBlock	DELETE;

@property (nonatomic, readonly) NSString *				primaryKey;
@property (nonatomic, HM_STRONG) NSNumber *				primaryID;

@property (nonatomic, readonly) BOOL					inserted;
@property (nonatomic, readonly) BOOL					deleted;
@property (nonatomic) BOOL						changed;

@property (nonatomic, HM_STRONG) NSMutableDictionary *		JSON;
@property (nonatomic, HM_STRONG) NSData *					JSONData;
@property (nonatomic, HM_STRONG) NSString *				JSONString;

- (id)initWithKey:(id)key;
- (id)initWithObject:(NSObject *)object;
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithJSONData:(NSData *)data;
- (id)initWithJSONString:(NSString *)string;

- (void)setDictionary:(NSDictionary *)dict;

- (void)load;	// for subclass
- (void)unload;	// for subclass

@end
