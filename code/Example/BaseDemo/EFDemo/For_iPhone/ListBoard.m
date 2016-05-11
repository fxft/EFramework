//
//  ListBoard.m
//  EFDemo
//
//  Created by mac on 16/5/10.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ListBoard.h"


@interface ListBoard ()

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



#pragma  mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.boards.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
