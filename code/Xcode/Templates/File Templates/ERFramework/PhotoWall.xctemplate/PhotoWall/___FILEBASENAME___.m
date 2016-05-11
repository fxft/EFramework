//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"


@interface ___FILEBASENAMEASIDENTIFIER___ ()<HMUIPhotoWallDelegate>
@property (nonatomic,strong)HMUIPhotoWall *wall;
@property (nonatomic,strong)NSMutableArray *imags;
@property (nonatomic,strong)HMUIRefreshControler *controller;
@end

@implementation ___FILEBASENAMEASIDENTIFIER___{
    
    NSInteger pn;
    NSInteger rn;
    int a;
}
@synthesize wall;
@synthesize imags;
@synthesize controller;

- (void)dealloc
{
    self.imags = nil;
    self.wall = nil;
    self.controller = nil;
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
    
    [self initialization];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialization{
    self.wall = [HMUIPhotoWall spawn];
    self.wall.backgroundColor = [UIColor md_grey_200];
    self.wall.frame = self.view.bounds;
    self.wall.space = 10;
    
    self.wall.dataSource = self;
    self.wall.delegate = self;
    
    [self.view addSubview:self.wall];
    [self.wall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
    }];
    //    self.wall.contentInset = UIEdgeInsetsTBAndHor(50, 50, 0);
    
    
    self.controller = [HMUIRefreshControler attachToScrollView:self.wall style:UIRefreshControlStyleAll|UIRefreshControlStyleLoadmoreAuto target:self refreshAction:@selector(refreshing) loadmoreAction:@selector(getwallmore)];
    controller.themeColor = [UIColor flatSilverColor];
    controller.textColor = [UIColor flatSilverColor];
    
    [controller startRefresh];
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

- (void)refreshing{
    pn = 0;
    [self getwallmore];
}

- (void)getwallmore{
    rn = 15;
    NSDictionary *para = @{@"sn":@(pn),
                           @"pn":@(rn),
                           @"ch":@"art",
                           @"cid":@"国画"};
    [[[self webApiUniqueCommand:@"http://m.image.so.com/zj" name:@"getImage" timeout:30.f]
      setWebParams:para]
     send];
}


ON_WebAPI(dlg){
    
    if (dlg.sending) {
        
        
    }else if (dlg.succeed){
        NSDictionary *dic = [dlg.output objectForKey:[HMWebAPI params]];
        if (self.imags==nil) {
            self.imags = [NSMutableArray array];
        }
        if (pn==0) {
            [self.imags removeAllObjects];
        }
        [self.imags addObjectsFromArray:[dic objectForKey:@"list"]];
        
        pn+=rn;
        if (pn==rn) {
            [self.wall reloadData];
        }else{
            [self.wall appendData];
        }
        
        if ([[dic objectForKey:@"end"] boolValue]) {
            controller.noMore = YES;
        }else{
            controller.noMore = NO;
        }
        [controller finishingLoadingWithMsg:@"哎呀妈呀！！" delay:.5f];
        
        
    }else if (dlg.failed){
        [controller finishingLoadingWithMsg:@"哎呀妈呀！！" delay:.5f];
        
        if (dlg.timeout) {
            [self showFailureTip:@"操作失败" detail:@"链接超时" timeOut:3.f];
            return;
        }
        
        [self showFailureTip:@"网络链接失败" detail:@"数据不存在或网络错误" timeOut:3.f];
    }else if (dlg.cancelled){
        
    }
    //#if (__ON__ == __HM_DEVELOPMENT__)
    //    CC( [self.class description],dlg.responseData?dlg.responseData:dlg.errorDesc);
    //#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}

#pragma mark -


- (void)photoWall:(HMUIPhotoWall *)browser touchInCell:(HMPhotoCell *)cell atIndexPath:(NSIndexPath*)indexPath{
    
}

-(NSUInteger)photoWallNumberOfRanks:(HMUIPhotoWall *)browser inSection:(NSInteger)section{
    
    return 2;
    
}

- (NSUInteger)photoWallRowOfCells:(HMUIPhotoWall *)browser inSection:(NSInteger)section{
    return self.imags.count;
}

- (NSUInteger)photoWallNumberOfSections:(HMUIPhotoWall *)browser{
    return 1;//2;
}

- (HMPhotoItem *)photoWall:(HMUIPhotoWall *)browser itemAtIndex:(NSIndexPath *)indexPath{
    HMPhotoItem *item = [[HMPhotoItem alloc]init];
    
    NSDictionary *data = [self.imags objectAtIndex:indexPath.row];
    CGFloat thumbnail_width = [[data objectForKey:@"cover_width"] floatValue];
    CGFloat thumbnail_height = [[data objectForKey:@"cover_height"] floatValue];
    
    //这个是整个HMPhotoCell的大小，由于图片是布满整个边框的，所以名字叫imageSize
    item.imageSize = CGSizeMake(thumbnail_width, thumbnail_height);
    item.indexPath = indexPath;
    if (indexPath.row==4) {
        item.fullScreen = YES;
        item.indent = 0;
        item.space = 0;
    }else{
        item.indent = -1;
        item.space = -1;
        item.fullScreen = NO;
    }
    return item;
}

- (HMPhotoCell *)photoWall:(HMUIPhotoWall *)browser cellForItem:(HMPhotoItem *)item cellReload:(HMPhotoCell *)cell rect:(CGRect)rect{
    if (cell==nil) {
        cell = [browser dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell==nil) {
            cell = [[HMPhotoCell alloc]initWithReuseIdentifier:@"Cell"];
        }
        
    }
    
    cell.photo = item;
    //    cell.imageInsets = UIEdgeInsetsTBAndHor(0, 20, 0);
    
    NSDictionary *data = [self.imags objectAtIndex:item.indexPath.row];
    item.webUrl =[data valueForKey:@"cover_imgurl"];
    UILabel * label =  (id)cell.descptionView;
    label.text = [data valueForKey:@"group_title"];
    cell.imageView.gifPlay = NO;
    cell.clipsToBounds = NO;
    [cell showBackgroundShadowStyle:styleEmbossLight];
    //要支持
    if (!item.suggestNotLoad) {
        
        [cell loadImageIfNotExist:YES];
    }
    
    
    return cell;
}

#pragma mark -

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [controller scrollViewDidScroll];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [controller scrollViewDidEndDragging];
}

#pragma mark 对item.suggestNotLoad的支持，不加下面的代码，item.suggestNotLoad都是NO
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    [self.wall scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.wall scrollViewDidEndDecelerating:scrollView];
}


@end
