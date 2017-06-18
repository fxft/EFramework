//
//  HMUIAlertView.m
//  GPSService
//
//  Created by Eric on 14-4-13.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIActionSheet.h"
#import "HMMacros.h"

@interface HMUIActionSheet ()<UIActionSheetDelegate>

@property (nonatomic,HM_STRONG) NSString *titleBack;
@property (nonatomic,HM_STRONG) UIWindow *keywindow;

@end

@implementation HMUIActionSheet{
    UIView *			_parentView;
    void (^_clicked)(HMUIActionSheet *alert,NSInteger index);
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


- (void)setClicked:(void (^)(HMUIActionSheet *, NSInteger))clicked{
    if (_clicked) {
        [_clicked release];
    }

    _clicked  = [clicked copy];
}

- (instancetype)onClicked:(ActionSheetClicked)clk{
    
    self.clicked = clk;
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.tagString = nil;
    self.keywindow = nil;
    self.titleBack = nil;
    self.clicked = nil;
    HM_SUPER_DEALLOC();
}

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message{

    return [HMUIActionSheet alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];

}

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message destructive:(NSString*)destructive{
    HMUIActionSheet *sheet = [HMUIActionSheet alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    if (destructive) {
        UIAlertAction *action = [sheet actionWithTitle:destructive style:UIAlertActionStyleDestructive];
        [sheet addAction:action];
    }
    return sheet;
}

- (nullable NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex{
    UIAlertAction *action = [self.actions safeObjectAtIndex:buttonIndex];
    return action.title;
}
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated{
    [self actionSheet:(id)self clickedButtonAtIndex:(NSInteger)buttonIndex];
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

- (void)dismissAnimated:(BOOL)animated
{
	[self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:animated];
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

- (void)showInView:(UIView *)view{
    self.keywindow = [[UIApplication sharedApplication] keyWindow];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:YES completion:^{
        
    }];

}

- (void)show{
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }
    [self showInView:window];
}

- (void)showInViewController:(UIViewController *)controller
{
	_parentView = controller.view;

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


- (void)actionSheet:(HMUIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (!_dismiss) {
        if (self.clicked) {
            self.clicked((id)actionSheet,buttonIndex);
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

- (void)actionSheet:(HMUIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.clicked) {
        self.clicked((id)actionSheet,buttonIndex);
    }
    [countdownTimer invalidate];
    [countdownTimer release];
    countdownTimer = nil;
    _showTimeOut = NO;
    _dismiss = YES;
}

@end

#pragma mark - for old sheet

@interface HMUIAction7Sheet ()<UIActionSheetDelegate>

@property (nonatomic,HM_STRONG) NSString *titleBack;
@property (nonatomic,HM_STRONG) UIWindow *keywindow;

@end

@implementation HMUIAction7Sheet{
    UIView *			_parentView;
    void (^_clicked)(HMUIAction7Sheet *alert,NSInteger index);
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


- (void)setClicked:(void (^)(HMUIAction7Sheet *, NSInteger))clicked{
    if (_clicked) {
        [_clicked release];
    }
    self.delegate = self;

    _clicked  = [clicked copy];
}

- (instancetype)onClicked:(Action7SheetClicked)clk{
    
    self.clicked = clk;
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    self.tagString = nil;
    self.keywindow = nil;
    self.titleBack = nil;
    self.clicked = nil;
    HM_SUPER_DEALLOC();
}

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message{

    return [HMUIAction7Sheet alertWithTitle:title message:message destructive:nil];
    
}

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message destructive:(NSString*)destructive{
    
    return [[HMUIAction7Sheet alloc]initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:destructive otherButtonTitles:nil];
    
}

- (void)addCancelTitle:(NSString *)title
{
    self.cancelButtonIndex = [self addButtonWithTitle:title];
}


- (void)dismissAnimated:(BOOL)animated
{
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:animated];
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

- (void)showInView:(UIView *)view{
    self.keywindow = [[UIApplication sharedApplication] keyWindow];

    [super showInView:view];

}

- (void)show{
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }
    [self showInView:window];
}

- (void)showInViewController:(UIViewController *)controller
{
    _parentView = controller.view;

    [self showInView:_parentView];
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


- (void)actionSheet:(HMUIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (!_dismiss) {
        if (self.clicked) {
            self.clicked((id)actionSheet,buttonIndex);
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

- (void)actionSheet:(HMUIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.clicked) {
        self.clicked((id)actionSheet,buttonIndex);
    }
    [countdownTimer invalidate];
    [countdownTimer release];
    countdownTimer = nil;
    _showTimeOut = NO;
    _dismiss = YES;
}

@end

@implementation NSObject (Sheet)

+ (instancetype)sheetViewWithTitle:(NSString *)title message:(NSString *)message{
    
    return [self sheetViewWithTitle:title message:message destructive:nil];
}
+ (instancetype)sheetViewWithTitle:(NSString *)title message:(NSString *)message destructive:(NSString *)destructive{
    Class alertZ;
    if (IOS8_OR_LATER) {
        alertZ = [HMUIActionSheet class];
    }else{
        alertZ = [HMUIAction7Sheet class];
    }
    return [alertZ alertWithTitle:title message:message destructive:destructive];

}

@end
