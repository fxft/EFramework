//
//  SystemInfo.m
//  EFDemo
//
//  Created by mac on 16/5/10.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "SystemInfo.h"


@interface SystemInfo ()

@end

@implementation SystemInfo

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
    self.boards = [NSMutableArray arrayWithCapacity:0];
    
    CGSize screenSize = [UIScreen mainScreen].currentMode.size;
    
    [self.boards addObject:@{@"title":@"系统",
                             @"items":@[@{@"title":@"版本",@"value":[HMSystemInfo OSVersion]},
                                        @{@"title":@"UUID",@"value":[HMSystemInfo deviceUUID]},
                                        @{@"title":@"设备型号",@"value":[HMSystemInfo deviceModel]},
                                        @{@"title":@"屏幕大小",@"value":NSStringFromCGSize(screenSize)},
                                        @{@"title":@"语言",@"value":[HMSystemInfo currentLanguage]}
                                                       ]}];
    

    
    [self.boards addObject:@{@"title":@"app",
                             @"items":@[@{@"title":@"版本",@"value":[HMSystemInfo appVersion]},
                                        @{@"title":@"名称",@"value":[HMSystemInfo appName]},
                                        @{@"title":@"标识符",@"value":[HMSystemInfo appIdentifier]},
                                        @{@"title":@"build版本",@"value":[HMSystemInfo appShortVersion]}
                                        ]}];
    
    HMMemoryInfo *memory = [HMSystemInfo memoryInfo];
    
    [self.boards addObject:@{@"title":@"存储",
                             @"items":@[@{@"title":@"总容量",@"value":[NSString formatVolume:memory.total]},
                                        @{@"title":@"已用容量",@"value":[NSString formatVolume:memory.used]},
                                        @{@"title":@"可用容量",@"value":[NSString formatVolume:memory.free]},
                                        @{@"title":@"active",@"value":[NSString formatVolume:memory.active]},
                                        @{@"title":@"inactive",@"value":[NSString formatVolume:memory.inactive]},
                                        @{@"title":@"wired",@"value":[NSString formatVolume:memory.wired]},
                                        @{@"title":@"purgable",@"value":[NSString formatVolume:memory.purgable]},
                                        ]}];
    
    HMCPUMemoryInfo *cpu = [HMSystemInfo cpuMemoryInfo];
    
    [self.boards addObject:@{@"title":@"内存",
                             @"items":@[@{@"title":@"总容量",@"value":[NSString formatVolume:cpu.total]},
                                        @{@"title":@"已用容量",@"value":[NSString formatVolume:cpu.used]},
                                        @{@"title":@"虚拟容量",@"value":[NSString formatVolume:cpu.virtuals]},
                                        @{@"title":@"使用率",@"value":[NSString stringWithFormat:@"%.2f%%",cpu.usage]},
                                        @{@"title":@"app使用时间",@"value":[[NSDate dateWithTimeIntervalSince1970:cpu.userTime] stringWithDateFormat:@"HH:mm:ss"]},
                                        @{@"title":@"系统使用时间",@"value":[[NSDate dateWithTimeIntervalSince1970:cpu.systemTime] stringWithDateFormat:@"HH:mm:ss"]},
                                        ]}];
    
    HMNetworkInfo *network = [HMSystemInfo networkInfo];
    
    [self.boards addObject:@{@"title":@"网络",
                             @"items":@[@{@"title":@"Wifi发送流量",@"value":[NSString formatVolume:network.wifiSent]},
                                        @{@"title":@"Wifi接收流量",@"value":[NSString formatVolume:network.wiFiReceived]},
                                        @{@"title":@"移动网络发送流量",@"value":[NSString formatVolume:network.wwanSent]},
                                        @{@"title":@"移动网络接收流量",@"value":[NSString formatVolume:network.wwanReceived]}
                                        
                                        ]}];

}

- (void)initSubviews{
    
    [self.tableView reloadData];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.boards.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *city = [self.boards objectAtIndex:section];
    return [[city valueForKey:@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *city = [self.boards objectAtIndex:section];
    return [city valueForKey:@"title"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 22;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"listCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    NSDictionary *city = [self.boards objectAtIndex:indexPath.section];
    city = [[city valueForKey:@"items"] objectAtIndex:indexPath.row];
    cell.textLabel.text = [city valueForKey:@"title"];
    cell.detailTextLabel.text = [city valueForKey:@"value"];
    cell.detailTextLabel.textColor = RGB(.5, .5, .5);
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

@end
