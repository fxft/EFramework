//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"


@interface ___FILEBASENAMEASIDENTIFIER___ ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, HM_STRONG) UITableView *table;
@property (nonatomic, HM_STRONG) UISearchBar *mySearchBar;
@property (nonatomic, HM_STRONG) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, HM_STRONG) NSArray *searchData;
@property (nonatomic, HM_STRONG) NSMutableArray *sectionData;
@property (nonatomic, HM_STRONG) NSMutableArray *sourceData;
@end

@implementation ___FILEBASENAMEASIDENTIFIER___
@synthesize table;
@synthesize mySearchBar;
@synthesize mySearchDisplayController;
@synthesize searchData;
@synthesize sectionData;
@synthesize sourceData;

- (void)dealloc
{
    self.mySearchBar = nil;
    self.mySearchDisplayController = nil;
    self.table = nil;
    self.searchData = nil;
    self.sectionData = nil;
    self.sourceData = nil;
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
    
    self.title = @"选择城市";
    
    [self initDatas];
    
    [self initSubviews];
}

- (void)initDatas{
    
}

- (void)initSubviews{
    UIButten *leftBtn = [[UIButten alloc]init];
    leftBtn.tagString = @"leftBtn";
    [leftBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMakeBound(32, 32)];
    leftBtn.eventReceiver = self;
    [self showBarButton:HMUINavigationBar.LEFT custom:leftBtn];
    [leftBtn releaseARC];
    
    table = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:table];
    table.backgroundColor = RGBViewBack;
    table.backgroundView = nil;
    
    mySearchBar = [[UISearchBar alloc] init];
    //    [mySearchBar setScopeButtonTitles:[NSArray arrayWithObjects:@"First",@"Last",nil]];
    mySearchBar.placeholder = @"请输入城市";
    mySearchBar.delegate = self;
    //    mySearchBar.backgroundImage = [UIImage imageNamed:@""];
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [mySearchBar sizeToFit];
    self.table.tableHeaderView = mySearchBar;
    
    
    mySearchDisplayController =[[UISearchDisplayController alloc] initWithSearchBar:self.mySearchBar contentsController:self];
    
    self.mySearchDisplayController.searchResultsDelegate= self;
    
    self.mySearchDisplayController.searchResultsDataSource = self;
    
    self.mySearchDisplayController.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Provineces" ofType:@"plist"];
        self.view.userInteractionEnabled = NO;
        self.sourceData = [NSMutableArray arrayWithContentsOfFile:path];
        self.sectionData = [NSMutableArray arrayWithArray:self.sourceData];
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
            [self.table reloadData];
        });
        
    });
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.delegate = self;
    self.table.dataSource = self;
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



- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self hideNavigationBarAnimated:YES];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self showNavigationBarAnimated:NO];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.CARNO CONTAINS[cd] %@ && self.DATATYPE == %@",searchString,@(1)];
    self.searchData = [self.sourceData filteredArrayUsingPredicate:predicate];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([tableView isEqual:self.mySearchDisplayController.searchResultsTableView]){
        
        return self.searchData.count;
        
    }
    return self.sectionData.count;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([tableView isEqual:self.mySearchDisplayController.searchResultsTableView]){
        
        return 1;
        
    }
    return 1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"listCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell= [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    cell.textLabel.textColor = RGBA(0, 0, 0, .6);
    if([tableView isEqual:self.mySearchDisplayController.searchResultsTableView]){
        NSDictionary *dic = [self.searchData objectAtIndex:indexPath.row];
        cell.textLabel.text = [dic objectForKey:@"CARNO"];
    }
        
    return cell;
}
/*@{@"CARID":@"1",@"CARNO":@"测试企业1",@"DEPTID":@"1",@"DEPTNAME":@"测试企业",@"DATATYPE":@(0),@"UIMNO":@"111",@"ISONLINE":@"0"},*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([tableView isEqual:self.mySearchDisplayController.searchResultsTableView]){
        [self.mySearchDisplayController setActive:NO animated:YES];
        NSDictionary *dic = [self.searchData objectAtIndex:indexPath.row];

        return;
    }

}
@end
