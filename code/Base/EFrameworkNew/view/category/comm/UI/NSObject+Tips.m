//
//  NSObject+Tips.m
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "NSObject+Tips.h"

#import "HMMacros.h"

@interface MBProgressHUD ()
- (void)done;
@end


@implementation HMMBProgressHUD
@synthesize touchFrame;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
  
    if (self.alpha<=0.03f) {
        return NO;
    }
    if (CGRectContainsPoint(self.touchFrame, point)) {
        return NO;
    }
    return YES;
}
- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context {
    
    if ([finished boolValue]) {
        [self done];
    }
    
}

@end

@interface Tips_private : NSObject<MBProgressHUDDelegate>
AS_SINGLETON(Tips_private);
@property (nonatomic,HM_STRONG) HMMBProgressHUD* hud;
@property (atomic, MB_STRONG) NSDate *showStarted;

-(HMMBProgressHUD*)showTTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval mode:(MBProgressHUDMode)mode;
-(void)ttipsDismiss:(BOOL)animated;

@end

@implementation Tips_private{
    BOOL _isShowed;
    BOOL _isAnimated;
    
    NSTimeInterval _delay;
    NSTimeInterval _elapsed;
}
DEF_SINGLETON(Tips_private);
@synthesize hud;

- (id)init
{
    self = [super init];
    if (self) {
        _isShowed = NO;
        UIWindow *window = nil;
        if (![HMUIApplication sharedInstance].window) {
            window = [UIApplication sharedApplication].keyWindow;
        }else{
            window = [HMUIApplication sharedInstance].window;
        }
        hud = [[HMMBProgressHUD alloc]initWithWindow:window];//[UIApplication sharedApplication].keyWindow];
        hud.delegate = self;
        //        hud.minShowTime = 1.f;
    }
    return self;
}

- (void)dealloc
{
    self.showStarted = nil;
    [hud release];
    HM_SUPER_DEALLOC();
}

- (void)hudWasHidden:(MBProgressHUD *)_hud{
#if (__ON__ == __HM_LOG__)
    CC([self class],@"hudWasHidden",@(_isShowed));
#endif

    _isAnimated = NO;
    _isShowed = NO;
}
- (void)ttipsDismiss:(BOOL)animated{
    
    hud.removeFromSuperViewOnHide = NO;
    
    _isAnimated = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hide:animated];
        [[HMTicker sharedInstance]removeReceiver:self];
    });
    
    
}
-(HMMBProgressHUD*)showTTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval mode:(MBProgressHUDMode)mode{
    return  [self showTTip:string detail:detail timeOut:interval mode:mode touchRect:CGRectZero];
}

-(HMMBProgressHUD*)showTTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval mode:(MBProgressHUDMode)mode touchRect:(CGRect)touchRect{
    return  [self showTTip:string detail:detail timeOut:interval mode:mode customView:nil touchRect:CGRectZero];
}

-(HMMBProgressHUD*)showTTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval mode:(MBProgressHUDMode)mode customView:(UIView*)customView touchRect:(CGRect)touchRect{
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ttipsDismiss) object:self];
    hud.labelText = string;
    hud.detailsLabelText = detail;
    hud.mode = mode;
    hud.touchFrame = touchRect;
    
    hud.opacity = .6f;
    hud.cornerRadius = 8.f;
    
    if (mode==MBProgressHUDModeCustomView) {
        hud.customView = customView;
    }else{
        hud.animationType = MBProgressHUDAnimationFade;
    }
    
    
    WS(weakSelf)
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_isAnimated) {//表示正在消失
            [CATransaction begin];
            [hud.layer removeAllAnimations];
            
            [CATransaction commit];
            _isAnimated = NO;
            _isShowed = NO;
        }
        
        if (!_isShowed) {
            
            if (hud.superview==nil) {
                UIWindow *window = nil;
                if (![HMUIApplication sharedInstance].window) {
                    window = [UIApplication sharedApplication].keyWindow;
                }else{
                    window = [HMUIApplication sharedInstance].window;
                }
                [window addSubview:hud];
            }
            hud.removeFromSuperViewOnHide = NO;
            _isShowed = YES;
            [hud.layer removeAllAnimations];
            
            [hud show:YES];
            weakSelf.showStarted = [NSDate date];
        }
        
    });
    

    _elapsed = 0;
    if (interval>0.01f) {
        _delay = interval;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HMTicker sharedInstance]addReceiver:self];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HMTicker sharedInstance] removeReceiver:self];
        });
    }
    
    return hud;
}

ON_Tick(elapsed){
    _elapsed += elapsed;
    if (_elapsed>=_delay) {
        
        [self ttipsDismiss:YES];
        //        _elapsed = 0;
    }
}

@end


@implementation NSObject (Tips)

#ifdef DEBUG
-(void)test_Tips{
    
    NSString *test = @"0";
    
    static int step = 0;
    NSLog(@"%s-%d",__func__,step);
    test = [NSString stringWithFormat:@"正在加载%d",step];
    switch (step) {
        case 1:
            
            [self showSuccessTip:test timeOut:-1];
            [self performSelector:@selector(test_Tips) withObject:nil afterDelay:3.1];
            break;
        case 2:
            
            [self performSelector:@selector(test_Tips) withObject:nil afterDelay:3.1];
            [self showSuccessTip:test timeOut:3];
            break;
        case 3:
            
            [self performSelector:@selector(test_Tips) withObject:nil afterDelay:2];
            [self showTip:test timeOut:3 mode:MBProgressHUDModeDeterminateHorizontalBar];
            break;
        case 4:
            
            [self performSelector:@selector(test_Tips) withObject:nil afterDelay:.5];
            [self showTip:test timeOut:3 mode:MBProgressHUDModeAnnularDeterminate];
            break;
        case 5:
            
            [self performSelector:@selector(test_Tips) withObject:nil afterDelay:1.4];
            [self showTip:test timeOut:3 mode:MBProgressHUDModeIndeterminate];
            break;
        case 6:
            
            //            [self performSelector:@selector(test_Tips) withObject:nil afterDelay:4];
            [self showTip:test timeOut:3 mode:MBProgressHUDModeCustomView];
            break;
        case 7:
            return;
            break;
        default:
            [self showSuccessTip:test timeOut:3];
            [self performSelector:@selector(test_Tips) withObject:nil afterDelay:2.9];
            break;
    }
    
    step++;
    
}
#endif

- (void)tipsDismiss{
    [[Tips_private sharedInstance] ttipsDismiss:YES];
    
}

- (void)tipsDismissNoAnimated{
    [[Tips_private sharedInstance] ttipsDismiss:NO];
    
}


- (HMMBProgressHUD *)showTip:(NSString *)string timeOut:(NSTimeInterval)interval mode:(MBProgressHUDMode)mode{
   return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:mode];
}

- (HMMBProgressHUD *)showSuccessTip:(NSString *)string timeOut:(NSTimeInterval)interval{
    
   return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeText];
    
}
- (HMMBProgressHUD *)showFailureTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval{
    
   return [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:MBProgressHUDModeText];
    
}
- (HMMBProgressHUD *)showMessageTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval{
    
   return [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:MBProgressHUDModeText];
    
}
- (HMMBProgressHUD *)showLoaddingTip:(NSString *)string timeOut:(NSTimeInterval)interval{
    
   return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeIndeterminate];
    
}

- (HMMBProgressHUD *)showCustomTip:(NSString *)string custom:(UIView *)custom timeOut:(NSTimeInterval)interval{
    return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeCustomView customView:custom touchRect:CGRectZero];
}

- (HMMBProgressHUD *)showModeTip:(NSString *)string detail:(NSString *)detail custom:(UIView *)custom mode:(MBProgressHUDMode)mode timeOut:(NSTimeInterval)interval{
    return  [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:mode customView:custom touchRect:CGRectZero];
}

//////////////////////////////////////////////////////////////////////

- (HMMBProgressHUD *)showTip:(NSString *)string timeOut:(NSTimeInterval)interval mode:(MBProgressHUDMode)mode touchView:(UIView *)touchView{
   return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:mode touchRect:[touchView frameInWindow]];
}

- (HMMBProgressHUD *)showSuccessTip:(NSString *)string timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView{
    
   return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeText touchRect:[touchView frameInWindow]];
    
}
- (HMMBProgressHUD *)showFailureTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView{
    
   return [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:MBProgressHUDModeText touchRect:[touchView frameInWindow]];
    
}

- (HMMBProgressHUD *)showMessageTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView{
    
    return [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:MBProgressHUDModeText touchRect:[touchView frameInWindow]];
    
}

- (HMMBProgressHUD *)showLoaddingTip:(NSString *)string timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView{
    
    return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeIndeterminate touchRect:[touchView frameInWindow]];
    
}

- (HMMBProgressHUD *)showCustomTip:(NSString *)string custom:(UIView *)custom timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView{
   return  [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeCustomView customView:custom touchRect:[touchView frameInWindow]];
}

- (HMMBProgressHUD *)showModeTip:(NSString *)string detail:(NSString *)detail custom:(UIView *)custom mode:(MBProgressHUDMode)mode timeOut:(NSTimeInterval)interval touchView:(UIView *)touchView{
    return  [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:mode customView:custom touchRect:[touchView frameInWindow]];
}


- (HMMBProgressHUD *)hideHUDViewAnimated:(BOOL)animated{
    HMMBProgressHUD *hud = [self myHUDView];
    [hud hide:animated];
    return hud;
}
- (HMMBProgressHUD *)myHUDView{
    UIView *view = [self superviewForHUD];
    return [HMMBProgressHUD HUDForView:view];
}

- (UIView*)superviewForHUD{
    UIView *view = nil;
    if ([self isKindOfClass:[UIViewController class]]) {
        view = [(UIViewController *)self view];
    }else if ([self isKindOfClass:[UIView class]]){
        view = (id)self;
    }else{
        if (![HMUIApplication sharedInstance].window) {
            view = [UIApplication sharedApplication].keyWindow;
        }else{
            view = [HMUIApplication sharedInstance].window;
        }
        
    }
    return view;
}
- (HMMBProgressHUD *)showHUDViewAnimated:(BOOL)animated touchView:(UIView *)touchView{
    
    UIView *view = [self superviewForHUD];
    
    HMMBProgressHUD *hud = [[[HMMBProgressHUD alloc] initWithView:view] autorelease];
    hud.removeFromSuperViewOnHide = YES;
    hud.touchFrame = [touchView frameInWindow];
    [view addSubview:hud];
    [hud show:animated];
    
    return hud;
}


//////////////////////////////////////////////////////////////////////

- (HMMBProgressHUD *)showTip:(NSString *)string timeOut:(NSTimeInterval)interval mode:(MBProgressHUDMode)mode touchNavigatorRange:(TouchRange)touchRange{
    CGRect touchRect = [self touchRect:touchRange];
   return  [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:mode touchRect:touchRect];
}

- (HMMBProgressHUD *)showSuccessTip:(NSString *)string timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange{
    CGRect touchRect = [self touchRect:touchRange];
   return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeText touchRect:touchRect];
    
}
- (HMMBProgressHUD *)showFailureTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange{
    CGRect touchRect = [self touchRect:touchRange];
   return [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:MBProgressHUDModeText touchRect:touchRect];
    
}
- (HMMBProgressHUD *)showMessageTip:(NSString *)string detail:(NSString *)detail timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange{
    CGRect touchRect = [self touchRect:touchRange];
   return [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:MBProgressHUDModeText touchRect:touchRect];
    
}
- (HMMBProgressHUD *)showLoaddingTip:(NSString *)string timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange{
    CGRect touchRect = [self touchRect:touchRange];
    
   return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeIndeterminate touchRect:touchRect];
    
}

- (HMMBProgressHUD *)showCustomTip:(NSString *)string custom:(UIView *)custom timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange{
    CGRect touchRect = [self touchRect:touchRange];
   return [[Tips_private sharedInstance] showTTip:string detail:nil timeOut:interval mode:MBProgressHUDModeCustomView customView:custom touchRect:touchRect];
}

- (HMMBProgressHUD *)showModeTip:(NSString *)string detail:(NSString *)detail custom:(UIView *)custom mode:(MBProgressHUDMode)mode timeOut:(NSTimeInterval)interval touchNavigatorRange:(TouchRange)touchRange{
    CGRect touchRect = [self touchRect:touchRange];
    return [[Tips_private sharedInstance] showTTip:string detail:detail timeOut:interval mode:mode customView:custom touchRect:touchRect];
}



- (CGRect)touchRect:(TouchRange)touchRange{
    CGRect touchRect = CGRectZero;
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }

    if ([self isKindOfClass:[UIViewController class]]) {
        CGRect vcR = [[(UIViewController*)self view] frameInWindow];
        touchRect.size = CGSizeMake(vcR.size.width, vcR.origin.y);
    }else{
        
        if ([HMUIConfig sharedInstance].interfaceMode == HMUIInterfaceMode_iOS6) {
            touchRect.size = CGSizeMake(window.width,64);
        }else{
            touchRect.size = CGSizeMake(window.width,44);
        }
    }
    if (touchRange != TouchRange_All) {
        //左边
        if (!!(touchRange&TouchRange_Left)) {
            touchRect.size.width = 60;
        }else if (!!(touchRange&TouchRange_Center)){//中间
            touchRect.origin.x = 60;
            touchRect.size.width -= 120;
        }else if (!!(touchRange&TouchRange_Right)) {//右边
            touchRect.origin.x = touchRect.size.width - 60;
            touchRect.size.width = 60;
        }else if (!!(touchRange&TouchRange_Screen)) {//全屏
            touchRect.size = CGSizeMake(window.width,window.height);
            touchRect.origin = CGPointZero;
        }
    }
    return touchRect;
}

@end
