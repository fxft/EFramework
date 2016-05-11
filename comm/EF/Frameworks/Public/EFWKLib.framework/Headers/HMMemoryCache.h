
#import "HMMacros.h"
#import "HMCacheProtocol.h"
#pragma mark -

@interface HMMemoryCache : NSCache<HMCacheProtocol>

@property (nonatomic) BOOL                     clearWhenMemoryLow;
/**
 *  默认存储数据的个数48个
 */
@property (nonatomic) NSUInteger               maxCacheCount;
@property (nonatomic) NSUInteger               cachedCount;

AS_SINGLETON( HMMemoryCache );

@end
