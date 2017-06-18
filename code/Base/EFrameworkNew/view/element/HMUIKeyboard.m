//
//  HMUIKeyboard.m
//  CarAssistant
//
//  Created by Eric on 14-3-19.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIKeyboard.h"

#undef	DEFAULT_KEYBOARD_HEIGHT
#define	DEFAULT_KEYBOARD_HEIGHT	(216.0f)

@interface UIResponder (KeyBoard)



@end

@implementation UIResponder (KeyBoard)
static BOOL	__blocked = NO;
static BOOL (*__becomeFirstResponder)( id, SEL );
static BOOL (*__resignFirstResponder)( id, SEL );

+ (void)hook
{
    static BOOL __swizzled = NO;
    if ( NO == __swizzled )
    {
        __becomeFirstResponder = (void*)[UIResponder swizzleSelector:@selector(becomeFirstResponder) withIMP:@selector(mybecomeFirstResponder)];
        
        __resignFirstResponder = (void*)[UIResponder swizzleSelector:@selector(resignFirstResponder) withIMP:@selector(myresignFirstResponder)];
        __swizzled = YES;
    }
}

+ (void)block:(BOOL)flag
{
    __blocked = flag;
}

- (BOOL)myresignFirstResponder{
    BOOL ret = NO;
    
    if ( __resignFirstResponder )
    {
        ret = __resignFirstResponder( self, _cmd );
    }
    if (ret&&([self isKindOfClass:[UITextField class]]||[self isKindOfClass:[UITextView class]])) {
        [HMUIKeyboard sharedInstance].lastResponder = nil;
    }
    
    return ret;
}

- (BOOL)mybecomeFirstResponder
{
    BOOL ret = NO;
    
    if (([self isKindOfClass:[UITextField class]]||[self isKindOfClass:[UITextView class]])&&[(UITextField*)self inputAccessoryView]==nil) {
        [(UITextField*)self setInputAccessoryView:[UIView spawn]];
    }
    
    if ( __becomeFirstResponder )
    {
        ret = __becomeFirstResponder( self, _cmd );
    }
    if (ret&&([self isKindOfClass:[UITextField class]]||[self isKindOfClass:[UITextView class]])) {
        [HMUIKeyboard sharedInstance].lastResponder = self;
    }
    
    return ret;
}

@end

@interface HMUIKeyboard()
{
	BOOL		_shown;
	BOOL		_animating;
	CGFloat		_height;
	
	CGRect		_accessorFrame;
    CGRect      _accessorRectInWindow;
//	__weak_type UIView *	_accessor;
	CGRect		_accessorVisableRect;
    
	NSTimeInterval			_animationDuration;
	UIViewAnimationCurve	_animationCurve;
    CGAffineTransform       _defultTransform;
}
@property (nonatomic) CGRect					accessorVisableRect;

@end

@implementation HMUIKeyboard


DEF_SINGLETON( HMUIKeyboard )

DEF_NOTIFICATION( SHOWN );
DEF_NOTIFICATION( HIDDEN );
DEF_NOTIFICATION( HEIGHT_CHANGED );

@synthesize shown = _shown;
@synthesize animating = _animating;
@synthesize height = _height;
@synthesize accessor = _accessor;
@synthesize accessorVisableRect = _accessorVisableRect;
@synthesize accessorBlock;
@synthesize visabler = _visabler;
@synthesize animationDuration = _animationDuration;
@synthesize animationCurve = _animationCurve;
@synthesize lastResponder = _lastResponder;

+ (BOOL)autoLoad
{
    [HMUIKeyboard sharedInstance];
    [UIResponder hook];
	return YES;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		_shown = NO;
		_animating = NO;
		_height = DEFAULT_KEYBOARD_HEIGHT;
        
		_accessorFrame = CGRectZero;
		self.accessor = nil;
        
		[self observeNotification:UIKeyboardDidShowNotification];
		[self observeNotification:UIKeyboardDidHideNotification];
		[self observeNotification:UIKeyboardWillChangeFrameNotification];
	}
	return self;
}

- (void)handleNotification:(NSNotification *)notification
{
	BOOL animated = YES;
	
	NSDictionary * userInfo = (NSDictionary *)[notification userInfo];
	if ( userInfo )
	{
		[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&_animationCurve];
		[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&_animationDuration];
	}
	BOOL Landscape = ([[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeLeft||[[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeRight);
    
    if ( [notification is:UIKeyboardDidShowNotification] )
	{
		if ( NO == _shown )
		{
			_shown = YES;
			[self postNotification:self.SHOWN];
		}
		
		NSValue * value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
		if ( value )
		{
			CGRect	keyboardEndFrame = [value CGRectValue];

            CGFloat	keyboardHeight = !Landscape?keyboardEndFrame.size.height:(IOS8_OR_LATER?keyboardEndFrame.size.height:keyboardEndFrame.size.width);

			if ( keyboardHeight != _height )
			{
				_height = keyboardHeight;
				
				[self postNotification:self.HEIGHT_CHANGED];
				animated = NO;
			}
		}
        return ;
	}
	else if ( [notification is:UIKeyboardWillChangeFrameNotification] )
	{
		NSValue * value1 = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
		NSValue * value2 = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
		if ( value1 && value2 )
		{
			CGRect rect1 = [value1 CGRectValue];
			CGRect rect2 = [value2 CGRectValue];
            
            CGFloat containerHeight = !Landscape?[UIScreen mainScreen].bounds.size.height:(IOS8_OR_LATER?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width);
            
			if ( rect1.origin.y == containerHeight
                || rect1.origin.x <= -rect1.size.width
                || rect1.origin.x >= containerHeight
                ||(rect1.origin.x==rect2.origin.x&&Landscape&&rect1.origin.y==0)
                ||(rect1.origin.y==rect2.origin.y&&!Landscape&&rect1.origin.x==0))
			{
				if ( NO == _shown )
				{
					_shown = YES;
					[self postNotification:self.SHOWN];
				}
                CGFloat	keyboardHeight = !Landscape?rect2.size.height:(IOS8_OR_LATER?rect2.size.height:rect2.size.width);

				if ( keyboardHeight != _height )
				{
					_height = keyboardHeight;
					[self postNotification:self.HEIGHT_CHANGED];
				}
			}
			else if ( rect2.origin.y == containerHeight
                     || rect2.origin.x <= -rect2.size.width
                     || rect2.origin.x == containerHeight )
			{
				CGFloat	keyboardHeight = !Landscape?rect2.size.height:(IOS8_OR_LATER?rect2.size.height:rect2.size.width);

				if ( keyboardHeight != _height )
				{
					_height = keyboardHeight;
					[self postNotification:self.HEIGHT_CHANGED];
				}
                
				if ( _shown )
				{
					_shown = NO;
					
					[self postNotification:self.HIDDEN];
				}
            }else if(rect2.size.height!=rect1.size.height){
                CGFloat	keyboardHeight = !Landscape?rect2.size.height:(IOS8_OR_LATER?rect2.size.height:rect2.size.width);
                
                if ( keyboardHeight != _height )
                {
                    _height = keyboardHeight;
                    [self postNotification:self.HEIGHT_CHANGED];
                }
            }else
                return;
		}
	}
	else if ( [notification is:UIKeyboardDidHideNotification] )
	{
		NSValue * value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
		if ( value )
		{
			CGRect	keyboardEndFrame = [value CGRectValue];
      
            CGFloat	keyboardHeight = !Landscape?keyboardEndFrame.size.height:(IOS8_OR_LATER?keyboardEndFrame.size.height:keyboardEndFrame.size.width);
            
			if ( keyboardHeight != _height )
			{
				_height = keyboardHeight;
				
                //	[self postNotification:self.HEIGHT_CHANGED];
//				animated = NO;
			}
		}
        
		if ( _shown )
		{
			_shown = NO;
			
			[self postNotification:self.HIDDEN];
            
		}

	}
    
    [self updateAccessorAnimated:animated duration:_animationDuration show:_shown];
}

- (void)dealloc
{
	[self unobserveAllNotifications];
    
    HM_SUPER_DEALLOC();
}

+ (void)hideKeyboard{
    [[HMUIKeyboard sharedInstance] hideKeyboard];
}

- (void)hideKeyboard{
    
    if ([[HMUIKeyboard sharedInstance].lastResponder isFirstResponder]) {
        [[HMUIKeyboard sharedInstance].lastResponder resignFirstResponder];
        
    }
    [HMUIKeyboard sharedInstance].lastResponder=nil;
}

- (void)setAccessorVisableRect:(CGRect)accessorVisableRect{

    _accessorVisableRect = accessorVisableRect;
    if (_shown) {
        [self updateAccessorAnimated:YES duration:_animationDuration show:_shown];
    }
}

- (void)setAccessor:(UIView *)view
{
    if (_accessor!=view) {
        if (_accessor&&_shown) {
            
            [self updateAccessorAnimated:YES duration:_animationDuration show:NO];
        }
        _defultTransform = view.transform;
        [_accessor release];
        _accessor = [view retain];
        _accessorFrame = view.frame;
        _accessorRectInWindow = [_accessor frameInWindow];
        
    }
//    if (_shown) {
//        [self updateAccessorAnimated:YES show:_shown];
//    }
}

- (void)setVisabler:(UIView *)visabler{
    if (_visabler!=visabler) {
        [_visabler release];
        _visabler = [visabler retain];
        
        _accessorVisableRect = [_visabler frameInWindow];
//        if (_shown) {
//            [self updateAccessorAnimated:YES show:_shown];
//        }
    }
    
}

- (void)showAccessor:(UIView *)view animated:(BOOL)animated
{
	self.accessor = view;
	_accessorFrame = view.frame;
	
	[self updateAccessorAnimated:animated duration:_animationDuration show:_shown];
}

- (void)hideAccessor:(UIView *)view animated:(BOOL)animated
{
	if ( _accessor == view )
	{
		BOOL isShown = _shown;
		
		_shown = NO;
		[self updateAccessorAnimated:animated duration:_animationDuration show:_shown];
		_shown = isShown;
		
		self.accessor = nil;
		_accessorFrame = CGRectZero;
        _accessorVisableRect = CGRectZero;
        _accessorRectInWindow = CGRectZero;
        
	}
}

- (void)updateAccessorAnimated:(BOOL)animated duration:(NSTimeInterval)duration show:(BOOL)show
{
	if ( nil == _accessor )
		return;

//    INFO(@"animated",@(animated),@"show",@(show),@(_height));
	if ( animated )
	{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//        [UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	if ( show )
	{
        
        CGRect newFrame = _accessor.frame;
        CGRect frame = [_accessor frameInWindow];//now，需要移动的视图现在的位置信息（相对window）
        CGRect visableFrame = [_visabler frameInWindow];//需要可见的视图的位置信息
        BOOL isScrollView =  [_accessor isKindOfClass:[UIScrollView class]];

        BOOL Landscape = ([[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeLeft||[[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeRight);
        
        CGFloat bottom = visableFrame.size.height+visableFrame.origin.y;//需要展示的view的位置信息
        CGFloat visableHeight = bottom;
        
        CGFloat containerHeight = !Landscape?[UIScreen mainScreen].bounds.size.height:(IOS8_OR_LATER?[UIScreen mainScreen].bounds.size.height:[UIScreen mainScreen].bounds.size.width);
        
       //计算Accessor视图的Bottom位置(相对window)+键盘高度与Window高度的差值
        CGFloat offsetNew = bottom+_height-containerHeight;

      //如果差值大于零（表示响应框的位置会被键盘挡住,响应框的位置应该移动offsetNew）
        if (offsetNew>0) {
            if (isScrollView) {
                CGFloat offsetSubv = visableHeight - (frame.origin.y+frame.size.height);
                if (offsetSubv>0) {
                    offsetNew -= offsetSubv;
                }
            }
            newFrame.origin.y -= offsetNew;
//            INFO(@(_accessor.transform.ty),@(_accessorRectInWindow.origin.y-newFrame.origin.y));
            if (IOS8_OR_LATER) {
                _accessor.transform = CGAffineTransformMakeTranslation(0, -_accessorFrame.origin.y+newFrame.origin.y);//CGAffineTransformTranslate(_accessor.transform, 0, -offsetNew);
            }else{
                _accessor.frame = newFrame;
            }
        
        }else if (_accessorRectInWindow.origin.y>frame.origin.y&&offsetNew<0){
           offsetNew = MIN(-offsetNew, _accessorRectInWindow.origin.y-frame.origin.y);
            newFrame.origin.y += offsetNew;
            if (IOS8_OR_LATER) {
                _accessor.transform = CGAffineTransformTranslate(_accessor.transform, 0, offsetNew);
            }else{
                _accessor.frame = newFrame;
            }
        }
//#if (__ON__ == __HM_DEVELOPMENT__)
//      /*KeyBoard offsetPre:145.00 offsetNow:145.00 bottom:497.00 newY:-135.00 offset:0.00
//       KeyBoard offsetPre:145.00 offsetNow:50.00 bottom:402.00 newY:-40.00 offset:-95.00*/
//      INFO(@"KeyBoard",@" offsetNow:%.2f bottom:%.2f newY:%.2f",offsetNew,bottom,newFrame.origin.y);
//#endif
	}
	else
	{
        if (IOS8_OR_LATER) {
            _accessor.transform = _defultTransform;//CGAffineTransformTranslate(_accessor.transform, 0, _accessorFrame.origin.y-_accessor.origin.y);
        }else{
            _accessor.frame = _accessorFrame;
        }
       
	}
    if (self.accessorBlock) {
        self.accessorBlock(show, _accessor);
    }
    if ( !show ){
        if (![self.lastResponder isFirstResponder]&&self.lastResponder==_visabler) {
            self.accessor = nil;
            self.visabler = nil;
            self.lastResponder = nil;
        }
        
    }
	if ( animated )
	{
		[UIView commitAnimations];
	}
}

@end
