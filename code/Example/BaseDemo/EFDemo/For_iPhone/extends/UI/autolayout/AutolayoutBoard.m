//
//  AutolayoutBoard.m
//  EFExtend
//
//  Created by mac on 16/4/8.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "AutolayoutBoard.h"
#import "HMUIShadowStyle.h"

@interface AutolayoutBoard ()

@end

@implementation AutolayoutBoard

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
    
    CGFloat padding = 15;
    
    HMUIStyle *style = nil;
    CGSize size = CGSizeMake(37, 37);
    CGFloat scale = [UIScreen mainScreen].scale;
    
    style = [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithRadius:10] next:[HMUIShadowStyle styleWithColor:RGB(0, 0, 0) blur:4 offset:CGSizeMake(1, 1) next:[HMUIInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 5, 0) next:[HMUISolidBorderStyle styleWithColor:RGB(1.0, 0, 0) width:2 next:nil]]]];
//    HMUIShadowStyle *shadow = [HMUIShadowStyle styleWithColor:RGB(0, 0, 0) blur:3 offset:CGSizeMake(1, 1) next:nil];
    
    
    UIButten *theDayBeforeYesterday = [[UIButten alloc] init];
    [theDayBeforeYesterday setTitle:@"前天" forState:UIControlStateNormal];
    [[[[[theDayBeforeYesterday EFBackgroundColor:[UIColor whiteColor]] EFTextColor:[UIColor whiteColor]] EFTextSelectedColor:HEX_RGB(0xffbfbf)] EFBackgroundImage:[[UIImage imageForStyle:style size:size scale:scale] stretched] forState:UIControlStateNormal] EFBackgroundImage:@"回放_0003_点亮.png" forState:UIControlStateSelected];
    theDayBeforeYesterday.tagString = @"前天";
    [self.view addSubview:theDayBeforeYesterday ];
    
    
    style = [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithTopLeft:-1 topRight:-1 bottomRight:0 bottomLeft:-1] next:[HMUISolidBorderStyle styleWithColor:RGB(1.0, 0, 0) width:2 next:nil]];
    
    UIButten *yesterday = [[UIButten alloc] init];
    [yesterday setTitle:@"昨天" forState:UIControlStateNormal];
    [[[[[yesterday EFBackgroundColor:[UIColor whiteColor]]EFTextColor:[UIColor whiteColor]] EFTextSelectedColor:HEX_RGB(0xffbfbf)] EFBackgroundImage:[[[UIImage imageForStyle:style size:size scale:scale] stretched] stretched] forState:UIControlStateNormal] EFBackgroundImage:@"回放_0003_点亮.png" forState:UIControlStateSelected];
    yesterday.tagString = @"前天";
    [self.view addSubview:yesterday];
    
    style = [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithTopLeft:-1 topRight:-1 bottomRight:0 bottomLeft:-1] next:[HMUISolidFillStyle styleWithColor:RGB(0, 0, 0) next:[HMUISolidBorderStyle styleWithColor:RGB(1.0, 0, 0) width:2 next:nil]]];
    
    UIButten *today = [[UIButten alloc] init];
    [today setTitle:@"今天" forState:UIControlStateNormal];
    [[[[[today EFBackgroundColor:[UIColor whiteColor]]EFTextColor:[UIColor whiteColor]] EFTextSelectedColor:HEX_RGB(0xffbfbf)] EFBackgroundImage:[[[UIImage imageForStyle:style size:size scale:scale] stretched] stretched] forState:UIControlStateNormal] EFBackgroundImage:@"回放_0003_点亮.png" forState:UIControlStateSelected];
    today.tagString = @"今天";
    [self.view addSubview:today];
    
    
    NSArray *arr = @[theDayBeforeYesterday,today,yesterday];
    [arr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:padding leadSpacing:padding tailSpacing:padding];
    [arr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(37);
        make.top.mas_equalTo(padding);
    }];
    
    
    UIButten *theDayBeforeYesterday2 = [[UIButten alloc] init];
    [theDayBeforeYesterday2 setTitle:@"前天" forState:UIControlStateNormal];
    [[[[[theDayBeforeYesterday2 EFBackgroundColor:[UIColor whiteColor]] EFTextColor:[UIColor whiteColor]] EFTextSelectedColor:HEX_RGB(0xffbfbf)] EFBackgroundImage:[[[UIImage imageForStyle:style size:size scale:scale] stretched] stretched] forState:UIControlStateNormal] EFBackgroundImage:@"回放_0003_点亮.png" forState:UIControlStateSelected];
    theDayBeforeYesterday2.tagString = @"前天";
    [self.view addSubview:theDayBeforeYesterday2 ];
    
    
    UIButten *yesterday2 = [[UIButten alloc] init];
    [yesterday2 setTitle:@"昨天" forState:UIControlStateNormal];
    [[[[[yesterday2 EFBackgroundColor:[UIColor blackColor]]EFTextColor:[UIColor whiteColor]] EFTextSelectedColor:HEX_RGB(0xffbfbf)] EFBackgroundImage:@"回放_0002_前天.png" forState:UIControlStateNormal] EFBackgroundImage:@"回放_0003_点亮.png" forState:UIControlStateSelected];
    yesterday2.tagString = @"前天";
    [self.view addSubview:yesterday2];
    
    UIButten *today2 = [[UIButten alloc] init];
    [today2 setTitle:@"今天" forState:UIControlStateNormal];
    [[[[[today2 EFBackgroundColor:[UIColor blackColor]]EFTextColor:[UIColor whiteColor]] EFTextSelectedColor:HEX_RGB(0xffbfbf)] EFBackgroundImage:@"回放_0002_前天.png" forState:UIControlStateNormal] EFBackgroundImage:@"回放_0003_点亮.png" forState:UIControlStateSelected];
    today2.tagString = @"今天";
    [self.view addSubview:today2];
    
    self.view.sd_equalWidthSubviews = @[theDayBeforeYesterday2,yesterday2,today2];
    
    theDayBeforeYesterday2.sd_layout
    .leftSpaceToView(self.view,padding)
    .topSpaceToView(self.view,100)
    .heightIs(37);
    
    yesterday2.sd_layout
    .topEqualToView(theDayBeforeYesterday2)
    .leftSpaceToView(theDayBeforeYesterday2,padding)
    .heightRatioToView(theDayBeforeYesterday2,1);
    
    today2.sd_layout
    .topEqualToView(theDayBeforeYesterday2)
    .leftSpaceToView(yesterday2,padding)
    .heightRatioToView(theDayBeforeYesterday2,1)
    .rightSpaceToView(self.view,padding);

    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(today2.mas_bottom).offset(padding);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
    }];
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


#pragma  mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"listCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
