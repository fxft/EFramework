

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "UIView+TapGesture.h"

#pragma mark -

@interface __SingleTapGestureRecognizer : UITapGestureRecognizer
{
	NSString *	_signalName;
}

@property (nonatomic, copy) NSString *	signalName;

@end

#pragma mark -

@implementation __SingleTapGestureRecognizer

@synthesize signalName = _signalName;

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
	}
	return self;
}

- (void)dealloc
{
    self.signalName = nil;
	HM_SUPER_DEALLOC();
}

@end

#pragma mark -

@interface UIView(TapGesturePrivate)
- (void)didSingleTappedIntent:(UITapGestureRecognizer *)tapGesture;
@end

#pragma mark -

@implementation UIView(TapGesture)

DEF_SIGNAL( TAPPED );

@dynamic tappable;
@dynamic tapEnabled;
@dynamic tapGesture;
@dynamic tapSignal;


- (BOOL)tappable
{
	return self.tapEnabled;
}

- (void)setTappable:(BOOL)flag
{
	self.tapEnabled = flag;
}

- (BOOL)tapEnabled
{
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__SingleTapGestureRecognizer class]] )
		{
			return gesture.enabled;
		}
	}
	
	return NO;
}

- (void)setTapEnabled:(BOOL)flag
{
	__SingleTapGestureRecognizer * singleTapGesture = (__SingleTapGestureRecognizer *)self.tapGesture;
	if ( singleTapGesture )
	{
		if ( flag )
		{
			self.userInteractionEnabled = YES;
		}
		else
		{
			self.userInteractionEnabled = NO;
		}
		
		singleTapGesture.enabled = flag;
	}
}

- (UITapGestureRecognizer *)tapGesture
{
	__SingleTapGestureRecognizer * tapGesture = nil;
	
	for ( UIGestureRecognizer * gesture in self.gestureRecognizers )
	{
		if ( [gesture isKindOfClass:[__SingleTapGestureRecognizer class]] )
		{
			tapGesture = (__SingleTapGestureRecognizer *)gesture;
		}
	}
	
	if ( nil == tapGesture )
	{
		tapGesture = [[[__SingleTapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTappedIntent:)] autorelease];
		[self addGestureRecognizer:tapGesture];
	}
	
	return tapGesture;
}

- (NSString *)tapSignal
{
	__SingleTapGestureRecognizer * singleTapGesture = (__SingleTapGestureRecognizer *)self.tapGesture;
	if ( singleTapGesture )
	{
		return singleTapGesture.signalName;
	}
	
	return nil;
}

- (void)setTapSignal:(NSString *)signal
{
	__SingleTapGestureRecognizer * singleTapGesture = (__SingleTapGestureRecognizer *)self.tapGesture;
	if ( singleTapGesture )
	{
		singleTapGesture.signalName = signal;
	}
}

- (void)didSingleTappedIntent:(UITapGestureRecognizer *)tapGesture
{
	if ( [tapGesture isKindOfClass:[__SingleTapGestureRecognizer class]] )
	{
		__SingleTapGestureRecognizer * singleTapGesture = (__SingleTapGestureRecognizer *)tapGesture;
        
		if ( UIGestureRecognizerStateEnded == singleTapGesture.state )
		{
        
            [self sendSignal:UIView.TAPPED];
			
		}
	}
}

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
