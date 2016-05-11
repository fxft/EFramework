
#import "HMMacros.h"

#pragma mark -

#if defined(__HM_PERFORMANCE__) && __HM_PERFORMANCE__

#define PERF_TAG( __X )		[NSString stringWithFormat:@"%s %s", __PRETTY_FUNCTION__, __X]
#define PERF_TAG1( __X )	[NSString stringWithFormat:@"enter %s %s", __PRETTY_FUNCTION__, __X]
#define PERF_TAG2( __X )	[NSString stringWithFormat:@"leave %s %s", __PRETTY_FUNCTION__, __X]

#define	PERF_MARK( __X ) \
		[HMPerformance markTag:PERF_TAG(#__X)];

#define	PERF_TIME( __X1, __X2 ) \
		[HMPerformance betweenTag:PERF_TAG(#__X1) andTag:PERF_TAG(#__X2)]

#define PERF_ENTER \
		[HMPerformance markTag:PERF_TAG1("")];

#define PERF_ENTER_( __X ) \
		[HMPerformance markTag:PERF_TAG1(#__X)];

#define PERF_LEAVE \
		[HMPerformance markTag:PERF_TAG2("")]; \
		[HMPerformance recordName:PERF_TAG("") andTime:[HMPerformance betweenTag:PERF_TAG1("") andTag:PERF_TAG2("")]];

#define PERF_LEAVE_( __X ) \
		[HMPerformance markTag:PERF_TAG2(#__X)]; \
		[HMPerformance recordName:PERF_TAG(#__X) andTime:[HMPerformance betweenTag:PERF_TAG1(#__X) andTag:PERF_TAG2(#__X)]];

#else	// #if defined(__HM_PERFORMANCE__) && __HM_PERFORMANCE__

#define	PERF_MARK( __TAG )
#define	PERF_TIME( __TAG1, __TAG2 )	(0.0f)

#define PERF_ENTER
#define PERF_LEAVE

#define PERF_ENTER_( __X )
#define PERF_LEAVE_( __X )

#endif	// #if defined(__HM_PERFORMANCE__) && __HM_PERFORMANCE__

#pragma mark -

@interface HMPerformance : NSObject

AS_SINGLETON( HMPerformance );

@property (nonatomic, readonly) NSMutableDictionary *	records;
@property (nonatomic, HM_STRONG) NSMutableDictionary *		tags;

+ (double)timestamp;

+ (double)markTag:(NSString *)tag;
+ (double)betweenTag:(NSString *)tag1 andTag:(NSString *)tag2;
+ (double)betweenTag:(NSString *)tag1 andTag:(NSString *)tag2 shouldRemove:(BOOL)remove;

+ (void)watchClass:(Class)clazz;
+ (void)watchClass:(Class)clazz andSelector:(SEL)selector;

+ (void)recordName:(NSString *)name andTime:(NSTimeInterval)time;

@end
