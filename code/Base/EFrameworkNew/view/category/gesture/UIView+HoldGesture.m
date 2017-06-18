

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "UIView+HoldGesture.h"

#pragma mark -

@interface __LongPressGestureRecognizer : UILongPressGestureRecognizer
@end

#pragma mark -

@implementation __LongPressGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	if ( self )
	{
		self.numberOfTapsRequired = 1;
		self.numberOfTouchesRequired = 1;
		self.cancelsTouchesInView = YES;
		self.delaysTouchesBegan = YES;
		self.delaysTouchesEnded = YES;
		self.minimumPressDuration = 1.0f;
		self.allowableMovement = 10;
	}
	return self;
}

- (void)dealloc
{
	HM_SUPER_DEALLOC();
}

@end

#pragma mark -

@interface UIView(HoldGesturePrivate)
- (void)didLongPressIntent:(UILongPressGestureRecognizer *)pressGesture;
@end

#pragma mark -

@implementation UIView(HoldGesture)

DEF_SIGNAL( HOLD )

@dynamic holdable;
@dynamic holdEnabled;
@dynamic holdGesture;

- (BOOL)holdable
{
	return self.holdGesture.enabled;
}

- (void)setHoldable:(BOOL)flag
{
	self.holdGesture.enabled = flag;
}

- (BOOL)holdEnabled
{
	return self.holdGesture.enabled;
}

- (void)setHoldEnabled:(BOOL)flag
{
	self.holdGesture.enabled = flag;
}

- (UILongPressGestureRecognizer *)holdGesture
{
	UILongPressGestureRecognizer * pressGesture = nil;
	
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__LongPressGestureRecognizer class]] )
		{
			pressGesture = (UILongPressGestureRecognizer *)gesture;
		}
	}

	if ( nil == pressGesture )
	{
		pressGesture = [[[__LongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressIntent:)] autorelease];
		[self addGestureRecognizer:pressGesture];
	}
	
	return pressGesture;
}

- (void)didLongPressIntent:(UILongPressGestureRecognizer *)pressGesture
{
    [self sendSignal:UIView.HOLD withObject:pressGesture];
	
}

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
