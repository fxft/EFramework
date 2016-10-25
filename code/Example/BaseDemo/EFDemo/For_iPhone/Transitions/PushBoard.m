//
//  PushBoard.m
//  EFDemo
//
//  Created by mac on 16/9/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "PushBoard.h"


@interface PushBoard ()

@end

@implementation PushBoard

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
    self.title = @(self.tag).description;
    
    UIButten *btn = [[UIButten spawn] EFOwner:self.view];
    [btn setTitle:@"push" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(10, 20, 150, 40);
    UIColor *color = [UIColor redColor];
    btn.style__ = [HMUIFourBorderStyle styleWithTop:color right:color bottom:color left:color width:.5f next:nil];
    btn.tagString  = @"push";
    
    
    btn = [[UIButten spawn] EFOwner:self.view];
    [btn setTitle:@"open" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(10, 80, 150, 40);
    btn.style__ = [HMUIFourBorderStyle styleWithTop:color right:color bottom:color left:color width:.5f next:nil];
    btn.tagString  = @"open";
    
    
    btn = [[UIButten spawn] EFOwner:self.view];
    [btn setTitle:@"pop to 1" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(10, 140, 150, 40);
    btn.style__ = [HMUIFourBorderStyle styleWithTop:color right:color bottom:color left:color width:.5f next:nil];
    btn.tagString  = @"pop to 1";
    
    
    btn = [[UIButten spawn] EFOwner:self.view];
    [btn setTitle:@"push 3 and back 2" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(10, 200, 150, 40);
    btn.style__ = [HMUIFourBorderStyle styleWithTop:color right:color bottom:color left:color width:.5f next:nil];
    btn.tagString  = @"push to 3 and back to 2";
    
    
    btn = [[UIButten spawn] EFOwner:self.view];
    [btn setTitle:@"back to main" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(150, 200, 150, 40);
    btn.style__ = [HMUIFourBorderStyle styleWithTop:color right:color bottom:color left:color width:.5f next:nil];
    btn.tagString  = @"back to main";
    
    
    btn = [[UIButten spawn] EFOwner:self.view];
    [btn setTitle:@"back to New" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(150,140, 150, 40);
    btn.style__ = [HMUIFourBorderStyle styleWithTop:color right:color bottom:color left:color width:.5f next:nil];
    btn.tagString  = @"back to New";
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
            
        }else if ([btn is:@"open"]){//customNavRightBtn
            
        }else if ([btn is:@"back to New"]){//customNavRightBtn
            
        }else if ([btn is:@"back to main"]){//customNavRightBtn
            [self.stack  backWithAnimate:YES remove:YES];
        }else if ([btn is:@"push to 3 and back to 2"]){//customNavRightBtn
            
            [self pushToPath:URLFOR_controller(@"PushBoard") map:@"3" animated:YES complete:^(BOOL viewLoaded, UIViewController *toBoard) {
                if (!viewLoaded) {
                    [toBoard setValue:@(3) forKey:@"tag"];
                    
                }else {
                    PushBoard *push = [[PushBoard alloc]init];
                    push.tag = 2;
                    NSMutableArray *vcs = [self.stack.viewControllers mutableArray];
                    [vcs insertObject:push atIndex:MAX((NSInteger)[vcs indexOfObject:toBoard], 0)];
                    
                    self.stack.viewControllers = vcs;
                }
            }];
            
        }else if ([btn is:@"pop to 1"]){//customNavRightBtn
            //@"1"表示 pushToPath:map: 的map名称
            [self backToMap:@"1" close:self.title animate:YES complete:^(BOOL viewLoaded, UIViewController *toBoard) {
                
            }];
        }else if ([btn is:@"push"]){//customNavRightBtn
            [self pushToPath:URLFOR_controller(@"PushBoard") map:@(self.tag+1).description animated:YES complete:^(BOOL viewLoaded, UIViewController *toBoard) {
                if (!viewLoaded) {
                    [toBoard setValue:@(self.tag+1) forKey:@"tag"];
                }
            }];
        }
    }
}

@end
