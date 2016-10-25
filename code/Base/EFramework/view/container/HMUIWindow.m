//
//  HMUIWindow.m
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIWindow.h"
#import "HMViewCategory.h"
#import "HMUIContainer.h"

#pragma mark -

#undef	D2R
#define D2R( __degree ) (M_PI / 180.0f * __degree)

#undef	MAX_DEPTH
#define MAX_DEPTH	(36)

#pragma mark -

@interface ServiceInspector_Layer : UIImageView

@property (nonatomic) CGFloat		depth;
@property (nonatomic) CGRect		rect;
@property (nonatomic, HM_WEAK) UIView *		view;
@property (nonatomic, HM_STRONG) UILabel *	label;

@end

#pragma mark -

@implementation ServiceInspector_Layer

@synthesize depth = _depth;
@synthesize rect = _rect;
@synthesize view = _view;
@synthesize label = _label;

- (void)load
{
	self.layer.shouldRasterize = YES;
	self.label = [[[UILabel alloc] init] autorelease];
	self.label.hidden = NO;
	self.label.textColor = [UIColor yellowColor];
	self.label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
	self.label.font = [UIFont boldSystemFontOfSize:12.0f];
	self.label.adjustsFontSizeToFitWidth = YES;
	self.label.textAlignment = UITextAlignmentCenter;
	[self addSubview:self.label];
}

- (void)unload
{
	[self.label removeFromSuperview];
	self.label = nil;
}

- (void)setFrame:(CGRect)f
{
	[super setFrame:f];
	
	CGRect labelFrame;
	labelFrame.size.width = fminf( 200.0f, f.size.width );
	labelFrame.size.height = fminf( 16.0f, f.size.height );
	labelFrame.origin.x = 0;
	labelFrame.origin.y = 0;
    
	self.label.frame = labelFrame;
}

@end
#pragma mark -

@interface HMUIWindow()
{
	float				_rotateX;
    float				_rotateY;
    float				_distance;
	BOOL				_animating;
	
	CGPoint				_panOffset;
	CGFloat				_pinchOffset;
	
	UIButton *          _showLabel;
	BOOL				_labelShown;
}

- (void)hide;
- (void)show;

- (void)buildLayers;
- (void)removeLayers;
- (void)transformLayers:(BOOL)flag;

@end
@implementation HMUIWindow
DEF_SINGLETON( HMUIWindow )
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self load];
    }
    return self;
}
- (id)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}
- (void)dealloc
{
    [self unload];
    HM_SUPER_DEALLOC();
}
- (void)load
{
	self.backgroundColor = [UIColor blackColor];
	self.hidden = YES;
	self.windowLevel = UIWindowLevelStatusBar + 99.0f;
	self.layer.shouldRasterize = YES;
    
	self.pannable = YES;
	self.pinchable = YES;
	
	_labelShown = NO;
	
	CGRect buttonFrame;
	buttonFrame.size.width = 100.0f;
	buttonFrame.size.height = 40.0f;
	buttonFrame.origin.x = 10.0f;
	buttonFrame.origin.y = self.frame.size.height - buttonFrame.size.height - 10.0f;
	
	_showLabel = [[UIButton alloc] initWithFrame:buttonFrame];
	_showLabel.hidden = NO;
	_showLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
	_showLabel.layer.cornerRadius = 6.0f;
	_showLabel.layer.borderColor = [UIColor grayColor].CGColor;
	_showLabel.layer.borderWidth = 2.0f;
    [_showLabel addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_showLabel setTitle:@"label (OFF)" forState:UIControlStateSelected];
    [_showLabel setTitle:@"label (ON)" forState:UIControlStateNormal];
	[self addSubview:_showLabel];
}

- (void)unload
{
	SAFE_RELEASE_SUBVIEW( _showLabel );
    
	[self removeLayers];
    
	self.pannable = NO;
	self.pinchable = NO;
}

- (CGFloat)buildSublayersFor:(UIView *)view depth:(CGFloat)depth origin:(CGPoint)origin
{
	if ( depth >= MAX_DEPTH )
		return 0;
	
	if ( view.hidden )
		return 0;
    
	if ( 0 == view.frame.size.width || 0 == view.frame.size.height )
		return 0;
	
	CGRect screenBound = [UIScreen mainScreen].bounds;
	CGRect viewFrame;
    CGPoint offsetPoint = CGPointZero;

    viewFrame.origin.x = origin.x + view.center.x - offsetPoint.x - view.bounds.size.width / 2.0f-([view.superview isKindOfClass:[UIScrollView class]]?[(UIScrollView *)view.superview contentOffset].x:0);
	viewFrame.origin.y = origin.y + view.center.y - offsetPoint.y - view.bounds.size.height / 2.0f-([view.superview isKindOfClass:[UIScrollView class]]?[(UIScrollView *)view.superview contentOffset].y:0);
	viewFrame.size.width = view.bounds.size.width;
	viewFrame.size.height = view.bounds.size.height;
    
	CGFloat overflowWidth = screenBound.size.width * 1.5;
	CGFloat overflowHeight = screenBound.size.height * 1.5;
	
	if ( CGRectGetMaxX(viewFrame) < -overflowWidth || CGRectGetMinX(viewFrame) > (screenBound.size.width + overflowWidth) )
		return 0;
	if ( CGRectGetMaxY(viewFrame) < -overflowHeight || CGRectGetMinY(viewFrame) > (screenBound.size.height + overflowHeight) )
		return 0;
    
    //	INFO( @"view = %@", [[view class] description] );
	
	ServiceInspector_Layer * layer = [[ServiceInspector_Layer alloc] init];
	if ( layer )
	{
		NSString * classType = [[view class] description];
		if ( [classType isEqualToString:@"UIWindow"] )
		{
			layer.backgroundColor = RGB( 1, 59, 79 );
		}
		else if ( [classType isEqualToString:@"UILayoutContainerView"] )
		{
			layer.backgroundColor = RGB( 2, 84, 112 );
		}
		else if ( [classType isEqualToString:@"UINavigationTransitionView"] )
		{
			layer.backgroundColor = RGB( 4, 106, 141 );
		}
		else if ( [classType isEqualToString:@"UIViewControllerWrapperView"] )
		{
			layer.backgroundColor = RGB( 6, 141, 187 );
		}
		else
		{
			layer.backgroundColor = [UIColor blackColor];
		}
        

        layer.layer.borderWidth = 2.0f;
        layer.layer.borderColor = HEX_RGB( 0x39b54a ).CGColor;
		
		layer.backgroundColor = [layer.backgroundColor colorWithAlphaComponent:0.1f];
        
		CGPoint anchor;
		anchor.x = (screenBound.size.width / 2.0f - viewFrame.origin.x) / viewFrame.size.width;
		anchor.y = (screenBound.size.height / 2.0f - viewFrame.origin.y) / viewFrame.size.height;
        
		layer.view = view;
		
		if ( view.tagString )
		{
			layer.label.text = [NSString stringWithFormat:@"#%@", view.tagString];
			layer.label.textColor = [UIColor yellowColor];
		}
		else
		{
			layer.label.text =  [[view class] description];
			layer.label.textColor = [UIColor yellowColor];
		}
		
		layer.label.hidden = _labelShown ? NO : YES;
		layer.rect = viewFrame;
		layer.depth = depth;
		layer.frame = viewFrame;
		layer.image = view.screenshotOneLayer;
		layer.layer.anchorPoint = anchor;
		layer.layer.anchorPointZ = (layer.depth * -1.0f) * 75.0f;
		[self addSubview:layer];
        
		[layer release];
	}
    CGFloat dep = layer.depth;
	for ( UIView * subview in view.subviews )
	{
		dep = [self buildSublayersFor:subview depth:(depth + 1 + [view.subviews indexOfObject:subview] * 0.005f) origin:layer.rect.origin];
	}
    return dep;
}
- (void)buildLayers
{

    CGFloat depth=0;
    for (NSInteger i = [UIApplication sharedApplication].windows.count-1 ;i>=0;i--) {
        
        UIWindow *window =[UIApplication sharedApplication].windows[i];
        if ([window isKindOfClass:[HMUIWindow class]]||[window isKindOfClass:NSClassFromString(@"HMDEBUGWindow")]||[window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
            continue;
        }
        depth = [self buildSublayersFor:window depth:depth origin:CGPointZero];
    }
}

- (void)removeLayers
{
	NSArray * subviewsCopy = [NSArray arrayWithArray:self.subviews];
    
	for ( UIView * subview in subviewsCopy )
	{
		if ( [subview isKindOfClass:[ServiceInspector_Layer class]] )
		{
			[subview removeFromSuperview];
		}
	}
}

- (void)transformLayers:(BOOL)setFrames
{
    CATransform3D transform2 = CATransform3DIdentity;
    transform2.m34 = -0.001;
	transform2 = CATransform3DTranslate( transform2, _rotateY * -2.5f, 0, 0 );
	transform2 = CATransform3DTranslate( transform2, 0, _rotateX * 3.5f, 0 );
    
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DMakeTranslation( 0, 0, _distance * 1000 );
    transform = CATransform3DConcat( CATransform3DMakeRotation(D2R(_rotateX), 1, 0, 0), transform );
    transform = CATransform3DConcat( CATransform3DMakeRotation(D2R(_rotateY), 0, 1, 0), transform );
    transform = CATransform3DConcat( CATransform3DMakeRotation(D2R(0), 0, 0, 1), transform );
    transform = CATransform3DConcat( transform, transform2 );
    
	NSArray * subviewsCopy = [NSArray arrayWithArray:self.subviews];
    
	for ( UIView * subview in subviewsCopy )
	{
		if ( [subview isKindOfClass:[ServiceInspector_Layer class]] )
		{
			ServiceInspector_Layer * layer = (ServiceInspector_Layer *)subview;
			layer.frame = layer.rect;
            
			if ( _animating )
			{
				layer.layer.transform = CATransform3DIdentity;
			}
			else
			{
				layer.layer.transform = transform;
			}
			
			[layer setNeedsDisplay];
		}
	}
}

- (void)prepareShow
{
	[self setHidden:NO];
    
	[self removeLayers];
	[self buildLayers];
    
	_rotateX = 0.0f;
	_rotateY = 0.0f;
	_distance = 0.0f;
	_animating = YES;
	
    //	[self setAlpha:1.0f];
	[self transformLayers:YES];
}

- (void)show
{
	_rotateX = -20.0f;
	_rotateY = 0.0f;
	_distance = -1.25f;
	_animating = NO;
    
    //	[self setAlpha:1.0f];
	[self transformLayers:NO];
    
}
-(void)showWithAnimate{
    [[HMUIWindow sharedInstance] prepareShow];
	
	[UIView beginAnimations:@"OPEN" context:nil];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	[[HMUIWindow sharedInstance] show];
	
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }
	window.alpha = 0.0f;
	
	[UIView commitAnimations];
}

- (void)prepareHide
{
	_rotateX = 0.0f;
	_rotateY = 0.0f;
	_distance = 0.0f;
	_animating = YES;
    
    //	[self setAlpha:0.0f];
	[self transformLayers:YES];
}

- (void)hide
{
	_animating = NO;
    
	[self removeLayers];
	
    //	[self setAlpha:0.0f];
	[self setHidden:YES];
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }
    [window makeKeyAndVisible];
}

- (void)buttonClicked:(UIButton*)btn{
    _labelShown = _labelShown ? NO : YES;
	
	btn.selected =_labelShown;
    
	for ( ServiceInspector_Layer * layer in self.subviews )
	{
		if ( [layer isKindOfClass:[ServiceInspector_Layer class]] )
		{
			layer.label.hidden = _labelShown ? NO : YES;
		}
	}
}

ON_PAN(signal){
    UIPanGestureRecognizer *pan = signal.inputValue;
    if (pan.state == UIGestureRecognizerStateBegan) {
        _panOffset.x = _rotateY;
        _panOffset.y = _rotateX * -1.0f;
    }else if (pan.state == UIGestureRecognizerStateChanged){
        _rotateY = _panOffset.x + self.panOffset.x * 0.5f;
        _rotateX = _panOffset.y * -1.0f - self.panOffset.y * 0.5f;
        
        [self transformLayers:NO];
    }else if (pan.state == UIGestureRecognizerStateCancelled){
        
    }
}

ON_PINCH(signal){
    UIPinchGestureRecognizer *pan = signal.inputValue;
    if (pan.state == UIGestureRecognizerStateBegan) {
        _pinchOffset = _distance;
    }else if (pan.state == UIGestureRecognizerStateChanged){
        _distance = _pinchOffset + (self.pinchScale - 1);
        _distance = (_distance < -5 ? -5 : (_distance > 0.5 ? 0.5 : _distance));
        
        [self transformLayers:NO];
    }else if (pan.state == UIGestureRecognizerStateCancelled){
        
    }
}

@end


#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#if (__ON__ == __HM_DEVELOPMENT__)
@implementation HMDEBUGWindow{
    UIButton *          _showLabel;
    BOOL                isHide;
}

DEF_SINGLETON(HMDEBUGWindow)

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self load];
}
- (id)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}
- (void)dealloc
{
    [self unload];
    HM_SUPER_DEALLOC();
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(_showLabel.frame, point)) {
        return YES;
    }
    return NO;
}

-(void)load{
    CGRect screenBound = [UIScreen mainScreen].bounds;
	CGRect shortcutFrame = screenBound;
//	shortcutFrame.size.width = 40.0f;
//	shortcutFrame.size.height = 40.0f;
//	shortcutFrame.origin.x = CGRectGetMaxX(screenBound) - shortcutFrame.size.width;
//	shortcutFrame.origin.y = CGRectGetMaxY(screenBound) - shortcutFrame.size.height * 2 - 44.0f;
    
	self.frame = shortcutFrame;
	self.backgroundColor = [UIColor clearColor];
	self.hidden = NO;
	self.windowLevel = UIWindowLevelStatusBar + 1004;
    
	CGRect buttonFrame;
	buttonFrame.origin = CGPointMake((shortcutFrame.size.width/2+50), 0);
	buttonFrame.size.width = 40.0f;
	buttonFrame.size.height = 40.0f;
    
    _showLabel = [[UIButton alloc] initWithFrame:buttonFrame];
	_showLabel.hidden = NO;
	_showLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
	_showLabel.layer.cornerRadius = 6.0f;
	_showLabel.layer.borderColor = [UIColor grayColor].CGColor;
	_showLabel.layer.borderWidth = 2.0f;
    [_showLabel addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_showLabel setTitle:@"OFF" forState:UIControlStateSelected];
    [_showLabel setTitle:@"ON" forState:UIControlStateNormal];
	[self addSubview:_showLabel];
    [self performSelector:@selector(timeToHide) withObject:nil afterDelay:10.f];

    self.rootViewController = [[UIViewController alloc]init];
    self.rootViewController.view.userInteractionEnabled = NO;
    self.rootViewController.view.backgroundColor = [UIColor clearColor];
}
-(void)unload{
    SAFE_RELEASE_SUBVIEW(_showLabel);
}


- (void)didClose
{
	[[HMUIWindow sharedInstance] hide];

}

- (void)timeToHide{
//    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:.25f animations:^{
        _showLabel.y = -20;
    }completion:^(BOOL finished) {
//        self.userInteractionEnabled = YES;
        isHide = YES;
    }];

}

- (void)buttonClicked:(UIButton*)btn{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeToHide) object:nil];
    
    [self performSelector:@selector(timeToHide) withObject:nil afterDelay:15.f];
    
    if (isHide) {
        [UIView animateWithDuration:.25f animations:^{
            btn.y = 0;
        }];
        isHide = NO;
        return;
    }
    
	btn.selected = !btn.selected;
    if (btn.selected) {
        
        [[HMUIWindow sharedInstance] prepareShow];
        
        [UIView beginAnimations:@"OPEN" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [[HMUIWindow sharedInstance] show];
        
        UIWindow *window = nil;
        if (![HMUIApplication sharedInstance].window) {
            window = [UIApplication sharedApplication].keyWindow;
        }else{
            window = [HMUIApplication sharedInstance].window;
        }
        window.alpha = 0.0f;
        
        [UIView commitAnimations];
    }else{
        [UIView beginAnimations:@"CLOSE" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didClose)];
        
        UIWindow *window = nil;
        if (![HMUIApplication sharedInstance].window) {
            window = [UIApplication sharedApplication].keyWindow;
        }else{
            window = [HMUIApplication sharedInstance].window;
        }
        window.alpha = 1.0f;
        window.layer.transform = CATransform3DIdentity;
        
        [[HMUIWindow sharedInstance] prepareHide];
        
        [UIView commitAnimations];
    }
}
@end
#pragma mark -

@interface UIWindow(ServiceInspectorPrivate)
- (void)mySendEvent:(UIEvent *)event;
@end

#pragma mark -

@implementation UIWindow(ServiceInspector)

DEF_NOTIFICATION( TOUCH_BEGAN );
DEF_NOTIFICATION( TOUCH_MOVED );
DEF_NOTIFICATION( TOUCH_ENDED );


static BOOL	__blocked = NO;
static void (*__sendEvent)( id, SEL, UIEvent * );

+ (void)hook
{
	static BOOL __swizzled = NO;
	if ( NO == __swizzled )
	{
		Method method;
		IMP implement;
        
		method = class_getInstanceMethod( [UIWindow class], @selector(sendEvent:) );
		__sendEvent = (void *)method_getImplementation( method );
		
		implement = class_getMethodImplementation( [UIWindow class], @selector(mySendEvent:) );
		method_setImplementation( method, implement );
		
		__swizzled = YES;
	}
}

+ (void)block:(BOOL)flag
{
	__blocked = flag;
}


- (void)mySendEvent:(UIEvent *)event
{
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }
    
	UIWindow * keyWindow = window;
	if ( self == keyWindow )
	{
		if ( UIEventTypeTouches == event.type )
		{
			NSSet * allTouches = [event allTouches];
			if ( 1 == [allTouches count] )
			{
				UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
				if ( 1 == [touch tapCount] )
				{
//					if ( UITouchPhaseBegan == touch.phase )
//					{
//						[self postNotification:self.TOUCH_BEGAN withObject:touch];
//                        
////						INFO( @"view '%@', touch began\n%@", [[touch.view class] description], [touch.view description] );
////						
////						ServiceInspector_Border * border = [ServiceInspector_Border new];
////						border.frame = touch.view.bounds;
////						[touch.view addSubview:border];
////						[border startAnimation];
////						[border release];
//					}
//					else if ( UITouchPhaseMoved == touch.phase )
//					{
//						[self postNotification:self.TOUCH_MOVED withObject:touch];
//					}
//					else if ( UITouchPhaseEnded == touch.phase || UITouchPhaseCancelled == touch.phase )
//					{
//						[self postNotification:self.TOUCH_ENDED withObject:touch];
//                        
////						INFO( @"view '%@', touch ended\n%@", [[touch.view class] description], [touch.view description] );
////                        
////						ServiceInspector_Indicator * indicator = [ServiceInspector_Indicator new];
////						indicator.frame = CGRectMake( 0, 0, 50.0f, 50.0f );
////						indicator.center = [touch locationInView:keyWindow];
////						[keyWindow addSubview:indicator];
////						[indicator startAnimation];
////						[indicator release];
//					}
				}
			}
		}
	}
    
	if ( NO == __blocked )
	{
		if ( __sendEvent )
		{
			__sendEvent( self, _cmd, event );
		}
	}
}

@end

#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
