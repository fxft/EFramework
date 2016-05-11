
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "HMMacros.h"
#import "HMEvent.h"

#pragma mark -

@interface UIView(HoldGesture)

AS_SIGNAL( HOLD )		// 长按

@property (nonatomic) BOOL								holdable;		// same as holdEnabled
@property (nonatomic) BOOL								holdEnabled;
@property (nonatomic, readonly) UILongPressGestureRecognizer *	holdGesture;

@end

#pragma mark -
#undef	ON_HOLD
#define ON_HOLD( signal )		ON_SIGNAL3( UIView, HOLD, signal)


@protocol ON_HOLD_handle <NSObject>

@optional
ON_HOLD( signal );


@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
