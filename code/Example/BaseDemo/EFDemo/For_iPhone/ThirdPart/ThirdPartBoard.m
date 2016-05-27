//
//  ThirdPartBoard.m
//  EFDemo
//
//  Created by mac on 16/5/11.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ThirdPartBoard.h"


@interface ThirdPartBoard ()<HMUIWebViewProgressDelegate,UIWebViewDelegate>
@property (nonatomic,strong) HMUIWebView *web;
@property (nonatomic,strong) HMUITapbarView * tab;
@end

@implementation ThirdPartBoard

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
    self.web = [[HMUIWebView alloc]init];
    [self.view addSubview:self.web];
    
    [self.web mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
    }];
    
    
    self.tab = [[HMUITapbarView alloc]init];
    self.tab.barStyle = UITapbarStyleCanFlexible;
    [self.view addSubview:self.tab];

    self.tab.sd_layout.heightIs(49).leftEqualToView(self.view).bottomEqualToView(self.view).rightEqualToView(self.view);
    
    self.tab.backgroundColor = [UIColor flatGreenSeaColor];
    self.tab.indentation=15;
    self.tab.tail=15;
    
    UIButten *btn = [self.tab addItemWithTitle:@"◀︎" imageName:nil size:CGSizeMake(80, 49)];
    [btn setTitleFont:[UIFont systemFontOfSize:22] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    btn.buttenType = UIButtenTypeNormal;
    
    btn = [self.tab addItemWithTitle:@"▶︎" imageName:nil size:CGSizeMake(80, 49)];
    [btn setTitleFont:[UIFont systemFontOfSize:22] forState:UIControlStateNormal];
    btn.buttenType = UIButtenTypeNormal;
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [self.tab addFlexible];
    
    btn = [self.tab addItemWithTitle:@"刷新" imageName:nil size:CGSizeMake(50, 49)];
    [btn setTitleFont:[UIFont systemFontOfSize:22] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    btn.buttenType = UIButtenTypeNormal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.web.delegate = (id)self.web;
    self.web.url = [self.boards valueForKey:@"url"];
  
}

ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {//customNavLeftBtn
            [self showTitleActivity:NO];
            [self backAndRemoveWithAnimate:YES];
        }else if ([btn is:@"rightBtn"]){//customNavRightBtn
            
        }
    }
}

ON_WebView(signal){
    HMUIWebView *webview = signal.source;
    
    if ([signal is:[HMUIWebView WILL_START]]) {
        
        [self showTitleActivity:YES];
    }else if ([signal is:[HMUIWebView DID_START]]){
        
    }else if ([signal is:[HMUIWebView DID_LOAD_FINISH]]){
//        self.title = [webview stringByEvaluatingJavaScriptFromString:@"document.title"];
        [self showTitleActivity:NO];
        
    }else if ([signal is:[HMUIWebView DID_LOAD_FAILED]]){
        
    }else if ([signal is:[HMUIWebView DID_LOAD_CANCELLED]]){
        
    }else if ([signal is:[HMUIWebView DID_SCROLLDOWN]]){
        self.tab.makeY(self.view.height).animate(.25f);
    }else if ([signal is:[HMUIWebView DID_SCROLLUP]]){
        self.tab.makeY(self.view.height-49).animate(.25f);
    }else if ([signal is:[HMUIWebView DID_SCROLL]]){
        
    }else if ([signal is:[HMUIWebView DID_SCROLLEND]]){
        
    }else if ([signal is:[HMUIWebView DID_LOADING_PERSENT]]){
        
    }
}

ON_TapBar(signal){
    HMUITapbarView *tapview = signal.source;
    
    if ([signal is:[HMUITapbarView TAPNOSELECTED]]) {
        [signal returnYES];
        
    }else if ([signal is:[HMUITapbarView TAPCHANGED]]){
        if (tapview.selectedIndex==0&&self.web.canGoBack) {
            [self.web goBack];
        }else if (tapview.selectedIndex==1&&self.web.canGoForward) {
            [self.web goForward];
        }else if (tapview.selectedIndex==2&&!self.web.isReload) {
            [self.web reload];
        }
    }
}

@end
