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
    self.step1List = [NSMutableArray array];
    self.step2List = [NSMutableArray array];
    
    self.presenter1 = [CargoPresenter presenter];
    self.presenter1.delegate = self;
    self.presenter2 = [CargoPresenter presenter];
    self.presenter2.delegate = self;
    
    [self.presenter1 doStore:[CargoPresenter myCargoListIO_rule] attributes:[UserCenter sharedInstance].role];
    [self.presenter2 doStore:[CargoPresenter myCargoListIO_rule] attributes:[UserCenter sharedInstance].role];
    [self.presenter1 doStore:[CargoPresenter myCargoListIO_rule] attributes:[UserCenter sharedInstance].userid];
    [self.presenter2 doStore:[CargoPresenter myCargoListIO_rule] attributes:[UserCenter sharedInstance].userid];
}

- (void)initSubviews{
    self.tap = [[HMUITapbarView spawn] EFOwner:self.view];
    self.tap.tag  = 100;
    self.tap.barStyle = UITapbarStyleFitSize;
    UIButten *tapBen = [self.tap addItemWithTitle:@"未过期" imageName:@"tab_left.png" size:CGSizeZero background:YES];
    [tapBen setTitleColor:Color_Theme_gray forState:UIControlStateSelected];
    [tapBen setTitleColor:Color_Theme_gray forState:UIControlStateNormal];
    
    tapBen = [self.tap addItemWithTitle:@"已过期" imageName:@"tab_right.png" size:CGSizeZero background:YES];
    [tapBen setTitleColor:Color_Theme_red forState:UIControlStateSelected];
    [tapBen setTitleColor:Color_Theme_gray forState:UIControlStateNormal];
    
    [self.tap mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.height.mas_equalTo(50);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
    }];
    
    self.scroll = [[UIScrollView alloc]init];
    [self.view addSubview:self.scroll];
    
    self.scroll.pagingEnabled = YES;
    self.scroll.showsHorizontalScrollIndicator = NO;
    self.scroll.delegate = self;
    self.scroll.bounces = NO;
    self.scroll.scrollEnabled = NO;
    
    
    [self.scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tap.mas_bottom).offset(0);
        make.leading.mas_equalTo(self.view.mas_leading).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(0);
    }];
    
    UIView *view = [UIView view];
    view.userInteractionEnabled = YES;
    [self.scroll addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scroll.mas_top).offset(0);
        make.leading.mas_equalTo(self.scroll.mas_leading).offset(0);
        make.trailing.mas_equalTo(self.scroll.mas_trailing).offset(0);
        make.bottom.mas_equalTo(self.scroll.mas_bottom).offset(0);
        make.right.mas_equalTo(self.scroll.mas_right).offset(0);
        make.left.mas_equalTo(self.scroll.mas_left).offset(0);
        make.height.mas_equalTo(self.view.mas_height).offset(-50);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(2);
        
    }];
    self.step1Table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.scroll addSubview:self.step1Table];
    self.step1Table.separatorInset = UIEdgeInsetsAll(20);
    self.step1Table.backgroundColor = self.view.backgroundColor;
    
    self.step2Table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.scroll addSubview:self.step2Table];
    self.step2Table.separatorInset = UIEdgeInsetsAll(20);
    self.step2Table.backgroundColor = self.view.backgroundColor;
    
    [self.step1Table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view.mas_top).offset(0);
        make.left.mas_equalTo(view.mas_left).offset(0);
        make.bottom.mas_equalTo(view.mas_bottom).offset(0);
        make.width.mas_equalTo(self.view.mas_width).offset(0);
    }];
    
    [self.step2Table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view.mas_top).offset(0);
        make.left.mas_equalTo(self.step1Table.mas_right).offset(0);
        make.bottom.mas_equalTo(view.mas_bottom).offset(0);
        make.width.mas_equalTo(self.view.mas_width).offset(0);
    }];
    
    [self.step1Table registerNib:[UINib nibWithNibName:@"CargoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CargoCell"];
    [self.step2Table registerNib:[UINib nibWithNibName:@"CargoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CargoCell"];
    
    self.step1Table.dataSource = self;
    self.step1Table.delegate  = self;
    
    self.step2Table.dataSource = self;
    self.step2Table.delegate  = self;
    
    
    WS(weakSelf)
    self.step1Table.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf doGet1];
    }];
    self.step1Table.footer.hidden = YES;
    
    self.step1Table.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.presenter1 doStore:weakSelf.presenter1.myCargoListIO_count attributes:@"20"];
        [weakSelf.presenter1 doStore:weakSelf.presenter1.myCargoListIO_offsetid attributes:@"0"];
        [weakSelf doGet1];
    }];
    
    self.step2Table.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf doGet2];
    }];
    self.step2Table.footer.hidden = YES;
    
    self.step2Table.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.presenter2 doStore:weakSelf.presenter2.myCargoListIO_count attributes:@"20"];
        [weakSelf.presenter2 doStore:weakSelf.presenter2.myCargoListIO_offsetid attributes:@"0"];
        [weakSelf doGet2];
    }];
    
    [_tap setSelectedIndex:0];
    
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
ON_TapBar(signal){
    if ([signal is:[HMUITapbarView TAPCHANGED]]) {
        if (_tap.selectedIndex==0) {
            
            if (self.step1List.count==0&&![self.step1Table.header isRefreshing]&&![self.step1Table.footer isRefreshing]) {
                [self.step1Table.header beginRefreshing];
            }
            
            [self.scroll setContentOffset:CGPointMake(0, 0) animated:YES];
            
        }else if (_tap.selectedIndex==1){
            if (self.step2List.count==0&&![self.step2Table.header isRefreshing]&&![self.step2Table.footer isRefreshing]) {
                [self.step2Table.header beginRefreshing];
            }
            [self.scroll setContentOffset:CGPointMake(self.view.width, 0) animated:YES];
        }
    }
}
#pragma mark - presenter

- (void)doGet1{
    [self.presenter1 doSomething:self.presenter1.myCargoList attributes:nil];
}
- (void)doGet2{
    [self.presenter2 doSomething:self.presenter2.myCargoList attributes:nil];
}

- (void)presenter:(Presenter *)presenter doSome:(NSString *)something bean:(WebAPIResult*)bean state:(PresenterProcess)state error:(NSError *)error{
    if (state==PresenterProcessSucced) {
        
        
        CargoPresenter * myPresenter = (id)presenter;
        NSMutableArray *list = presenter==self.presenter1?self.step1List:self.step2List;
        UITableView *tableview = presenter==self.presenter1?self.step1Table:self.step2Table;
        
        if (![[presenter doReStore:[CargoPresenter myCargoListIO_offsetid]] notEmpty]||[[presenter doReStore:[CargoPresenter myCargoListIO_offsetid]] is:@"0"]) {
            [list removeAllObjects];
        }
        
        myCargoList *cargolist = bean.resultObject;
        
        [list addObjectsFromArray:cargolist.list];
        
        if (tableview.footer.isRefreshing) {
            [tableview.footer endRefreshing];
        }
        
        if (tableview.header.isRefreshing) {
            [tableview.header endRefreshing];
        }
        cargoItem *cargo = list.lastObject;
        if (cargo) {
            [myPresenter doStore:myPresenter.myCargoListIO_offsetid attributes:cargo.cargoid];
        }
        if ([cargolist.total integerValue]<=list.count) {
            [tableview.footer noticeNoMoreData];
        }else{
            tableview.footer.hidden = NO;
            [tableview.footer resetNoMoreData];
        }
        [tableview reloadData];
    }
}

#pragma  mark - table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView view];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView==self.step1Table) {
        return self.step1List.count;
    }else{
        return self.step2List.count;
    }
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
    NSMutableArray *list = tableView==self.step1Table?self.step1List:self.step2List;
    myCargoItem *item = [list safeObjectAtIndex:indexPath.section];
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
    
    cell.backgroundColor = tableView.backgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *list = tableView==self.step1Table?self.step1List:self.step2List;
    myCargoItem *item = [list safeObjectAtIndex:indexPath.section];
    
    if (indexPath.row==2) {
        UIViewController *cc = [[self open:URLFOR_controllerWithNav(@"MyBidding") animate:YES] myTopBoard];
        [cc setValue:item forKey:@"item"];
    }
}

@end
