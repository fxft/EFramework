//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"


@interface ___FILEBASENAMEASIDENTIFIER___ ()<PresenterCallBackProtocol>
@property (nonatomic,strong) Presenter * presenter;
@property (nonatomic,strong) NSMutableArray * list;

@end

@implementation ___FILEBASENAMEASIDENTIFIER___

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
    self.presenter = [Presenter presenter];
    self.presenter.delegate = self;
    self.list = [NSMutableArray array];
    
}

- (void)initSubviews{
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CargoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CargoCell"];
    
    [self.presenter doStore:self.presenter.biddingListIO_count attributes:@"20"];
    
    WS(weakSelf)
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf doGet];
    }];
    self.tableView.footer.hidden = YES;
    
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.presenter doStore:weakSelf.presenter.biddingListIO_offsetid attributes:@"0"];
        [weakSelf doGet];
    }];
    
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.view sendSubviewToBack:self.tableView];
    
    [self.tableView.header beginRefreshing];
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

#pragma mark - presenter

- (void)doGet{
    [self.presenter doSomething:self.presenter.biddingList attributes:nil];
}

- (void)presenter:(Presenter *)presenter doSome:(NSString *)something bean:(WebAPIResult*)bean state:(PresenterProcess)state error:(NSError *)error{
    if (state==PresenterProcessSucced) {
        if ([something is:[CargoPresenter bidding]]) {
            
            return;
        }
        if (![[presenter doReStore:self.presenter.biddingListIO_offsetid] notEmpty]||[[presenter doReStore:self.presenter.biddingListIO_offsetid] is:@"0"]) {
            [self.list removeAllObjects];
        }
        biddingList *cargolist = bean.resultObject;
        
        [self.list addObjectsFromArray:cargolist.list];
        
        if (self.tableView.footer.isRefreshing) {
            [self.tableView.footer endRefreshing];
        }
        
        if (self.tableView.header.isRefreshing) {
            [self.tableView.header endRefreshing];
        }
        biddingItem *bidding = self.list.lastObject;
        if (bidding) {
            [self.presenter doStore:self.presenter.biddingListIO_offsetid attributes:bidding.biddingid];
        }
        if ([cargolist.total integerValue]<=self.list.count) {
            [self.tableView.footer noticeNoMoreData];
        }else{
            self.tableView.footer.hidden = NO;
            [self.tableView.footer resetNoMoreData];
        }
        [self.tableView reloadData];
    }else if (state==PresenterProcessFailed||state==PresenterProcessTimeOut){
        if (self.tableView.footer.isRefreshing) {
            [self.tableView.footer endRefreshing];
        }
        
        if (self.tableView.header.isRefreshing) {
            [self.tableView.header endRefreshing];
        }
    }
}

#pragma  mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 50;
    }else if (indexPath.row==1){
        return 135;
    }else if (indexPath.row==2){
        return 44;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    biddingItem *item = [self.list safeObjectAtIndex:indexPath.section];
    NSString *identifier=@"listCell";
    if (indexPath.row==1) {
        identifier = @"CargoCell";
    }else if (indexPath.row==2){
        identifier = @"remarkCell";
    }
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
