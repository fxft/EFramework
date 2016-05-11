//
//  TabbarBoard.m
//  EFDemo
//
//  Created by mac on 16/5/11.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "TabbarBoard.h"


@interface TabbarBoard ()
@property (nonatomic,strong) HMUITapbarView * tab;
@end

@implementation TabbarBoard{
   
}

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
    
   UIViewController *homeViewController = [HMURLMAPItem setupWith:URLFOR_controllerWithNav(@"TabbarSubController")].board;
    homeViewController.myTopBoard.title = @"0";
    homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:1];
    UIViewController *sameCityViewController = [HMURLMAPItem setupWith:URLFOR_controllerWithNav(@"TabbarSubNormalController")].board;
    sameCityViewController.myTopBoard.title = @"1";
    sameCityViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:2];
    UIViewController *messageViewController = [HMURLMAPItem setupWith:URLFOR_controllerWithNav(@"TabbarSubController")].board;
    messageViewController.myTopBoard.title = @"2";
    messageViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:3];
    UIViewController *mineViewController = [HMURLMAPItem setupWith:URLFOR_controllerWithNav(@"TabbarSubController")].board;
    mineViewController.myTopBoard.title = @"3";
    mineViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:4];
    
    self.viewControllers = @[homeViewController, sameCityViewController, messageViewController, mineViewController];

    self.tab = [[HMUITapbarView alloc] init];
    self.tab.barStyle  = UITapbarStyleFitWidth;
    self.tab.clipsToBounds = NO;
    self.tab.backgroundImage = [[UIImage imageNamed:@"tapbar_top_line"] stretched];
    self.tab.backgroundImageView.height = 5;

    /**
     *  设置透明毛玻璃效果（有关tableview的controller请使用tableviewcontroller）
     */
//    tabbarController.tabBar.translucent = YES;
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
    
    [self.tab addSubview:effectview];
    [self.tab sendSubviewToBack:effectview];
    
    
    UIButten *btn = [self.tab addItemWithTitle:@"首页" imageName:@"home.png" size:CGSizeMake(54, 54)];
    btn.buttenType = UIButtenTypeIconSideTop|UIButtenTypeContenSideBottom;
    btn.textMargin = 5;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleFont:[UIFont systemFontOfSize:12] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    
    btn = [self.tab addItemWithTitle:@"同城" imageName:@"mycity.png" size:CGSizeMake(54, 54)];
    btn.buttenType = UIButtenTypeIconSideTop|UIButtenTypeContenSideBottom;
    btn.textMargin = 5;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleFont:[UIFont systemFontOfSize:12] forState:UIControlStateNormal];
    
    btn = [self.tab addItemWithTitle:@"发布" imageName:@"post.png" size:CGSizeMake(54+58/2, 54+58/2)];
    btn.buttenType = UIButtenTypeIconSideTop|UIButtenTypeContenSideBottom;
    btn.textMargin = 3;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleFont:[UIFont systemFontOfSize:12] forState:UIControlStateNormal];
    
    btn = [self.tab addItemWithTitle:@"消息" imageName:@"message.png" size:CGSizeMake(54, 54)];
    btn.buttenType = UIButtenTypeIconSideTop|UIButtenTypeContenSideBottom;
    btn.textMargin = 5;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleFont:[UIFont systemFontOfSize:12] forState:UIControlStateNormal];
    
    btn = [self.tab addItemWithTitle:@"我的" imageName:@"account.png" size:CGSizeMake(54, 54)];
    btn.buttenType = UIButtenTypeIconSideTop|UIButtenTypeContenSideBottom;
    btn.textMargin = 5;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn setTitleFont:[UIFont systemFontOfSize:12] forState:UIControlStateNormal];
    
    [self.tabBar addSubview:self.tab];
    
//    [self.tab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(54);
//        make.left.mas_equalTo(self.tabBar.mas_left).offset(0);
//        make.bottom.mas_equalTo(self.tabBar.mas_bottom).offset(0);
//        make.right.mas_equalTo(self.tabBar.mas_right).offset(0);
//    }];

    self.tab.frame = CGRectMake(0, -5, self.tabBar.width, 54);
    
    [effectview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(49);
        make.left.mas_equalTo(self.tab.mas_left).offset(0);
        make.bottom.mas_equalTo(self.tab.mas_bottom).offset(0);
        make.right.mas_equalTo(self.tab.mas_right).offset(0);
    }];
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
            [self backAndRemoveWithAnimate:YES];
        }else if ([btn is:@"rightBtn"]){//customNavRightBtn
            
        }
    }
}

ON_TapBar(signal){
    HMUITapbarView *tapview = signal.source;
    
    if ([signal is:[HMUITapbarView TAPNOSELECTED]]) {
        if (tapview.selectedIndex==2) {
            [signal returnYES];
            
        }
    }else if ([signal is:[HMUITapbarView TAPCHANGED]]){

        if (tapview.selectedIndex==2) {
            return;
        }
        if (tapview.selectedIndex>2) {
            self.selectedIndex = tapview.selectedIndex-1;
        }else{
            self.selectedIndex = tapview.selectedIndex;
        }
    }
}

@end
