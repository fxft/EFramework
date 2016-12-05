//
//  HMUITextView.m
//  GPSService
//
//  Created by Eric on 14-4-25.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUITextView.h"

@implementation UIResponder (HMUITextView)

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
        [self resignFirstResponder];        
	}
}

@end

#pragma mark -

@interface HMUITextViewAgent : NSObject<UITextViewDelegate>
{
	HMUITextView *	_target;
}

@property (nonatomic, HM_WEAK) HMUITextView *	target;

@end

#pragma mark -

@implementation HMUITextViewAgent

@synthesize target = _target;

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _target.placeholderLabel.hidden = YES;
	[_target sendSignal:HMUITextView.WILL_ACTIVE];
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[_target sendSignal:HMUITextView.DID_ACTIVED];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text length]) {
        _target.placeholderLabel.hidden = YES;
    }else{
        _target.placeholderLabel.hidden = NO;
    }
	[_target sendSignal:HMUITextView.WILL_DEACTIVE];
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	[_target sendSignal:HMUITextView.DID_DEACTIVED];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
    
	if ( 1 == range.length )
	{
		[_target sendSignal:HMUITextView.TEXT_CHANGED];
		return YES;
	}
	
	if ( [string isEqualToString:@"\n"] || [string isEqualToString:@"\r"] )
	{
		HMSignal * signal = [_target sendSignal:HMUITextView.RETURN_ACTION];
		if ( signal )
		{
			return signal.boolValue;
		}
	}
	
	NSString * text = [_target.text stringByReplacingCharactersInRange:range withString:string];
	if ( _target.maxLength > 0 && text.length > _target.maxLength )
	{
		[_target sendSignal:HMUITextView.TEXT_OVERFLOW];
		return NO;
	}
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{

	[_target sendSignal:HMUITextView.TEXT_CHANGED];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    
	[_target sendSignal:HMUITextView.SELECTION_CHANGED];
}

@end

@interface HMUITextView()
{
	BOOL					_inited;
	HMUITextViewAgent *	_agent;
    NSString *				_placeholder;
    UIColor *				_placeholderColor;
    UILabel *				_placeholderLabel;
	NSUInteger				_maxLength;
	UIResponder *			_nextChain;
}

@end
@implementation HMUITextView
DEF_SIGNAL2( WILL_ACTIVE ,HMUITextView)
DEF_SIGNAL2( DID_ACTIVED ,HMUITextView)
DEF_SIGNAL2( WILL_DEACTIVE ,HMUITextView)
DEF_SIGNAL2( DID_DEACTIVED ,HMUITextView)
DEF_SIGNAL2( TEXT_CHANGED ,HMUITextView)
DEF_SIGNAL2( TEXT_OVERFLOW ,HMUITextView)
DEF_SIGNAL2( SELECTION_CHANGED ,HMUITextView)
DEF_SIGNAL2( RETURN_ACTION ,HMUITextView)

@synthesize placeholder = _placeholder;
@synthesize placeholderLabel = _placeholderLabel;
@synthesize placeholderColor = _placeholderColor;
@synthesize maxLength = _maxLength;
@synthesize nextChain = _nextChain;

- (id)init
{
    return  [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    if( self )
    {
		[self initSelfDefault];
    }
    return self;
}

// thanks to @ilikeido
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if ( self )
	{

	}
	return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initSelfDefault];
}

- (void)initSelfDefault
{
	if ( NO == _inited )
	{
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.font = [UIFont systemFontOfSize:14.0f];
        
		self.placeholderColor = [UIColor grayColor];
        
		_agent = [[HMUITextViewAgent alloc] init];
		_agent.target = self;
		self.delegate = _agent;
		
		_maxLength = 0;
		_inited = YES;
        
		[self load];

	}
}

- (UILabel *)placeholderLabel{
    if ( nil == _placeholderLabel )
    {
        CGRect labelFrame = CGRectEdgeInsets(self.bounds, UIEdgeInsetsVerAndHor(9, 8));
        
        _placeholderLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _placeholderLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        _placeholderLabel.textAlignment = UITextAlignmentLeft;
        _placeholderLabel.numberOfLines = 0;
        _placeholderLabel.font =  self.font;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.textColor = _placeholderColor;
        [self addSubview:_placeholderLabel];
    }
    return _placeholderLabel;
    
}

- (void)setPlaceholder:(NSString *)placeholder{
    [_placeholder release];
    _placeholder = [placeholder retain];
    self.placeholderLabel.text = _placeholder;
    self.placeholderLabel.font = self.font;
    [_placeholderLabel sizeToFit];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont{
    if (_placeholderFont!=placeholderFont) {
        [_placeholderFont  release];
        _placeholderFont = [placeholderFont  retain];
    }
    self.placeholderLabel.font = _placeholderFont;
}

- (void)dealloc
{
 	[self unload];
    
	[_agent release];
    self.placeholderFont = nil;
	self.placeholderLabel = nil;
	self.placeholderColor = nil;
	self.placeholder = nil;
    
    HM_SUPER_DEALLOC();
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset{
    if (IOS7_OR_LATER) {
        [super setTextContainerInset:textContainerInset];
    }
}

- (UIEdgeInsets)textContainerInset{
    UIEdgeInsets styleInsets = [super textContainerInset];
    if (self.style__) {
        styleInsets = [self styleInsets];
    }
    return styleInsets;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _placeholderLabel.frame = CGRectEdgeInsets(self.bounds, self.textContainerInset);
    
    _placeholderLabel.font = self.font;
    [_placeholderLabel sizeToFit];
    if (self.style__) {
        [self setNeedsDisplay];
    }
    
}

- (void)setText:(NSString *)text{
    [super setText:text];
    if ([text length]) {
        _placeholderLabel.hidden = YES;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText{
    [super setAttributedText:attributedText];
    if ([attributedText length]) {
        _placeholderLabel.hidden = YES;
    }
}

- (void)drawRect:(CGRect)rect
{
    [self drawStyleInRect:self.bounds];
    [super drawRect:rect];
    
}

ON_TextView(signal) {
    
    if ( [signal is:self.RETURN_ACTION] )
	{
		if ( _nextChain && _nextChain != self )
		{
			[_nextChain becomeFirstResponder];
		}else if (self.shouldHideIfReturn){
            self.active = NO;
        }else{
            [signal returnYES];
        }
	}
    signal.forward = YES;
}


@end
