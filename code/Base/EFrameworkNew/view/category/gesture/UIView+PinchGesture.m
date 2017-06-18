

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "UIView+PinchGesture.h"

#pragma mark -

@interface __PinchGestureRecognizer : UIPinchGestureRecognizer
@end

@implementation __PinchGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	if ( self )
	{
	}
	return self;
}

- (void)dealloc
{
	HM_SUPER_DEALLOC();
}

@end

#pragma mark -

@interface UIView(PinchGesturePrivate)
- (void)didPinchIntent:(UIPinchGestureRecognizer *)panGesture;
@end

#pragma mark -

@implementation UIView(PinchGesture)

DEF_SIGNAL( PINCH )

@dynamic pinchable;		// same as pinchEnabled
@dynamic pinchEnabled;
@dynamic pinchScale;
@dynamic pinchVelocity;
@dynamic pinchGesture;

- (BOOL)pinchable
{
	return self.pinchGesture.enabled;
}

- (void)setPinchable:(BOOL)flag
{
	self.pinchGesture.enabled = flag;
}

- (BOOL)pinchEnabled
{
	return self.pinchGesture.enabled;
}

- (void)setPinchEnabled:(BOOL)flag
{
	self.pinchGesture.enabled = flag;
}

- (CGFloat)pinchScale
{
	UIPinchGestureRecognizer * gesture = self.pinchGesture;
	if ( nil == gesture )
	{
		return 1.0f;
	}
	
	return gesture.scale;
}

- (UIPinchGestureRecognizer *)pinchGesture
{
	UIPinchGestureRecognizer * pinchGesture = nil;
	
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__PinchGestureRecognizer class]] )
		{
			pinchGesture = (UIPinchGestureRecognizer *)gesture;
		}
	}
	
	if ( nil == pinchGesture )
	{
		pinchGesture = [[[__PinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchIntent:)] autorelease];
		[self addGestureRecognizer:pinchGesture];
	}

	return pinchGesture;
}

- (void)didPinchIntent:(UIPinchGestureRecognizer *)pinchGesture
{
	[self sendSignal:UIView.PINCH withObject:pinchGesture];
}

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
