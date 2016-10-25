//
//  HMBaseNavigator.m
//  GPSService
//
//  Created by Eric on 14-4-3.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMBaseNavigator.h"
#import "HMMacros.h"
#import "HMFoundation.h"
#import "HMViewCategory.h"

@interface HMBaseNavigator ()
{
    HMURLMap * _map;
    
}

@property (nonatomic,assign) UIViewController* currentC;
@property (nonatomic,assign) UIViewController* previousC;
@property (nonatomic,HM_STRONG)NSString *currentMap;


@end

@implementation HMBaseNavigator

@synthesize map=_map;
@synthesize currentC;
@synthesize previousC;
@synthesize currentMap;


DEF_SINGLETON(HMBaseNavigator)

+ (HMURLMap *)map{
    return [HMBaseNavigator sharedInstance].map;
}
- (NSString *)previousMap{
    return self.previousC.nickname;
}
- (NSString *)currentMap{
    return self.currentC.nickname;
}

- (void)load{
    [self observeNotification:[HMUINavigationBar STYLE_CHANGED]];
    self.map = [HMURLMap sharedInstance];
//    self.includesOpaque = YES;
}

- (void)unload{
    [self unobserveAllNotifications];
    self.currentC = nil;
    self.previousC = nil;
    self.currentMap = nil;
    [_map release];
    _map = nil;
}

- (void)viewDidLayoutSubviews{
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.viewVisable = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[self.class description] isEqualToString:@"HMBaseNavigator"]) {
        [self hideNavigationBarAnimated:NO];
    }
    if ([HMUIConfig sharedInstance].allowControlerGestureBack) {
        self.view.panEnabled = YES;
    }
    [self observeNotification:@"allowControlerGestureBackChanged"];

}

- (void)subcontrolers:(UIViewController*)root{
    for (UINavigationController*vc in root.childViewControllers) {
        if ([vc isKindOfClass:[UINavigationController class]]) {
            [vc updateNavigationBar];
        }else{
            [self subcontrolers:vc];
        }
    }
}

- (void)handleNotification:(NSNotification *)notification{
    if ([notification.name is:@"allowControlerGestureBackChanged"]) {
        self.view.panEnabled = [HMUIConfig sharedInstance].allowControlerGestureAutoControl;
    }else if ([notification.name is:[HMUINavigationBar STYLE_CHANGED]]){
        [self subcontrolers:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//override style for ios7
-(BOOL)prefersStatusBarHidden{

    return [self.visableViewController prefersStatusBarHidden];
}

-(UIStatusBarStyle)preferredStatusBarStyle{

    return [self.visableViewController preferredStatusBarStyle];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    if (!self.visableViewController) {
        return [super preferredStatusBarUpdateAnimation];
    }
    return [self.visableViewController respondsToSelector:@selector(preferredStatusBarUpdateAnimation)]?[self.visableViewController preferredStatusBarUpdateAnimation]:[super preferredStatusBarUpdateAnimation];
}


#if defined(__IPHONE_6_0)
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    UIInterfaceOrientation mask;
    if (!self.visableViewController) {
        mask= [super preferredInterfaceOrientationForPresentation];
    }else
    mask =  [self.visableViewController respondsToSelector:@selector(preferredInterfaceOrientationForPresentation)]?[self.visableViewController preferredInterfaceOrientationForPresentation]:[super preferredInterfaceOrientationForPresentation];
#ifdef  DEBUG
    CC(@"Orientation",@"preferredInterfaceOrientationForPresentation",@"for:",self.visableViewController,@"mask:",@(mask));
#endif
    return mask;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIInterfaceOrientationMask mask;
    if (!self.visableViewController) {
        mask =  [super supportedInterfaceOrientations];
    }else{
        mask =  [self.visableViewController respondsToSelector:@selector(supportedInterfaceOrientations)]?[self.visableViewController supportedInterfaceOrientations]:[super supportedInterfaceOrientations];
    }
#ifdef  DEBUG
    CC(@"Orientation",@"supportedInterfaceOrientations",@"for:",self.visableViewController,@"mask:",@(mask));
#endif
    return mask;
}

- (BOOL)shouldAutorotate
{
    BOOL can ;
    if (!self.visableViewController) {
        can = [super shouldAutorotate];
    }else
    can = [self.visableViewController respondsToSelector:@selector(shouldAutorotate)]?[self.visableViewController shouldAutorotate]:[super shouldAutorotate];
#ifdef  DEBUG
    CC(@"Orientation",@"shouldAutorotate",@"for:",self.visableViewController,@"mask:",@(can));
#endif
    return can;
}

#endif	// #if defined(__IPHONE_6_0)

- (UIViewController*)previousViewController {
    NSArray* viewControllers = self.childViewControllers;
    if (viewControllers.count > 0) {
        
        return [self viewControllerBefore:viewControllers.lastObject after:nil];
    }
    return nil;
}

- (UIViewController *)visableViewController{
    if (self.currentC&&(self.currentC.view.superview==self.view)) {
        return self.currentC;
    }
    NSArray *subViews = [self.view subviews];
    for (NSInteger i=subViews.count-1; i>0; i--) {
        UIView *view = [subViews safeObjectAtIndex:i];
        if (!view.hidden&&view.viewController) {
            self.currentC = view.viewController;
        }
    }
    if ([self.currentC isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController*)self.currentC topViewController];
    }
    return self.currentC;
}


- (void)setViewVisable:(BOOL)viewVisable{
    [super setViewVisable:viewVisable];
    NSArray *all = self.childViewControllers;
    for (UIViewController*vv in all) {
        vv.viewVisable = NO;
    }
    
    [self.visableViewController setViewVisable:viewVisable];
}

//UIApplicationDidChangeStatusBarFrameNotification
- (void)addSubcontroller:(HMURLMAPItem *)item animated:(BOOL)animated complete:(void (^)(BOOL,UIViewController*))commple{
    
    
    HMURLMAPItem *preItem = item;
    
    //新的路由规则：只认item.board
    UIViewController *stackBoard = item.board;
    
    if (item.backing) {
        
        item = [self.map objectForBoard:[self viewControllerBefore:stackBoard after:nil]];
        
        item.backing = YES;
        stackBoard = item.board;
    }
    if (item==nil) {
        return;
    }
    BOOL isNew = NO;
    if (stackBoard) {
        if (commple) {
            commple(NO,stackBoard);
        }
        if (![self.childViewControllers containsObject:stackBoard]){
            [self addChildViewController:stackBoard];
        }
        
        if (![self.childViewControllers containsObject:stackBoard]) {
            
        }
        if (stackBoard.view.superview!=self.view) {
            if (!item.fullScreen) {
                CGFloat hei = MIN([UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height);
                stackBoard.view.frame = CGRectMake(0, hei, self.view.width, self.view.height-hei);
            }else{
                stackBoard.view.frame = self.view.bounds;
            }
            stackBoard.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//            stackBoard.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            isNew = YES;
            
            [self.view addSubview:stackBoard.view];
        }
        
    }
    
    
    if (self.currentC==item.board) {
        return;
    }
    
    if (!item.backing) {
        item.board.openDate = [NSDate date];
        self.previousC = [self viewControllerBefore:stackBoard after:nil];
        
    }else{
        self.previousC = [self viewControllerBefore:nil after:stackBoard];

        self.previousC.openDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if ( stackBoard )
    {
        
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"UIBoard",@"open %@ %@ now has %@",stackBoard,[stackBoard.openDate stringWithDateFormat:nil],[self.childViewControllers valueForKeyPath:@"@distinctUnionOfObjects.nickname"]);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        stackBoard.view.hidden = NO;
        if ([HMUIConfig sharedInstance].allowControlerGestureBack) {
            if (stackBoard.stack.viewControllers.count>1) {
                [HMUIConfig sharedInstance].allowControlerGestureAutoControl = NO;
            }else{
                [HMUIConfig sharedInstance].allowControlerGestureAutoControl = YES;
            }
        }
        self.currentC = stackBoard;
        self.viewVisable = YES;
        if (animated) {
            
             self.currentC.view.alpha=0.f;
            
            __block __weak_type typeof(self) blockSelf = self;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *currentVC = blockSelf.currentC;
                UIViewController *previousVC = blockSelf.previousC;
                CGAffineTransform trans = CGAffineTransformIdentity;
                CGAffineTransform transBack = CGAffineTransformIdentity;
                CGFloat width = currentVC.view.width;
                CGFloat height = currentVC.view.height;
                
                HMURLMAPItem *currentItem = item;
                if (item.backing) {
                    previousVC = blockSelf.currentC;
                    currentVC = blockSelf.previousC;
                    currentItem = preItem;
                    
                }
                
                if (!currentVC || !previousVC){
                    blockSelf.currentC.view.transform = CGAffineTransformIdentity;
                    blockSelf.currentC.view.alpha = 1.0f;
                    if (commple) {
                        commple(YES,blockSelf.currentC);
                    }
                    return ;
                }
                
                if (currentItem.option > UIViewAnimationOptionTransitionFlipFromBottom||currentItem.option<UIViewAnimationOptionTransitionFlipFromLeft||currentItem.option==UIViewAnimationOptionCurveEaseIn||currentItem.option==UIViewAnimationOptionCurveLinear){
                    blockSelf.currentC.view.hidden=NO;
                    UIViewAnimationOptionsMap o = (UIViewAnimationOptionsMap)currentItem.option;
                    
                    if (o == UIViewAnimationOptionCustom) {
                        
                        //item 即使需要显示的视图
                        currentVC.view.alpha  =1.f;
                        previousVC.view.alpha = 1.f;
                        if (item.backing) {
                            preItem.backBoard = item.board;
                            NSTimeInterval duration = [preItem.animaterBack transitionDuration:preItem];
                            [preItem.animaterBack animateTransition:preItem];
                            if (duration<=0) {
                                duration = preItem.duration;
                            }
                            
                            [UIView animateWithDuration:duration animations:^{
                                
                                preItem.board.view.alpha = 0.0f;
                                
                            } completion:^(BOOL finished) {
                                item.board.view.transform = CGAffineTransformIdentity;
                                preItem.board.view.hidden = YES;
                                
                                [self.view bringSubviewToFront:item.board.view];
                                preItem.backBoard = nil;
                                if (commple) {
                                    commple(YES,item.board);
                                }
                            }];
                        }else{
                            item.backBoard = previousVC;
                            NSTimeInterval duration = [item.animaterFront transitionDuration:item];
                            [item.animaterFront animateTransition:item];
                            if (duration<=0) {
                                duration = item.duration;
                            }
                            [UIView animateWithDuration:duration animations:^{
                                
                                item.board.view.alpha = 1.0f;
                                
                            } completion:^(BOOL finished) {
                                item.board.view.transform = CGAffineTransformIdentity;
                                item.backBoard.view.hidden = YES;
                                [self.view bringSubviewToFront:item.board.view];
                                item.backBoard = nil;
                                if (commple) {
                                    commple(YES,item.board);
                                }
                            }];
                        }
                        
                        
                        return;
                    }
                    
                    switch ((NSUInteger)o) {
                        case UIViewAnimationOptionTransitionFromBottom:
                            trans = CGAffineTransformMakeTranslation(0, height);
//                            transBack = CGAffineTransformMakeTranslation(0, -50);
                            transBack = CGAffineTransformMakeTranslation(0, 0);
                            break;
                        case UIViewAnimationOptionTransitionFromTop:
                            trans = CGAffineTransformMakeTranslation(0, -height);
//                            transBack = CGAffineTransformMakeTranslation(0, 50);
                            transBack = CGAffineTransformMakeTranslation(0, 0);
                            break;
                            
                        case UIViewAnimationOptionTransitionFromLeft:
                            trans = CGAffineTransformMakeTranslation(-width,0);
                            transBack = CGAffineTransformMakeTranslation(50, 0);
                            break;
                            
                        case UIViewAnimationOptionTransitionFromRight:
                            trans = CGAffineTransformMakeTranslation(width, 0);
                            transBack = CGAffineTransformMakeTranslation(-50, 0);
                            break;
                        case UIViewAnimationOptionGesture:
                            trans = CGAffineTransformMakeTranslation(width, 0);
                            transBack = CGAffineTransformMakeTranslation(-50, 0);
                            break;
                        case UIViewAnimationOptionCurveLinear:
                            
                            break;
                        default:
                            trans = CGAffineTransformMakeScale(.95, .95);
                            break;
                    }
                    
                    currentVC.view.transform = !currentItem.backing?trans:CGAffineTransformIdentity;
                    currentVC.view.alpha = 1.0f;
                    
                    UIView *leftview = nil;
                    UIView *rightview = nil;
                    UIView *centerview = nil;
                    
                    UIView *leftviewNext = nil;
                    UIView *rightviewNext = nil;
                    UIView *centerviewNext = nil;
                    
                    if (previousVC.navigatorBar!=nil) {
                        UIViewController *cc = previousVC;
                        if ([previousVC isKindOfClass:[UINavigationController class]]) {
                            cc = [(UINavigationController*)previousVC topViewController];
                        }
                        leftview = [cc navigateBarCustomView:[HMUINavigationBar LEFT]];
                        rightview = [cc navigateBarCustomView:[HMUINavigationBar RIGHT]];
                        centerview = [cc customNavTitleView];
                    }
                    
                    if (currentVC.navigatorBar!=nil) {
                        UIViewController *cc = currentVC;
                        if ([currentVC isKindOfClass:[UINavigationController class]]) {
                            cc = [(UINavigationController*)currentVC topViewController];
                        }
                        leftviewNext = [cc navigateBarCustomView:[HMUINavigationBar LEFT]];
                        rightviewNext = [cc navigateBarCustomView:[HMUINavigationBar RIGHT]];
                        centerviewNext = [cc customNavTitleView];
                    }
                    
                    if (item.backing) {
                        previousVC.view.alpha = 0.5f;
                        previousVC.view.alpha = 1.f;
                        if (currentItem.option<UIViewAnimationOptionTransitionFlipFromLeft) {
                            previousVC.view.alpha = 1.f;
                        }
                        previousVC.view.transform = transBack;
                        [[HMUIKeyboard sharedInstance] hideKeyboard];
                    }else{
                        if (currentItem.option<UIViewAnimationOptionTransitionFlipFromLeft) {
                            currentVC.view.alpha = 0.f;
                            previousVC.view.alpha = 1.f;
                        }
                        
                        [self.view bringSubviewToFront:currentVC.view];
                    }
                    
                    if (currentItem.backing)
                    {
                        [previousVC viewWillAppear:YES];
                        [currentVC viewWillDisappear:YES];
                    }
                    else{
                        if (!isNew) {
                            [currentVC viewWillAppear:YES];
                        }
                        
                        [previousVC viewWillDisappear:YES];
                    }
                    currentVC.view.userInteractionEnabled = NO;
                    previousVC.view.userInteractionEnabled = NO;
                    [UIView animateWithDuration:currentItem.duration animations:^{
                        
                        if (currentItem.option<UIViewAnimationOptionTransitionFlipFromLeft) {
                            currentVC.view.alpha = currentItem.backing?0.f:1.0f;
                        }

                        currentVC.view.transform = currentItem.backing?trans:CGAffineTransformIdentity;
                        if (currentItem.backing){
                            previousVC.view.alpha = 1.0f;
                            previousVC.view.transform = CGAffineTransformIdentity;
                            leftview.alpha = 1.f;
                            centerview.alpha = 1.f;
                            rightview.alpha = 0.f;
                            leftviewNext.alpha = 0.f;
                            centerviewNext.alpha = 0.f;
                            rightviewNext.alpha = 0.f;
                        }else{
                            previousVC.view.transform = transBack;
                            leftview.alpha = 0.f;
                            centerview.alpha = 0.f;
                            rightview.alpha = 0.f;
                            leftviewNext.alpha = 1.f;
                            centerviewNext.alpha = 1.f;
                            rightviewNext.alpha = 1.f;
                            if (currentItem.option<UIViewAnimationOptionTransitionFlipFromLeft) {
                                previousVC.view.alpha = 1.f;
                            }else{
//                                previousVC.view.alpha = .5f;
                                previousVC.view.alpha = 1.f;
                            }
                        }
                        
                    } completion:^(BOOL finished) {
                        currentVC.view.userInteractionEnabled = YES;
                        previousVC.view.userInteractionEnabled = YES;
                        currentVC.view.transform = CGAffineTransformIdentity;
                        if (currentItem.backing){
                            currentVC.view.hidden = YES;
                            [self.view bringSubviewToFront:previousVC.view];
                            [previousVC viewDidAppear:YES];
                            [currentVC viewDidDisappear:YES];
                        }else{
                            previousVC.view.hidden=YES;
                            if (!isNew)
                            [currentVC viewDidAppear:YES];
                            [previousVC viewDidDisappear:YES];
                        }
                        leftview.alpha = 1.f;
                        centerview.alpha = 1.f;
                        rightview.alpha = 1.f;
                        if (commple) {
                            commple(YES,currentVC);
                        }
                    }];
                    
                }else{
                    
                    UIViewAnimationOptions options = currentItem.option;
                    if (currentItem.backing) {
                        switch (options) {
                            case UIViewAnimationOptionTransitionCurlDown:
                                options = UIViewAnimationOptionTransitionCurlUp;
                                break;
                            case UIViewAnimationOptionTransitionCurlUp:
                                options = UIViewAnimationOptionTransitionCurlDown;
                                break;
                            case UIViewAnimationOptionTransitionFlipFromLeft:
                                options = UIViewAnimationOptionTransitionFlipFromRight;
                                break;
                            case UIViewAnimationOptionTransitionFlipFromRight:
                                options = UIViewAnimationOptionTransitionFlipFromLeft;
                                break;
                            case UIViewAnimationOptionTransitionFlipFromTop:
                                options = UIViewAnimationOptionTransitionFlipFromBottom;
                                break;
                            case UIViewAnimationOptionTransitionFlipFromBottom:
                                options = UIViewAnimationOptionTransitionFlipFromTop;
                                break;
                            default:
                                break;
                        }
                    }
                    blockSelf.currentC.view.alpha=1.0f;
                    [blockSelf transitionFromViewController:blockSelf.previousC toViewController:blockSelf.currentC duration:currentItem.duration options:options animations:^{
                        
                    } completion:^(BOOL finished) {
                        if (currentItem.backing){
                            currentVC.view.hidden = YES;
                        }else{
                            previousVC.view.hidden=YES;
                        }
                        if (commple) {
                            commple(YES,blockSelf.currentC);
                        }
                    }];
                }
                
            });
            
        }else{
            
            self.currentC.view.transform = CGAffineTransformIdentity;
            self.currentC.view.alpha = 1.0f;
            if (commple) {
                commple(YES,self.currentC);
            }
        }
    }
}

#pragma mark - touch

ON_PAN(signal){
    UIPanGestureRecognizer * panGesture = signal.inputValue;
    [self syncPanPosition:panGesture animated:YES];
}

- (void)syncPanPosition:(UIPanGestureRecognizer *)pan animated:(BOOL)animte{
    if (![HMUIConfig sharedInstance].allowControlerGestureBack) {
        return;
    }
    
    CGPoint point = [pan locationInView:self.view];
    
    static  CGPoint startPoint = {0,0};

    UIView *leftview = nil;
    UIView *rightview = nil;
    UIView *centerview = nil;
    
    UIView *leftviewNext = nil;
    UIView *rightviewNext = nil;
    UIView *centerviewNext = nil;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        startPoint = point;
        self.previousC = [self viewControllerBefore:self.currentC after:nil];
        [self.currentC.view showBackgroundShadowStyle:styleEmbossDarkLineLeft];
        if (self.previousC&&self.previousC.view.superview==nil) {
            
            [self.view insertSubview:self.previousC.view belowSubview:self.currentC.view];
            
        }
        if (self.previousC.navigatorBar!=nil) {
            UIViewController *cc = self.previousC;
            if ([self.previousC isKindOfClass:[UINavigationController class]]) {
                cc = [(UINavigationController*)self.previousC topViewController];
            }
            leftview = [cc navigateBarCustomView:[HMUINavigationBar LEFT]];
            rightview = [cc navigateBarCustomView:[HMUINavigationBar RIGHT]];
            centerview = [cc customNavTitleView];
        }
        
        if (self.currentC.navigatorBar!=nil) {
            UIViewController *cc = self.currentC;
            if ([self.currentC isKindOfClass:[UINavigationController class]]) {
                cc = [(UINavigationController*)self.currentC topViewController];
            }
            leftviewNext = [cc navigateBarCustomView:[HMUINavigationBar LEFT]];
            rightviewNext = [cc navigateBarCustomView:[HMUINavigationBar RIGHT]];
            centerviewNext = [cc customNavTitleView];
        }
    }

    if (self.previousC==nil) {
        return;
    }
    CGFloat slide=point.x-startPoint.x;
    CGFloat present = MIN(fabs(slide/self.view.width)*.5+.5,1.0);
    if (pan.state == UIGestureRecognizerStateChanged) {
        if (slide<2)return;
        self.previousC.view.hidden = NO;
        self.previousC.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -50*(1-present), 0);
//        self.previousC.view.alpha=present;
        self.currentC.view.left = slide;
    }
    
    if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded) {
        if (animte) {
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.25f];
            [UIView setAnimationDelegate:self];
            
            if ( slide < (self.currentC.view.width / 2.0f) )
            {
//                self.previousC.view.alpha=.5f;
                self.currentC.view.left = 0;
                self.previousC.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -50, 0);;
                [UIView setAnimationDidStopSelector:@selector(didTransformCancel)];
            }
            else
            {
//                self.previousC.view.alpha=1.f;
                self.previousC.view.transform = CGAffineTransformIdentity;
                self.currentC.view.left = self.currentC.view.width;
                [UIView setAnimationDidStopSelector:@selector(didTransformOk)];
            }
            [UIView commitAnimations];
        }
    }
}

- (void)didTransformCancel{
    self.previousC.view.transform = CGAffineTransformIdentity;
    self.previousC.view.hidden = YES;
//    self.previousC.view.alpha=.5f;
}

- (void)didTransformOk{
    if ([self.previousC valueForKey:@"nickname"]) {
        [self.currentC backWithAnimate:NO];
        self.previousC.view.left = 0;
        self.previousC.view.hidden = YES;
    }
    
}

@end

#pragma mark - for navigator

@implementation UINavigationController (HMBaseNavigatorDelegate)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)previousViewController {
    NSArray* viewControllers = self.viewControllers;
    if (viewControllers.count > 1) {
        NSUInteger controllerIndex = [viewControllers indexOfObject:self.visibleViewController];
        if (controllerIndex != NSNotFound && controllerIndex > 0) {
            return [viewControllers objectAtIndex:controllerIndex-1];
        }
    }
    
    return nil;
}

- (UIViewController *)visableViewController{
    return self.topViewController;
}

- (void)addSubcontroller:(HMURLMAPItem *)item animated:(BOOL)animated complete:(void (^)(BOOL,UIViewController*))commple{
    UIViewController * viewC = item.board;//item.board.stack==nil?item.board:[(UINavigationController*)item.board viewControllers].firstObject;
    item.board.openDate = [NSDate date];
    NSArray *all = self.viewControllers;
    for (UIViewController *vv in all) {
        vv.viewVisable = NO;
    }
    viewC.viewVisable = YES;
    if ([self.viewControllers containsObject:viewC]) {
        if (item.backing) {
            [self popViewControllerAnimated:animated];
        }else{
            [self popToViewController:viewC animated:animated];
        }
    }else{
        [self pushViewController:viewC animated:animated];
    }
    if (commple) {
        if (animated) {
//            [self delay:.35f invoke:^{
//                
//                commple(YES,viewC);
//            }];
            [self delayInMain:.35f invoke:^{
                commple(YES,viewC);
            }];
        }else{
            commple(YES,viewC);
        }
        
    }
    
}

@end
