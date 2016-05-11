

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "HMMacros.h"
#import "HMEvent.h"

#pragma mark -

@interface UIView(PanGesture)

AS_SIGNAL( PAN )				// 左右滑动

@property (nonatomic) BOOL                                      pannable;	// same as panEnabled
@property (nonatomic) BOOL                                      panEnabled;
@property (nonatomic, readonly) CGPoint							panOffset;
@property (nonatomic, readonly) UIPanGestureRecognizer *		panGesture;

@end

#pragma mark -


#undef	ON_PAN
#define ON_PAN( signal )		ON_SIGNAL3( UIView, PAN, signal)


@protocol ON_PAN_handle <NSObject>
@optional
ON_PAN( signal );

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
