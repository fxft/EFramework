//
//  HMPhotoBrowserBoard.h
//  WestLuckyStar
//
//  Created by Eric on 14-5-10.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

/*
 eg.
 HMPhotoBrowserBoard *browserboard = [HMPhotoBrowserBoard spawn];
 
 browserboard.delegate= self;
 browserboard.dataSource = self;
 browserboard.allowZoom = NO;
 browserboard.allowAutoScroll = YES;

 数据代理通过datasource，delegate实现
 
 HMPhotoItem 数据对象类
 
 NSMutableArray *arry = [NSMutableArray array];
 NSInteger count =0;
 for (NSDictionary *detail in imagelist) {
 HMPhotoItem *item = [[HMPhotoItem alloc]init];
 
 item.image = [UIImage imageNamed:@"main_mainbar_bg.png"];
 item.webUrl = [detail valueForKey:@"img_url"];
 [arry addObject:item];
 }
 
 两种用法
 1、  [browserboard show];//直接弹出显示
 2、  [self.view addSubview:browserboard];//
 */


@class HMUIPhotoBrowser, HMPhotoItem,HMPhotoCell;


@protocol HMUIPhotoBrowserDelegate,HMUIPhotoBrowserDatasource;

/**
 * 滚动视图控件：循环播放的图片新闻条，图片浏览控件：支持缩放查看
 */
@interface HMUIPhotoBrowser : HMUIView
// 代理
@property (nonatomic, HM_WEAK) id<HMUIPhotoBrowserDelegate> delegate;
@property (nonatomic, HM_WEAK) id<HMUIPhotoBrowserDatasource> dataSource;
// 所有的图片对象
@property (nonatomic, HM_STRONG) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;//当前图片索引
@property (nonatomic, assign) CGFloat padding;//页间距

@property (nonatomic, assign) BOOL      allowGifPlay;//允许gif自动播放
@property (nonatomic, assign) BOOL      allowOriententation;
@property (nonatomic, assign) BOOL      allowAutoScroll;//允许自动滚动
@property (nonatomic, assign) NSTimeInterval   autoScrollInteval;//自动滚动播放
@property (nonatomic, assign) BOOL      allowZoom;//支持缩放
@property (nonatomic, assign) BOOL      allowHumb;//图片弹出效果
@property (nonatomic, assign) BOOL      showText;
@property (nonatomic, assign) BOOL      circulation;//是否支持循环
@property (nonatomic, assign) UIViewContentMode photoContentMode;//图像显示方式

@property (nonatomic,HM_STRONG,readonly) UIImageView *backgroundBaseView;//可以对该属性进行背景设置，比如颜色，添加图层,default black color
// 显示
- (void)show;
- (void)showFromView:(UIView *)view animated:(BOOL)animated;
- (void)hidden;

- (void)nextPhotoIndexAnimated:(BOOL)animated;
- (void)prePhotoIndexAnimated:(BOOL)animated;

- (void)reloadData;

- (HMPhotoCell *)currentPhotoView;

@end


@protocol HMUIPhotoBrowserDatasource <NSObject>
/**
 *  数据源获取
 *
 *  @param browser  当前的browser
 *  @param index   数据索引
 *
 *  @return 数据源
 */
- (HMPhotoItem *)photoBrowser:(HMUIPhotoBrowser *)browser itemAtIndex:(NSUInteger)index;


@optional

/**
 *  数据源原位置获取图片或uiview。前提allowHumb＝YES
 *
 *  @param browser  当前的browser
 *  @param index   数据索引
 *
 *  @return 数据源
 */
- (id)photoBrowser:(HMUIPhotoBrowser *)browser sourceAtIndex:(NSUInteger)index;


/**
 *  数据源原位置获取，如果-［self photoBrowser:sourceAtIndex:］返回的是UIView则－［self photoBrowser:frameAtIndex:］
 *
 *  @param browser  当前的browser
 *  @param index   数据索引
 *
 *  @return 数据源
 */
- (CGRect)photoBrowser:(HMUIPhotoBrowser *)browser frameAtIndex:(NSUInteger)index;

/**
 *  cell视图获取
 *
 *  @param photoBrowser 当前的browser
 *  @param item 当前数据源
 *
 *  @return cell视图
 */
- (HMPhotoCell *)photoBrowser:(HMUIPhotoBrowser *)photoBrowser forItem:(HMPhotoItem *)item;

//- (void)photoBrowser:(HMUIPhotoBrowser *)photoBrowser didDisplayCell:(HMPhotoCell *)cell forItem:(HMPhotoItem *)item;

/**
 *  个数返回
 *
 *  @param browser  当前的browser
 *
 *  @return 个数
 */
- (NSUInteger )photoBrowserNumbers:(HMUIPhotoBrowser *)browser;

@end

@protocol HMUIPhotoBrowserDelegate <NSObject>

@optional
//每次更换页面就会加载一次，日后改进
- (void)photoBrowser:(HMUIPhotoBrowser *)photoBrowser didLoadCell:(HMPhotoCell*)cell atIndex:(NSUInteger)index;
// 切换到某一页图片
- (void)photoBrowser:(HMUIPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

//返回NO则Browser将从屏幕中移除,返回YES不做操作
- (BOOL)photoBrowser:(HMUIPhotoBrowser *)photoBrowser didTouchedIndex:(NSUInteger)index;
//长按事件
- (void)photoBrowser:(HMUIPhotoBrowser *)photoBrowser didLongTouchedIndex:(NSUInteger)index;
//双击事件,如果返回NO，可以屏蔽双击放大的事件
- (BOOL)photoBrowser:(HMUIPhotoBrowser *)photoBrowser didDoubbleTouchedIndex:(NSUInteger)index;



/**
 *  humbImageView
 *
 *  @param browser  当前的browser
 *  @param index   数据索引
 *
 *  @return 数据源
 */
- (void)photoBrowser:(HMUIPhotoBrowser *)browser willshowHumbImageView:(UIImageView*)humb atIndex:(NSUInteger)index;

/**
 *  获取window当前图片是否有旋转角度,当支持旋转时
 *
 *  @param browser  当前的browser
 *
 *  @return 是否已经选择
 */
- (BOOL)photoBrowserWindowRoated:(HMUIPhotoBrowser *)browser;

@end
