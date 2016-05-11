//
//  HMUIColumnBoard.m
//  EFExtend
//
//  Created by mac on 15/7/2.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUIColumnBoard.h"


@interface HMUIColumnBoard ()
@property (nonatomic,HM_STRONG,readwrite) UIViewController *leftController;
@property (nonatomic,HM_STRONG,readwrite) UIViewController *rightController;
@end

@implementation HMUIColumnBoard
@synthesize leftController;
@synthesize rightController;

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
    self.leftController = [self columControllerForPosition:ColumPositionLeft];
    if (leftController) {
//        self.leftController.view.hidden = YES;
        [self.view addSubview:leftController.view];
        [self addChildViewController:leftController];
        leftController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    }
    
    
    self.rightController = [self columControllerForPosition:ColumPositionRight];
    if (rightController) {
//        self.rightController.view.hidden = YES;
        [self.view addSubview:rightController.view];
        [self addChildViewController:rightController];
        rightController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.leftWidth = [self columWidthForPosition:ColumPositionLeft];
    self.leftController.view.frame = CGRectMake(0, 0, self.leftWidth, self.view.height);
    self.rightWidth = [self columWidthForPosition:ColumPositionRight];
    self.rightController.view.frame = CGRectMake(self.leftController.view.width, 0, self.rightWidth, self.view.height);
}

- (UIViewController *)columControllerForPosition:(ColumPosition)position{
    return [HMUIBoard board];
}

- (CGFloat)columWidthForPosition:(ColumPosition)position{
    return self.view.width/2;
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

@end
