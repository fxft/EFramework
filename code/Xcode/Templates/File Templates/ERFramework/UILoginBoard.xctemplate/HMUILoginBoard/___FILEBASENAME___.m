//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//



#import "___FILEBASENAME___.h"

#undef PASS
//#define PASS 

@interface ___FILEBASENAMEASIDENTIFIER___ ()

@end

@implementation ___FILEBASENAMEASIDENTIFIER___

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
    self.view.backgroundColor = RGBViewBack;
    self.title = @"登录";

    [self resetView];
}
- (void)dealloc
{
    [_passwdL release];
    [_accountL release];
    [_registerBtn release];
    [_loginBtn release];
    [_autologinBtn release];
    [_rememberBtn release];
    [_passwdTF release];
    [_accountTF release];
    [_textFieldView release];
   
    HM_SUPER_DEALLOC();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetView{
    
    self.textFieldView.backgroundColor = RGBViewBack;
//    self.textFieldView.style__ = [HMUIShapeStyle styleWithShape:
//                                  [HMUIRoundedRectangleShape shapeWithRadius:5] next:
//                                  [HMUISolidFillStyle styleWithColor:[UIColor whiteColor] next:
//                                   
//                                   [HMUIInsetStyle styleWithSaveForNewFrame:CGRectMake(0, 0, self.textFieldView.width, 63) next:
//                                    [HMUIShapeStyle styleWithShape:[HMUIRectangleShape shape] next:
//                                     [HMUIFourBorderStyle styleWithBottom:RGBSpaceLine width:1 next:
//                                      [HMUIInsetStyle styleWithRestoreNext:
//                                       
//                                       [HMUIInsetStyle styleWithSaveForNewFrame:CGRectMake(0, 63, self.textFieldView.width, 63) next:
//                                        [HMUIShapeStyle styleWithShape:[HMUIRectangleShape shape] next:
//                                         [HMUIFourBorderStyle styleWithBottom:RGBSpaceLine width:1 next:
//                                          [HMUIInsetStyle styleWithRestoreNext:nil]]]]]]]]]];
    
    UIImage *image = nil;
    if ([HMSystemInfo isPhoneRetina4]) {
        image = [UIImage imageWithContentsOfFile:[HMSandbox pathWithbundleName:nil fileName:@"Default-568h@2x.png"]];
    }else{
        image = [UIImage imageWithContentsOfFile:[HMSandbox pathWithbundleName:nil fileName:@"Default@2x.png"]];
    }
    self.view.backgroundImageView.contentMode = UIViewContentModeBottom;
    self.view.backgroundImage = image;
    
    self.accountTF.style__ = [HMUIInsetStyle styleWithInset:UIEdgeInsetsVerAndLR(0, 5, 0) next:nil];
    self.accountTF.backgroundImage = [[UIImage imageNamed:@"input1.png"]stretched];
    self.accountTF.nextChain = self.passwdTF;
    self.accountTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.accountTF.returnKeyType = UIReturnKeyNext;
    
    self.passwdTF.style__ = [HMUIInsetStyle styleWithInset:UIEdgeInsetsVerAndLR(0, 5, 0) next:nil];
    self.passwdTF.backgroundImage = [[UIImage imageNamed:@"input1.png"]stretched];
    self.passwdTF.shouldHideIfReturn = YES;
    self.passwdTF.secureTextEntry = YES;
    
    self.rememberBtn.buttenType = UIButtenTypeCheckBox;
    [self.rememberBtn setImage:[UIImage imageNamed:@"checkbox0.png"] forState:UIControlStateNormal];
    [self.rememberBtn setImage:[UIImage imageNamed:@"checkbox1.png"] forState:UIControlStateSelected];
    [self.rememberBtn setTitle:@"记住密码" forState:UIControlStateNormal];
    [self.rememberBtn setTitleColor:RGBTextNormal forState:UIControlStateNormal];
    self.rememberBtn.imageSize = CGSizeMake(20, 20);
    [self.rememberBtn sizeToFit];
    self.rememberBtn.tagString = @"记住密码";
    
    
    self.autologinBtn.buttenType = UIButtenTypeCheckBox;
    [self.autologinBtn setImage:[UIImage imageNamed:@"checkbox0.png"] forState:UIControlStateNormal];
    [self.autologinBtn setImage:[UIImage imageNamed:@"checkbox1.png"] forState:UIControlStateSelected];
    [self.autologinBtn setTitle:@"自动登录" forState:UIControlStateNormal];
    [self.autologinBtn setTitleColor:RGBTextNormal forState:UIControlStateNormal];
    self.autologinBtn.imageSize = CGSizeMake(20, 20);
    [self.autologinBtn sizeToFit];
    self.autologinBtn.tagString = @"自动登录";
    
    
    [self.loginBtn setBackgroundImage:[[UIImage imageNamed:@"btn80.png"] stretched] forState:UIControlStateNormal];
    [self.loginBtn setTitle:@"登  录" forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.loginBtn.tagString = @"登录";
    
    [self.registerBtn setBackgroundImage:[[UIImage imageNamed:@"btn80.png"] stretched] forState:UIControlStateNormal];
    [self.registerBtn setTitle:@"注   册" forState:UIControlStateNormal];
    self.registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.registerBtn.tagString = @"注册";
    
    
    
    NSString *account = [UserCenter sharedInstance].userName;
    if (![account empty]) {
        self.rememberBtn.selected = [UserCenter sharedInstance].ismarkPassWord;
        self.accountTF.text = account;
    }else{
        self.rememberBtn.selected = YES;
    }
    NSString *passwd = [UserCenter sharedInstance].passWord;
    if (self.rememberBtn.selected) {
        self.passwdTF.text = passwd;
    }
    
    self.autologinBtn.selected = [UserCenter sharedInstance].isautoLogin;
    
    if (self.autologinBtn.selected&&![UserCenter sharedInstance].loginOut) {
        [self login];
    }
    [UserCenter sharedInstance].loginOut = NO;
}


- (BOOL)login{

#ifdef PASS
    [self open:@"MainPage" close:@"LoginPage" animate:YES];
    return YES;
#endif
    
    self.accountTF.active = NO;
    
    if (self.accountTF.text==nil || [self.accountTF.text empty]) {
        [self showMessageTip:@"请输入帐号" detail:nil timeOut:1.5f];
        return NO;
    }
    self.passwdTF.active = NO;
    
    if (self.passwdTF.text==nil || [self.passwdTF.text empty]) {
        [self showMessageTip:@"请输入密码" detail:nil timeOut:1.5f];
        return NO;
    }
    
    NSString *command = COMMAND_LOGIN;
    NSString *date = [[NSDate date] stringWithDateFormat:nil];
    NSString *passw=[NSString stringWithFormat:@"%@%@",date,self.passwdTF.text];
    passw = [passw MD5String];
    NSDictionary *dic = @{@"UserName":self.accountTF.text,
                          @"Password":passw,
                          @"LoginTime":date,
                          @"baiduUserID":[UserCenter sharedInstance].userid_token,
                          @"channelID":[UserCenter sharedInstance].channelid_token
                          };
    
    if (![self isSending:[HMWebAPI WebAPI] name:command]) {
        [[[self dealWith:[HMWebAPI WebAPI] timeout:20.f] input:[HMWebAPI params],dic,[HMWebAPI command],command,nil] send];
        return YES;
    }
    return NO;
}


ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {
            [self backWithAnimate:YES];
        }else if ([btn is:@"记住密码"]) {
            if (!btn.selected) {
                self.autologinBtn.selected = NO;
            }
            [UserCenter sharedInstance].markPassWord = btn.selected;
        }else if ([btn is:@"自动登录"]) {
            if (btn.selected) {
                self.rememberBtn.selected = YES;
            }
            [UserCenter sharedInstance].autoLogin = btn.selected;
        }else if ([btn is:@"登录"]) {
            
            [self login];
            
        }
    }
}

ON_TextField(signal){
    UITextField *textfield  = signal.source;
    if ([signal is:[HMUITextField WILL_ACTIVE]]) {
        [HMUIKeyboard sharedInstance].accessor =  self.textFieldView;
        [HMUIKeyboard sharedInstance].accessorVisableRect = textfield.frame;
        
    }else if ([signal is:[HMUITextField RETURN]]) {
        
    }else if ([signal is:[HMUITextField TEXT_CHANGED]]){
        if (textfield==self.accountTF && textfield.text!=nil && textfield.text.length>0) {
            NSString *pw = [[UserCenter sharedInstance].users valueForKey:textfield.text];
            self.passwdTF.text = pw;
        }
        
    }
}

ON_WebAPI(dlg){
    
    if (dlg.sending) {
        
        if([dlg isName:COMMAND_LOGIN]) {
            [self showLoaddingTip:@"登录中..." timeOut:30.f];
        }
        
    }else if (dlg.succeed){
        NSDictionary *dic = [dlg.output objectForKey:[HMWebAPI params]];
        
        WebAPIResult *result = [dic objectForClass:[WebAPIResult class]];
        
        if (result.successI) {
            
            result.resultClass = [CustomerInfo class];
            CustomerInfo *customer = result.resultObject;
            if (customer){

                if([dlg isName:COMMAND_LOGIN]) {
                    [UserCenter sharedInstance].userName = self.accountTF.text;
                    [UserCenter sharedInstance].markPassWord = self.rememberBtn.selected;
                    [UserCenter sharedInstance].passWord = self.passwdTF.text;
                    [Model sharedInstance].customerInfo = customer;
                    
                    [self tipsDismiss];
                    [self open:@"MainPage" close:@"LoginPage" animate:YES];
                    
                }
                return;
            }
        }
        if (result.Message) {
            [self showFailureTip:@"登录失败" detail:result.Message timeOut:3.f];
        }else{
            [self showFailureTip:@"登录失败" detail:nil timeOut:3.f];
        }
    }else if (dlg.failed){
        if (dlg.timeout) {
            [self showFailureTip:@"登录失败" detail:@"链接超时" timeOut:3.f];
            return;
        }
        
        [self showFailureTip:@"网络链接失败" detail:@"数据不存在或网络错误" timeOut:3.f];
    }else if (dlg.cancelled){
        
    }
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],dlg.responseData?dlg.responseData:dlg.errorDesc);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}


@end
