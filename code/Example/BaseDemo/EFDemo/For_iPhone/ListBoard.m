//
//  ListBoard.m
//  EFDemo
//
//  Created by mac on 16/5/10.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ListBoard.h"


@interface ListBoard ()<HMUIPhotoBrowserDelegate,HMUIPhotoBrowserDatasource>

@end

@implementation ListBoard

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
    
//    NSMutableArray *subBoards = [NSMutableArray arrayWithCapacity:0];
//    [subBoards addObject:@{@"title":@"Foundation",@"subtitle":@"基础工具",@"map":@"Foundation",@"open":@"push",@"url":URLFOR_controller(@"ListBoard"),@"boards":@[]}];
//     [boards addObject:@{@"title":@"Foundation",@"subtitle":@"基础工具",@"map":@"Foundation",@"open":@"push",@"url":URLFOR_controller(@"ListBoard"),@"boards":subBoards}];
    
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

- (BOOL)photoBrowser:(HMUIPhotoBrowser *)photoBrowser didTouchedIndex:(NSUInteger)index{
    
    return NO;
}

- (void)photoBrowser:(HMUIPhotoBrowser *)photoBrowser didLoadCell:(HMPhotoCell *)cell atIndex:(NSUInteger)index{
    cell.imageView.gifPlay = YES;
}


- (HMPhotoItem *)photoBrowser:(HMUIPhotoBrowser *)browser itemAtIndex:(NSUInteger)index{
    NSDictionary *city = [self.boards objectAtIndex:browser.tag];
    NSArray *imags= [city valueForKey:@"imgurl"];
    NSString *imgurl = imags[index];
    HMPhotoItem *item = [[HMPhotoItem alloc]init];
    item.image = [UIImage imageNamed:@"Icon-60"];
    item.webUrl = imgurl;
    return item;
}

- (NSUInteger)photoBrowserNumbers:(HMUIPhotoBrowser *)browser{
    NSDictionary *city = [self.boards objectAtIndex:browser.tag];
    NSArray *imags= [city valueForKey:@"imgurl"];
    return imags.count;
}

ON_TAPPED(signal){
    if ([signal is:[UIView TAPPED]]) {
        UIView *source = signal.source;
        NSDictionary *city = [self.boards objectAtIndex:source.tag];
        NSArray *imgurl= [city valueForKey:@"imgurl"];
        if ([imgurl count]) {
            HMUIPhotoBrowser *browserboard = [[HMUIPhotoBrowser alloc]init];
            browserboard.delegate= self;
            browserboard.dataSource = self;
            browserboard.allowZoom = NO;
            browserboard.allowAutoScroll = YES;
            browserboard.tag = source.tag;
            
            [browserboard show];
        }
    }
}

#pragma  mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.boards.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *height = [self.boards[indexPath.row] valueForKey:@"listheight"];
    if (height) {
        return [height integerValue];
    }
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"listCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    NSDictionary *city = [self.boards objectAtIndex:indexPath.row];
    cell.textLabel.text = [city valueForKey:@"title"];
    cell.detailTextLabel.text = [city valueForKey:@"subtitle"];
    cell.detailTextLabel.textColor = RGB(.5, .5, .5);
    cell.detailTextLabel.numberOfLines = 0;
    NSArray *imgurl= [city valueForKey:@"imgurl"];
    UIImageView *imageview = (id)cell.accessoryView;
    
    if ([imgurl count]) {
        if (imageview==nil) {
            imageview = [[UIImageView alloc]init];
            cell.accessoryView= imageview;
            imageview.tapEnabled = YES;
        }
        [imageview setImageWithURLString:imgurl.firstObject placeholderImage:[UIImage imageNamed:@"Icon-60"]];
        CGFloat wi = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        imageview.bounds = CGRectMakeBound(wi, wi);
        imageview.gifPlay = YES;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        imageview.tag = indexPath.row;
    }else{
        imageview.image = nil;
    }
   
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *city = [self.boards objectAtIndex:indexPath.row];
    
    NSString *map = [city valueForKey:@"map"];
    NSString *url = [city valueForKey:@"url"];
    NSString *open = [city valueForKey:@"open"];
    NSArray *boards = [city valueForKey:@"boards"];
    
    
    void (^complete)(BOOL viewLoaded, UIViewController* toBoard)=^(BOOL viewLoaded, UIViewController *toBoard){
        if (!viewLoaded) {
            [toBoard.myTopBoard setTitle:[city valueForKey:@"title"]];
            
            if ([toBoard.myTopBoard respondsToSelector:@selector(boards)]) {
                [toBoard.myTopBoard setValue:boards forKey:@"boards"];
            }
        }
    };
    
    UIViewController *vc = nil;
    if ([open isEqualToString:@"open"]) {
        vc = [self open:url name:map animate:YES complete:complete];
    }else if ([open isEqualToString:@"push"]) {
        vc = [self pushToPath:url map:map animated:YES complete:complete];
    }else if ([open isEqualToString:@"present"]) {
        vc = [self presentToPath:url map:map animated:YES complete:complete];
    }
    
    
    
}

@end
