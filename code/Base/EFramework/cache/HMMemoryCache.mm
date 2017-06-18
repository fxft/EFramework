

#import "HMMemoryCache.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

#undef	DEFAULT_MAX_COUNT
#define DEFAULT_MAX_COUNT	(48)

#pragma mark -

@interface HMMemoryCache()
{
	BOOL					_clearWhenMemoryLow;
	NSUInteger				_maxCacheCount;
	NSUInteger				_cachedCount;
}
@end

#pragma mark -

@implementation HMMemoryCache

@synthesize clearWhenMemoryLow = _clearWhenMemoryLow;
@synthesize maxCacheCount = _maxCacheCount;
@synthesize cachedCount = _cachedCount;

DEF_SINGLETON( HMMemoryCache );

- (id)init
{
	self = [super init];
	if ( self )
	{
		_clearWhenMemoryLow = YES;
		_maxCacheCount = DEFAULT_MAX_COUNT;
		_cachedCount = 0;
        WS(weakSelf)
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            NSLog(@"MemoryCache clearing");
            SS(strongSelf)
            [strongSelf removeAllObjects];
        }];
	}

	return self;
}

- (BOOL)hasObjectForKey:(id)key
{
    if (key==nil) {
        return  NO;
    }
	return [self objectForKey:key] ? YES : NO;
}


- (void)setObject:(id)object forKey:(id)key
{
	if ( nil == key )
		return;
	
	if ( nil == object )
		return;
	
	_cachedCount += 1;

	if ( _cachedCount >= _maxCacheCount )
	{
		[self removeAllObjects];
        _cachedCount = 1;
	}

    [super setObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key
{
    if (key==nil) {
        return;
    }
    if (_cachedCount) {
        _cachedCount--;
    }
	[super removeObjectForKey:key];
}

- (void)removeAllObjects
{
	[super removeAllObjects];
    
	_cachedCount = 0;
}

@end

