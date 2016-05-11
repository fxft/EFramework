//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"

@implementation TGSelectedCell
@synthesize iconI=_iconI;
@synthesize textL=_textL;

- (void)dealloc
{
    self.iconI = nil;
    self.textL = nil;
    HM_SUPER_DEALLOC();
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UIImageView *)iconI{
    if (_iconI==nil) {
        _iconI = [[UIImageView alloc]init];
        [self addSubview:_iconI];
    }
    return _iconI;
}

- (UILabel *)textL{
    if (_textL==nil) {
        _textL = [[UILabel spawn]retain];
        _textL.textAlignment = UITextAlignmentLeft;
        [self addSubview:_textL];
    }
    return _textL;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    frame.origin.x = (self.indentationLevel+1)*self.indentationWidth;
    if (_iconI) {
        frame = CGRectMake(frame.origin.x, (self.height-_iconI.height)/2, _iconI.width, _iconI.height);
        _iconI.frame = frame;
        frame.origin.x+=5+_iconI.width;
    }
    if (_textL) {
        CGFloat width = self.width - frame.origin.x;
        if (self.accessoryType!=UITableViewCellAccessoryNone) {
            width -= 20;
        }else if (self.accessoryView){
            width -= self.accessoryView.width;
        }
        frame = CGRectMake(frame.origin.x, 0, width, self.height);
        _textL.frame = frame;
    }
    
}

@end


@implementation ThreeItem
@synthesize rowNum;
@synthesize data;
@synthesize indentationLevel;
@synthesize end;
@synthesize selected;

- (void)dealloc{
    self.data = nil;
    HM_SUPER_DEALLOC();
}


@end


@interface HMTableThreeBoard ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, HM_STRONG) UITableView *table;
@property (nonatomic, HM_STRONG) UISearchBar *mySearchBar;
@property (nonatomic, HM_STRONG) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, HM_STRONG) NSArray *searchData;
@property (nonatomic, HM_STRONG) NSMutableArray *sectionData;
@property (nonatomic, HM_STRONG) NSMutableDictionary *selects;
@end

@implementation HMTableThreeBoard{
    NSObject *_itemSelected;
    UIButten *rightBtn;
}
@synthesize table;
@synthesize mySearchBar;
@synthesize mySearchDisplayController;
@synthesize searchData;
@synthesize sourceData;
@synthesize sectionData;
@synthesize selects;
@synthesize itemSelected=_itemSelected;

DEF_SIGNAL(DIDSELECTED)
DEF_SIGNAL(MUTISELECTED)

- (void)dealloc
{
    self.mySearchBar = nil;
    self.mySearchDisplayController = nil;
    self.table = nil;
    self.searchData = nil;
    self.sourceData = nil;
    self.sectionData = nil;
    self.selects = nil;
    self.itemSelected = nil;
    [rightBtn releaseARC];
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
    
    self.title = @"选择车辆";
    UILabel *labelTitle = [UILabel spawn];
    labelTitle.textColor = RGBTextNormal;
    labelTitle.font = [UIFont boldSystemFontOfSize:18];
    self.navigationItem.titleView = labelTitle;
    labelTitle.text = self.title;
    [labelTitle sizeToFit];
    
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
    mySearchBar.placeholder = @"请输入车牌号码";
    mySearchBar.delegate = self;
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [mySearchBar sizeToFit];
    self.table.tableHeaderView = mySearchBar;
    
    
    mySearchDisplayController =[[UISearchDisplayController alloc] initWithSearchBar:self.mySearchBar contentsController:self];
    
    self.mySearchDisplayController.searchResultsDelegate= self;
    
    self.mySearchDisplayController.searchResultsDataSource = self;
    
    self.mySearchDisplayController.delegate = self;
    
    self.sourceData = [TGModel sharedInstance].carlist;
    
    [self resetData];
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.delegate = self;
    self.table.dataSource = self;
}

- (void)showAllBtn:(BOOL)yes{
    if (!yes) {
        [self hideBarButton:HMUINavigationBar.RIGHT];
        rightBtn.hidden = YES;
        [rightBtn releaseARC];
        rightBtn = nil;
    }else{
        if (rightBtn==nil) {
            rightBtn = [[UIButten alloc]init];
            rightBtn.tagString = @"rightBtn";
            [rightBtn setBackgroundImage:[[UIImage imageNamed:@"btn_rightup.png"] stretched] forState:UIControlStateNormal];
            [rightBtn setTitle:@"全部" forState:UIControlStateNormal];
            rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [rightBtn setTitleColor:RGBTextNormal forState:UIControlStateNormal];
            [rightBtn setFrame:CGRectMakeBound(63, 32)];
            rightBtn.eventReceiver = self;
            [self showBarButton:HMUINavigationBar.RIGHT custom:rightBtn];

        }
   }
}
- (void)setItemSelected:(NSObject *)itemSelected{

    [_itemSelected releaseARC];
    _itemSelected = [itemSelected retainARC];
    
    if (!self.mutiSelect) {
        [self.selects removeAllObjects];
        if (itemSelected) {
            NSString *carID = [itemSelected valueForKey:@"CARID"];
            
            [self.selects setObject:@"YES" forKey:carID];
        }
        
        [self.table reloadData];
    }
}

- (void)resetData{
    self.sectionData = [NSMutableArray array];
    
    if (self.sourceData.count) {
        
        NSArray *arry = [[TGModel sharedInstance] topSection];
        
        if (self.selects==nil) {
            self.selects = [NSMutableDictionary dictionary];
            NSUInteger route=0;
            NSMutableArray *cars = [NSMutableArray array];
            CAR *dic = [[TGModel sharedInstance] firstCar:arry Route:&route cars:cars indentationLevel:0];
            if (dic) {
                [self.selects setObject:@"YES" forKey:[dic valueForKey:@"CARID"]];
            }
            
            for (CAR *dic in cars) {
                
                ThreeItem *item = [[ThreeItem alloc]init];
                item.rowNum = self.sectionData.count;
                item.data = dic;
                item.end = dic.DATATYPEI==-1?YES:NO;
                item.selected  = dic.selected;
                item.indentationLevel = dic.indentationLevel;
                [self.sectionData addObject:item];
                [item release];
            }
        }
       
    }
}


- (void)calculateForTable:(UITableView*)tableView item:(ThreeItem *)from{
  
    BOOL selected = from.selected;
    selected = !selected;
    from.selected = selected;
    NSInteger fromNum = from.rowNum+1;
    NSUInteger level = from.indentationLevel;
    NSMutableArray *paths = [NSMutableArray array];
    
    if (selected) {

        NSArray *arry = [[TGModel sharedInstance] deptSection:from.data];
        
        NSMutableArray *items = [NSMutableArray array];
        for (CAR *dic in arry) {
            ThreeItem *item = [[ThreeItem alloc]init];
            item.end = dic.DATATYPEI == -1?YES:NO;
            item.data = dic;
            item.rowNum = from.rowNum+1;
            item.indentationLevel = level+1;
            from = item;
            [items addObject:item];
            [item release];
            
        }
        
        if (items.count) {
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(fromNum, items.count)];
            
            NSArray *others = [self.sectionData subarrayWithRange:NSMakeRange(fromNum, self.sectionData.count-fromNum)];
            [others enumerateObjectsUsingBlock:^(ThreeItem* obj, NSUInteger idx, BOOL *stop) {
                obj.rowNum += items.count;
            }];
            
            [self.sectionData insertObjects:items atIndexes:set];
            
            for (NSUInteger c=0; c<items.count; c++) {
                [paths addObject:[NSIndexPath indexPathForRow:c+fromNum inSection:0]];
            }
            
            [tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
        }
    }else{
        for (NSUInteger c=fromNum; c<self.sectionData.count; c++) {
            ThreeItem *item = [self.sectionData objectAtIndex:c];
            if (item.indentationLevel<=level) {
                from = item;
                break;
            }else{
                if (c==self.sectionData.count-1) {
                    from=nil;
                }
                [paths addObject:[NSIndexPath indexPathForRow:c inSection:0]];
            }
        }
        if (paths.count) {
            if (from) {
                NSArray *others = [self.sectionData subarrayWithRange:NSMakeRange(from.rowNum, self.sectionData.count-from.rowNum)];
                [others enumerateObjectsUsingBlock:^(ThreeItem* obj, NSUInteger idx, BOOL *stop) {
                    obj.rowNum -= paths.count;
                }];
            }
            
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(fromNum, paths.count)];
            
            if (paths.count < [self tableView:tableView numberOfRowsInSection:0]) {
                [self.sectionData removeObjectsAtIndexes:set];
                [tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
            }
            
        }
    }

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
            [self backAndRemoveWithAnimate:YES];
        }else if ([btn is:@"rightBtn"]) {
            [self sendSignal:[HMTableThreeBoard MUTISELECTED] withObject:nil];
            [self backAndRemoveWithAnimate:YES];
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

    self.searchData = [[TGModel sharedInstance] searchCars:searchString];
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

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:self.mySearchDisplayController.searchResultsTableView]){
        return 0;
    }
    ThreeItem *item = [self.sectionData objectAtIndex:indexPath.row];
    return item.indentationLevel;
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
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    if([tableView isEqual:self.mySearchDisplayController.searchResultsTableView]){
        NSDictionary *dic = [self.searchData objectAtIndex:indexPath.row];
        cell.textLabel.text = [dic valueForKey:@"CARNO"];
    }else{
        ThreeItem *item = [self.sectionData objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [item.data valueForKey:@"CARNO"];
        cell.accessoryType = item.end?UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator;
        
        if (item.end) {
            NSString *identifier=@"SelectedCell";
            TGSelectedCell *cells=[tableView dequeueReusableCellWithIdentifier:identifier];
            
            if (!cells) {
                cells= [[[TGSelectedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
                cells.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }
            cells.tagString = [item.data valueForKey:@"CARID"];
            BOOL selec = !![self.selects valueForKey:cells.tagString];
            UIImage *image = nil;
            if (selec) {
#if (__ON__ == __HM_DEVELOPMENT__)
                CC( [self.class description],@"%@",[item.data valueForKey:@"CARNO"]);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
                image = [UIImage imageNamed:@"radio_1.png"];
            }else{
                image = [UIImage imageNamed:@"radio_0.png"];
            }
            cells.textL.text = [item.data valueForKey:@"CARNO"];
            NSString *status = [item.data valueForKey:@"ISONLINE"];
            cells.textL.textColor = [status isEqualToString:@"1"]?RGBA(0, 0, 0, .6):[UIColor redColor];
            cells.textL.font = [UIFont systemFontOfSize:15];
            cells.iconI.image = image;
            cells.iconI.size = CGSizeMake(20, 20);
            cell = cells;
        }else{
            cell.tagString = [item.data valueForKey:@"CARNO"];
            UIImage *image = nil;
            if (item.selected) {
                image = [UIImage imageNamed:@"grayarrow_down.png"];
            }else{
                image = [UIImage imageNamed:@"grayarrow_right.png"];
            }
            UIImageView *view = [[[UIImageView alloc]initWithImage:image]autorelease];
            view.frame = CGRectMake(0, 0, 14, 14);
            cell.accessoryView = view;
        }
        cell.textLabel.backgroundColor = [UIColor clearColor];
        UIImageView *view = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"carlist%d.png",item.indentationLevel+1]]]autorelease];
        view.frame = cell.bounds;
        cell.backgroundView = view;
    }
    
    return cell;
}
/*@{@"CARID":@"1",@"CARNO":@"测试企业1",@"DEPTID":@"1",@"DEPTNAME":@"测试企业",@"DATATYPE":@(0),@"UIMNO":@"111",@"ISONLINE":@"0"},*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if([tableView isEqual:self.mySearchDisplayController.searchResultsTableView]){
        [self.mySearchDisplayController setActive:NO animated:YES];
        NSDictionary *dic = [self.searchData objectAtIndex:indexPath.row];
        if (!self.mutiSelect) {
            [self.selects removeAllObjects];
            
            NSString *carID = [dic valueForKey:@"CARID"];
            [self.selects setObject:@"YES" forKey:carID];
            [self.table reloadData];
        }
        [self sendSignal:[HMTableThreeBoard DIDSELECTED] withObject:dic];

        return;
    }
    [tableView beginUpdates];
    ThreeItem *from = [self.sectionData objectAtIndex:indexPath.row];
    UITableViewCell *cellNow = [tableView cellForRowAtIndexPath:indexPath];
    if (from.end){
        TGSelectedCell *cellS = (id)cellNow;
        if (!self.mutiSelect) {
            if (![selects valueForKey:cellS.tagString]) {
                
                cellS.iconI.image = [UIImage imageNamed:@"radio_1.png"];
            }
            NSArray *cells = [tableView visibleCells];
            for (UITableViewCell *cell in cells) {
                if (![cell isKindOfClass:[TGSelectedCell class]]) {
                    continue;
                }
                
                if ([self.selects valueForKey:cell.tagString]&&![cellS.tagString isEqualToString:cell.tagString]) {
                   
                    [(TGSelectedCell *)cell iconI].image = [UIImage imageNamed:@"radio_0.png"];
                    break;
                }
            }
            
            [self.selects removeAllObjects];
            
            NSString *carID = [from.data valueForKey:@"CARID"];
            [self.selects setObject:@"YES" forKey:carID];
            
            [self sendSignal:[HMTableThreeBoard DIDSELECTED] withObject:from.data];
        }else{
            
        }
        
    }else{
        
        [self calculateForTable:tableView item:from];
        UIImage *image = nil;
        if (from.selected) {
            image = [UIImage imageNamed:@"grayarrow_down.png"];
        }else{
            image = [UIImage imageNamed:@"grayarrow_right.png"];
        }
        UIImageView *view = (id)cellNow.accessoryView;
        if (view==nil) {
            view = [[[UIImageView alloc]initWithImage:image]autorelease];
            view.frame = CGRectMake(0, 0, 14, 14);
            cellNow.accessoryView = view;
        }else{
            view.image = image;
        }
        
    }
 [tableView endUpdates];
}
@end
