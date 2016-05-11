

#import "HMMacros.h"
#import "HMKeychain.h"

#pragma mark -

@interface NSObject(HMKeychain)

+ (NSString *)keychainRead:(NSString *)key;
+ (void)keychainWrite:(NSString *)value forKey:(NSString *)key;
+ (void)keychainDelete:(NSString *)key;

- (NSString *)keychainRead:(NSString *)key;
- (void)keychainWrite:(NSString *)value forKey:(NSString *)key;
- (void)keychainDelete:(NSString *)key;

@end
