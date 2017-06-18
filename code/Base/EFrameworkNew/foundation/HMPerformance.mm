
#import "HMPerformance.h"

//#import "HM_UnitTest.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@interface HMPerformance()
{
	NSMutableDictionary *	_records;
	NSMutableDictionary *	_tags;
}
@end

#pragma mark -

@implementation HMPerformance

DEF_SINGLETON( HMPerformance );

@synthesize records = _records;
@synthesize tags = _tags;

- (id)init
{
	self = [super init];
	if ( self )
	{
		_records = [[NSMutableDictionary alloc] init];
		_tags = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
    [_tags removeAllObjects];
    
	
    [_records removeAllObjects];
    
#if  __has_feature(objc_arc)
    
#else
    [_tags release];
    [_records release];
#endif

	HM_SUPER_DEALLOC();
}

+ (double)timestamp
{
	return CACurrentMediaTime();
}

+ (double)markTag:(NSString *)tag
{
	double curr = CACurrentMediaTime();
	
	NSNumber * time = [NSNumber numberWithDouble:curr];
	[[HMPerformance sharedInstance].tags setObject:time forKey:tag];
	
	return curr;
}

+ (double)betweenTag:(NSString *)tag1 andTag:(NSString *)tag2
{
	return [self betweenTag:tag1 andTag:tag2 shouldRemove:YES];
}

+ (double)betweenTag:(NSString *)tag1 andTag:(NSString *)tag2 shouldRemove:(BOOL)remove
{
	NSNumber * time1 = [[HMPerformance sharedInstance].tags objectForKey:tag1];
	NSNumber * time2 = [[HMPerformance sharedInstance].tags objectForKey:tag2];
	
	if ( nil == time1 || nil == time2 )
		return 0.0;
	
	double time = fabs( [time2 doubleValue] - [time1 doubleValue] );
	
	if ( remove )
	{
		[[HMPerformance sharedInstance].tags removeObjectForKey:tag1];
		[[HMPerformance sharedInstance].tags removeObjectForKey:tag2];
	}
	
	return time;
}

+ (void)watchClass:(Class)clazz
{
	[self watchClass:clazz andSelector:nil];
}

+ (void)watchClass:(Class)clazz andSelector:(SEL)selector
{
	// TODO:
}

+ (void)recordName:(NSString *)name andTime:(NSTimeInterval)time
{
	INFO( @"'%@' = %.4f(s)", name, time );
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if defined(__HM_UNITTEST__) && __HM_UNITTEST__

TEST_CASE( HMPerformance )
{
	TIMES( 3 )
	{
		PERF_ENTER
		{
			HERE( "step 1",
			{	
				PERF_ENTER_( step_one )
				{
					TIMES( 10 )
					{
						rand();
					}
				}
				PERF_LEAVE_( step_one )
			});

			HERE( "step 2",
			{
				PERF_ENTER_( step_two )
				{
					TIMES( 10000 )
					{
						rand();
					}
				}
				PERF_LEAVE_( step_two )
			});

			HERE( "step 3",
			{
				PERF_MARK( step_three_1 );
				{
					TIMES( 10000 )
					{
						rand();
					}
				}
				PERF_MARK( step_three_2 );
			});

			HERE( "print time",
			{
				CC( @"step_three = %f", PERF_TIME( step_three_1, step_three_2 ) );
			});
		}
		PERF_LEAVE
	}
}
TEST_CASE_END

#endif	// #if defined(__HM_UNITTEST__) && __HM_UNITTEST__
