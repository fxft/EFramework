//
//  Sandbox.m
//  EFDemo
//
//  Created by mac on 16/5/10.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "Sandbox.h"


@interface Sandbox ()

@end

@implementation Sandbox

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
    /*
     程序目录，不能存任何东西
     文档目录，需要ITUNES同步备份的数据存这里
     配置目录，配置文件存这里
     缓存目录，系统永远不会删除这里的文件，ITUNES会删除
     临时目录，APP退出后，系统可能会删除这里的内容
     */
    
    INFO(@"程序目录",[HMSandbox appPath]);
    INFO(@"文档目录",[HMSandbox docPath]);
    INFO(@"配置目录",[HMSandbox libPrefPath]);
    INFO(@"缓存目录",[HMSandbox libCachePath]);
    INFO(@"临时目录",[HMSandbox tmpPath]);
    
    
    NSString *path = [[HMSandbox appPath] stringByAppendingPathComponent:@"test/test.txt"];
    if ([HMSandbox touch:path]){
        INFO(@"创建文件夹成功",path);
    }
    path = [[HMSandbox docPath] stringByAppendingPathComponent:@"test/test.txt"];
    if ([HMSandbox touchIgnoreName:path]){
        INFO(@"创建文件夹成功",path);
    }
    path = [[HMSandbox libPrefPath] stringByAppendingPathComponent:@"test/test.txt"];
    if ([HMSandbox touchIgnoreName:path]){
        INFO(@"创建文件夹成功",path);
    }
    path = [[HMSandbox libCachePath] stringByAppendingPathComponent:@"test/test.txt"];
    if ([HMSandbox touchIgnoreName:path]){
        INFO(@"创建文件夹成功",path);
    }
    path = [[HMSandbox tmpPath] stringByAppendingPathComponent:@"test/test.txt"];
    if ([HMSandbox touchIgnoreName:path]){
        INFO(@"创建文件夹成功",path);
    }
    
    
    path = [[HMSandbox appPath] stringByAppendingPathComponent:@"test.txt"];
    if ([HMSandbox touch:path]){
        INFO(@"创建文件成功",path);
    }
    path = [[HMSandbox docPath] stringByAppendingPathComponent:@"test.txt"];
    if ([HMSandbox touch:path]){
        INFO(@"创建文件成功",path);
    }
    path = [[HMSandbox libPrefPath] stringByAppendingPathComponent:@"test.txt"];
    if ([HMSandbox touch:path]){
        INFO(@"创建文件成功",path);
    }
    path = [[HMSandbox libCachePath] stringByAppendingPathComponent:@"test.txt"];
    if ([HMSandbox touch:path]){
        INFO(@"创建文件成功",path);
    }
    path = [[HMSandbox tmpPath] stringByAppendingPathComponent:@"test.txt"];
    if ([HMSandbox touch:path]){
        INFO(@"创建文件成功",path);
    }
    
    /**
     1、在模拟器下运行，
     2、复制一个文件夹路径，
     3、打开finder 快捷键：command+G
     4、黏贴后 回车
     5、可以查看到对应的目录和文件
     */
    
}

- (void)initSubviews{
    
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
