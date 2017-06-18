//
//  HMUIPageViewController.m
//  EFExtend
//
//  Created by mac on 15/4/21.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUIPageViewController.h"

@interface HMUIPageViewController ()

@end

@implementation HMUIPageViewController{
    CGRect cantouchRect;
}
@dynamic delegate;

- (void)handleTouch:(UITouch*)touch{
    static BOOL show = NO;
    static  CGPoint startPoint = {0,0};
    
    if (touch.phase == UITouchPhaseBegan) {
        startPoint = [touch locationInView:self.view];
        show = YES;
    }else if (touch.phase == UITouchPhaseMoved) {
        CGPoint point = [touch locationInView:self.view];
        if (fabs(point.x-startPoint.x)>10||fabs(point.y-startPoint.y)>10) {
            show = NO;
        }
    }else if (touch.phase == UITouchPhaseEnded) {
        if (show) {
            CGPoint point = [touch locationInView:self.view];
            CGFloat width = self.view.width/3;
            CGFloat height = self.view.height/5;
            if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.edgeInsets)) {
                self.edgeInsets = UIEdgeInsetsMake(width, height, width, height);
            }
            cantouchRect = CGRectEdgeInsets(self.view.bounds, self.edgeInsets);
            if (CGRectContainsPoint(cantouchRect, point)) {
                if ([self.delegate respondsToSelector:@selector(pageViewControllerHadTaped:)]) {
                    [self.delegate pageViewControllerHadTaped:self];
                }
            }else if (point.x<self.view.width-width&&point.x>width){
                //左边
                UIViewController *nowVC = [self.viewControllers firstObject];
                UIViewController *nextVC = nil;
                BOOL forword = YES;
                if (point.x > cantouchRect.origin.x+cantouchRect.size.width/2) {
                    nextVC = [self.dataSource pageViewController:self viewControllerAfterViewController:nowVC];
                }else{
                    forword =  NO;
                    nextVC = [self.dataSource pageViewController:self viewControllerBeforeViewController:nowVC];
                }
                if (nextVC) {
                    NSArray *nextArray =@[nextVC];
                    [self.delegate pageViewController:self willTransitionToViewControllers:nextArray];
                    
                    __weak_type typeof(self) selfWeak = self;
                    
                    [self setViewControllers:nextArray direction:forword?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
                        [selfWeak.delegate pageViewController:selfWeak didFinishAnimating:finished previousViewControllers:selfWeak.viewControllers transitionCompleted:YES];
                    }];
                }
                //右边
            }
            
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    [self handleTouch:touch];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    [self handleTouch:touch];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    [self handleTouch:touch];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    [self handleTouch:touch];
    
}

@end

