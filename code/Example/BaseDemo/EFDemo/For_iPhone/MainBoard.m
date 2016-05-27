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
    [subBoards addObject:@{@"title":@"Api网关",@"subtitle":@"阿里云api网关调用",@"map":@"FileLoader",@"open":@"push",@"url":URLFOR_controller(@"APIGateway")}];
    
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
    [subBoards addObject:@{@"title":@"按钮",@"subtitle":@"按钮控件",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ButtonBoard")}];
    
    [self.boards addObject:@{@"title":@"Elements",@"subtitle":@"常规控件介绍",@"map":@"Elements",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"tabbar controller",@"subtitle":@"标签栏控件",@"map":@"Button",@"open":@"present",@"url":URLFOR_controller(@"TabbarBoard")}];
    
    [self.boards addObject:@{@"title":@"Controllers",@"subtitle":@"常规控制器介绍",@"map":@"Controllers",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"AFNetworking",@"subtitle":@"网络加载库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/AFNetworking/AFNetworking",@"source":@"AFNetworking"}}];
    
    [subBoards addObject:@{@"title":@"JHChainableAnimations",@"subtitle":@"动画库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/jhurray/JHChainableAnimations",@"source":@"JHChainableAnimations"}}];
    
    [subBoards addObject:@{@"title":@"SDWebImage",@"subtitle":@"图片加载库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/rs/SDWebImage",@"source":@"SDWebImage"}}];
    
    [subBoards addObject:@{@"title":@"ZipArchive",@"subtitle":@"压缩库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/mattconnolly/ZipArchive",@"source":@"ZipArchive"}}];
    
    [subBoards addObject:@{@"title":@"Realm",@"subtitle":@"Realm数据库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/realm/realm-cocoa",@"source":@"Realm"}}];
    
    [subBoards addObject:@{@"title":@"FMDB",@"subtitle":@"sqlite数据库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/ccgus/fmdb",@"source":@"FMDB"}}];
    
    [subBoards addObject:@{@"title":@"Ono",@"subtitle":@"html、xml解析库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/mattt/Ono",@"source":@"Ono"}}];
    
    [subBoards addObject:@{@"title":@"Masonry",@"subtitle":@"autolayout库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/cloudkite/Masonry",@"source":@"Masonry"}}];
    
    [subBoards addObject:@{@"title":@"SDAutoLayout",@"subtitle":@"autolayout效率库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gsdios/SDAutoLayout",@"source":@"SDAutoLayout"}}];
    
    
    [subBoards addObject:@{@"title":@"CocoaAsyncSocket",@"subtitle":@"TCP、UDP库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/robbiehanson/CocoaAsyncSocket",@"source":@"CocoaAsyncSocket"}}];
    
    [subBoards addObject:@{@"title":@"GPUImage",@"subtitle":@"图像处理库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/BradLarson/GPUImage",@"source":@"GPUImage"}}];
    
    [subBoards addObject:@{@"title":@"GPUImageFilter",@"subtitle":@"GPUImage图像滤镜处理样例",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/sealband/GPUImageFilter",@"source":@"GPUImageFilter"}}];
    
    
    [self.boards addObject:@{@"title":@"ThirdPart",@"subtitle":@"第三方框架介绍",@"map":@"ThirdPart",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"MBProgressHUD",@"subtitle":@"提示框",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/matej/MBProgressHUD",@"source":@"MBProgressHUD"}}];
    
    [subBoards addObject:@{@"title":@"SDLoopProgressView",@"subtitle":@"进度指示器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gsdios/SDProgressView",@"source":@"SDLoopProgressView"}}];
    
    [subBoards addObject:@{@"title":@"NVActivityIndicatorView",@"subtitle":@"加载指示器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/ninjaprox/NVActivityIndicatorView",@"source":@"NVActivityIndicatorView"}}];
    
    [subBoards addObject:@{@"title":@"MJRefresh",@"subtitle":@"下拉刷新",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/CoderMJLee/MJRefresh",@"source":@"MJRefresh"}}];
    
    [subBoards addObject:@{@"title":@"SDCycleScrollView",@"subtitle":@"图片轮播器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gsdios/SDCycleScrollView",@"source":@"SDCycleScrollView"}}];
    
    [subBoards addObject:@{@"title":@"SDPhotoBrowser",@"subtitle":@"图片浏览器，模仿微博图片浏览器动感效果，综合了图片展示和存储等多项能",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gsdios/SDPhotoBrowser",@"source":@"SDPhotoBrowser"}}];
    
    [subBoards addObject:@{@"title":@"ZLPhotoBrowser",@"subtitle":@"方便易用的相册照片多选框架，支持拍照、预览快速多选；相册混合选择；在线下载iCloud端图片，且针对iCloud端图片的选择做了细节处理；自定义最大选择量及最大预览量",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/longitachi/ZLPhotoBrowser",@"source":@"ZLPhotoBrowser"}}];
    
    [subBoards addObject:@{@"title":@"TZImagePickerController",@"subtitle":@"一个支持多选、选原图和视频的图片选择器，同时有预览功能，适配了iOS6789系统",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/banchichen/TZImagePickerController",@"source":@"TZImagePickerController"}}];
    
    
    
    
    [subBoards addObject:@{@"title":@"SYStarRatingView",@"subtitle":@"评分指示器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/zhangsuya/SYStarRatingView",@"source":@"SYStarRatingView"}}];
    
    [subBoards addObject:@{@"title":@"Permission",@"subtitle":@"用户权限控制器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/delba/Permission",@"source":@"Permission"}}];
    
     [subBoards addObject:@{@"title":@"SYStickHeaderWaterFall",@"subtitle":@"支持各种类型的瀑布流结构",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/zhangsuya/SYStickHeaderWaterFall",@"source":@"SYStickHeaderWaterFall"}}];
    
    
    [subBoards addObject:@{@"title":@"YSLDraggableCardContainer",@"subtitle":@"卡片拖动切换",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/y-hryk/YSLDraggableCardContainer",@"source":@"YSLDraggableCardContainer"}}];
    
    [subBoards addObject:@{@"title":@"ZFPlayer",@"subtitle":@"视频播放器，横竖全屏",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/renzifeng/ZFPlayer",@"source":@"ZFPlayer"}}];
    
    [subBoards addObject:@{@"title":@"WMPlayer",@"subtitle":@"继承UIView，支持播放mp4、m3u8、3gp、mov，全屏和小屏播放同时支持",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/zhengwenming/WMPlayer",@"source":@"WMPlayer"}}];
    
    [subBoards addObject:@{@"title":@"LiveVideoCoreSDK",@"subtitle":@"手机美颜视频直播",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/runner365/LiveVideoCoreSDK",@"source":@"LiveVideoCoreSDK"}}];
    
    [subBoards addObject:@{@"title":@"ijkplayer",@"subtitle":@"视频播放器，Bilibili支持RTSP，支持ios/android",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/Bilibili/ijkplayer",@"source":@"ijkplayer"}}];
    
    [subBoards addObject:@{@"title":@"TBPlayer",@"subtitle":@"视频边下边播播，把播放器播放过的数据流缓存到本地",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/suifengqjn/TBPlayer",@"source":@"TBPlayer"}}];
    
    
    [subBoards addObject:@{@"title":@"SSVideoPlayer",@"subtitle":@"视频播放器，支持拉动，播放列表，全屏",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/immrss/SSVideoPlayer",@"source":@"SSVideoPlayer"}}];
    
    
    
    [subBoards addObject:@{@"title":@"emitterLoop",@"subtitle":@"粒子特效动画",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/zhangsuya/emitterLoop",@"source":@"emitterLoop"}}];
    
    [subBoards addObject:@{@"title":@"HyPopMenuView",@"subtitle":@"菜单弹出框，毛玻璃效果，仿新浪",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/wwdc14/HyPopMenuView",@"source":@"HyPopMenuView"}}];
    
    [subBoards addObject:@{@"title":@"FORScrollViewEmptyAssistant",@"subtitle":@"空数据提示图",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/ZhipingYang/FORScrollViewEmptyAssistant",@"source":@"FORScrollViewEmptyAssistant"}}];
    
    
    [subBoards addObject:@{@"title":@"Wonderful",@"subtitle":@"高亮文本、颜色扩展、跑马灯、颜色渐变、颜色提取",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/dsxNiubility/Wonderful",@"source":@"Wonderful"}}];
    
    
    [subBoards addObject:@{@"title":@"JMHoledView",@"subtitle":@"高亮帮助页提示",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/leverdeterre/JMHoledView",@"source":@"JMHoledView"}}];
    
    [subBoards addObject:@{@"title":@"TextFieldEffects",@"subtitle":@"多种带动画的输入框样式",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/raulriera/TextFieldEffects",@"source":@"TextFieldEffects"}}];
    
    [subBoards addObject:@{@"title":@"FSInteractiveMap",@"subtitle":@"显示svg图片，应用:地图块选择",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/ArthurGuibert/FSInteractiveMap",@"source":@"FSInteractiveMap"}}];
    
    
    [subBoards addObject:@{@"title":@"MZTimerLabel",@"subtitle":@"倒计时Label",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/mineschan/MZTimerLabel",@"source":@"MZTimerLabel"}}];
    
    [subBoards addObject:@{@"title":@"AnimatedTransitionGallery",@"subtitle":@"各种转场动画",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/shu223/AnimatedTransitionGallery",@"source":@"AnimatedTransitionGallery"}}];
    
    
    
    
    
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
