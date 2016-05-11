//
//  YCLoginViewController.m
//  MadeInFXFT
//
//  Created by yc on 16/3/21.
//  Copyright © 2016年 yc. All rights reserved.
//

#import "YCLoginViewController.h"
#import "YCUserPresenter.h"
#import "YCRegistViewController.h"
#import "YCForgetPasswordViewController.h"
#import "YCSMSLoginViewController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
@interface YCLoginViewController ()<PresenterCallBackProtocol>
@property (strong, nonatomic) IBOutlet HMUITextField *telePhoneField;
@property (strong, nonatomic) IBOutlet HMUITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButten *openSecretBtn;
@property (strong, nonatomic) IBOutlet UIButten *loginBtn;
@property (strong, nonatomic) IBOutlet UIButten *forgetPasswordBtn;
@property (strong, nonatomic) IBOutlet UIButten *smsLoginBtn;
@property (strong, nonatomic) IBOutlet UIButten *thirdParBtn1;
@property (strong, nonatomic) IBOutlet UIButten *thirdParBtn2;
@property (strong, nonatomic) IBOutlet UIButten *thirdParBtn3;

@property (strong, nonatomic) YCUserPresenter *userPresenter;

@end

@implementation YCLoginViewController
@synthesize userPresenter=_userPresenter;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [self.customNavLeftBtn setImage:[UIImage imageNamed:@"back_blue"] forState:UIControlStateNormal];
//    [self.customNavLeftBtn setFrame:CGRectMakeBound(50, 32)];

    [self.customNavRightBtn setTitle:@"注册" forState:UIControlStateNormal];
    [self.customNavRightBtn setFrame:CGRectMakeBound(50, 32)];
    [self.customNavRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self initDatas];
    [self initSubviews];
}
-(void)initDatas{
    _userPresenter = [[YCUserPresenter alloc]init];
    _userPresenter.delegate = self;
}
-(void)initSubviews{
    [self.passwordField setSecureTextEntry:YES];
    self.openSecretBtn.tagString = @"openSecretBtn";
    self.loginBtn.tagString = @"loginBtn";
    self.forgetPasswordBtn.tagString = @"forgetPasswordBtn";
    self.smsLoginBtn.tagString = @"smsLoginBtn";
    [self thirdConfig];
}
-(void)thirdConfig{
    if([QQApiInterface isQQInstalled]&&[WXApi isWXAppInstalled]){
        self.thirdParBtn1.tagString = @"weixinBtn";
        [self.thirdParBtn1 setImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        self.thirdParBtn2.tagString = @"qqBtn";
        [self.thirdParBtn2 setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
        self.thirdParBtn3.tagString = @"weiboBtn";
        [self.thirdParBtn3 setImage:[UIImage imageNamed:@"weibo"] forState:UIControlStateNormal];
    }else if(![QQApiInterface isQQInstalled]&&![WXApi isWXAppInstalled]){
        self.thirdParBtn2.tagString = @"weiboBtn";
        [self.thirdParBtn2 setImage:[UIImage imageNamed:@"weibo"] forState:UIControlStateNormal];
    }else{
        if([QQApiInterface isQQInstalled]){
            self.thirdParBtn1.tagString = @"qqBtn";
            [self.thirdParBtn1 setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
        }else{
            self.thirdParBtn1.tagString = @"weixinBtn";
            [self.thirdParBtn1 setImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        }
        self.thirdParBtn3.tagString = @"weiboBtn";
        [self.thirdParBtn3 setImage:[UIImage imageNamed:@"weibo"] forState:UIControlStateNormal];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {
            [self backAndRemoveWithAnimate:YES];
        }else if ([btn is:@"rightBtn"]){
            YCRegistViewController *registVC = [[YCRegistViewController alloc]init];
            [self.navigationController pushViewController:registVC animated:YES];
        }else if ([btn is:@"openSecretBtn"]){
            if(self.passwordField.secureTextEntry){
                [self.passwordField setSecureTextEntry:NO];
                [btn setImage:[UIImage imageNamed:@"48X48px显示密码-l"] forState:UIControlStateNormal];
            }else{
                [self.passwordField setSecureTextEntry:YES];
                [btn setImage:[UIImage imageNamed:@"48X48px显示密码"] forState:UIControlStateNormal];
            }
        }else if ([btn is:@"loginBtn"]){
            NSArray *ary = @[@{@"telephone":self.telePhoneField.text,@"password":self.passwordField.text}];
            [_userPresenter doSomething:_userPresenter.login attributes:ary];
        }else if ([btn is:@"forgetPasswordBtn"]){
            YCForgetPasswordViewController *forgetPasswordVC = [[YCForgetPasswordViewController alloc]init];
            [self.navigationController pushViewController:forgetPasswordVC animated:YES];
        }else if ([btn is:@"smsLoginBtn"]){
            YCSMSLoginViewController *smsLoginVC = [[YCSMSLoginViewController alloc]init];
            [self.navigationController pushViewController:smsLoginVC animated:YES];
        }else if ([btn is:@""]){
            
        }else if ([btn is:@""]){
            
        }else if ([btn is:@""]){
            
        }
    }
}
ON_TextField(signal){
    HMUITextField *field = signal.source;
    if ([signal is:[HMUITextField WILL_ACTIVE]]){
        [HMUIKeyboard sharedInstance].visabler = field;
        [HMUIKeyboard sharedInstance].accessor = self.view;
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [HMUIKeyboard hideKeyboard];
}
-(void)presenter:(Presenter *)presenter doSome:(NSString *)something bean:(id)bean state:(PresenterProcess)state error:(NSError *)error{
    if([something is:_userPresenter.login]){
        if(state == APIProcessSucced){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
