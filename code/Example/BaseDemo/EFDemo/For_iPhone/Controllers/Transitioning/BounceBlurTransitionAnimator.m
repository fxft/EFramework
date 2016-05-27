//
//  BounceBlurTransitionAnimator.m
//  EFDemo
//
//  Created by mac on 16/5/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "BounceBlurTransitionAnimator.h"

@implementation BounceBlurTransitionAnimator


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    // For a Push:
    //      fromView = The current top view controller.
    //      toView   = The incoming view controller.
    // For a Pop:
    //      fromView = The outgoing view controller.
    //      toView   = The new top view controller.
    UIView *fromView;
    UIView *toView;
    
    // In iOS 8, the viewForKey: method was introduced to get views that the
    // animator manipulates.  This method should be preferred over accessing
    // the view of the fromViewController/toViewController directly.
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    } else {
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    // If a push is being animated, the incoming view controller will have a
    // higher index on the navigation stack than the current top view
    // controller.
//    BOOL isPush = ([toViewController.navigationController.viewControllers indexOfObject:toViewController] > [fromViewController.navigationController.viewControllers indexOfObject:fromViewController]);
    
    // Our animation will be operating on snapshots of the fromView and toView,
    // so the final frame of toView can be configured now.
//    fromView.frame = [transitionContext initialFrameForViewController:fromViewController];
//    toView.frame = [transitionContext finalFrameForViewController:toViewController];
    
    
    UIView *snapshot = [containerView viewWithTagString:@"snapshotsnapshotsnapshotsnapshotsnapshot"];
    UIVisualEffectView *effectview  = (id)[containerView viewWithTagString:@"effectvieweffectvieweffectvieweffectvieweffectview"];
    
    if (self.operation==UINavigationControllerOperationPush) {
        
        snapshot = [containerView resizableSnapshotViewFromRect:containerView.frame  afterScreenUpdates:YES withCapInsets:UIEdgeInsetsTBAndHor(64, 0, 0)];
        snapshot.userInteractionEnabled = NO;
        snapshot.tagString = @"snapshotsnapshotsnapshotsnapshotsnapshot";
        [containerView addSubview:snapshot];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectview.userInteractionEnabled = NO;
        effectview.tagString = @"effectvieweffectvieweffectvieweffectvieweffectview";
        [containerView addSubview:effectview];
        effectview.frame = CGRectEdgeInsets(toView.frame, UIEdgeInsetsTBAndHor(64, 0, 0));
        effectview.alpha = 0.f;
        
    }else{
        
    }
    // We are responsible for adding the incoming view to the containerView
    // for the transition.
//    snapshot.alpha = 0.0f;
   
    fromView.alpha = 1.0f;
    toView.alpha = 0.0f;
    
    [containerView addSubview:toView];
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        fromView.alpha = 0.0f;
        effectview.alpha = 1.f;
        toView.alpha = 1.0;
    } completion:^(BOOL finished) {
        // When we complete, tell the transition context
        // passing along the BOOL that indicates whether the transition
        // finished or not.
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
        if (self.operation==UINavigationControllerOperationPop){
            [snapshot removeFromSuperview];
            [effectview removeFromSuperview];
        }
    }];
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25f;
}

@end
