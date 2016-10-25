//
//  ApiTest.m
//  EFDemo
//
//  Created by mac on 16/9/2.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ApiTest.h"


@interface ApiTest ()

@end

@implementation ApiTest

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
    
    [self.customNavRightBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [self.customNavRightBtn setFrame:CGRectMakeBound(32, 32)];
    
    [self initDatas];
    
    [self initSubviews];
}

- (void)initDatas{
    
}

- (void)testCount:(NSInteger)cout{
    for (int i=0; i<cout; i++) {
        [self testApi:@"http://121.43.99.119/taskclient.php"];
    }
}

- (void)testApi:(NSString*)url{
    [[self webApiWithCommand:url timeout:20.f] send];
}

- (void)initSubviews{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

ON_WebAPI(dlg){
    if (dlg.sending) {
        
        
    }else if (dlg.progressed){
        // 必须在发送web Api 时指定 setWebProcess:YES
        //          dlg.ownRequest.downloadPercent;
        //          dlg.ownRequest.uploadPercent;
        
    }else if (dlg.succeed){
        NSDictionary *dic = [dlg.output objectForKey:[HMWebAPI params]];
        
        
    }else if (dlg.failed){
        if (dlg.timeout) {
            [self showFailureTip:@"操作失败" detail:@"链接超时" timeOut:2.f];
            return;
        }
        
        [self showFailureTip:@"网络链接失败" detail:@"数据不存在或网络错误" timeOut:3.f];
    }else if (dlg.cancelled){
        [self showFailureTip:@"操作失败" detail:@"链接已取消" timeOut:2.f];
    }
}

ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {//customNavLeftBtn
            [self backAndRemoveWithAnimate:YES];
        }else if ([btn is:@"rightBtn"]){//customNavRightBtn
            [self testCount:32];
        }
    }
}

@end
