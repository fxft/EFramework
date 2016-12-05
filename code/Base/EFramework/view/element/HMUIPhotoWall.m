//
//  HMphotoWall.m
//  WestLuckyStar
//
//  Created by Eric on 14-5-6.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIPhotoWall.h"
#import "HMPhotoCell.h"

@interface NSSectionPath : NSObject
@property(nonatomic,assign) NSInteger section;//分组
@property(nonatomic,assign) NSInteger from;//分组相对总体数量的索引
@property(nonatomic,assign) NSInteger to;
@property(nonatomic,assign) NSInteger length;//分组长度
@property(nonatomic,assign) NSInteger ranks;//分组里面的列数
@property(nonatomic,assign) CGRect  minMax;
@property(nonatomic,assign) CGFloat  sizeHeight;
@property(nonatomic,assign) CGFloat  startOffset;
+ (NSSectionPath *)sectionPathFrom:(NSInteger)from length:(NSInteger)length inSection:(NSInteger)section ranks:(NSInteger)ranks;
@end

@implementation NSSectionPath
@synthesize from;
@synthesize section;
@synthesize length;
@synthesize ranks;
@synthesize to;
@synthesize minMax;
@synthesize sizeHeight;
@synthesize startOffset;

+ (NSSectionPath *)sectionPathFrom:(NSInteger)from length:(NSInteger)length inSection:(NSInteger)section ranks:(NSInteger)ranks{
    NSSectionPath *path = [[[NSSectionPath alloc]init]autorelease];
    path.section = section;
    path.from = from;
    path.length = length;
    path.ranks = ranks;
    path.to = from+length;
    return path;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"section:%@ from:%@ to:%@ lenght:%@ ranks:%@ %@ %@", @(section),@(from),@(to),@(length),@(ranks),@(startOffset),LOGFRAMEFormat(minMax)];
}
@end

#pragma mark -
#pragma mark HMUIPhotoWall
#pragma mark -

@interface HMUIPhotoWall ()<HMPhotoCellDelegate>

@property (nonatomic,HM_STRONG) NSMutableDictionary  *reuseCells;/*可复用的CellView*/
@property (nonatomic,HM_STRONG) NSMutableArray  *rankMaps;/*所有已经加载过的视图的位置数据表*/
@property (nonatomic,HM_STRONG) NSArray         *preMaps;/*上一屏的位置表*/
@property (nonatomic,HM_STRONG) NSArray         *nextMaps;/*下一屏需要显示的位置表*/
@property (nonatomic,HM_STRONG) NSMutableArray  *loadedIndexs;/*已经加载的CellView索引*/
@property (nonatomic,HM_STRONG) NSMutableArray  *sectionMaps;/*分组信息NSSectionPath*/

@property (nonatomic,HM_STRONG) UIActivityIndicatorView *activity;
@property (nonatomic,assign,readwrite) BOOL loading;
@property (nonatomic,assign) CGPoint targetloadPoint;
@property (nonatomic,assign) CGPoint targetloadVelocity;

@property (nonatomic,HM_STRONG) NSMutableArray *floatScreens;
@property (nonatomic,HM_STRONG) NSMutableArray *currentFloats;

@property (nonatomic,HM_STRONG) HMPhotoCell *currentCell;
@end

@implementation HMUIPhotoWall{
    BOOL            _enableRefresh;
    BOOL            _reloading;
    BOOL            _noMore;
    
    CGFloat         _rankWidth;
    CGFloat         _rankWidthPre;
    
    CGFloat         _rankFullWidth;
    
    CGFloat         _rankBottom[20];
    CGFloat         _rankTop[20];
    
    NSInteger       _numberOfCells;
    
    NSRange         _currentRange;
    NSRange         _lastRange;
    
    BOOL            scrollDown;
    BOOL            _loading;
    UIEdgeInsets    _scrollDefaultInsets;
    CGRect          _accessoryFrame;
    CGSize          _mySize;
}
@synthesize loading=_loading;
@synthesize activity;
@synthesize rankNumber;
@synthesize space=_space;
@synthesize indent=_indent;
@synthesize dataSource=_dataSource;

@synthesize reuseCells;
@synthesize rankMaps;
@synthesize loadedIndexs;
@synthesize preMaps;
@synthesize nextMaps;
@synthesize horizontal;
@synthesize targetloadPoint;
@synthesize targetloadVelocity;
@synthesize floatScreens;
@synthesize currentCell;
@synthesize currentFloats;
@synthesize perRanks;

#pragma mark - 代码开始

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelfDefault];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)dealloc
{
    self.sectionMaps = nil;
    self.dataSource = nil;
    self.reuseCells = nil;
    self.rankMaps = nil;
    self.preMaps = nil;
    self.nextMaps = nil;
    self.loadedIndexs = nil;
    self.activity = nil;
    self.floatScreens = nil;
    self.currentCell = nil;
    self.currentFloats = nil;
    HM_SUPER_DEALLOC();
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    HMPhotoCell *cell=nil;
    if (identifier==nil) {
        return nil;
    }
    NSArray *reuses = [self.reuseCells objectForKey:identifier];
    for (HMPhotoCell *cells in reuses) {
        if (cells.reused) {
            cell = cells;
            break;
        }
    }
    
    return cell;
}

- (void)initSelfDefault{
    self.space = 5;
    self.indent = 5;
    self.reuseCells = [NSMutableDictionary dictionary];
    self.rankMaps = [NSMutableArray array];
    self.loadedIndexs = [NSMutableArray array];
    self.sectionMaps = [NSMutableArray array];
    self.floatScreens = [NSMutableArray array];
    self.currentFloats = [NSMutableArray array];
    _noMore = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initSelfDefault];
    
    if (self.superview&&_dataSource) {
        [self reloadData];
    }
}



- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if (self.superview&&_dataSource&&!CGSizeEqualToSize(_mySize, self.frame.size)) {
        _mySize= self.frame.size;
        [self reloadData];
    }
}


#pragma mark - 位置运算

- (NSArray*)cellsInScreen{
    NSMutableArray *arry = [NSMutableArray arrayWithArray:self.rankMaps];
    
    NSPredicate *pred = self.horizontal?
    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(self.x+self.w >= %.2f && self.x <= %.2f)",self.contentOffset.x,self.contentOffset.x+self.width]]:
    [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(self.y+self.h >= %.2f && self.y <= %.2f)",self.contentOffset.y,self.contentOffset.y+self.height]];
    
    [arry filterUsingPredicate:pred];
    
    NSMutableArray *cells = [NSMutableArray array];
    NSDictionary *maps = [NSDictionary dictionaryWithDictionary:self.reuseCells];
    for (NSString *key in maps.allKeys) {
        NSArray *reuse = [maps objectForKey:key];
        
        for (HMPhotoCell *cell  in reuse) {
            NSDictionary *dicDel = nil;
            if (cell.loaded) {
                BOOL yes = NO;
                for (NSDictionary *dic in arry) {
                    if ([[dic valueForKey:@"index"] integerValue]== cell.index) {
                        [cells addObject:cell];
                        yes = YES;
                        dicDel = dic;
                        break;
                    }
                }
                if (yes) {
                    [arry removeObject:dicDel];
                }
            }
        }
    }
    [cells sortUsingComparator:^NSComparisonResult(HMPhotoCell * obj1, HMPhotoCell * obj2) {
        return obj1.index>obj2.index?NSOrderedDescending:NSOrderedAscending;
    }];
    return cells;
}
/**
 *  获取到屏幕上需要加载的视图
 *
 *  @param offset 视图当前滑动到的偏移
 *
 *  @return 需要加载的位置块
 */
- (NSArray *)firstItemAtOffset:(CGPoint)offset{
    
    NSMutableArray *arry = [NSMutableArray arrayWithArray:self.rankMaps];
    
    NSPredicate *pred = self.horizontal?[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(self.x+self.w >= %.2f && self.x <= %.2f)",offset.x,offset.x+self.frame.size.width]]:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(self.y+self.h >= %.2f && self.y <= %.2f)",offset.y,offset.y+self.frame.size.height]];
    
    [arry filterUsingPredicate:pred];
    
    NSArray * noLoad = nil;
    NSInteger from = 0;
    NSInteger to = _numberOfCells;
    BOOL load = YES;
    
    if (arry.count>0) {
        CGFloat bottom = (self.horizontal?(offset.x+self.frame.size.width):(offset.y+self.frame.size.height));
        CGRect minMax = [self getMinMax:[self.sectionMaps lastObject] pre:nil newline:NO unity:NO maxbottom:0 currentRank:NULL];
        if (bottom>minMax.size.width) {
            load = YES;
        }
    }
    
    
    if ((arry.count==0||noLoad.count>0||load)&&self.rankMaps.count<_numberOfCells) {
        
        CGFloat maxRank=CGFLOAT_MIN;/*contentsize最大值*/
        CGFloat minRank=CGFLOAT_MIN;
        BOOL start = NO;
        
        CGFloat bottom = CGFLOAT_MIN;
        CGFloat top = CGFLOAT_MIN;
        NSSectionPath *path = nil;
        NSSectionPath *prepath = nil;
        
        for (NSInteger c=from; c<to; c++) {
            
            if ([self.loadedIndexs containsObject:@(c)]) {
                NSDictionary *i = [self.rankMaps safeObjectAtIndex:c];
                if (i) {
                    if (self.horizontal?([[i objectForKey:@"x"] floatValue]+(!self.horizontal?path.startOffset:0)>offset.x+self.frame.size.width):([[i objectForKey:@"y"] floatValue]+(self.horizontal?path.startOffset:0)>offset.y+self.frame.size.height)) {
                        break;
                    }
                }
                continue;
            }
            BOOL newPath=NO;
            if (path==nil||path.to<=c) {
                
                prepath = path;
                for (NSInteger i=(prepath==nil?0:[self.sectionMaps indexOfObject:prepath]); i<self.sectionMaps.count; i++) {
                    NSSectionPath* sectionPath = [self.sectionMaps safeObjectAtIndex:i];
                    if (sectionPath.from<=c&&sectionPath.to>c) {
                        path = sectionPath;
                        break;
                    }
                    
                    prepath = sectionPath;
                    
                }
                
            }
            //获取到第c个视图对应的section,得到相对的row
            NSInteger row = c-path.from;
            if (row==0) {
                newPath = YES;
            }
            NSIndexPath *p = [NSIndexPath indexPathForRow:row inSection:path.section];
            //下半部分还没有对 self.horizontal进行处理
            HMPhotoItem *item = [self.dataSource photoWall:self itemAtIndex:p];
            item.indexPath = p;
            NSInteger ranks = path.ranks;
            
            CGFloat rankMax = 0;
            CGFloat rankMin = 0;
            
            
            NSInteger rankOffset = 0;//row%ranks;
            
            //矫正一下
            BOOL newLine = newPath|item.fullScreen;
            CGFloat maxbottom = self.horizontal?(offset.x+self.frame.size.width):(offset.y+self.frame.size.height);
            CGRect currentRank = CGRectMake(row%ranks, 0, 0, 0);
            //先不记录每组的位置，只记录最后一层的位置
            CGRect templMinMax = [self getMinMax:path pre:prepath newline:newPath unity:newLine maxbottom:maxbottom currentRank:&currentRank];
            CGRect minMax = templMinMax;
            if (!self.autoFit) {
                minMax = currentRank;
            }
            rankOffset = newLine?minMax.origin.y:minMax.origin.x;
            
            //根据比例确定cell的位置关系
            NSArray *perrank = [self.perRanks safeObjectAtIndex:p.section];
            BOOL isPercentage = perrank.count==ranks;
            CGFloat indexx = (item.indent==-1?_indent:item.indent);
            CGFloat spacee = (item.space==-1?_space:item.space);
            CGFloat width = self.horizontal?self.frame.size.height:self.frame.size.width;
            CGFloat sizeW = item.fullScreen?(width-indexx*2):(isPercentage?((width-indexx*(ranks+1))*([[perrank safeObjectAtIndex:rankOffset] floatValue])):((width-indexx*(ranks+1))/ranks));
            sizeW = floorf(sizeW);
            
            CGFloat sizeH = ceilf((self.horizontal?(item.imageSize.width * sizeW /item.imageSize.height):(item.imageSize.height * sizeW /item.imageSize.width))-.5);
            
            CGFloat offsetH = sizeH+spacee;
            rankMin = MAX(minMax.size.width, 0)+(item.leading==-1?_space:item.leading);//最小项的跟进项的上边缘位置
            rankMax = rankMin + offsetH;//最小项的跟进项的下边缘位置
            
            maxRank = MAX(rankMax,minMax.size.height);//最大项有没有被刷新纪录
            
            minRank = rankMin;
            
            top = rankMin;
            bottom = rankMax;
            
            if (newPath) {
                path.startOffset = top;
            }
            //枪打出头鸟》》》从这个开始算是visable
            //位于容器的上边缘，看下是不是第一个开始的
            if (!start&&rankMax>=offset.y&&(rankMin<=maxbottom)) {
                start = YES;
            }
            //如果最小项超出了屏幕，就不添加到屏幕上了
            //            if (minRank>=maxbottom) {
            ////                INFO(@(minRank),@">=",@(maxbottom),@"so break",@(c),path);
            //                break;
            //            }
            
            
            if ((templMinMax.size.width>=maxbottom)) {
                break;
            }
            
            if (minRank>=maxbottom) {
                //                INFO(@(minRank),@">=",@(maxbottom),@"so break",@(c),path);
                continue;
            }
            
            //如果列按比例分配，计算出宽度占比
            CGFloat prex = 0;
            if (isPercentage) {
                CGFloat prePercent = 0;
                for (int a = 0; a<rankOffset; a++) {
                    prePercent += [[perrank safeObjectAtIndex:a] floatValue];
                }
                prex = (width-indexx*(ranks+1))*prePercent+rankOffset*indexx;
            }else{
                prex = (sizeW+indexx)*(rankOffset);
            }
            
            CGFloat x = prex+indexx-path.startOffset;
            //            x = (sizeW+indexx)*(rankOffset)+indexx;
            CGRect frame = self.horizontal?CGRectMake(rankMin, x, sizeH, sizeW):CGRectMake(x, rankMin, sizeW, sizeH);
            
            NSDictionary *dic = @{@"index": @(c),@"x":@(frame.origin.x),@"y":@(frame.origin.y),@"w":@(frame.size.width),@"h":@(frame.size.height)};
            
            [self.rankMaps addObject:dic];
            
            if (start) {
                [arry addObject:dic];
            }
            
            if (![self.loadedIndexs containsObject:@(c)]) {
                [self.loadedIndexs addObject:@(c)];
            }
            
            _rankBottom[rankOffset] = bottom;
            _rankTop[rankOffset] = top;
            if (item.fullScreen) {
                for (NSInteger i=0; i<path.ranks; i++) {
                    _rankBottom[i] = bottom;
                }
            }
            
#if (__ON__ == __HM_DEVELOPMENT__)
            CC( @"photoWall",@"%@>>>>%d>>minRank:%.2f maxRank:%.2f height:%.2f bottom:%.2f \n top [0]%.2f [1]%.2f [2]%.2f\n bot [0]%.2f [1]%.2f [2]%.2f\n section:%d rank:%d row:%d startOffset:%.2f",start?@"add":@"hide",c,rankMin,rankMax,sizeH,bottom,_rankTop[0],_rankTop[1],_rankTop[2],_rankBottom[0],_rankBottom[1],_rankBottom[2],p.section,rankOffset,row,path.startOffset);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
            if (self.horizontal) {
                path.sizeHeight = bottom-path.minMax.size.width;
                if (maxRank>self.contentSize.width) {
                    self.contentSize = CGSizeMake(maxRank+self.frame.size.width,self.contentSize.height);
                }
                if (self.rankMaps.count==_numberOfCells) {
                    if (self.contentSize.width>maxRank) {
                        self.contentSize = CGSizeMake(MAX(self.frame.size.width+1, maxRank),self.contentSize.height);
                    }
                }
            }else{
                path.sizeHeight = bottom-path.minMax.size.height;
                if (maxRank>self.contentSize.height) {
                    self.contentSize = CGSizeMake(self.contentSize.width, maxRank+self.frame.size.height);
                }
//                if (c==_numberOfCells-1) {
                 if (self.rankMaps.count==_numberOfCells) {
                    if (self.contentSize.height>maxRank) {
                        self.contentSize = CGSizeMake(self.contentSize.width, MAX(self.frame.size.height+1, maxRank));
                    }
                }
            }
            
        }
    }
    return arry;
}
//取得最后一排的最高空位和最低空位，如果是新行（参考点是上一组） 如果是全屏（参考点是本组）
//返回值 y表示最高的列索引 x表示最低的列索引 height表示y列的bottom值 width表示x列的bottom值
- (CGRect)getMinMax:(NSSectionPath*)item pre:(NSSectionPath*)prepath newline:(BOOL)newline unity:(BOOL)unity maxbottom:(CGFloat)maxbottom currentRank:(CGRect*)current{
    CGFloat maxHight=-1;
    CGFloat minHight=CGFLOAT_MAX-1;
    CGRect minMax = CGRectZero;
    if (item==nil) {
        return CGRectZero;
    }
    if (prepath==nil) {
        prepath = item;
    }
    
    for (NSInteger i=0; i<(newline?prepath.ranks:item.ranks); i++) {
        
        if (maxHight < _rankBottom[i]) {
            maxHight = _rankBottom[i];//层最大高度
            minMax.origin.y = i;//层最大项
        }
        if (minHight > _rankBottom[i]) {
            minHight = _rankBottom[i];//层最小高度
            minMax.origin.x = i;//层最小项
        }
        
    }
    
    
    if (minHight==CGFLOAT_MAX-1) {
        minHight=0;
    }
    
    minMax.size.width = minHight;
    minMax.size.height = maxHight;
    
    if (unity) {
        //        maxbottom=100000;
        for (NSInteger i=0; (i<item.ranks)&&(maxHight<maxbottom); i++) {
            _rankBottom[i] = minMax.size.height;
        }
        
        minMax.origin.x = 0;
        minMax.origin.y = 0;
        minMax.size.width = maxHight;
        minMax.size.height = maxHight;
    }
    
    if (current) {
        NSInteger index = (*current).origin.x;
        (*current).origin.y = index;
        (*current).size.width = _rankBottom[index];
        (*current).size.height = _rankBottom[index];
    }
    
    if (newline&&CGRectEqualToRect(item.minMax, CGRectZero)) {
        item.minMax = minMax;
    }
    //#if (__ON__ == __HM_DEVELOPMENT__)
    //    INFO(@"newline:%d unity:%d min:%.0f-%.1f max:%.0f-%.1f>>%.1f-%.1f",newline,unity,minMax.origin.x,minMax.size.width,minMax.origin.y,minMax.size.height,minHight,maxbottom);
    //#endif
    return minMax;
}

- (void)reloadSubView:(CGPoint)offset{
    
    /**
     *  根据现在的偏移获取需要加载的视图对象
     */
    
    self.nextMaps = [self firstItemAtOffset:offset];
    
    /**
     *  获取可重用的Cell
     */
    NSDictionary *maps = [NSDictionary dictionaryWithDictionary:self.reuseCells];
    NSMutableArray *reuse = [NSMutableArray array];
    for (NSString *key in maps.allKeys) {
        [reuse addObjectsFromArray:[maps objectForKey:key]];
    }
    
    /**
     *  下一屏需要加载的视图的位置信息表
     */
    NSMutableArray *arry = [NSMutableArray array];
    for (NSDictionary *dic in self.nextMaps) {
        [arry addObject:[dic valueForKey:@"index"]];
    }
    /**
     *  按需更新屏幕上的视图
     */
    [self updateViewsIfNeeded:arry reuse:reuse];
    
    /**
     *  调整可漂浮cell的位置
     *  经过滑动后漂浮视图会被复用，导致视图被删除，所以需要考虑复用问题
     */
    [self updateFloatView:offset];
    
}

- (void)updateViewsIfNeeded:(NSMutableArray*)arry reuse:(NSMutableArray*)reuse{
    BOOL suggestToLoad = YES;
    
    /**
     *  剔除已经显示在页面上的视图
     */
    
    NSPredicate *preLoaded = [NSPredicate predicateWithFormat:@"loaded == YES && index IN %@",arry];
    NSArray *loaded = [reuse filteredArrayUsingPredicate:preLoaded];
    
    if (loaded.count) {
        //去掉已经在视图中的部分
        [reuse removeObjectsInArray:loaded];
        for (HMPhotoCell *cell in loaded) {
            [arry removeObject:@(cell.index)];
            
            if (!CGPointEqualToPoint(self.targetloadVelocity, CGPointZero)){
                //判断上下滑动，太快时需要重新初始化cell视图
                //                if (cell.photo.suggestNotLoad&&(self.horizontal?(self.targetloadPoint.x!= offset.x):(self.targetloadPoint.y!= offset.y))) {
                if (cell.photo.suggestNotLoad) {
                    cell.photo.suggestNotLoad = !suggestToLoad;
                    [self.dataSource photoWall:self cellForItem:cell.photo cellReload:cell rect:cell.frame];
                }
            }
            
        }
    }
    
    //#if (__ON__ == __HM_DEVELOPMENT__)
    //    LogTimeCostEndTo(15, 5, @"计算出屏幕上需要添加的视图")
    //#endif
    if (!CGPointEqualToPoint(self.targetloadVelocity, CGPointZero)) suggestToLoad = NO;
    
    
    if (arry.count) {
        preLoaded = [NSPredicate predicateWithFormat:@"SELF.index IN %@",arry];
        loaded = [self.nextMaps filteredArrayUsingPredicate:preLoaded];
        NSMutableArray *needs = [NSMutableArray arrayWithArray:loaded];
        if (needs.count) {
            
            NSSectionPath *path = nil;
            NSSectionPath *prepath = nil;
            for (NSDictionary *dic in needs) {
                
                NSInteger index = [[dic valueForKey:@"index"] integerValue];
                
                
                if (path==nil||path.to<=index) {
                    prepath = path;
                    for (NSInteger i=(prepath==nil?0:[self.sectionMaps indexOfObject:prepath]); i<self.sectionMaps.count; i++) {
                        NSSectionPath* sectionPath = [self.sectionMaps safeObjectAtIndex:i];
                        if (sectionPath.from<=index&&sectionPath.to>index) {
                            path = sectionPath;
                            break;
                        }
                    }
                }
                
                NSIndexPath *p = [NSIndexPath indexPathForRow:index-path.from inSection:path.section];
                
                CGRect frame = CGRectMake([[dic objectForKey:@"x"] floatValue]+(!self.horizontal?path.startOffset:0), [[dic objectForKey:@"y"] floatValue]+(self.horizontal?path.startOffset:0), [[dic objectForKey:@"w"] floatValue], [[dic objectForKey:@"h"] floatValue]);
                
                //下半部分还没有对 self.horizontal进行处理
                HMPhotoItem *item = [self.dataSource photoWall:self itemAtIndex:p];
                //                item.index = index;
                item.indexPath = p;
                
                item.suggestNotLoad = !suggestToLoad;
                
                HMPhotoCell *cell = [self.dataSource photoWall:self cellForItem:item cellReload:nil rect:frame];
                
                cell.frame = frame;
                cell.index = index;
                cell.photo = item;
                cell.dataSource = self;
                cell.reused = NO;
                cell.loaded = YES;
                
                if (cell.superview!=self)
                    [self addSubview:cell];
                
                //判断是否支持漂浮
                if (item.floatScreen) {
                    if (([(HMPhotoCell*)self.floatScreens.lastObject index]<cell.index)||(self.floatScreens.count==0)) {
                        [self.floatScreens addObject:cell];
                    }else{
                        [self.floatScreens insertObject:cell atIndex:0];
                    }
                    
                }
                
                for (HMPhotoCell *cc in self.floatScreens) {
                    [self bringSubviewToFront:cc];
                }
                
                if (cell.reuseId) {
                    NSMutableArray *arry = [self.reuseCells objectForKey:cell.reuseId];
                    if (arry==nil) {
                        arry = [NSMutableArray array];
                        //现在屏幕上需要显示的目标
                        [self.reuseCells setObject:arry forKey:cell.reuseId];
                    }
                    if (![arry containsObject:cell]) {
                        [arry addObject:cell];
                    }
                }
            }
        }
    }else{
        preLoaded = [NSPredicate predicateWithFormat:@"loaded == YES"];
        NSArray *loaded = [reuse filteredArrayUsingPredicate:preLoaded];
        for (HMPhotoCell *cell in loaded) {
            if ([self.floatScreens containsObject:cell]) {
                continue;
            }
            [self resetCell:cell];
        }
    }
}

- (void)updateFloatView:(CGPoint)offset{
    
    if (self.currentCell==nil) {
        self.currentCell = self.floatScreens.firstObject;
    }
    if (self.currentCell) {
        NSDictionary *dic = [self.rankMaps safeObjectAtIndex:self.currentCell.index];
        if (dic) {
            NSSectionPath *path = [self.sectionMaps safeObjectAtIndex:self.currentCell.photo.indexPath.section];
            
            CGRect frame = CGRectMake([[dic objectForKey:@"x"] floatValue]+(!self.horizontal?path.startOffset:0), [[dic objectForKey:@"y"] floatValue]+(self.horizontal?path.startOffset:0), [[dic objectForKey:@"w"] floatValue], [[dic objectForKey:@"h"] floatValue]);
            NSInteger index = [self.floatScreens indexOfObject:self.currentCell];
            HMPhotoCell *nextcell = [self.floatScreens safeObjectAtIndex:index+1];
            CGFloat offf = CGFLOAT_MAX-1;
            if (self.horizontal) {
                if (nextcell) {
                    offf = nextcell.x-frame.size.width;
                }
                
                if (((offset.x<offf)&&(offset.x>frame.origin.x))){
                    self.currentCell.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, offset.x-frame.origin.x,0);
                }else{
                    if (offset.x >= offf) {
                        self.currentCell = nextcell;
                    }else if (offset.x <= frame.origin.x){
                        HMPhotoCell *precell = [self.floatScreens safeObjectAtIndex:index-1];
                        self.currentCell.transform = CGAffineTransformIdentity;
                        if (precell) {
                            self.currentCell = precell;
                        }
                    }
                }
            }else{
                if (nextcell) {
                    offf = nextcell.y-frame.size.height;
                }
                
                if (((offset.y<offf)&&(offset.y>frame.origin.y))){
                    self.currentCell.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, offset.y-frame.origin.y);
                }else{
                    if (offset.y >= offf) {
                        self.currentCell = nextcell;
                    }else if (offset.y <= frame.origin.y){
                        HMPhotoCell *precell = [self.floatScreens safeObjectAtIndex:index-1];
                        self.currentCell.transform = CGAffineTransformIdentity;
                        if (precell) {
                            self.currentCell = precell;
                        }
                    }
                }
            }
        }
    }
}

- (void)resetCell:(HMPhotoCell*)cell{
    cell.index = MAXFLOAT;
    cell.photo = nil;
    [cell removeFromSuperview];
    cell.loaded = NO;
    cell.reused = YES;
}
#warning sectionMaps 移除了组信息，影响了 startOffset的计算
- (NSUInteger)getNumbersOfCells:(NSInteger)from{
    //获取到cell总数
    from = MAX(0, from);
    NSInteger sections = 1;
    if ([self.dataSource respondsToSelector:@selector(photoWallNumberOfSections:)]) {
        sections = [self.dataSource photoWallNumberOfSections:self];
    }
    NSUInteger numberOfCells = 0;
   
    if (from) {
        numberOfCells = [[self.sectionMaps safeObjectAtIndex:from-1] to];
    }
    if ([self.dataSource respondsToSelector:@selector(photoWallRowOfCells:inSection:)]) {
        for (NSInteger i = from ; i<sections; i++) {
            NSUInteger cells = [self.dataSource photoWallRowOfCells:self inSection:i];
            NSInteger ranks = [self.dataSource photoWallNumberOfRanks:self inSection:i];
            NSSectionPath *path = [self.sectionMaps safeObjectAtIndex:i];
            if (path==nil) {
                path = [NSSectionPath sectionPathFrom:numberOfCells length:cells inSection:i ranks:ranks];
                [self.sectionMaps addObject:path];
            }else{
                path.from = numberOfCells;
                path.length = cells;
                path.section = i;
                path.ranks = ranks;
                path.to = path.from+path.length;
            }
            numberOfCells += cells;
        }
    }
    if (self.sectionMaps.count>sections) {
        [self.sectionMaps removeObjectsInRange:NSMakeRange(sections, self.sectionMaps.count-sections)];
    }
    
    return numberOfCells;
}


- (void)calcSubviews:(BOOL)reload{
    if (CGSizeEqualToSize(_mySize, CGSizeZero)) {
        return;
    }
    _reloading = YES;
    self.targetloadVelocity = CGPointZero;
    
    [self removeAllCells];
    
    _numberOfCells = [self getNumbersOfCells:0];
    
    self.contentSize = self.horizontal?CGSizeMake(self.bounds.size.width+1, self.bounds.size.height):CGSizeMake(self.bounds.size.width, self.bounds.size.height+1);
    
    if (_numberOfCells==0) {
        
        return;
    }
    
    memset(_rankTop, 0, sizeof(_rankTop));
    memset(_rankBottom, 0, sizeof(_rankBottom));
    
    _reloading = NO;
    [self reloadSubView:CGPointZero];
    
}

- (void)removeAllCells{
    NSDictionary *maps = [NSDictionary dictionaryWithDictionary:self.reuseCells];
    for (NSString *key in maps) {
        NSArray *reuse = [maps objectForKey:key];
        [reuse makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    self.currentCell = nil;
    self.nextMaps = nil;
    self.preMaps = nil;
    [self.reuseCells removeAllObjects];
    [self.rankMaps removeAllObjects];
    [self.loadedIndexs removeAllObjects];
    [self.sectionMaps removeAllObjects];
    [self.floatScreens removeAllObjects];
}

- (void)appendData{
    if (self.dataSource==nil) {
        return;
    }
    //获取到cell总数
    _numberOfCells = [self getNumbersOfCells:self.sectionMaps.count-1];
    [self reloadSubView:self.contentOffset];
}

- (void)reloadData{
    
    if (self.dataSource==nil) {
        return;
    }
    
    [self calcSubviews:YES];
    
    if (!self.isDecelerating&&!self.isDragging&&!self.isTracking) {
        if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
            [self.delegate scrollViewDidEndDecelerating:self];
        }
    }
}

- (void)reloadDataSection:(NSInteger)section animated:(BOOL)animated{
    NSSectionPath *path = [self.sectionMaps safeObjectAtIndex:section];
    if (path) {
        //去掉需要重新加载的数据
        if (self.rankMaps.count>=path.from) {
            [self.rankMaps removeObjectsInRange:NSMakeRange(path.from, self.rankMaps.count-path.from)];
        }
//        if (self.loadedIndexs.count>=path.from) {
//            [self.loadedIndexs removeObjectsInRange:NSMakeRange(path.from, self.loadedIndexs.count-path.from)];
//        }
        for (NSInteger a=path.from; a<path.to; a++) {
            [self.loadedIndexs removeObject:@(a)];
        }
        //清除漂浮层
        NSMutableArray *floatScreen = [NSMutableArray arrayWithArray:self.floatScreens];
        for (HMPhotoCell *cell in floatScreen) {
            if (cell.index>=path.from) {
                [self.floatScreens removeObject:cell];
            }
        }
        self.currentCell = nil;
        
        //去掉重用的cell
        NSDictionary *maps = [NSDictionary dictionaryWithDictionary:self.reuseCells];
        for (NSString *key in maps.allKeys) {
            for (HMPhotoCell *cell in [maps objectForKey:key]) {
                if ([cell isKindOfClass:[HMPhotoCell class]]) {
                    if (cell.photo.indexPath.section>=section) {
                        [self resetCell:cell];
                    }
                }
            }
        }
        
        //重置计算高度
        NSSectionPath *prePath = [self.sectionMaps safeObjectAtIndex:section-1];
        for (NSInteger i=0; i<20; i++) {
            _rankBottom[i] = prePath.minMax.size.height+prePath.sizeHeight;
        }
        
        [self.sectionMaps removeObjectsInRange:NSMakeRange(section, self.sectionMaps.count-section)];
        //获取到cell总数
        _numberOfCells = [self getNumbersOfCells:section];
        if (self.horizontal) {
            CGFloat height = MAX(prePath.minMax.size.width+prePath.sizeHeight, self.frame.size.width+1);
            self.contentSize = CGSizeMake(height,self.contentSize.height);
            [self reloadSubView:self.contentOffset];
            if (self.contentOffset.x>0) {
                [self setContentOffset:CGPointMake(MAX(prePath.minMax.size.width+prePath.sizeHeight-self.frame.size.width-1, 0),self.contentOffset.y) animated:YES];
            }
        }else{
            CGFloat height = MAX(prePath.minMax.size.height+prePath.sizeHeight, self.frame.size.height+1);
            self.contentSize = CGSizeMake(self.contentSize.width, height);
            [self reloadSubView:self.contentOffset];
            if (self.contentOffset.y>0) {
                [self setContentOffset:CGPointMake(self.contentOffset.x, MAX(prePath.minMax.size.height+prePath.sizeHeight-self.frame.size.height-1, 0)) animated:YES];
            }
        }
        
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 */
#pragma mark - 交互处理

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self reloadSubView:scrollView.contentOffset];
    self.targetloadVelocity = CGPointZero;
    self.targetloadPoint = CGPointZero;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    CGPoint point = *targetContentOffset;
    self.targetloadVelocity = velocity;
    self.targetloadPoint = point;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        NSValue *value = [change objectForKey:@"new"];
        CGPoint contentOffset = CGPointZero;
        [value getValue:&contentOffset];
        NSValue *valueold = [change objectForKey:@"old"];
        CGPoint contentOffsetold = CGPointZero;
        [valueold getValue:&contentOffsetold];
        
        if (_dataSource&&!_reloading) {
            if (self.horizontal?(contentOffsetold.x!=contentOffset.x):(contentOffsetold.y!=contentOffset.y)){
                
                for (NSString *key in [(UIView*)object layer].animationKeys) {
                    CAAnimation *animation = [[(UIView*)object layer] animationForKey:key];
                    if (animation) {
                        return;
                    }
                }
                
                [self reloadSubView:contentOffset];
            }
        }
    }
}

- (void)setDataSource:(id)dataSource{
    if (_dataSource!=dataSource&&_dataSource!=nil) {
        [self removeObserver:self forKeyPath:@"contentOffset" context:self];
    }
    _dataSource = dataSource;
    if (dataSource) {
        
        if (![self.dataSource respondsToSelector:@selector(photoWall:itemAtIndex:)]) {
            NSAssert(NO, @"photoWall:itemAtIndex:  no responds");
        }
        if (![self.dataSource respondsToSelector:@selector(photoWall:cellForItem:cellReload:rect:)]) {
            NSAssert(NO, @"photoWall:cellForItem:cellReload:frame:  no responds");
        }
        
        if (![self.dataSource respondsToSelector:@selector(photoWallNumberOfRanks:inSection:)]) {
            NSAssert(NO, @"photoWallNumberOfRanks:  no responds");
        }
        if (![self.dataSource respondsToSelector:@selector(photoWallRowOfCells:inSection:)]) {
            NSAssert(NO, @"photoWall:rowOfCells:  no responds");
        }
        
        [self calcSubviews:YES];
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:self];
    }
}

- (void)photoCellTouchIn:(HMPhotoCell *)cell{
    
    if ([self.dataSource respondsToSelector:@selector(photoWall:touchInCell:atIndexPath:)]) {
        [self.dataSource photoWall:self touchInCell:cell atIndexPath:cell.photo.indexPath];
    }
}

@end
