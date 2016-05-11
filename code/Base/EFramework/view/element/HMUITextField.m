//
//  HMUITextField.m
//  CarAssistant
//
//  Created by Eric on 14-3-26.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUITextField.h"
#import "HMMacros.h"
#import "HMFoundation.h"
#import "HMViewCategory.h"

@implementation UIResponder (HMUITextField)

@dynamic active;

- (BOOL)active
{
	return [self isFirstResponder];
}

- (void)setActive:(BOOL)flag
{
	if ( flag )
	{
		[self becomeFirstResponder];
	}
	else
	{
        if ([self isKindOfClass:[UITextField class]]) {
            [(UITextField*)self endEditing:YES];
        }else{
            [self resignFirstResponder];
        }
        
	}
}

@end

#pragma mark -

@interface HMUITextFieldAgent : NSObject<UITextFieldDelegate>
{
	HMUITextField __weak_type * _target;
}

@property (nonatomic, HM_WEAK) HMUITextField *	target;

@end

#pragma mark -

@implementation HMUITextFieldAgent


@synthesize target = _target;


- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	HM_SUPER_DEALLOC();
}


#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    HMSignal * signal = [_target sendSignal:HMUITextField.WILL_ACTIVE];
	if ( signal && signal.returnValue )
	{
		return signal.boolValue;
	}
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if ( NO == textField.window.isKeyWindow )
    {
        [textField.window makeKeyAndVisible];
    }
    
	[_target sendSignal:HMUITextField.DID_ACTIVED];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
	HMSignal * signal = [_target sendSignal:HMUITextField.WILL_DEACTIVE];
	if ( signal && signal.returnValue )
	{
		return signal.boolValue;
	}
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[_target sendSignal:HMUITextField.DID_DEACTIVED];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if ( 1 == range.length )
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(notifyTextChanged) withObject:nil afterDelay:0.1f];
		return YES;
	}
	else
	{
		NSString * text = [_target.text stringByReplacingCharactersInRange:range withString:string];
		if ( _target.maxLength > 0 && text.length > _target.maxLength )
		{
			[_target sendSignal:HMUITextField.TEXT_OVERFLOW];
			return NO;
		}
        
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(notifyTextChanged) withObject:nil afterDelay:0.1f];
		return YES;
	}
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	HMSignal * signal = [_target sendSignal:HMUITextField.CLEAR];
	if ( signal && signal.returnValue )
	{
		return signal.boolValue;
	}
    
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	HMSignal * signal = [_target sendSignal:HMUITextField.RETURN_ACTION];
	if ( signal && signal.returnValue )
	{
		return signal.boolValue;
	}
	
	return YES;
}

- (void)notifyTextChanged
{
	[_target sendSignal:HMUITextField.TEXT_CHANGED withObject:_target.text];
}

@end

#pragma mark -
@interface HMUITextField()
{
	BOOL					_inited;
	HMUITextFieldAgent *	_agent;
	NSUInteger				_maxLength;
	__weak_type UIResponder *_nextChain;
    
    CGRect                  _leftViewRect;
    CGRect                  _rightViewRect;
}

@property(nonatomic,HM_STRONG) UILabel *topTip;

@end

@implementation HMUITextField

DEF_SIGNAL2( WILL_ACTIVE ,HMUITextField)
DEF_SIGNAL2( DID_ACTIVED ,HMUITextField)
DEF_SIGNAL2( WILL_DEACTIVE ,HMUITextField)
DEF_SIGNAL2( DID_DEACTIVED ,HMUITextField)
DEF_SIGNAL2( TEXT_CHANGED ,HMUITextField)
DEF_SIGNAL2( TEXT_OVERFLOW ,HMUITextField)
DEF_SIGNAL2( CLEAR ,HMUITextField)
DEF_SIGNAL2( RETURN_ACTION ,HMUITextField)

@synthesize nextChain = _nextChain;
@synthesize maxLength = _maxLength;
@synthesize shouldHideIfReturn;
@synthesize userTag;
@synthesize placeholderColor=_placeholderColor;
@synthesize topTipsColor=_topTipsColor;
@synthesize fieldStyle;
@synthesize bottomLineColor=_bottomLineColor;
@synthesize topTipsText=_topTipsText;
@synthesize topTip = _topTip;
@synthesize textEdgeInsets;
@synthesize placeholderFont = _placeholderFont;

- (UILabel *)topTip{
    if (_topTip==nil) {
        _topTip = [[UILabel alloc]init];
        [self addSubview:_topTip];
    }
    return _topTip;
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor{
    if (_bottomLineColor!=bottomLineColor) {
        [_bottomLineColor  release];
        _bottomLineColor = [bottomLineColor  retain];
    }
    if (_bottomLineColor) {
        self.style__ = [HMUIFourBorderStyle styleWithBottom:bottomLineColor width:2 next:nil];
    }else{
        self.style__ = nil;
    }
}

- (void)setPlaceholder:(NSString *)placeholder{
    [super setPlaceholder:placeholder];
    if (_placeholderColor) {
        [self setPlaceholderColor:_placeholderColor];
    }
    if (_placeholderFont) {
        [self setPlaceholderFont:_placeholderFont];
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor{
    if (_placeholderColor!=placeholderColor) {
        [_placeholderColor  release];
        _placeholderColor = [placeholderColor  retain];
    }
    
    if (self.placeholder.length&&_placeholderColor) {
        NSMutableAttributedString *ats = nil;
        if (self.attributedPlaceholder) {
            ats = [[[NSMutableAttributedString alloc]initWithAttributedString:self.attributedPlaceholder]autorelease];
        }else{
            ats = [[[NSMutableAttributedString alloc]initWithString:self.placeholder]autorelease];
        }
        
        [ats setAttributes:@{(NSString *)NSForegroundColorAttributeName:_placeholderColor} range:NSMakeRange(0, self.placeholder.length)];
        
        self.attributedPlaceholder = ats;
    }
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont{
    if (_placeholderFont!=placeholderFont) {
        [_placeholderFont  release];
        _placeholderFont = [placeholderFont  retain];
    }
    if (self.placeholder.length&&_placeholderFont) {
        NSMutableAttributedString *ats = nil;
        if (self.attributedPlaceholder) {
            ats = [[[NSMutableAttributedString alloc]initWithAttributedString:self.attributedPlaceholder]autorelease];
        }else{
            ats = [[[NSMutableAttributedString alloc]initWithString:self.placeholder]autorelease];
        }
        
        [ats setAttributes:@{(NSString *)NSFontAttributeName:_placeholderFont} range:NSMakeRange(0, self.placeholder.length)];
        
        self.attributedPlaceholder = ats;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.style__) {
        [self setNeedsDisplay];
    }
    
}

+ (id)spawn{
    
    HMUITextField *textField = [[HMUITextField alloc]init];
    
    [textField initSelfDefault];
    
    return [textField autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelfDefault];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)awakeFromNib{
    [self initSelfDefault];
}

- (void)setTopTipsText:(NSString *)topTipsText{
    _topTip.text = topTipsText;
    [_topTip sizeToFit];
}

- (NSString *)topTipsText{
    return _topTip.text;
}

- (void)setTopTipsColor:(UIColor *)topTipsColor{
    if (_topTipsColor!=topTipsColor) {
        [_topTipsColor  release];
        _topTipsColor = [topTipsColor  retain];
    }
    _topTip.textColor = topTipsColor;
}

- (UIColor *)topTipsColor{
    return _topTip.textColor;
}

- (void)dealloc
{
    self.delegate = nil;
    self.bottomLineColor = nil;
    self.topTipsColor = nil;
    self.topTip = nil;
    self.placeholderColor = nil;
    self.placeholderFont = nil;
    [_agent release];
    self.topTipsText = nil;
    HM_SUPER_DEALLOC();
}

- (void)initSelfDefault{
    if ( NO == _inited )
	{
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.contentMode = UIViewContentModeCenter;
        
        self.topTipsColor = [[UIColor blueColor] colorWithAlphaComponent:.8];
        
		_agent = [[HMUITextFieldAgent alloc] init];
		_agent.target = self;
		self.delegate = _agent;
		
		_maxLength = 0;
		_inited = YES;
        
		[self load];
	}
}

- (CGRect)borderRectForBounds:(CGRect)bounds{
    if (!UIEdgeInsetsEqualToEdgeInsets(self.textEdgeInsets, UIEdgeInsetsZero)) {
        return CGRectEdgeInsets(bounds, self.textEdgeInsets);
    }
    return [self styleForBounds:bounds];
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    if (!UIEdgeInsetsEqualToEdgeInsets(self.textEdgeInsets, UIEdgeInsetsZero)) {
        return CGRectEdgeInsets(bounds, self.textEdgeInsets);
    }
    return [self styleForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    if (!UIEdgeInsetsEqualToEdgeInsets(self.textEdgeInsets, UIEdgeInsetsZero)) {
        return CGRectEdgeInsets(bounds, self.textEdgeInsets);
    }
    return [self styleForBounds:bounds];
}
- (CGRect)editingRectForBounds:(CGRect)bounds{
    if (!UIEdgeInsetsEqualToEdgeInsets(self.textEdgeInsets, UIEdgeInsetsZero)) {
        return CGRectEdgeInsets(bounds, self.textEdgeInsets);
    }
    return [self styleForBounds:bounds];

}
//- (CGRect)clearButtonRectForBounds:(CGRect)bounds{
//    
//}

- (void)setLeftView:(UIView *)leftView{
    [super setLeftView:leftView];
    _leftViewRect = CGRectZero;
}

- (void)setRightView:(UIView *)rightView{
    [super setRightView:rightView];
    _rightViewRect = CGRectZero;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    if (self.leftView) {
        if (CGRectEqualToRect(_leftViewRect, CGRectZero)) {
            _leftViewRect = self.leftView.frame;
        }
        return _leftViewRect;
    }
    return CGRectZero;
}
- (CGRect)rightViewRectForBounds:(CGRect)bounds{
    if (self.rightView) {
        if (CGRectEqualToRect(_rightViewRect, CGRectZero)) {
            _rightViewRect = self.rightView.frame;
        }
        return _rightViewRect;
    }
    return CGRectZero;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawStyleInRect:rect];
}

ON_TextField(signal) {
    
    if ([signal is:self.WILL_ACTIVE]||[signal is:self.TEXT_CHANGED]) {
        if (self.fieldStyle == TextFieldStyleTopTips&&(self.placeholder||self.topTipsText)) {
            [self.topTip sizeToFit];
            self.topTip.x = [self placeholderRectForBounds:self.bounds].origin.x;
            if ([signal is:self.WILL_ACTIVE]) {
                self.topTip.text = self.topTipsText.length?self.topTipsText:self.placeholder;
                self.topTip.textColor = self.topTipsColor;
                self.topTip.font = [UIFont systemFontOfSize:self.height/3];
                
                if (self.contentVerticalAlignment != UIControlContentVerticalAlignmentBottom) {
                    self.topTip.alpha = 0.f;
                }
                
            }
            if ((self.text.length&&self.contentVerticalAlignment != UIControlContentVerticalAlignmentBottom)) {
                [UIView animateWithDuration:.15f animations:^{
                    self.topTip.alpha = 1.0f;
                    self.topTip.y = 0;
                    self.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
                }];
                
            }else if(self.text.length==0&&self.contentVerticalAlignment != UIControlContentVerticalAlignmentCenter){
                [UIView animateWithDuration:.15f animations:^{
                    self.topTip.alpha = .0f;
                    self.topTip.y = (self.height-self.topTip.height)/2;
                    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                }];
            }
            
            
        }
    }else if ( [signal is:self.RETURN_ACTION] ){
		if (self.shouldHideIfReturn){
            self.active = NO;
        }else if ( _nextChain && _nextChain != self ){
            [_nextChain becomeFirstResponder];
		}
	}
    signal.forward = YES;
}

@end
