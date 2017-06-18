

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "UIView+PanGesture.h"


#pragma mark -

@interface __PanGestureRecognizer : UIPanGestureRecognizer
@end

@implementation __PanGestureRecognizer

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

@interface UIView(PanGesturePrivate)
- (void)didPanIntent:(UIPanGestureRecognizer *)panGesture;
@end

#pragma mark -

@implementation UIView(PanGesture)
DEF_SIGNAL( PAN )

@dynamic pannable;
@dynamic panEnabled;
@dynamic panOffset;
@dynamic panGesture;

- (BOOL)pannable
{
	return self.panGesture.enabled;
}

- (void)setPannable:(BOOL)flag
{
	self.panGesture.enabled = flag;
}

- (BOOL)panEnabled
{
	return self.panGesture.enabled;
}

- (void)setPanEnabled:(BOOL)flag
{
	self.panGesture.enabled = flag;
}

- (CGPoint)panOffset
{
	return [self.panGesture translationInView:self];
}

- (UIPanGestureRecognizer *)panGesture
{
	UIPanGestureRecognizer * panGesture = nil;
	
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__PanGestureRecognizer class]] )
		{
			panGesture = (UIPanGestureRecognizer *)gesture;
		}
	}
	
	if ( nil == panGesture )
	{
		panGesture = [[[__PanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanIntent:)] autorelease];
        panGesture.enabled = NO;
		[self addGestureRecognizer:panGesture];
	}

	return panGesture;
}

- (void)didPanIntent:(UIPanGestureRecognizer *)panGesture
{
    [self sendSignal:UIView.PAN withObject:panGesture];

}

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
