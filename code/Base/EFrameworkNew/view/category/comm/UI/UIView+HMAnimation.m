//
//  UIView+HMAnimation.m
//  EFMWKLib
//
//  Created by Eric on 14-11-8.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "UIView+HMAnimation.h"

@implementation UIView (HMAnimation)

- (CAKeyframeAnimation*)animationRoateY:(BOOL)clockwise durantion:(CGFloat)durantion{
    
    NSInteger reverse = clockwise?1:-1;
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D rotation1 = CATransform3DMakeRotation(90 * M_PI/180, 0, reverse, 0);
    CATransform3D rotation2 = CATransform3DMakeRotation(180 * M_PI/180, 0, reverse, 0);
    CATransform3D rotation3 = CATransform3DMakeRotation(270 * M_PI/180, 0, reverse, 0);
    CATransform3D rotation4 = CATransform3DMakeRotation(360 * M_PI/180, 0, reverse, 0);
    
    [keyAnim setValues:[NSArray arrayWithObjects:
                        [NSValue valueWithCATransform3D:rotation1],
                        [NSValue valueWithCATransform3D:rotation2],
                        [NSValue valueWithCATransform3D:rotation3],
                        [NSValue valueWithCATransform3D:rotation4],
                        nil]];
    [keyAnim setKeyTimes:@[[NSNumber numberWithFloat:0.0f],
                           [NSNumber numberWithFloat:0.2f],
                           [NSNumber numberWithFloat:0.8f],
                           [NSNumber numberWithFloat:1.0f],]];
    [keyAnim setDuration:durantion];
    [keyAnim setFillMode:kCAFillModeForwards];
    [keyAnim setRemovedOnCompletion:NO];
    
    [self.layer addAnimation:keyAnim forKey:@"__transform_roateY"];
    
    return keyAnim;
}

- (CABasicAnimation *)animationShakeDurantion:(CGFloat)durantion{
    
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:- 0.2];
    shake.toValue   = [NSNumber numberWithFloat:+ 0.2];
    shake.duration = 0.1;
    shake.autoreverses = YES;
    shake.repeatCount = 4;
    [self.layer addAnimation:shake forKey:@"__transform_Shake"];
    
    return shake;
    
}

+ (void)animationVibrate{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


@end


#pragma mark - 页面切换

@interface AnimatorZBFallenBricks ()
@property (nonatomic,HM_STRONG) UIDynamicAnimator *animator;
@end


@implementation AnimatorZBFallenBricks
{
    NSMutableArray *views;
    NSInteger row;
    NSInteger column;
}
DEF_SINGLETON(AnimatorZBFallenBricks)
@synthesize animator;

- (instancetype)init
{
    self = [super init];
    if (self) {
        row = 5;
        column = 5;
    }
    return self;
}

- (void)dealloc
{
    self.animator = nil;
    [views release];
    views = nil;
    HM_SUPER_DEALLOC();
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (!views) {
        views = [[NSMutableArray alloc] init];
    }
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGFloat width = containerView.bounds.size.width / row;
    CGFloat height = containerView.bounds.size.height / column;
    NSInteger index = [toVC.view.subviews count];
    for (NSInteger i = 0; i < row; i++) {
        for (NSInteger j = 0; j < column; j++) {
            CGRect aRect = CGRectMake(j * width, i * height, width, height);
            UIView *aView = [fromVC.view resizableSnapshotViewFromRect:aRect
                                                    afterScreenUpdates:NO
                                                         withCapInsets:UIEdgeInsetsZero];
            aView.frame = aRect;
            CGFloat angle = ((j + i) % 2 ? 1 : -1) * (rand() % 5 / 10.0);
            aView.transform = CGAffineTransformMakeRotation(angle);
            aView.layer.borderWidth = 0.5;
            aView.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
            [views addObject:aView];
            [toVC.view insertSubview:aView atIndex:index];
        }
    }
    [fromVC.view removeFromSuperview];
    [containerView addSubview:toVC.view];
    
    self.animator = [[[UIDynamicAnimator alloc] initWithReferenceView:toVC.view] autorelease];
    UIDynamicBehavior *behaviour = [[[UIDynamicBehavior alloc] init] autorelease];
    UIGravityBehavior *gravityBehaviour = [[[UIGravityBehavior alloc] initWithItems:views] autorelease];
    UICollisionBehavior *collisionBehavior = [[[UICollisionBehavior alloc] initWithItems:views] autorelease];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionMode = UICollisionBehaviorModeBoundaries;
    
    [behaviour addChildBehavior:gravityBehaviour];
    [behaviour addChildBehavior:collisionBehavior];
    
    for (UIView *aView in views) {
        UIDynamicItemBehavior *itemBehaviour = [[[UIDynamicItemBehavior alloc] initWithItems:@[aView]] autorelease];
        itemBehaviour.elasticity = (rand() % 5) / 8.0;
        itemBehaviour.density = (rand() % 5 / 3.0);
        //		itemBehaviour.allowsRotation = YES;
        [behaviour addChildBehavior:itemBehaviour];
    }
    
    [animator addBehavior:behaviour];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        for (UIView *aView in views) {
            aView.alpha = 0.0;
        }
        toVC.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        for (UIView *view in views) {
            [view removeFromSuperview];
        }
        [views removeAllObjects];
        [transitionContext completeTransition:YES];
    }];
}
@end


#pragma mark 
@implementation AnimatorTransitionHorizontalLines

#define HLANIMATION_TIME1 0.01
#define HLANIMATION_TIME2 3.70
/// returns the duration of the verticalLinesAnimation
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return HLANIMATION_TIME1+HLANIMATION_TIME2;
}


#define HLINEHEIGHT 4.0
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //get the container view
    UIView *containerView = [transitionContext containerView];
    
    //lets get a snapshot of the outgoing view
    UIView *mainSnap = [fromVC.view snapshotViewAfterScreenUpdates:NO];
    //cut it into vertical slices
    NSArray *outgoingLineViews = [self cutView:mainSnap intoSlicesOfHeight:HLINEHEIGHT yOffset:fromVC.view.frame.origin.y];
    
    //add the slices to the content view.
    for (UIView *v in outgoingLineViews) {
        [containerView addSubview:v];
    }
    
    
    UIView *toView = [toVC view];
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView addSubview:toView];
    
    
    CGFloat toViewStartX = toView.frame.origin.x;
    toView.alpha = 0;
//    fromVC.view.hidden = YES;
    
    toVC.view.alpha = 1;
    UIView *mainInSnap = [toView snapshotViewAfterScreenUpdates:YES];
    //cut it into vertical slices
    NSArray *incomingLineViews = [self cutView:mainInSnap intoSlicesOfHeight:HLINEHEIGHT yOffset:toView.frame.origin.y];
    
    BOOL presenting = self.presenting;
    
    [UIView animateWithDuration:HLANIMATION_TIME1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //This is basically a hack to get the incoming view to render before I snapshot it.
    } completion:^(BOOL finished) {
        
        //move the slices in to start position (incoming comes from the right)
        [self repositionViewSlices:incomingLineViews moveLeft:!presenting];
        
        //add the slices to the content view.
        for (UIView *v in incomingLineViews) {
            [containerView addSubview:v];
        }
        toView.hidden = YES;
        
        [UIView animateWithDuration:HLANIMATION_TIME2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self repositionViewSlices:outgoingLineViews moveLeft:presenting];
            [self resetViewSlices:incomingLineViews toXOrigin:toViewStartX];
        } completion:^(BOOL finished) {
            fromVC.view.hidden = NO;
            toView.hidden = NO;
            [toView setNeedsUpdateConstraints];
            for (UIView *v in incomingLineViews) {
                [v removeFromSuperview];
            }
            for (UIView *v in outgoingLineViews) {
                [v removeFromSuperview];
            }
            [transitionContext completeTransition:YES];
        }];
        
    }];
    
}

/**
 cuts a \a view into an array of smaller views of \a height
 @param view the view to be sliced up
 @param height The height of each slice
 @returns A mutable array of the sliced views with their frames representative of their position in the sliced view.
 */
-(NSMutableArray *)cutView:(UIView *)view intoSlicesOfHeight:(float)height yOffset:(float)yOffset{
    
    CGFloat lineWidth = CGRectGetWidth(view.frame);
    
    NSMutableArray *lineViews = [NSMutableArray array];
    
    for (int y=0; y<CGRectGetHeight(view.frame); y+=height) {
        CGRect subrect = CGRectMake(0, y, lineWidth, height);
        
        
        UIView *subsnapshot;
        subsnapshot = [view resizableSnapshotViewFromRect:subrect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        subrect.origin.y += yOffset;
        subsnapshot.frame = subrect;
        
        [lineViews addObject:subsnapshot];
    }
    return lineViews;
    
}

/**
 repositions an array of \a views to the left or right by their frames width
 @param views The array of views to reposition
 @param left should the frames be moved to the left
 */
-(void)repositionViewSlices:(NSArray *)views moveLeft:(BOOL)left{
    
    
    CGRect frame;
    float width;
    for (UIView *line in views) {
        frame = line.frame;
        width = CGRectGetWidth(frame) * RANDOM_FLOAT(1.0, 8.0);
        
        frame.origin.x += (left)?-width:width;
        
        //save the new position
        line.frame = frame;
    }
}

/**
 resets the views back to a specified x origin.
 @param views The array of uiview objects to reposition
 @param x The x origin to set all the views frames to.
 */
-(void)resetViewSlices:(NSArray *)views toXOrigin:(CGFloat)x{
    
    CGRect frame;
    for (UIView *line in views) {
        frame = line.frame;
        
        frame.origin.x = x;
        
        //save the new position
        line.frame = frame;
        
    }
}


@end