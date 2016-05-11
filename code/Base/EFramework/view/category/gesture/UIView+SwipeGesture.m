
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "UIView+SwipeGesture.h"

#pragma mark -

@interface __SwipeGestureRecognizer : UISwipeGestureRecognizer
@end

#pragma mark -

@implementation __SwipeGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
	self = [super initWithTarget:target action:action];
	if ( self )
	{
		self.numberOfTouchesRequired = 1;
	}
	return self;
}

- (void)dealloc
{
    HM_SUPER_DEALLOC();
}

@end

#pragma mark -

@interface UIView(SwipeGesturePrivate)
- (void)didSwipeIntent:(UISwipeGestureRecognizer *)swipeGesture;
@end

#pragma mark -

@implementation UIView(SwipeGesture)

DEF_SIGNAL( SWIPE_UP )
DEF_SIGNAL( SWIPE_DOWN )
DEF_SIGNAL( SWIPE_LEFT )
DEF_SIGNAL( SWIPE_RIGHT )

@dynamic swipeUpEnabled;
@dynamic swipeUpGesture;

@dynamic swipeDownEnabled;
@dynamic swipeDownGesture;

@dynamic swipeLeftEnabled;
@dynamic swipeLeftGesture;

@dynamic swipeRightEnabled;
@dynamic swipeRightGesture;

- (BOOL)swipeUpEnabled
{
	return self.swipeUpGesture.enabled;
}

- (void)setSwipeUpEnabled:(BOOL)flag
{
	self.swipeUpGesture.enabled = flag;
}

- (UISwipeGestureRecognizer *)swipeUpGesture{
    return [self swipeGesture:UISwipeGestureRecognizerDirectionUp];
}

- (BOOL)swipeDownEnabled
{
    return self.swipeDownGesture.enabled;
}

- (void)setSwipeDownEnabled:(BOOL)flag
{
    self.swipeDownGesture.enabled = flag;
}

- (UISwipeGestureRecognizer *)swipeDownGesture{
    return [self swipeGesture:UISwipeGestureRecognizerDirectionDown];
}

- (BOOL)swipeLeftEnabled
{
    return self.swipeLeftGesture.enabled;
}

- (void)setSwipeLeftEnabled:(BOOL)flag
{
    self.swipeLeftGesture.enabled = flag;
}

- (UISwipeGestureRecognizer *)swipeLeftGesture{
    return [self swipeGesture:UISwipeGestureRecognizerDirectionLeft];
}

- (BOOL)swipeRightEnabled
{
    return self.swipeRightGesture.enabled;
}

- (void)setSwipeRightEnabled:(BOOL)flag
{
    self.swipeRightGesture.enabled = flag;
}

- (UISwipeGestureRecognizer *)swipeRightGesture{
    return [self swipeGesture:UISwipeGestureRecognizerDirectionRight];
}


- (UISwipeGestureRecognizer *)swipeGesture:(UISwipeGestureRecognizerDirection)direction
{
	UISwipeGestureRecognizer * swipeGesture = nil;
	
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__SwipeGestureRecognizer class]]&& !!([(__SwipeGestureRecognizer*)gesture direction]&direction) )
		{
			swipeGesture = (UISwipeGestureRecognizer *)gesture;
		}
	}

	if ( nil == swipeGesture )
	{
		swipeGesture = [[[__SwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeIntent:)] autorelease];
      swipeGesture.direction = direction;
		[self addGestureRecognizer:swipeGesture];
	}
	
	return swipeGesture;
}

- (void)didSwipeIntent:(UISwipeGestureRecognizer *)swipeGesture
{
	if ( UIGestureRecognizerStateEnded == swipeGesture.state )
	{
		if ( UISwipeGestureRecognizerDirectionUp & swipeGesture.direction ){
			[self sendSignal:UIView.SWIPE_UP];
		}else if ( UISwipeGestureRecognizerDirectionDown & swipeGesture.direction ){
			[self sendSignal:UIView.SWIPE_DOWN];
		}else	if ( UISwipeGestureRecognizerDirectionLeft & swipeGesture.direction ){
			[self sendSignal:UIView.SWIPE_LEFT];
		}else	if ( UISwipeGestureRecognizerDirectionRight & swipeGesture.direction ){
			[self sendSignal:UIView.SWIPE_RIGHT];
		}
	}
}

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
