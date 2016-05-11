
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "HMMacros.h"
#import "HMEvent.h"

#pragma mark -

@interface UIView(TapGesture)

@property (nonatomic) BOOL							tappable;	// same as tapEnabled
@property (nonatomic) BOOL							tapEnabled;
@property (nonatomic, HM_STRONG) NSString *					tapSignal;
@property (nonatomic, readonly) UITapGestureRecognizer *	tapGesture;

AS_EVENT( TAPPED );	// 单击

@end

#pragma mark -

#undef	ON_TAPPED
#define ON_TAPPED( signal )		ON_SIGNAL3( UIView, TAPPED, signal )
@protocol ON_TAPPED_handle <NSObject>

ON_TAPPED( signal );

@end
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
