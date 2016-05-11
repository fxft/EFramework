//
//  HMUIPhotoWall.h
//  WestLuckyStar
//
//  Created by Eric on 14-5-6.
//  Copyright (c) 2014年 Eric. All rights reserved.
//
/*
 
 _browser = [[HMUIPhotoWall alloc]initWithFrame:CGRectMake(0, 0, 320, 400)];
 _browser.enableRefresh = YES;
 _browser.tag = 100;
 _browser.dataSource = self;
 _browser.delegate = self;
 _browser.noMore = NO;
 [self.view addSubview:_browser];
 [_browser release];
 
 
 eg.
 static NSInteger count=50;
 
 -(NSUInteger)photoWallNumberOfRanks:(HMUIPhotoWall *)browser{
 return 2;
 }
 
 - (NSUInteger)photoWallNumberOfCells:(HMUIPhotoWall *)browser{
 return _urls.count;
 }
 
 - (HMPhotoItem *)photoWall:(HMUIPhotoWall *)browser itemAtIndex:(NSIndexPath *)indexPath{
 HMPhotoItem *item = [[[HMPhotoItem alloc]init]autorelease];
 item.imageSize = CGSizeMake(50, 60+(3-indexPath.row%3)*10);
 item.tag = indexPath.row;
 //        item.localUrl = @"Icon.png";
 
 item.webUrl = [_urls objectAtIndex:indexPath.row];
 return item;
 }
 
 - (HMPhotoCell *)photoWall:(HMUIPhotoWall *)browser cellForItem:(HMPhotoItem *)item frame:(CGRect)frame{
 HMPhotoCell *cell = [browser dequeueReusableCellWithIdentifier:@"Cell"];
 cell.photo = item;
 cell.defaultImage = [UIImage imageNamed:@"Icon.png"];
 UILabel * label =  (id)cell.descptionView;
 label.text = [NSString stringWithFormat:@"%d",item.tag];
 [cell loadImageIfNotExist];
 cell.imageView.gifPlay = NO;
 return cell;
 }
 
 - (HMPhotoCell *)photoWall:(HMUIPhotoWall *)browser cellReload:(HMPhotoCell *)cell{
 
 UILabel * label =  (id)cell.descptionView;
 label.text = [NSString stringWithFormat:@"%d",cell.tag];
 
 cell.photo.webUrl = [_urls objectAtIndex:cell.tag];
 cell.imageView.gifPlay = NO;
 [cell loadImageIfNotExist];
 return cell;
 }
 
 - (void)photoWall:(HMUIPhotoWall *)browser touchInCell:(HMPhotoCell *)cell{
 #if (__ON__ == __HM_DEVELOPMENT__)
 CC( @"photoWall",@"touch in %d",cell.tag);
 #endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
 
 HMUIPhotoWallBoard *browserboard = [HMUIPhotoWallBoard spawn];
 
 NSMutableArray *arry = [NSMutableArray array];
 NSInteger count =0;
 for (HMPhotoCell *item in [_browser cellsInScreen]) {
 if (item.tag==cell.tag) {
 browserboard.currentPhotoIndex = count;
 }
 NSString *url = [_urls[item.tag] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
 item.photo.webUrl = url;
 count++;
 
 item.photo.srcImageView = item.imageView;
 
 [arry addObject:item.photo];
 }

 [browserboard show];
 }
 
 - (void)photoWallDataLoadMore:(HMUIPhotoWall *)browser{
 count += 10;
 [browser performSelector:@selector(reloadData) withObject:self afterDelay:.5f];
 }
 
 - (void)photoWallDataReloadIng:(HMUIPhotoWall *)browser{
 [browser.refreshControl stopRefreshWithMessage:@"数据刷新" interval:3.f];
 if (count%10==0) {
 count-=10;
 }else{
 count += 10;
 browser.noMore = NO;
 }
 
 [browser reloadData];
 
 }
 
 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
 if (!decelerate) {
 [self performSelector:@selector(loadImages) withObject:self afterDelay:.5f];
 }
 }
 - (void)loadImages{
 for (HMPhotoCell *cell in [_browser cellsInScreen]) {
 
 //        cell.imageView.gifPlay = YES;
 [cell loadImageIfNotExist];
 }
 }
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
 if (!scrollView.isDragging) {
 [self performSelector:@selector(loadImages) withObject:self afterDelay:.5f];
 }
 }
 
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 for (HMPhotoCell *cell in [_browser cellsInScreen]) {
 
 cell.imageView.gifPlay = NO;
 }
 }
 */


#import <UIKit/UIKit.h>


@class HMPhotoCell;
@class HMUIPhotoWall;
@class HMPhotoItem;

@protocol HMUIPhotoWallDelegate <NSObject>

//按组返回列数
- (NSUInteger)photoWallNumberOfRanks:(HMUIPhotoWall *)browser inSection:(NSInteger)section;
//按组返回成员个数
- (NSUInteger)photoWallRowOfCells:(HMUIPhotoWall *)browser inSection:(NSInteger)section;
//按指定的组对象数据成员
- (HMPhotoItem *)photoWall:(HMUIPhotoWall *)browser itemAtIndex:(NSIndexPath*)indexPath;
//返回需要显示的单位视图 item 是数据成员对象 cell是重新加载的对象
- (HMPhotoCell *)photoWall:(HMUIPhotoWall *)browser cellForItem:(HMPhotoItem*)item cellReload:(HMPhotoCell*)cell rect:(CGRect)rect;

@optional
- (void)photoWallDataReloadIng:(HMUIPhotoWall *)browser;
- (NSUInteger)photoWallNumberOfSections:(HMUIPhotoWall *)browser;
- (void)photoWallDataLoadMore:(HMUIPhotoWall *)browser;
- (void)photoWall:(HMUIPhotoWall *)browser touchInCell:(HMPhotoCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end


@interface HMUIPhotoWall : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,assign,readonly) NSInteger rankNumber;

@property (nonatomic,assign) CGFloat   space;
@property (nonatomic,assign) CGFloat   indent;
@property (nonatomic,HM_WEAK) id<HMUIPhotoWallDelegate>    dataSource;
@property (nonatomic, assign) BOOL horizontal;//横向，默认纵向
@property (nonatomic, assign) BOOL autoFit;//当行列高度足够补充空缺时是否自动适配填充，default NO

/**
 *  每列占比 eg.@[@[],@[],@[],@[@(200/300.f),@(50/300.f),@(50/300.f)]];
 *  例子 前提：当前瀑布流控件中有且只有4组视图，而且第四组一定是3列，结果：第一、二、三组视图不进行比例切分，第四组视图有3列，每列的宽域占比
 **/
@property (nonatomic, HM_STRONG) NSArray * perRanks;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (void)reloadData;
- (void)appendData;
- (void)reloadDataSection:(NSInteger)section animated:(BOOL)animated;
- (NSArray*)cellsInScreen;

@end

