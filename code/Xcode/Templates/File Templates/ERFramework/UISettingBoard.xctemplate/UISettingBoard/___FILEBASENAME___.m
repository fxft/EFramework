//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"
#import "CAShareViewWQW.h"

@interface ___FILEBASENAMEASIDENTIFIER___ ()<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, retain) NSArray * settingData;
@property (retain, nonatomic) HMUIPopoverView *popover;
@end

@implementation ___FILEBASENAMEASIDENTIFIER___

@synthesize settingData,table,popover; //设置页面 tableview 显示内容

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
    //设置页面 tableview 显示内容
    
    self.settingData = [NSArray arrayWithObjects:@"切换用户",@"修改密码",@"关于",@"软件分享",@"清除缓存",nil] ;
    
    self.navigationItem.title = @"设置";
    self.view.backgroundColor = RGBViewBack;
    
    //设置tableview圆角
    self.table.layer.cornerRadius = 5;
    self.table.layer.borderColor = RGBBodorGrayLight.CGColor;
    self.table.layer.borderWidth = 1;
    UIButten *leftBtn = [[UIButten alloc]init];
    leftBtn.tagString = @"leftBtn";
    [leftBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMakeBound(32, 32)];
    leftBtn.eventReceiver = self;
    [self showBarButton:HMUINavigationBar.LEFT custom:leftBtn];
    [leftBtn releaseARC];
    
    UIButten *btn =  (id)[self.view viewWithTag:2];
    
    [btn setBackgroundImage:[[UIImage imageNamed:@"btn80.png"] stretched] forState:UIControlStateNormal];

}

- (void)dealloc
{
    [table release];
    [settingData release];
    
    HM_SUPER_DEALLOC();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.settingData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    //重用UITableViewCell对象
    if (!cell) {
        
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"]autorelease];
        
        //cell右边小箭头
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    //cell文字及颜色
    cell.textLabel.text = [settingData objectAtIndex:[indexPath row]];
    cell.textLabel.textColor = RGBTextNormal;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.autoresizesSubviews = YES;
    if (indexPath.row==2&&[self userDefaultsRead:trackVersionKEY_Update]) {
        
//        HMBadgeLabel *badge = [HMBadgeLabel spawn];
//        badge.type = 0;
//        badge.color = [UIColor redColor];
//        badge.maxSize = CGSizeMake(40, 25);
//        badge.autoPosition = badgeAutoPosition_Center;
//        badge.textLabel.text = @"new";
//        [cell.contentView addSubview:badge];
        [cell.contentView setBadgeType:0 color:[UIColor redColor] maxSize:CGSizeMake(40, 25)].autoPosition = badgeAutoPosition_Center;
        cell.contentView.badgeText = @"new";
    }
    //设置选中点击颜色为灰色
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    return cell;
}

//选中cell行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([indexPath row]) {
        case 0:     //切换用户
        {
            [CDUserCenter sharedInstance].loginOut = YES;
            [self open:@"LoginPage" close:@"MainPage" animate:YES];
        }
            break;
        case 1:     //修改密码
        {
            UIViewController * PasswordBoard = [UIStoryboard boardWithName:@"CAPasswordBoard" inStory:@"Main"];
            [self.stack pushViewController:PasswordBoard animated:YES];
        }
            break;
        case 2:     //关于
        {
            UIViewController * messageBoard = [UIStoryboard boardWithName:@"CDAboutBoard" inStory:@"Main"];
            [self.stack pushViewController:messageBoard animated:YES];
        }
            break;
        
        case 4:     //清除缓存
        {
            [self showMessageTip:@"正在清除" detail:@"请稍等" timeOut:10.f];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[HMFileCache sharedInstance] removeObjectForKey:nil];
                [self tipsDismiss];
            });
        }
            break;
        
        case 3:     //软件分享
        {
            if (_popover==nil || ![_popover.contentView isKindOfClass:[UIView class]]) {
                [_popover releaseARC];
                _popover = (id)[[HMUIPopoverView spawnWithReferView:nil inView:self.view]retainARC];
            }
            
            CAShareViewWQW * shareview = nil;
            _popover.containerMode = UIPopoverContainerModeLight;
            if (shareview==nil) {
                shareview = (id)_popover.contentView;
                if (![shareview isKindOfClass:[CAShareViewWQW class]]) {
                    shareview = [[[NSBundle mainBundle]loadNibNamed:@"CAShareViewWQW" owner:self options:nil] objectAtIndex:0];
                    
                    shareview.smsBtn.tagString = @"sms";
                    shareview.wxBtn.tagString = @"wxlt";
                    shareview.pyBtn.tagString = @"wxpy";
                    shareview.sinaBtn.tagString = @"sina";
                    shareview.txBtn.tagString = @"tx";
                    shareview.exitBtn.tagString = @"exit";
                    [shareview.exitBtn setBackgroundImage:[[UIImage imageNamed:@"btn80.png"] stretched] forState:UIControlStateNormal];
                    shareview.layer.cornerRadius = 8;
                    shareview.backgroundColor = [UIColor whiteColor];
                    _popover.contentCustom = YES;
                    _popover.contentView = shareview;
                    _popover.popoverArrowDirection  = UIPopoverArrowDirectionUnknown;
                }
            }
            _popover.contentRect = CGRectMakeBound(280, 270);
            
            [_popover showWithAnimated:YES];
            
          
            break;
        }
            

        default:
            break;
    }
    
    
}


ON_Button(signal){
    UIButten *btn = signal.source;
    
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {
            [self backWithAnimate:YES];
        }else if (btn.tag == 2){
            [CDUserCenter sharedInstance].loginOut = YES;
            [self open:@"LoginPage" close:@"MainPage" animate:YES];
            
        }else if ([btn is:@"exit"])
        {
            [_popover dissmissAnimated:YES];
        }else{
            UIImage * image = [UIImage imageNamed:@"Icon@120.png"];
            NSString *shareUrl = @"http://CarAssistant.on4s.net/appShare";
            HMShareItemObject *item = [HMShareItemObject spawn];
            item.title = @"云狗管家";
            item.description = @"云狗管家，提供专业的云狗设置服务";
            item.thumb = image;
            item.media = shareUrl;
            [_popover dissmissAnimated:YES];
            if ([btn is:@"sina"])
            {
                item.mediaType = HMShareMediaType_SLWebpage;
                
                [HMShareService share:HMShareTypeSinaWeibo shareBody:item];
                
            }else if ([btn is:@"wxpy"])
            {
                
                item.mediaType = HMShareMediaType_WXWebpage;
                item.subType = HMShareSubType_WXTimeline;
                
                [HMShareService share:HMShareTypeWeChat shareBody:item];
                
            }else if ([btn is:@"wxlt"])
            {
                
                item.mediaType = HMShareMediaType_WXWebpage;
                item.subType = HMShareSubType_WXSession;
                
                [HMShareService share:HMShareTypeWeChat shareBody:item];
                
            }else if ([btn is:@"tx"])
            {
                
                item.mediaType = HMShareMediaType_TCWebpage;
                item.rootController = self;
                [HMShareService share:HMShareTypeTencentWeibo shareBody:item];
            }else if ([btn is:@"sms"])
            {
                item.description = [NSString stringWithFormat:@"我分享了云狗管家给您，地址是%@",shareUrl];
                item.mediaType = HMShareMediaType_TCWebpage;
                item.rootController = self;
                [HMShareService share:HMShareTypeSMS shareBody:item];
            }
        }
    }
}


@end
