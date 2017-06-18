//
//  HMUIAlertView.m
//  GPSService
//
//  Created by Eric on 14-4-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIAlertView.h"
#import "HMMacros.h"

@interface HMUIAlertView ()<UIAlertViewDelegate>

@property (nonatomic,HM_STRONG) NSString *titleBack;
@property (nonatomic,HM_STRONG) UIWindow *keywindow;
@end

@implementation HMUIAlertView{
    UIView *			_parentView;
    void (^_clicked)(HMUIAlertView *alert,NSInteger index);
    BOOL _showTimeOut;
    NSInteger myelapsed;
    NSInteger myindex;
    NSTimer *countdownTimer;
    BOOL _dismiss;
}
@synthesize clicked=_clicked;
@synthesize titleBack;
@synthesize keywindow;

@synthesize cancelButtonIndex;
@synthesize delegate;
@synthesize tagString;
@synthesize alertViewStyle = _alertViewStyle;

- (void)setClicked:(void (^)(HMUIAlertView *, NSInteger))clicked{
    if (_clicked) {
        [_clicked release];
    }
    _clicked  = [clicked copy];
}

- (instancetype)onClicked:(AlertViewClicked)clk{
    self.clicked = clk;
    return self;
}

- (void)setAlertViewStyle:(UIAlertViewStyle)alertViewStyle{
    _alertViewStyle = alertViewStyle;
    
    if (alertViewStyle==UIAlertViewStylePlainTextInput||alertViewStyle==UIAlertViewStyleLoginAndPasswordInput) {
        [self addTextFieldWithConfigurationHandler:^(UITextField * textField) {
            
        }];
    }
    if (alertViewStyle==UIAlertViewStyleSecureTextInput||alertViewStyle==UIAlertViewStyleLoginAndPasswordInput) {
        [self addTextFieldWithConfigurationHandler:^(UITextField * textField) {
            textField.secureTextEntry = YES;
        }];
    }
    
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex{
    [self.textFields safeObjectAtIndex:textFieldIndex];
    return nil;
}

- (void)dealloc
{
    self.titleBack = nil;
    self.clicked = nil;
    self.delegate = nil;
    self.tagString = nil;
    self.keywindow = nil;
    HM_SUPER_DEALLOC();
}


- (void)dismissAnimated:(BOOL)animated
{
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:animated];
}


+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message{
    if (IOS7_OR_EARLIER) {
        NSAssert(false, @"please user HMUIAlert7View insteaded.");
    }
    return [HMUIAlertView alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
}

- (nullable NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex{
    UIAlertAction *action = [self.actions safeObjectAtIndex:buttonIndex];
    return action.title;
}
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated{
    [self alertView:(id)self clickedButtonAtIndex:buttonIndex];
    [self dismissViewControllerAnimated:animated completion:^{
        
    }];
}

- (NSInteger)addButtonWithTitle:(NSString *)title{
    
    UIAlertAction *action = [self actionWithTitle:title style:UIAlertActionStyleDefault];
    [self addAction:action];
    return self.actions.count-1;
}

- (UIAlertAction *)actionWithTitle:(NSString*)title style:(UIAlertActionStyle)style{
    WS(weakSelf)
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * action) {
        SS(strongSelf)
        if (strongSelf.clicked) {
            for (UIAlertAction *ac in strongSelf.actions) {
                if ([ac.title is:action.title]) {
                    
                    [strongSelf dismissWithClickedButtonIndex:[strongSelf.actions indexOfObject:ac] animated:YES];
                    break;
                }
            }
            
        }
    }];
    return action;
}

- (void)addCancelTitle:(NSString *)title
{
    UIAlertAction *action = [self actionWithTitle:title style:UIAlertActionStyleCancel];
    [self addAction:action];
    self.cancelButtonIndex = self.actions.count-1;
}

- (void)timeoutSec:(NSInteger)interval toClick:(NSInteger)index animated:(BOOL)animated{
    if (interval>0 && !![self buttonTitleAtIndex:index]) {
        if (countdownTimer) {
            [countdownTimer invalidate];
            [countdownTimer release];
            countdownTimer = nil;
        }
        
        _showTimeOut = animated;
        myelapsed = interval;
        myindex = index;

        self.titleBack = self.title;
        if (self.titleBack==nil) {
            self.titleBack = self.message;
        }
        
        [self updateView];
        
        if (countdownTimer==nil) {
            countdownTimer = [[NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(countDown:) userInfo:nil repeats:YES]retain];
        }
    }
}

- (void)updateView{
    if (_showTimeOut) {
        
        if (self.title) {
            
            self.title = [NSString stringWithFormat:@"%@(%ds)",self.titleBack,(int)myelapsed];
        }else if (self.message) {
            
            self.message = [NSString stringWithFormat:@"%@(%ds)",self.titleBack,(int)myelapsed];
        }
    }
}

-(void)countDown:(NSTimer*)timer{
    if (myelapsed) {
        myelapsed--;
        
        [self updateView];
    }
    
    if (myelapsed==0) {
        [countdownTimer invalidate];
        [countdownTimer release];
        countdownTimer = nil;
        [self dismissWithClickedButtonIndex:myindex animated:YES];
    }
}

- (void)show{
    self.keywindow = [[UIApplication sharedApplication] keyWindow];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:YES completion:^{
        
    }];
}

- (void)showInView:(UIView *)view
{
    _parentView = view;
    
    [self show];
}

- (void)showInViewController:(UIViewController *)controller
{
    [controller presentViewController:self animated:YES completion:^{
        
    }];
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


- (void)alertView:(HMUIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (!_dismiss) {
        if (self.clicked) {
            self.clicked((id)alertView,buttonIndex);
        }
        [countdownTimer invalidate];
        [countdownTimer release];
        countdownTimer = nil;
    }
    _dismiss = NO;
    _showTimeOut = NO;
    [self.keywindow makeKeyWindow];
    self.keywindow = nil;
}

- (void)alertView:(HMUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.clicked) {
        self.clicked((id)alertView,buttonIndex);
    }
    [countdownTimer invalidate];
    [countdownTimer release];
    countdownTimer = nil;
    _showTimeOut = NO;
    _dismiss = YES;
}

@end

#pragma mark - for old Alert

@interface HMUIAlert7View ()<UIAlertViewDelegate>

@property (nonatomic,HM_STRONG) NSString *titleBack;
@property (nonatomic,HM_STRONG) UIWindow *keywindow;
@end

@implementation HMUIAlert7View{
    UIView *			_parentView;
    void (^_clicked)(HMUIAlert7View *alert,NSInteger index);
    BOOL _showTimeOut;
    NSInteger myelapsed;
    NSInteger myindex;
    NSTimer *countdownTimer;
    BOOL _dismiss;
}
@synthesize clicked=_clicked;
@synthesize titleBack;
@synthesize keywindow;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setClicked:(void (^)(HMUIAlert7View *, NSInteger))clicked{
    if (_clicked) {
        [_clicked release];
    }
    self.delegate = self;

    _clicked  = [clicked copy];
}

- (instancetype)onClicked:(Alert7ViewClicked)clk{
    self.clicked = clk;
    return self;
}

- (void)dealloc
{
    self.titleBack = nil;
    self.clicked = nil;
    self.delegate = nil;
    self.tagString = nil;
    HM_SUPER_DEALLOC();
}


- (void)dismissAnimated:(BOOL)animated
{
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:animated];
}


+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message{

    return [[HMUIAlert7View alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
}


- (void)addCancelTitle:(NSString *)title
{
    self.cancelButtonIndex = [self addButtonWithTitle:title];
}

- (void)timeoutSec:(NSInteger)interval toClick:(NSInteger)index animated:(BOOL)animated{
    if (interval>0 && !![self buttonTitleAtIndex:index]) {
        if (countdownTimer) {
            [countdownTimer invalidate];
            [countdownTimer release];
            countdownTimer = nil;
        }
        
        _showTimeOut = animated;
        myelapsed = interval;
        myindex = index;
        self.delegate = self;

        self.titleBack = self.title;
        if (self.titleBack==nil) {
            self.titleBack = self.message;
        }
        
        [self updateView];
        
        if (countdownTimer==nil) {
            countdownTimer = [[NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(countDown:) userInfo:nil repeats:YES]retain];
        }
    }
}

- (void)updateView{
    if (_showTimeOut) {
        
        if (self.title) {
            
            self.title = [NSString stringWithFormat:@"%@(%ds)",self.titleBack,(int)myelapsed];
        }else if (self.message) {
            
            self.message = [NSString stringWithFormat:@"%@(%ds)",self.titleBack,(int)myelapsed];
        }
    }
}

-(void)countDown:(NSTimer*)timer{
    if (myelapsed) {
        myelapsed--;
        
        [self updateView];
    }
    
    if (myelapsed==0) {
        [countdownTimer invalidate];
        [countdownTimer release];
        countdownTimer = nil;
        [self dismissWithClickedButtonIndex:myindex animated:YES];
    }
}

- (void)show{
    self.keywindow = [[UIApplication sharedApplication] keyWindow];

    [super show];

}

- (void)showInView:(UIView *)view
{
    _parentView = view;
    
    [self show];
}

- (void)showInViewController:(UIViewController *)controller
{

    _parentView = controller.view;
    
    [self show];
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


- (void)alertView:(HMUIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (!_dismiss) {
        if (self.clicked) {
            self.clicked((id)alertView,buttonIndex);
        }
        [countdownTimer invalidate];
        [countdownTimer release];
        countdownTimer = nil;
    }
    _dismiss = NO;
    _showTimeOut = NO;
    [self.keywindow makeKeyWindow];
    self.keywindow = nil;
}

- (void)alertView:(HMUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.clicked) {
        self.clicked((id)alertView,buttonIndex);
    }
    [countdownTimer invalidate];
    [countdownTimer release];
    countdownTimer = nil;
    _showTimeOut = NO;
    _dismiss = YES;
}

@end

@implementation NSObject (Alert)

+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)message{
    
    Class alertZ;
    if (IOS8_OR_LATER) {
        alertZ = [HMUIAlertView class];
    }else {
        alertZ = [HMUIAlert7View class];
    }
    return [alertZ alertWithTitle:title message:message];
}

@end

