

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "HMMacros.h"
#import "HMEvent.h"

#pragma mark -

@interface UIView(PinchGesture)

AS_SIGNAL( PINCH )			// 左右滑动开始

@property (nonatomic) BOOL								pinchable;		// same as pinchEnabled
@property (nonatomic) BOOL								pinchEnabled;
@property (nonatomic, readonly) CGFloat							pinchScale;
@property (nonatomic, readonly) CGFloat							pinchVelocity;
@property (nonatomic, readonly) UIPinchGestureRecognizer *		pinchGesture;

@end

#pragma mark -

#undef	ON_PINCH
#define ON_PINCH( signal )		ON_SIGNAL3( UIView, PINCH, signal)

@protocol ON_PINCH_handle <NSObject>
@optional
ON_PINCH( signal );

@end
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
