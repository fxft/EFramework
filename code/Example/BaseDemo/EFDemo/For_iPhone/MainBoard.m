//
//  MainBoard.m
//  EFDemo
//
//  Created by mac on 15/3/17.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "MainBoard.h"


@interface MainBoard ()

@end

@implementation MainBoard{
    
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
    
    self.title = @"EFramework";
    
    self.boards = [[NSMutableArray alloc]init];
    
    
    /**
     *  基础
     */
    NSMutableArray *subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"系统信息",@"subtitle":@"系统版本、手机型号、网络状态、内存状态、cpu状态、UUID",@"map":@"SystemInfo",@"open":@"push",@"url":URLFOR_controller(@"SystemInfo")}];
    [subBoards addObject:@{@"title":@"黑盒信息",@"subtitle":@"App路径",@"map":@"Sandbox",@"open":@"push",@"url":URLFOR_controller(@"Sandbox")}];
    [subBoards addObject:@{@"title":@"定时器",@"subtitle":@"HMTicker、NSTimer",@"map":@"Timer",@"open":@"push",@"url":URLFOR_controller(@"Timer")}];
    [subBoards addObject:@{@"title":@"Log打印",@"subtitle":@"HMLog:INFO、CC、WARN、ERROR",@"map":@"Timer",@"open":@"push",@"url":URLFOR_controller(@"Timer")}];
    
    [self.boards addObject:@{@"title":@"Foundation",@"subtitle":@"基础常用工具",@"map":@"Foundation",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    

    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"数据转换工具",@"subtitle":@"Json、xml、Obect",@"map":@"DataAction",@"open":@"push",@"url":URLFOR_controller(@"DataAction")}];
    [subBoards addObject:@{@"title":@"常规轻量存储",@"subtitle":@"文件缓存、Keychain密钥、内存缓存、归档缓存、UserDefaults、plist文件存储",@"map":@"NormalStore",@"open":@"push",@"url":URLFOR_controller(@"NormalStore")}];
    [subBoards addObject:@{@"title":@"Sql数据库存储",@"subtitle":@"sqlite存储（FMDataBase）",@"map":@"SqliteStore",@"open":@"push",@"url":URLFOR_controller(@"SqliteStore")}];
    [subBoards addObject:@{@"title":@"Realm数据库存储",@"subtitle":@"Realm对象存储",@"map":@"RealmStore",@"open":@"push",@"url":URLFOR_controller(@"RealmStore")}];
    
    [self.boards addObject:@{@"title":@"Data stroe",@"subtitle":@"数据存储",@"map":@"DataStroe",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"定位、加速器",@"subtitle":@"location",@"map":@"Location",@"open":@"push",@"url":URLFOR_controller(@"Location")}];
    [subBoards addObject:@{@"title":@"蓝牙连接",@"subtitle":@"bluetooth",@"map":@"bluetooth",@"open":@"push",@"url":URLFOR_controller(@"Bluetooth")}];
    
    
    [self.boards addObject:@{@"title":@"Devices",@"subtitle":@"设备能力",@"map":@"Devices",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"音频",@"subtitle":@"audio",@"map":@"audio",@"open":@"push",@"url":URLFOR_controller(@"Audio")}];
    [subBoards addObject:@{@"title":@"视频",@"subtitle":@"video",@"map":@"video",@"open":@"push",@"url":URLFOR_controller(@"Video")}];
    [subBoards addObject:@{@"title":@"录音、录像",@"subtitle":@"Record",@"map":@"Record",@"open":@"push",@"url":URLFOR_controller(@"Record")}];
    
    
    [self.boards addObject:@{@"title":@"Medias",@"subtitle":@"多媒体能力",@"map":@"Medias",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"POI搜索",@"subtitle":@"SearchPOI",@"map":@"SearchPOI",@"open":@"push",@"url":URLFOR_controller(@"SearchPOI")}];
    [subBoards addObject:@{@"title":@"地图操作",@"subtitle":@"A Map",@"map":@"AMap",@"open":@"push",@"url":URLFOR_controller(@"AMap")}];
    
    [self.boards addObject:@{@"title":@"Map",@"subtitle":@"地图",@"map":@"Map",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"常规操作",@"subtitle":@"net work",@"map":@"NetWorkNormal",@"open":@"push",@"url":URLFOR_controller(@"NetWorkNormal")}];
    [subBoards addObject:@{@"title":@"图片下载",@"subtitle":@"image loader",@"map":@"ImageLoader",@"open":@"push",@"url":URLFOR_controller(@"ImageLoader")}];
    [subBoards addObject:@{@"title":@"文件下载",@"subtitle":@"file loader",@"map":@"FileLoader",@"open":@"push",@"url":URLFOR_controller(@"FileLoader")}];
    
    [self.boards addObject:@{@"title":@"NetWork",@"subtitle":@"网络数据、异步、多线程",@"map":@"NetWork",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"MVC",@"subtitle":@"MVC开发模式",@"map":@"MVC",@"open":@"push",@"url":URLFOR_controller(@"MVC")}];
    [subBoards addObject:@{@"title":@"MVP",@"subtitle":@"MVP开发模式",@"map":@"MVP",@"open":@"push",@"url":URLFOR_controller(@"MVP")}];
    [subBoards addObject:@{@"title":@"MVVM",@"subtitle":@"MVVM开发模式",@"map":@"MVVM",@"open":@"push",@"url":URLFOR_controller(@"MVVM")}];
    
    [self.boards addObject:@{@"title":@"DevelopmentMode",@"subtitle":@"开发模式",@"map":@"DevelopmentMode",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"转场",@"subtitle":@"转场方式",@"map":@"transitions",@"open":@"push",@"url":URLFOR_controller(@"Transitions")}];
    
    [self.boards addObject:@{@"title":@"Router",@"subtitle":@"路由规则",@"map":@"Router",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"按钮",@"subtitle":@"按钮控件",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"Button")}];
    
    [self.boards addObject:@{@"title":@"Elements",@"subtitle":@"常规控件介绍",@"map":@"Elements",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"tabbar controller",@"subtitle":@"标签栏控件",@"map":@"Button",@"open":@"present",@"url":URLFOR_controller(@"TabbarBoard")}];
    
    [self.boards addObject:@{@"title":@"Controllers",@"subtitle":@"常规控制器介绍",@"map":@"Controllers",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    
    
    [self.boards addObject:@{@"title":@"ThirdPart",@"subtitle":@"第三方框架介绍",@"map":@"ThirdPart",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    
    
    [self.boards addObject:@{@"title":@"ThirdComponent",@"subtitle":@"第三方控件介绍",@"map":@"ThirdComponent",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    
    
    [self.boards addObject:@{@"title":@"Others",@"subtitle":@"其他",@"map":@"Others",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
   [self.tableView reloadData];
    
}
- (void)dealloc
{
   
    HM_SUPER_DEALLOC();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {
            [self backWithAnimate:YES];
        }
    }
}

@end
