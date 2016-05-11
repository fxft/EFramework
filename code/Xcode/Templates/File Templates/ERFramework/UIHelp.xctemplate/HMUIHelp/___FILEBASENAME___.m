//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___.h"


@interface ___FILEBASENAMEASIDENTIFIER___ ()
@property (nonatomic,HM_STRONG) UIScrollView *scroll;
@property (nonatomic,HM_STRONG) NSMutableArray *array;
@property (nonatomic,HM_STRONG) NSMutableArray *pageSubviews;
@property (nonatomic,HM_STRONG) UIPageControl *pageControl;
@end

@implementation ___FILEBASENAMEASIDENTIFIER___{
    int curentPage;
}


- (void)dealloc
{
    self.pageControl = nil;
    self.array = nil;
    self.scroll = nil;
    self.pageSubviews = nil;
    HM_SUPER_DEALLOC();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initDatas];
    
    [self initSubviews];
}

- (void)initDatas{
    self.array = [NSMutableArray array];
    NSDictionary *page = nil;
    /**
     NSNumber *top = [frame objectForKey:@"top"];
     NSNumber *bottom = [frame objectForKey:@"bottom"];
     NSNumber *left = [frame objectForKey:@"left"];
     NSNumber *right = [frame objectForKey:@"right"];
     NSNumber *centerX = [frame objectForKey:@"centerX"];
     NSNumber *centerY = [frame objectForKey:@"centerY"];
     NSNumber *width = [frame objectForKey:@"width"];
     NSNumber *height = [frame objectForKey:@"height"];
     */
    CGFloat space = 20;
    //    page = @{@"back":@"",@"members":@[
    //                     @{@"name":@"boy",
    //                       @"type":@"UIButten",
    //                       @"image":@"boy.png",
    //                       @"frame":
    //                           @{@"centerX":@(0),
    //                             @"centerY":@(-55-space-20),
    //                             @"width":@(109),
    //                             @"height":@(109)}},
    //                     @{@"name":@"boy",
    //                       @"type":@"UILabel",
    //                       @"title":@"我是男的",
    //                       @"font":[UIFont systemFontOfSize:16],
    //                       @"color":[UIColor md_brown_300],
    //                       @"frame":
    //                           @{@"centerX":@(0),
    //                             @"centerY":@(-space-5),}},
    //                     @{@"name":@"girl",
    //                       @"type":@"UIButten",
    //                       @"image":@"girl.png",
    //                       @"frame":
    //                           @{@"centerX":@(0),
    //                             @"centerY":@(55+space),
    //                             @"width":@(109),
    //                             @"height":@(109)}},
    //                     @{@"name":@"boy",
    //                       @"type":@"UILabel",
    //                       @"title":@"我是女的",
    //                       @"font":[UIFont systemFontOfSize:16],
    //                       @"color":[UIColor md_red_300],
    //                       @"frame":
    //                           @{@"centerX":@(0),
    //                             @"centerY":@(space+109+15),}},
    //                     ]};
    //
    //    [self.array addObject:page];
    //
    page = @{@"back":@"",@"members":@[
                     @{@"name":@"simpelified",
                       @"type":@"UIButten",
                       @"image":@"jianti.png",
                       @"frame":
                           @{@"centerX":@(0),
                             @"centerY":@(-55-space-20),
                             @"width":@(109),
                             @"height":@(109)}},
                     @{@"name":@"boy",
                       @"type":@"UILabel",
                       @"title":@"我用简体",
                       @"font":[UIFont systemFontOfSize:16],
                       @"color":[UIColor md_brown_300],
                       @"frame":
                           @{@"centerX":@(0),
                             @"centerY":@(-space-5),}},
                     @{@"name":@"traditional",
                       @"type":@"UIButten",
                       @"image":@"fanti.png",
                       @"frame":
                           @{@"centerX":@(0),
                             @"centerY":@(55+space),
                             @"width":@(109),
                             @"height":@(109)}},
                     @{@"name":@"boy",
                       @"type":@"UILabel",
                       @"title":@"我用繁體",
                       @"font":[UIFont systemFontOfSize:16],
                       @"color":[UIColor md_red_300],
                       @"frame":
                           @{@"centerX":@(0),
                             @"centerY":@(space+109+15),}},
                     ]};
    [self.array addObject:page];
    
    page = @{@"back":@"",@"members":@[
                     @{@"name":@"",
                       @"type":@"UIImageView",
                       
#ifndef EbookOnline
                       @"image":@"helpIcon.png",
                       @"frame":
                           @{@"centerX":@(0),
                             @"centerY":@(0),
                             @"width":@(240),
                             @"height":@(240)}},
#else
                     @"image":@"Icon@1024HelpIconItaotao.png",
                     @"frame":
                     @{@"centerX":@(0),
                       @"centerY":@(0),
                       @"width":@(240),
                       @"height":@(240)}},
#endif
                     
                     
                     @{@"name":@"rightBtn",
                       @"type":@"UIButten",
                       @"backImage":@"btn.png",
                       @"title":TXT(@"开始阅读"),
                       @"frame":
                           @{@"centerX":@(0),
                             @"bottom":@(-55),
                             @"width":@(200),
                             @"height":@(44)}},
                     ]};
    [self.array addObject:page];
    
}

- (void)initSubviews{
    
    self.scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    //    self.scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scroll];
    self.scroll.pagingEnabled = YES;
    self.scroll.delegate = self;
    self.scroll.bounces = NO;
    self.scroll.showsVerticalScrollIndicator = NO;
    self.scroll.showsHorizontalScrollIndicator = NO;
    
    [self.scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
    }];
    
    if (self.array.count>1) {
        self.pageControl = [UIPageControl spawn];
        
        [self.view addSubview:self.pageControl];
        self.pageControl.currentPageIndicatorTintColor = [UIColor md_brown_100];
        [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.height.offset(30);
            make.left.mas_equalTo(self.view.mas_left).offset(0);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-5);
            make.right.mas_equalTo(self.view.mas_right).offset(0);
        }];
        self.pageControl.numberOfPages = self.array.count;
        self.pageControl.currentPage = 0;
    }
    self.pageSubviews = [NSMutableArray array];
    for (NSInteger i=0;i<self.array.count;i++) {
        NSMutableArray *subviews = [NSMutableArray array];
        [self.pageSubviews addObject:subviews];
    }
    [self initization];
}

- (void)viewDidAppear:(BOOL)animated{
    self.scroll.contentSize = CGSizeMake(self.scroll.width*self.array.count, self.scroll.height);
}

- (void)initization{
    UIView *lastPage = nil;
    for (int i = 0;i<self.array.count;i++) {
        NSDictionary* item = [self.array objectAtIndex:i];
        
        UIView *page = [UIView spawn];
        page.backgroundColor = [UIColor clearColor];
        [self.scroll addSubview:page];
        //        page.frame = CGRectMake(i*self.scroll.width, 0, self.scroll.w, self.scroll.height);
        [page mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.scroll.mas_top).offset(0);
            if (!lastPage) {
                make.left.mas_equalTo(self.scroll.mas_left).offset(0);
            }else{
                make.left.mas_equalTo(lastPage.mas_right).offset(0);
            }
            
            make.width.mas_equalTo(self.view.mas_width);
            make.height.mas_equalTo(self.view.mas_height);
        }];
        lastPage = page;
        NSString *path = [item valueForKey:@"back"];
        path = [[NSBundle mainBundle] pathForResource:path ofType:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            UIImageView *imagev = [UIImageView spawn];
            imagev.image = [UIImage imageWithContentsOfFile:path];
            imagev.translatesAutoresizingMaskIntoConstraints = NO;
            [page addSubview:imagev];
            [imagev mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(page.mas_top).offset(0);
                make.left.mas_equalTo(page.mas_left).offset(0);
                make.bottom.mas_equalTo(page.mas_bottom).offset(0);
                make.right.mas_equalTo(page.mas_right).offset(0);
            }];
        }
        
        NSArray *members = [item objectForKey:@"members"];
        for (int j =0; j< members.count; j++) {
            NSDictionary *member = [members objectAtIndex:j];
            NSString *type = [member valueForKey:@"type"];
            NSString *image = [member valueForKey:@"image"];
            NSString *backImage = [member valueForKey:@"backImage"];
            NSString *title = [member valueForKey:@"title"];
            NSString *name = [member valueForKey:@"name"];
            
            //for label
            UIColor *color = [member valueForKey:@"color"];
            UIFont *font = [member valueForKey:@"font"];
            
            UIView *target = nil;
            
            if ([type is:@"UIButten"]) {
                UIButten *btn = [UIButten spawn];
                [page addSubview:btn];
                if ([image notEmpty]) {
                    [btn setImagePrefixName:image title:title];
                }
                if ([backImage notEmpty]) {
                    [btn setBackgroundImagePrefixName:backImage title:title];
                }
                
                btn.tagString = name;
                
                target = btn;
                
            }else if ([type is:@"UIImageView"]){
                
                UIImageView *img = [UIImageView spawn];
                [page addSubview:img];
                img.image = [image notEmpty]?[UIImage imageNamed:image]:nil;
                target = img;
            }else if ([type is:@"UILabel"]){
                
                UILabel *lbl = [UILabel spawn];
                [page addSubview:lbl];
                lbl.text = title;
                if (color) {
                    lbl.textColor = color;
                }
                if (font) {
                    lbl.font = font;
                }
                target = lbl;
            }
            
            NSDictionary *frame = [member valueForKey:@"frame"];
            if (frame) {
                NSNumber *top = [frame objectForKey:@"top"];
                NSNumber *bottom = [frame objectForKey:@"bottom"];
                NSNumber *left = [frame objectForKey:@"left"];
                NSNumber *right = [frame objectForKey:@"right"];
                NSNumber *centerX = [frame objectForKey:@"centerX"];
                NSNumber *centerY = [frame objectForKey:@"centerY"];
                NSNumber *width = [frame objectForKey:@"width"];
                NSNumber *height = [frame objectForKey:@"height"];
                
                [target mas_makeConstraints:^(MASConstraintMaker *make) {
                    if (top) {
                        make.top.mas_equalTo(page.mas_top).offset([top floatValue]);
                    }
                    if (bottom) {
                        make.bottom.mas_equalTo(page.mas_bottom).offset([bottom floatValue]);
                    }
                    if (left) {
                        make.left.mas_equalTo(page.mas_left).offset([left floatValue]);
                    }
                    if (right) {
                        make.right.mas_equalTo(page.mas_right).offset([right floatValue]);
                    }
                    if (centerX) {
                        make.centerX.mas_equalTo(page.mas_centerX).offset([centerX floatValue]);
                    }
                    if (centerY) {
                        make.centerY.mas_equalTo(page.mas_centerY).offset([centerY floatValue]);
                    }
                    if (width) {
                        make.width.mas_equalTo([width floatValue]);
                    }
                    if (height) {
                        make.height.mas_equalTo([height floatValue]);
                    }
                }];
            }
            
            NSMutableArray *subViews = [self.pageSubviews safeObjectAtIndex:i];
            [subViews addObject:target];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    curentPage = (int)(scrollView.contentOffset.x/scrollView.size.width);
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    self.pageControl.currentPage = (int)(scrollView.contentOffset.x/scrollView.size.width);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.pageControl.currentPage = (int)(scrollView.contentOffset.x/scrollView.size.width);
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
            
            NSString *sex = [self userDefaultsRead:@"sex__"];
            NSString *localizable = [self userDefaultsRead:@"localizable__"];
            //            if (![sex notEmpty]) {
            //                [self showMessageTip:@"" detail:TXT(@"请选择一下性别") timeOut:1.f];
            //                return;
            //            }
            if (![localizable notEmpty]) {
                [self showMessageTip:@"" detail:TXT(@"请选择一下语言") timeOut:1.f];
                return;
            }
            [UMExt event:@"sex" attributes:@{@"sex":sex}];
            [UMExt event:@"localizable" attributes:@{@"localizable":localizable}];
            [self open:self.openUrl close:self.nickname animate:YES];
            [HMApp updateNewInstall];
            
        }else if ([btn is:@"boy"]){
            btn.selected = YES;
            UIButten* preButton = [self currentSubViewWithTagstring:@"girl"];
            preButton.selected = NO;
            [self userDefaultsWrite:@"boy" forKey:@"sex__"];
            [self.scroll setContentOffset:CGPointMake(self.scroll.width, 0) animated:YES];
        }else if ([btn is:@"girl"]){
            btn.selected = YES;
            UIButten* preButton = [self currentSubViewWithTagstring:@"boy"];
            preButton.selected = NO;
            [self userDefaultsWrite:@"girl" forKey:@"sex__"];
            [self.scroll setContentOffset:CGPointMake(self.scroll.width, 0) animated:YES];
        }else if ([btn is:@"traditional"]){
            btn.selected = YES;
            UIButten* preButton = [self currentSubViewWithTagstring:@"simpelified"];
            preButton.selected = NO;
            preButton = [self  actionbtn];
            [self userDefaultsWrite:@"zh-Hant" forKey:@"localizable__"];
            [HMUIConfig sharedInstance].localizable  = @"zh-Hant";
            [preButton setTitle:TXT(@"开始阅读") forState:UIControlStateNormal];
            [self.scroll setContentOffset:CGPointMake(self.scroll.width*(self.array.count-1), 0) animated:YES];
        }else if ([btn is:@"simpelified"]){
            btn.selected = YES;
            UIButten* preButton = [self currentSubViewWithTagstring:@"traditional"];
            preButton.selected = NO;
            preButton = [self  actionbtn];
            [self userDefaultsWrite:@"zh-Hans" forKey:@"localizable__"];
            [HMUIConfig sharedInstance].localizable  = @"zh-Hans";
            [preButton setTitle:TXT(@"开始阅读") forState:UIControlStateNormal];
            [self.scroll setContentOffset:CGPointMake(self.scroll.width*(self.array.count-1), 0) animated:YES];
        }
    }
}

- (id)currentSubViewWithTagstring:(NSString*)tagstring{
    NSMutableArray *subViews = [self.pageSubviews safeObjectAtIndex:curentPage];
    for (UIView *vv in subViews) {
        if ([vv.tagString isEqual:tagstring]) {
            return vv;
        }
    }
    return nil;
}

- (UIButten*)actionbtn{
    NSMutableArray *subViews = [self.pageSubviews lastObject];
    for (UIButten *vv in subViews) {
        if ([vv.tagString isEqual:@"rightBtn"]) {
            return vv;
        }
    }
    return nil;
}

@end
