//
//  TabbarSubController.m
//  EFDemo
//
//  Created by mac on 16/5/11.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "TabbarSubController.h"
#import "BounceBlurTransitionAnimator.h"

@interface TabbarSubController ()<UINavigationControllerDelegate,UIViewControllerTransitioningDelegate>

@end

@implementation TabbarSubController

- (void)dealloc
{
   
    HM_SUPER_DEALLOC();
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.customNavLeftBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [self.customNavLeftBtn setFrame:CGRectMakeBound(32, 32)];
    
    [self initDatas];
    
    [self initSubviews];
}

- (void)initDatas{
    
}

- (void)initSubviews{
    self.view.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:178 / 255.0 blue:10 / 255.0 alpha:1];
    [self.tableView reloadData];
    
    self.navigationController.delegate = self;
    self.transitioningDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {//customNavLeftBtn
            if (self.presentingViewController) {
                [self backAndRemoveWithAnimate:YES];
            }else{
                if (self.navigationController.viewControllers.count==1) {
                    [self.tabBarController backAndRemoveWithAnimate:YES];
                }else{
                    [self backAndRemoveWithAnimate:YES];
                }
            }
            
        }else if ([btn is:@"rightBtn"]){//customNavRightBtn
            
        }
    }
}


#pragma  mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"listCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    cell.imageView.image = [UIImage imageNamed:@"tabbar_discoverHL"];
    cell.imageView.size = CGSizeMake(60, 60);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//   [self pushToPath:URLFOR_controller(@"TabbarSubController") map:nil
//           animated:YES complete:^(BOOL viewLoaded, UIViewController *toBoard) {
//               if (!viewLoaded) {
//                   toBoard.hidesBottomBarWhenPushed = YES;
//               }
//           }];
    [self presentToPath:URLFOR_controllerWithNav(@"BounceBlurController") map:nil animated:YES complete:^(BOOL viewLoaded, UIViewController *toBoard) {
        if (!viewLoaded) {
            toBoard.transitioningDelegate = self;
        }
    }];
}
#pragma mark UIViewController TransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    BounceBlurTransitionAnimator * animator = [BounceBlurTransitionAnimator new];
    animator.operation = UINavigationControllerOperationPush;
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    BounceBlurTransitionAnimator * animator = [BounceBlurTransitionAnimator new];
    animator.operation = UINavigationControllerOperationPop;
    
    return animator;
}

#pragma mark - navigation transition
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    BounceBlurTransitionAnimator * animator = [BounceBlurTransitionAnimator new];
    animator.operation = operation;
    
    return animator;
}

//- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
//    
//    return nil;
//}

@end
