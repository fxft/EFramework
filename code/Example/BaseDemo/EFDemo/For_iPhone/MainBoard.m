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
    
    [self.boards addObject:@{@"title":@"Foundation",@"subtitle":@"基础常用工具",@"map":@"Foundation",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    

    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"数据转换工具",@"subtitle":@"Json、xml、Obect",@"map":@"DataAction",@"open":@"push",@"url":URLFOR_controller(@"DataAction")}];
    [subBoards addObject:@{@"title":@"常规轻量存储",@"subtitle":@"文件缓存、Keychain密钥、内存缓存、归档缓存、UserDefaults、plist文件存储",@"map":@"NormalStore",@"open":@"push",@"url":URLFOR_controller(@"NormalStore")}];
    [subBoards addObject:@{@"title":@"Sql数据库存储",@"subtitle":@"sqlite存储（FMDataBase）",@"map":@"SqliteStore",@"open":@"push",@"url":URLFOR_controller(@"SqliteStore")}];
    [subBoards addObject:@{@"title":@"Realm数据库存储",@"subtitle":@"Realm对象存储",@"map":@"RealmStore",@"open":@"push",@"url":URLFOR_controller(@"RealmStore")}];
    
    [self.boards addObject:@{@"title":@"Data stroe",@"subtitle":@"数据存储",@"map":@"DataStroe",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"定位、加速器",@"subtitle":@"location",@"map":@"Location",@"open":@"push",@"url":URLFOR_controller(@"Location")}];
    [subBoards addObject:@{@"title":@"蓝牙连接",@"subtitle":@"bluetooth",@"map":@"bluetooth",@"open":@"push",@"url":URLFOR_controller(@"Bluetooth")}];
    
    
    [self.boards addObject:@{@"title":@"Devices",@"subtitle":@"设备能力",@"map":@"Devices",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"音频",@"subtitle":@"audio",@"map":@"audio",@"open":@"push",@"url":URLFOR_controller(@"Audio")}];
    [subBoards addObject:@{@"title":@"视频",@"subtitle":@"video",@"map":@"video",@"open":@"push",@"url":URLFOR_controller(@"Video")}];
    [subBoards addObject:@{@"title":@"录音、录像",@"subtitle":@"Record",@"map":@"Record",@"open":@"push",@"url":URLFOR_controller(@"Record")}];
    
    
    [self.boards addObject:@{@"title":@"Medias",@"subtitle":@"多媒体能力",@"map":@"Medias",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"POI搜索",@"subtitle":@"SearchPOI",@"map":@"SearchPOI",@"open":@"push",@"url":URLFOR_controller(@"SearchPOI")}];
    [subBoards addObject:@{@"title":@"地图操作",@"subtitle":@"A Map",@"map":@"AMap",@"open":@"push",@"url":URLFOR_controller(@"AMap")}];
    
    [self.boards addObject:@{@"title":@"Map",@"subtitle":@"地图",@"map":@"Map",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"常规操作",@"subtitle":@"net work",@"map":@"NetWorkNormal",@"open":@"push",@"url":URLFOR_controller(@"NetWorkNormal")}];
    [subBoards addObject:@{@"title":@"图片下载",@"subtitle":@"image loader",@"map":@"ImageLoader",@"open":@"push",@"url":URLFOR_controller(@"ImageLoader")}];
    [subBoards addObject:@{@"title":@"文件下载",@"subtitle":@"file loader",@"map":@"FileLoader",@"open":@"push",@"url":URLFOR_controller(@"FileLoader")}];
    [subBoards addObject:@{@"title":@"Api网关",@"subtitle":@"阿里云api网关调用",@"map":@"FileLoader",@"open":@"push",@"url":URLFOR_controller(@"APIGateway")}];
    
    [self.boards addObject:@{@"title":@"NetWork",@"subtitle":@"网络数据、异步、多线程",@"map":@"NetWork",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"MVC",@"subtitle":@"MVC开发模式",@"map":@"MVC",@"open":@"push",@"url":URLFOR_controller(@"MVC")}];
    [subBoards addObject:@{@"title":@"MVP",@"subtitle":@"MVP开发模式",@"map":@"MVP",@"open":@"push",@"url":URLFOR_controller(@"MVP")}];
    [subBoards addObject:@{@"title":@"MVVM",@"subtitle":@"MVVM开发模式",@"map":@"MVVM",@"open":@"push",@"url":URLFOR_controller(@"MVVM")}];
    
    [self.boards addObject:@{@"title":@"DevelopmentMode",@"subtitle":@"开发模式",@"map":@"DevelopmentMode",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"转场",@"subtitle":@"转场方式",@"map":@"transitions",@"open":@"push",@"url":URLFOR_controller(@"Transitions")}];
    
    [self.boards addObject:@{@"title":@"Router",@"subtitle":@"路由规则",@"map":@"Router",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"navgabar color",@"subtitle":@"导航条颜色",@"map":@"color",@"open":@"push",@"url":URLFOR_controller(@"color")}];
    
    [self.boards addObject:@{@"title":@"UIEffect",@"subtitle":@"UI效果介绍",@"map":@"Controllers",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"按钮",@"subtitle":@"按钮控件",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ButtonBoard")}];
    
    [self.boards addObject:@{@"title":@"Elements",@"subtitle":@"常规控件介绍",@"map":@"Elements",@"open":@"open",@"url":URLFOR_controllerWithNavCustom(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"tabbar controller",@"subtitle":@"标签栏控件",@"map":@"Button",@"open":@"present",@"url":URLFOR_controller(@"TabbarBoard")}];
    
    [self.boards addObject:@{@"title":@"Controllers",@"subtitle":@"常规控制器介绍",@"map":@"Controllers",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"AFNetworking",@"subtitle":@"网络加载库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/AFNetworking/AFNetworking",@"source":@"AFNetworking"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"JHChainableAnimations",@"subtitle":@"动画库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/jhurray/JHChainableAnimations",@"source":@"JHChainableAnimations"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"SDWebImage",@"subtitle":@"图片加载库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/rs/SDWebImage",@"source":@"SDWebImage"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"ZipArchive",@"subtitle":@"压缩库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/mattconnolly/ZipArchive",@"source":@"ZipArchive"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"Realm",@"subtitle":@"Realm数据库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/realm/realm-cocoa",@"source":@"Realm"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"FMDB",@"subtitle":@"sqlite数据库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/ccgus/fmdb",@"source":@"FMDB"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"Ono",@"subtitle":@"html、xml解析库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/mattt/Ono",@"source":@"Ono"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"Masonry",@"subtitle":@"autolayout库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/cloudkite/Masonry",@"source":@"Masonry"}}];
    
    [subBoards addObject:@{@"title":@"SDAutoLayout",@"subtitle":@"autolayout效率库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gsdios/SDAutoLayout",@"source":@"SDAutoLayout"},@"imgurl":@[]}];
    
    
    [subBoards addObject:@{@"title":@"CocoaAsyncSocket",@"subtitle":@"TCP、UDP库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/robbiehanson/CocoaAsyncSocket",@"source":@"CocoaAsyncSocket"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"GPUImage",@"subtitle":@"图像处理库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/BradLarson/GPUImage",@"source":@"GPUImage"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"GPUImageFilter",@"subtitle":@"GPUImage图像滤镜处理样例",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/sealband/GPUImageFilter",@"source":@"GPUImageFilter"},@"imgurl":@[]}];
    
    
    [self.boards addObject:@{@"title":@"ThirdPart",@"subtitle":@"第三方框架介绍",@"map":@"ThirdPart",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    [subBoards addObject:@{@"title":@"MBProgressHUD",@"subtitle":@"提示框",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/matej/MBProgressHUD",@"source":@"MBProgressHUD"},@"imgurl":@[@"https://camo.githubusercontent.com/f0501c946d277d84a2f3ba9eefb1988fd13e5f75/687474703a2f2f646c2e64726f70626f782e636f6d2f752f3337383732392f4d4250726f67726573734855442f76312f362d7468756d622e706e67"]}];
    
    [subBoards addObject:@{@"title":@"SDLoopProgressView",@"subtitle":@"进度指示器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gsdios/SDProgressView",@"source":@"SDLoopProgressView"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"PageControls",@"subtitle":@"分页指示器,带切换动画",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/popwarsweet/PageControls",@"source":@"PageControls"},@"imgurl":@[@"https://github.com/popwarsweet/PageControls/raw/master/demo.gif"]}];
    
    
    [subBoards addObject:@{@"title":@"NVActivityIndicatorView",@"subtitle":@"加载指示器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/ninjaprox/NVActivityIndicatorView",@"source":@"NVActivityIndicatorView"},@"imgurl":@[@"https://raw.githubusercontent.com/ninjaprox/NVActivityIndicatorView/master/Demo.gif"]}];
    
    [subBoards addObject:@{@"title":@"MJRefresh",@"subtitle":@"下拉刷新",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/CoderMJLee/MJRefresh",@"source":@"MJRefresh"},@"imgurl":@[@"https://camo.githubusercontent.com/911191d46157ea3961728b16696aea4440ffeb92/687474703a2f2f696d61676573302e636e626c6f67732e636f6d2f626c6f67323031352f3439373237392f3230313530362f3134313230343430323233383338392e676966",@"https://camo.githubusercontent.com/4772eed28dc18a8e6509ba794253ab1b41a82ebb/687474703a2f2f696d61676573302e636e626c6f67732e636f6d2f626c6f67323031352f3439373237392f3230313530362f3134313230353230303938353737342e676966"]}];
    
    [subBoards addObject:@{@"title":@"SDCycleScrollView",@"subtitle":@"图片轮播器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gsdios/SDCycleScrollView",@"source":@"SDCycleScrollView"},@"imgurl":@[@"https://camo.githubusercontent.com/e5c0f0255483caf06271df08982d078c5e2cc432/687474703a2f2f7777342e73696e61696d672e636e2f626d6964646c652f39623831343665646a7731657376797471376c777267323038703066636538322e676966"]}];
    
    [subBoards addObject:@{@"title":@"SDPhotoBrowser",@"subtitle":@"图片浏览器，模仿微博图片浏览器动感效果，综合了图片展示和存储等多项能",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gsdios/SDPhotoBrowser",@"source":@"SDPhotoBrowser"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"ZLPhotoBrowser",@"subtitle":@"方便易用的相册照片多选框架，支持拍照、预览快速多选；相册混合选择；在线下载iCloud端图片，且针对iCloud端图片的选择做了细节处理；自定义最大选择量及最大预览量",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/longitachi/ZLPhotoBrowser",@"source":@"ZLPhotoBrowser"},@"imgurl":@[@"https://github.com/longitachi/ZLPhotoBrowser/raw/master/%E6%95%88%E6%9E%9C%E5%9B%BE/%E9%A2%84%E8%A7%88%E5%9B%BE%E5%BF%AB%E9%80%9F%E9%80%89%E6%8B%A9.gif",@"https://github.com/longitachi/ZLPhotoBrowser/raw/master/%E6%95%88%E6%9E%9C%E5%9B%BE/%E9%A2%84%E8%A7%88%E5%A4%A7%E5%9B%BE%E5%BF%AB%E9%80%9F%E9%80%89%E6%8B%A9.gif",@"https://github.com/longitachi/ZLPhotoBrowser/raw/master/%E6%95%88%E6%9E%9C%E5%9B%BE/%E6%9F%A5%E7%9C%8B%E5%A4%A7%E5%9B%BE%E6%94%AF%E6%8C%81%E7%BC%A9%E6%94%BE.gif",@"https://github.com/longitachi/ZLPhotoBrowser/raw/master/%E6%95%88%E6%9E%9C%E5%9B%BE/%E7%9B%B8%E5%86%8C%E5%86%85%E6%B7%B7%E5%90%88%E9%80%89%E6%8B%A9.gif",@"https://github.com/longitachi/ZLPhotoBrowser/raw/master/%E6%95%88%E6%9E%9C%E5%9B%BE/%E5%8E%9F%E5%9B%BE%E5%8A%9F%E8%83%BD.gif",@"https://github.com/longitachi/ZLPhotoBrowser/raw/master/%E6%95%88%E6%9E%9C%E5%9B%BE/%E5%AE%9E%E6%97%B6%E7%9B%91%E6%8E%A7%E7%9B%B8%E5%86%8C%E5%8F%98%E5%8C%96.gif",@"https://github.com/longitachi/ZLPhotoBrowser/raw/master/%E6%95%88%E6%9E%9C%E5%9B%BE/%E5%8A%A0%E8%BD%BDiCloud%E7%85%A7%E7%89%87.gif"]}];
    
    [subBoards addObject:@{@"title":@"TZImagePickerController",@"subtitle":@"一个支持多选、选原图和视频的图片选择器，同时有预览功能，适配了iOS6789系统",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/banchichen/TZImagePickerController",@"source":@"TZImagePickerController"},@"imgurl":@[@"https://github.com/banchichen/TZImagePickerController/raw/master/TZImagePickerController/ScreenShots/photoPickerVc.PNG",@"https://github.com/banchichen/TZImagePickerController/raw/master/TZImagePickerController/ScreenShots/photoPreviewVc.PNG"]}];
    
    [subBoards addObject:@{@"title":@"YangMingShan",@"subtitle":@"雅虎开开源的图片选择器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/yahoo/YangMingShan",@"source":@"YangMingShan"},@"imgurl":@[@"https://github.com/yahoo/YangMingShan/raw/master/media/ymsphotopicker-demo.gif",@"https://github.com/yahoo/YangMingShan/raw/master/media/ymsphotopicker-theme.gif"]}];
    
    [subBoards addObject:@{@"title":@"CBImagePicker",@"subtitle":@"iOS 交互效果很不错的一个图片选择器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/cbangchen/CBImagePicker",@"source":@"CBImagePicker"},@"imgurl":@[@"https://camo.githubusercontent.com/dbd319650211d16b578c117c134636473964180d/687474703a2f2f7777342e73696e61696d672e636e2f6c617267652f303036744e633739677731663662316b31627674726a3330377630613461617a2e6a7067"]}];
    
    
    
    [subBoards addObject:@{@"title":@"TOCropViewController",@"subtitle":@"漂亮的 iOS 图片裁切工具库",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/TimOliver/TOCropViewController",@"source":@"TOCropViewController"},@"imgurl":@[@"https://github.com/TimOliver/TOCropViewController/raw/master/screenshot.jpg"]}];
    
    
    
    
    
    [subBoards addObject:@{@"title":@"SYStarRatingView",@"subtitle":@"评分指示器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/zhangsuya/SYStarRatingView",@"source":@"SYStarRatingView"},@"imgurl":@[@"https://github.com/zhangsuya/SYStarRatingView/raw/master/SYStarRatingView/1.gif"]}];
    
    [subBoards addObject:@{@"title":@"Permission",@"subtitle":@"用户权限控制器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/delba/Permission",@"source":@"Permission"},@"imgurl":@[@"https://raw.githubusercontent.com/delba/Permission/assets/permission.gif"]}];
    
     [subBoards addObject:@{@"title":@"SYStickHeaderWaterFall",@"subtitle":@"支持各种类型的瀑布流结构",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/zhangsuya/SYStickHeaderWaterFall",@"source":@"SYStickHeaderWaterFall"},@"imgurl":@[@"https://github.com/zhangsuya/SYStickHeaderWaterFall/raw/master/SYStickHeaderWaterFall/2.gif"]}];
    
    
    [subBoards addObject:@{@"title":@"YSLDraggableCardContainer",@"subtitle":@"卡片拖动切换",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/y-hryk/YSLDraggableCardContainer",@"source":@"YSLDraggableCardContainer"},@"imgurl":@[@"https://raw.githubusercontent.com/y-hryk/YSLDraggingCardContainer/master/sample1.gif",@"https://raw.githubusercontent.com/y-hryk/YSLDraggingCardContainer/master/sample2.gif"]}];
    
    [subBoards addObject:@{@"title":@"expanding-collection",@"subtitle":@"展开和收缩的卡片",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/Ramotion/expanding-collection",@"source":@"expanding-collection"},@"imgurl":@[@"https://raw.githubusercontent.com/Ramotion/expanding-collection/master/preview.gif"]}];
    
    
    
    [subBoards addObject:@{@"title":@"ZFPlayer",@"subtitle":@"视频播放器，横竖全屏",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/renzifeng/ZFPlayer",@"source":@"ZFPlayer"},@"imgurl":@[@"https://github.com/renzifeng/ZFPlayer/raw/master/progress.png"]}];
    
    [subBoards addObject:@{@"title":@"WMPlayer",@"subtitle":@"继承UIView，支持播放mp4、m3u8、3gp、mov，全屏和小屏播放同时支持",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/zhengwenming/WMPlayer",@"source":@"WMPlayer"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"LiveVideoCoreSDK",@"subtitle":@"手机美颜视频直播",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/runner365/LiveVideoCoreSDK",@"source":@"LiveVideoCoreSDK"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"PLStreamingKit",@"subtitle":@"PLStreamingKit 是一个适用于 iOS 的 RTMP 直播推流 SDK",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/runner365/PLStreamingKit",@"source":@"PLStreamingKit"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"ijkplayer",@"subtitle":@"视频播放器，Bilibili支持RTSP，支持ios/android",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/Bilibili/ijkplayer",@"source":@"ijkplayer"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"TBPlayer",@"subtitle":@"视频边下边播播，把播放器播放过的数据流缓存到本地",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/suifengqjn/TBPlayer",@"source":@"TBPlayer"},@"imgurl":@[]}];
    
    
    [subBoards addObject:@{@"title":@"SSVideoPlayer",@"subtitle":@"视频播放器，支持拉动，播放列表，全屏",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/immrss/SSVideoPlayer",@"source":@"SSVideoPlayer"},@"imgurl":@[@"https://raw.githubusercontent.com/immrss/SSVideoPlayer/master/Demo.gif"]}];
    
    [subBoards addObject:@{@"title":@"CTVideoPlayerView",@"subtitle":@"超强的 Video Player 组件，可以同时播放多个视频，提供下载和自定义功能。",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/casatwy/CTVideoPlayerView",@"source":@"CTVideoPlayerView"},@"imgurl":@[]}];
    
    [subBoards addObject:@{@"title":@"VRMediaPlayer",@"subtitle":@"一款基于谷歌的GVR框架封装的简单VR视频播放器",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/KaelYHB/VRMediaPlayer-iOS",@"source":@"VRMediaPlayer"},@"imgurl":@[]}];
    
    
    [subBoards addObject:@{@"title":@"emitterLoop",@"subtitle":@"粒子特效动画",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/zhangsuya/emitterLoop",@"source":@"emitterLoop"},@"imgurl":@[@"https://github.com/zhangsuya/emitterLoop/raw/master/emitterLoop/emitterLoop/3.gif",@"https://github.com/zhangsuya/emitterLoop/raw/master/emitterLoop/emitterLoop/1.gif"]}];
    
    [subBoards addObject:@{@"title":@"HyPopMenuView",@"subtitle":@"菜单弹出框，毛玻璃效果，仿新浪",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/wwdc14/HyPopMenuView",@"source":@"HyPopMenuView"},@"imgurl":@[@"https://github.com/wwdc14/HyPopMenuView/raw/master/HyPopMenuView/Untitled6.gif",@"https://github.com/wwdc14/HyPopMenuView/raw/master/HyPopMenuView/Untitled2.gif"]}];
    
    [subBoards addObject:@{@"title":@"VHBoomMenuButton",@"subtitle":@"浮层菜单按钮，支持比较多的样式和动画，双版支持",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/Nightonke/VHBoomMenuButton",@"source":@"VHBoomMenuButton"},@"imgurl":@[@"https://github.com/Nightonke/VHBoomMenuButton/raw/master/VHBoomMenuButtonPictures/Gif_0.gif?raw=true",@"https://github.com/Nightonke/VHBoomMenuButton/raw/master/VHBoomMenuButtonPictures/Gif_2.gif?raw=true",@"https://github.com/Nightonke/VHBoomMenuButton/raw/master/VHBoomMenuButtonPictures/Gif_3.gif?raw=true"]}];
    
    
    [subBoards addObject:@{@"title":@"FORScrollViewEmptyAssistant",@"subtitle":@"空数据提示图",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/ZhipingYang/FORScrollViewEmptyAssistant",@"source":@"FORScrollViewEmptyAssistant"},@"imgurl":@[@"https://raw.githubusercontent.com/dzenbot/UITableView-DataSet/master/Examples/Applications/Screenshots/Screenshots_row1.png",@"https://raw.githubusercontent.com/dzenbot/UITableView-DataSet/master/Examples/Applications/Screenshots/Screenshots_row2.png"]}];
    
    
    [subBoards addObject:@{@"title":@"Wonderful",@"subtitle":@"高亮文本、颜色扩展、跑马灯、颜色渐变、颜色提取",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/dsxNiubility/Wonderful",@"source":@"Wonderful"},@"imgurl":@[@"https://github.com/dsxNiubility/Wonderful/raw/master/screenshots/1006.png",@"https://github.com/dsxNiubility/Wonderful/raw/master/screenshots/004.gif",@"https://github.com/dsxNiubility/Wonderful/raw/master/screenshots/1002.png"]}];
    
    [subBoards addObject:@{@"title":@"IBAnimatableMaterial",@"subtitle":@"Material Design 水波效果的动画",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/IBAnimatable/IBAnimatableMaterial",@"source":@"IBAnimatableMaterial"},@"imgurl":@[@"https://cloud.githubusercontent.com/assets/573856/16713775/151b34d6-46f5-11e6-9334-875453a01a9a.gif"]}];
    
    
    [subBoards addObject:@{@"title":@"JMHoledView",@"subtitle":@"高亮帮助页提示",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/leverdeterre/JMHoledView",@"source":@"JMHoledView"},@"imgurl":@[@"https://github.com/leverdeterre/JMHoledView/raw/master/screenshots/demo1.png"]}];
    
    [subBoards addObject:@{@"title":@"TextFieldEffects",@"subtitle":@"多种带动画的输入框样式",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/raulriera/TextFieldEffects",@"source":@"TextFieldEffects"},@"imgurl":@[@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Kaede.gif",@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Hoshi.gif",@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Jiro.gif",@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Isao.gif",@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Minoru.gif",@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Yoko.gif",@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Madoka.gif",@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Akira.gif",@"https://github.com/raulriera/TextFieldEffects/raw/master/Screenshots/Yoshiko.gif"]}];
    
    [subBoards addObject:@{@"title":@"FSInteractiveMap",@"subtitle":@"显示svg图片，应用:地图块选择",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/ArthurGuibert/FSInteractiveMap",@"source":@"FSInteractiveMap"},@"imgurl":@[@"https://github.com/ArthurGuibert/FSInteractiveMap/raw/master/Screenshots/screen02.png",@"https://github.com/ArthurGuibert/FSInteractiveMap/raw/master/Screenshots/screen00.png",@"https://github.com/ArthurGuibert/FSInteractiveMap/raw/master/Screenshots/screen01.png"]}];
    
    
    [subBoards addObject:@{@"title":@"MZTimerLabel",@"subtitle":@"倒计时Label",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/mineschan/MZTimerLabel",@"source":@"MZTimerLabel"},@"imgurl":@[@"https://camo.githubusercontent.com/10e65649d00c0cd1e184c69c9b283a911575e777/68747470733a2f2f7261772e6769746875622e636f6d2f6d696e65736368616e2f4d5a54696d65724c6162656c2f6d61737465722f64656d6f2e676966",@"https://camo.githubusercontent.com/fd5cc2c28c0cd6e46cd632021995113bc2cd79ce/68747470733a2f2f7261772e6769746875622e636f6d2f6d696e65736368616e2f4d5a54696d65724c6162656c2f6d61737465722f4d5a54696d65724c6162656c5f44656d6f322e706e67"]}];
    
    [subBoards addObject:@{@"title":@"AnimatedTransitionGallery",@"subtitle":@"各种转场动画",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/shu223/AnimatedTransitionGallery",@"source":@"AnimatedTransitionGallery"},@"imgurl":@[@"https://github.com/shu223/AnimatedTransitionGallery/raw/master/gif/gallery.gif",@"https://github.com/shu223/AnimatedTransitionGallery/raw/master/gif/coreimage.gif",@"https://github.com/shu223/AnimatedTransitionGallery/raw/master/gif/motionblur.gif",@"https://github.com/shu223/AnimatedTransitionGallery/raw/master/gif/boxblur.gif"]}];
    
    [subBoards addObject:@{@"title":@"EvernoteAnimation",@"subtitle":@"仿 Evernote 的列表的下拉弹性效果，之前一直很好奇这个的实现原理，终于有人做出来了",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/imwangxuesen/EvernoteAnimation",@"source":@"EvernoteAnimation"},@"imgurl":@[@"https://camo.githubusercontent.com/caa326ef59ab1ca6f16c639d3639f98e835b6dd9/687474703a2f2f7777312e73696e61696d672e636e2f6d773639302f30303662645137716a773166357876307336736730673330623430697171376d2e676966"]}];
    
    [subBoards addObject:@{@"title":@"GSKStretchyHeaderView",@"subtitle":@"一个通用有弹性的HeaderView",@"map":@"Button",@"open":@"push",@"url":URLFOR_controller(@"ThirdPartBoard"),@"boards":@{@"url":@"https://github.com/gskbyte/GSKStretchyHeaderView",@"source":@"GSKStretchyHeaderView"},@"imgurl":@[@"https://raw.githubusercontent.com/gskbyte/GSKStretchyHeaderView/master/screenshots/airbnb_small.gif",@"https://raw.githubusercontent.com/gskbyte/GSKStretchyHeaderView/master/screenshots/stretchy_blur_small.gif",@"https://raw.githubusercontent.com/gskbyte/GSKStretchyHeaderView/master/screenshots/tabs_small.gif",@"https://raw.githubusercontent.com/gskbyte/GSKStretchyHeaderView/master/screenshots/twitter_small.gif",@"https://raw.githubusercontent.com/gskbyte/GSKStretchyHeaderView/master/screenshots/scalable_text_small.gif"]}];
    
    
    
    
    [self.boards addObject:@{@"title":@"ThirdComponent",@"subtitle":@"第三方控件介绍",@"map":@"ThirdComponent",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
    
    subBoards = [NSMutableArray arrayWithCapacity:0];
    
    
    [self.boards addObject:@{@"title":@"Others",@"subtitle":@"其他",@"map":@"Others",@"open":@"open",@"url":URLFOR_controllerWithNav(@"ListBoard"),@"listheight":@(49),@"boards":subBoards}];
    
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
