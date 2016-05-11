
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "HMMacros.h"
#import "HMEvent.h"

#pragma mark -

@interface UIView(SwipeGesture)

AS_SIGNAL( SWIPE_UP )		// 瞬间向上滑动
AS_SIGNAL( SWIPE_DOWN )		// 瞬间向下滑动
AS_SIGNAL( SWIPE_LEFT )		// 瞬间向左滑动
AS_SIGNAL( SWIPE_RIGHT )	// 瞬间向右滑动

@property (nonatomic) BOOL								swipeUpEnabled;
@property (nonatomic) BOOL								swipeDownEnabled;
@property (nonatomic) BOOL								swipeLeftEnabled;
@property (nonatomic) BOOL								swipeRightEnabled;

@property (nonatomic, readonly) UISwipeGestureRecognizer *		swipeUpGesture;
@property (nonatomic, readonly) UISwipeGestureRecognizer *		swipeDownGesture;
@property (nonatomic, readonly) UISwipeGestureRecognizer *		swipeLeftGesture;
@property (nonatomic, readonly) UISwipeGestureRecognizer *		swipeRightGesture;

@end

#pragma mark -

#undef	ON_SWIPE_UP
#define ON_SWIPE_UP( signal )		ON_SIGNAL3( UIView, SWIPE_UP, signal )

#undef	ON_SWIPE_DOWN
#define ON_SWIPE_DOWN( signal )		ON_SIGNAL3( UIView, SWIPE_DOWN, signal )

#undef	ON_SWIPE_LEFT
#define ON_SWIPE_LEFT( signal )		ON_SIGNAL3( UIView, SWIPE_LEFT, signal )

#undef	ON_SWIPE_RIGHT
#define ON_SWIPE_RIGHT( signal )	ON_SIGNAL3( UIView, SWIPE_RIGHT, signal )

@protocol ON_SWIPE_handle <NSObject>
@optional
ON_SWIPE_UP( signal );
ON_SWIPE_DOWN( signal );
ON_SWIPE_LEFT( signal );
ON_SWIPE_RIGHT( signal );

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
