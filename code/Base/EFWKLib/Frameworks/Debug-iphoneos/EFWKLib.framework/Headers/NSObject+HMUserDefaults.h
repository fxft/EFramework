

#import "HMMacros.h"
#import "HMRuntime.h"

#pragma mark -

@interface NSObject(HMUserDefaults)

// for key value

+ (id)userDefaultsRead:(NSString *)key;
- (id)userDefaultsRead:(NSString *)key;

+ (void)userDefaultsWrite:(id)value forKey:(NSString *)key;
- (void)userDefaultsWrite:(id)value forKey:(NSString *)key;

+ (void)userDefaultsRemove:(NSString *)key;
- (void)userDefaultsRemove:(NSString *)key;

// for object

+ (id)readObject;
+ (id)readObjectForKey:(NSString *)key;

+ (void)saveObject:(id)obj;
+ (void)saveObject:(id)obj forKey:(NSString *)key;

+ (void)removeObject;
+ (void)removeObjectForKey:(NSString *)key;

+ (id)readFromUserDefaults:(NSString *)key;
- (void)saveToUserDefaults:(NSString *)key;

@end
