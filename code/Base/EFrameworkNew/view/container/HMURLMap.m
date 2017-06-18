//
//  HMURLMap.m
//  GPSService
//
//  Created by Eric on 14-4-3.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMURLMap.h"
#import "HMFoundation.h"
#import "HMViewCategory.h"

@interface HMURLMAPItem ()

@end

@implementation HMURLMAPItem{
    CGRect finalRect;
    CGRect initalRect;
}
DEF_INT( TYPE_UNKNOWN,	0 )	// unknown
DEF_INT( TYPE_CLASS,		1 )	// class
DEF_INT( TYPE_BOARD,		2 )	// view controller
DEF_INT( TYPE_NAVBOARD,		3 )	// view controller with a navigation
DEF_INT( TYPE_VIEW,		4 )	// view controller
DEF_INT( TYPE_WINDOW,		5 )	// view controller
DEF_INT( TYPE_EXTERNAL,		6 )	// External Open
DEF_INT( TYPE_WEB,		7 )	// Web View

@synthesize rule = _rule;
@synthesize bindto = _bindto;
@synthesize type = _type;
@synthesize url = _url;
@synthesize board = _board;
@synthesize option;
@synthesize duration;
@synthesize navigateMode;
@synthesize animaterFront;
@synthesize animaterBack;
@synthesize backing;
@synthesize fullScreen;
@synthesize backBoard;

- (id)init
{
    self = [super init];
    if (self) {
        self.type = self.TYPE_UNKNOWN;
        fullScreen=YES;
        
        self.option = UIViewAnimationOptionCurveEaseIn;
        self.duration = .35f;
    }
    return self;
}

- (void)dealloc
{
    self.animaterFront = nil;
    self.animaterBack = nil;
    self.rule = nil;
    self.url = nil;
    self.board = nil;
    self.bindto = nil;
    self.backBoard = nil;
    HM_SUPER_DEALLOC();
}

+ (HMURLMAPItem*)setupWith:(NSString*)url{
    return [HMURLMAPItem setupWith:url toMap:nil];
}

+ (HMURLMAPItem*)setupWith:(NSString*)url toMap:(HMURLMAPItem *)map{
    
    NSURL *URL = [NSURL URLWithString:url];
    if (URL==nil) {
        map = [HMURLMap objectForMap:url];
        if (map==nil) {
            return nil;
        }
    }
    if (map==nil) {
        map = [[[HMURLMAPItem alloc]init]autorelease];
        map.url = url;
    }
    if (map.board) {
        return map;
    }
    NSString *scheme = URL.scheme;
    NSString *host = URL.host;
    NSArray *items = [host componentsSeparatedByString:@"."];
    NSString *clazzName = nil;
    
    if ([scheme isEqualToString:@"cc"]) {
        //cc://(HMUIStack.)HMUIBoard(.xib)
        
        BOOL hasStack = NO;
        if ([host rangeOfString:@"HMUIStack"].location != NSNotFound) {
            hasStack = YES;
            clazzName = [items safeObjectAtIndex:1];
        }else{
            clazzName = [items safeObjectAtIndex:0];
        }
        Class clazz = NSClassFromString( clazzName );
        
        if (clazz&&[clazz isSubclassOfClass:[UIViewController class]]) {
            
            SEL clazzSel = NULL;
            if ([host rangeOfString:@"xib"].location != NSNotFound) {
                clazzSel = NSSelectorFromString(@"boardFromXib");
            }else{
                clazzSel = NSSelectorFromString(@"board");
            }
            
            Method method = class_getClassMethod(clazz, clazzSel);
            //                id viewC = method_invoke(clazz, method);
            id (*typed_invoke)(id, Method) = (void *)method_invoke;
            id viewC = typed_invoke(clazz, method);
            
            if (hasStack) {
                map.board = ([host rangeOfString:@"HMUIStackCustom"].location != NSNotFound)?[[[HMUIStack alloc] initCustomBarWithRootViewController:viewC] autorelease]:[[[HMUIStack alloc]initWithRootViewController:viewC]autorelease];
                map.type = HMURLMAPItem.TYPE_NAVBOARD;
            }else{
                map.board = viewC;
                map.type = HMURLMAPItem.TYPE_BOARD;
            }
            
        }
        
        
    }else if ([scheme isEqualToString:@"storyboard"]){
        //storyboard://name(.identifier)
        NSString *identifier = nil;
        NSString *stackname = nil;
        BOOL hasStack = NO;
        if (items.count>0) {
            clazzName = [items firstObject];
            stackname = clazzName;
            if (items.count>1) {
                
                if ([clazzName rangeOfString:@"HMUIStack"].location != NSNotFound) {
                    hasStack = YES;
                    
                    clazzName = [items safeObjectAtIndex:1];
                    identifier = [items safeObjectAtIndex:2];
                }else{
                    identifier = [items safeObjectAtIndex:1];
                }
            }
        }
        UIViewController *vc = [UIStoryboard boardWithName:identifier inStory:clazzName];
        if (hasStack) {
            vc = ([stackname rangeOfString:@"HMUIStackCustom"].location != NSNotFound)?[[[HMUIStack alloc] initCustomBarWithRootViewController:vc] autorelease]:[[[HMUIStack alloc]initWithRootViewController:vc]autorelease];
        }
        map.board = vc;
        
        if ([map.board isKindOfClass:[UINavigationController class]]) {
            map.type = HMURLMAPItem.TYPE_NAVBOARD;
        }else {
            map.type = HMURLMAPItem.TYPE_BOARD;
        }
        
    }else if ([scheme isEqualToString:@"vv"]){
        //vv://class(.xib)#
        if (items.count>0) {
            clazzName = [items firstObject];
        }
        Class clazz = NSClassFromString( clazzName );
        
        if (clazz&&[clazz isSubclassOfClass:[UIViewController class]]) {
            
            SEL clazzSel = NULL;
            if ([host rangeOfString:@"xib"].location != NSNotFound) {
                clazzSel = NSSelectorFromString(@"viewFromXib");
            }else{
                clazzSel = NSSelectorFromString(@"spawn");
            }
            
            Method method = class_getClassMethod(clazz, clazzSel);
            //                self.board = method_invoke(clazz, method);
            id (*typed_invoke)(id, Method) = (void *)method_invoke;
            map.board = typed_invoke(clazz, method);
            
            if ([map.board isKindOfClass:[UIWindow class]]) {
                map.type = HMURLMAPItem.TYPE_WINDOW;
            }else {
                map.type = HMURLMAPItem.TYPE_VIEW;
            }
        }
        
    }
    
    if (map.board==nil) {
        map.type = HMURLMAPItem.TYPE_UNKNOWN;
    }
    
    if ([map isExternalURL:URL]){

        map.type = HMURLMAPItem.TYPE_EXTERNAL;
        return map;

    }else if ([map isWebURL:URL]){
        
        map.type = HMURLMAPItem.TYPE_WEB;
        return map;
        
    }
    
    return map;
}

- (BOOL)buildStack
{
    if ( nil == self.board )
    {
        [HMURLMAPItem setupWith:self.url toMap:self];
        
    }else if (self.type==self.TYPE_CLASS){
        
        if ([self.board isKindOfClass:[UINavigationController class]]) {
            self.type = self.TYPE_NAVBOARD;
        }else if ([self.board isKindOfClass:[UIViewController class]]){
            self.type = self.TYPE_BOARD;
        }else if ([self.board isKindOfClass:[UIWindow class]]){
            self.type = self.TYPE_WINDOW;
        }else if ([self.board isKindOfClass:[UIView class]]){
            self.type = self.TYPE_VIEW;
        }else{
            self.type = self.TYPE_UNKNOWN;
        }
    }
    
    return self.type != self.TYPE_UNKNOWN;
}

static NSMutableDictionary *_schemes=nil;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWebURL:(NSURL*)URL {
    return [URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"ftp"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"ftps"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"data"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"file"] == NSOrderedSame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isExternalURL:(NSURL*)URL {
    if ([URL.host isEqualToString:@"maps.google.com"]
        || [URL.host isEqualToString:@"itunes.apple.com"]
        || [URL.host isEqualToString:@"phobos.apple.com"]
        || [URL.scheme isEqualToString:@"telprompt"]) {
        return YES;
        
    } else {
        return NO;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isSchemeSupported:(NSString*)scheme {
    return nil != scheme && !![_schemes objectForKey:scheme];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isAppURL:(NSURL*)URL {
    return [self isExternalURL:URL]
    || ([[UIApplication sharedApplication] canOpenURL:URL]
        && ![self isSchemeSupported:URL.scheme]
        && ![self isWebURL:URL]);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"url=%@ rule=%@ board=%@ bindto %@ type=%ld", self.url,self.rule,self.board,self.bindto,(long)self.type];
}

#pragma mark - for transition

- (void)finishInteractiveTransition{
    
}

- (BOOL)isAnimated{
    return YES;
}



- (void)completeTransition:(BOOL)didComplete{
    
    self.backBoard = nil;
}

- (BOOL)isInteractive{
    return YES;
}

- (BOOL)transitionWasCancelled{
    return NO;
}

- (void)cancelInteractiveTransition{
    
}


- (void)updateInteractiveTransition:(CGFloat)percentComplete{
    
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc{
    if (CGRectEqualToRect(finalRect, CGRectZero)) {
        finalRect = vc.view.frame;
    }
    return finalRect;
}

- (CGRect)initialFrameForViewController:(UIViewController *)vc{
    if (CGRectEqualToRect(initalRect, CGRectZero)) {
        initalRect = vc.view.frame;
    }
    return initalRect;
}

- (UIViewController *)viewControllerForKey:(NSString *)key{
    if ([key isEqualToString:UITransitionContextFromViewControllerKey]) {
        UIViewController *boardd = nil;
        if (self.backing) {
            boardd = self.board;
        }else{
            boardd = self.backBoard;
        }
        if (CGRectEqualToRect(initalRect, CGRectZero)) {
            initalRect = boardd.view.frame;
        }
        return boardd;
    }
    if ([key isEqualToString:UITransitionContextToViewControllerKey]) {
        UIViewController *boardd = nil;
        if (self.backing) {
            boardd = self.backBoard;
        }else{
            boardd = self.board;
        }
        if (CGRectEqualToRect(finalRect, CGRectZero)) {
            finalRect = boardd.view.frame;
        }
        return boardd;
    }
    return self.board;
}

- (UIView *)viewForKey:(NSString *)key{
    UIViewController *vcontrol = [self viewControllerForKey:key];
    return vcontrol.view;
}

//前置的页面
- (UIView *)containerView{
    
    UIViewController *boardd = nil;
    if (self.backing) {
        boardd = self.backBoard;
    }else{
        boardd = self.board;
    }
    
    return boardd.view.superview;
}

- (UIModalPresentationStyle)presentationStyle{
    return UIModalPresentationNone;
}


@end

@interface HMURLMap (){
    NSMutableDictionary *	_mapping;
    NSMutableArray *	_mappingOrder;
}

@property (nonatomic, HM_STRONG) NSMutableDictionary *	mapping;
@property (nonatomic, HM_STRONG) NSMutableArray *	mappingOrder;
@end

@implementation HMURLMap
DEF_SINGLETON(HMURLMap)
@synthesize mapping=_mapping;
@synthesize mappingOrder = _mappingOrder;

- (id)init
{
    self = [super init];
    if (self) {
        _mapping  = [[NSMutableDictionary alloc]init];
        _mappingOrder = [[NSMutableArray alloc]init];
    }
    return self;
}
- (void)dealloc
{
    [_mapping removeAllObjects];
    [_mapping release];
    [_mappingOrder removeAllObjects];
    [_mappingOrder release];
    HM_SUPER_DEALLOC();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * What's a scheme?
 * It's a specific URL that is registered with the URL map.
 * Example:
 *  @"cc://some/path"
 *
 * This method registers them.
 *
 * @private
 */
+ (void)registerScheme:(NSString*)scheme {
    if (nil != scheme) {
        if (nil == _schemes) {
            _schemes = [[NSMutableDictionary alloc] init];
        }
        [_schemes setObject:[NSNull null] forKey:scheme];
    }
}

- (HMURLMAPItem*)map:(NSString *)map bindto:(NSString*)to URL:(NSString *)url mode:(HMNavigationMode)mode board:(id)boardOrView{
    
    //    NSParameterAssert(map&&url);
    if (map==nil) {
        return nil;
    }
    
    HMURLMAPItem *item = [_mapping objectForKey:map];
    if (item&&![item.url isEqualToString:url]) {
        item = nil;
    }
    if (item==nil) {
        item = [[[HMURLMAPItem alloc]init]autorelease];
        item.rule = map;
        item.bindto = to;
        item.url = url;
        item.board = boardOrView;
        item.navigateMode = mode;
        item.type = [HMURLMAPItem TYPE_CLASS];
        [_mapping setObject:item forKey:map];
    }
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }
    if(window.rootViewController==nil){
        [item buildStack];
        
        if ([item.board isKindOfClass:[UIViewController class]]){
            window.rootViewController = item.board;

//            if ([item.board isKindOfClass:[UINavigationController class]]) {
//                [HMUIApplication sharedInstance].window.rootViewController = item.board;
//            }else{
//                [HMUIApplication sharedInstance].window.rootViewController = [[[HMUIStack alloc]initWithRootViewController:item.board]autorelease];
//            }
            
        }
        
    }
    return item;
}
- (HMURLMAPItem*)map:(NSString *)map bindto:(NSString*)to URL:(NSString *)url{
    return [self map:map bindto:to URL:url mode:HMNavigationModeCreate board:nil];
}
- (HMURLMAPItem*)map:(NSString *)map boardOrView:(id)boardOrView{
    return [self map:map bindto:nil URL:nil mode:HMNavigationModeCreate board:boardOrView];
}
- (HMURLMAPItem*)mapGround:(NSString *)map URL:(NSString *)url{
    return [self map:map bindto:nil URL:url mode:HMNavigationModeGround board:nil];
}

- (HMURLMAPItem*)map:(NSString *)map URL:(NSString *)url{
    return [self map:map bindto:nil URL:url mode:HMNavigationModeCreate board:nil];
}

+ (HMURLMAPItem*)map:(NSString *)map bindto:(NSString*)to URL:(NSString *)url{
    return [[HMURLMap sharedInstance] map:map bindto:to URL:url mode:HMNavigationModeCreate board:nil];
}
+ (HMURLMAPItem*)map:(NSString *)map boardOrView:(id)boardOrView{
    return [[HMURLMap sharedInstance] map:map bindto:nil URL:nil mode:HMNavigationModeCreate board:boardOrView];
}
+ (HMURLMAPItem*)mapGround:(NSString *)map URL:(NSString *)url{
    return [[HMURLMap sharedInstance] map:map bindto:nil URL:url mode:HMNavigationModeGround board:nil];
}

+ (HMURLMAPItem*)map:(NSString *)map URL:(NSString *)url{
    return [[HMURLMap sharedInstance] map:map bindto:nil URL:url mode:HMNavigationModeCreate board:nil];
}

+ (NSArray *)allMapItem{
    return [HMURLMap sharedInstance].mapping.allValues;
}

+ (void)removeMap:(NSString *)map{
    return[[HMURLMap sharedInstance] removeMap:map];
}
- (void)removeMap:(NSString *)map{
    if (map==nil) {
        return;
    }
    
    HMURLMAPItem *item = [_mapping objectForKey:map];
    [self removeItem:item];
}

- (void)removeItem:(HMURLMAPItem *)mapItem{
    if (mapItem.rule==nil) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"UIBoard",@"close failed,mapItem is nil");
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        return;
    }
    HMURLMAPItem *item = mapItem;
    if (item!=nil) {
        
        if (item.board) {
            if ([item.board isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)item.board popToRootViewControllerAnimated:NO];
            }
            if([item.board.parentViewController respondsToSelector:NSSelectorFromString(@"setPreviousC:")]){
                [item.board.parentViewController setValue:nil forKey:@"previousC"];
                if ([item.board.parentViewController valueForKey:@"currentC"]==item.board) {
                    [item.board.parentViewController setValue:nil forKey:@"currentC"];
                }
            }
            [item.board.view removeFromSuperview];
            [item.board removeFromParentViewController];
#if (__ON__ == __HM_DEVELOPMENT__)
            CC( @"UIBoard",@"close %@ now has %@",item.rule,item.board.parentViewController.childViewControllers);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        }
        item.board = nil;
        
        item.type = [HMURLMAPItem TYPE_CLASS];
    }
}

+ (id)boardForMap:(NSString*)map{
    return [[HMURLMap sharedInstance] boardForMap:map];
}
- (id)boardForMap:(NSString*)map{
    HMURLMAPItem *item = [_mapping objectForKey:map];
    if (item!=nil) {
        [item buildStack];
        return item.board;
    }
    return nil;
}

+ (id)boardForTopMap:(NSString *)map{
    UIViewController *vc = [[HMURLMap sharedInstance] boardForMap:map];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController*)vc topViewController];
    }
    return vc;
}

+ (id)boardForFirstMap:(NSString *)map{
    UIViewController *vc = [[HMURLMap sharedInstance] boardForMap:map];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [[(UINavigationController*)vc viewControllers] firstObject];
    }
    return vc;
}

+ (id)objectForMap:(NSString*)map{
    return [[HMURLMap sharedInstance]objectForMap:map];
}
- (id)objectForMap:(NSString*)map{
    
    if (map==nil) {
        return nil;
    }
    HMURLMAPItem *item = [_mapping objectForKey:map];
    
    return item;
}
+ (id)objectForBoard:(id)__board{
    return [[HMURLMap sharedInstance] objectForBoard:__board];
}
- (id)objectForBoard:(id)__board{
    
    if (__board==nil) {
        return nil;
    }
    for (NSString *key in [_mapping allKeys]) {
        HMURLMAPItem *item = [_mapping objectForKey:key];
        if (item!=nil) {
            
            if (item.board == __board)
            {
                return item;
            }
            else if ([item.board isKindOfClass:[UINavigationController class]])
            {
                UINavigationController* navC = (UINavigationController*)item.board;
                
                if (navC.viewControllers.firstObject == __board) {
                    return item;
                }
                
            }
        }
        
    }
    return nil;
}


@end


#pragma mark - categray
@implementation UIView (HMURLMap)
@dynamic urlMap;

static int __urlMapKEY;
-  (NSString *)urlMap
{
    return objc_getAssociatedObject( self, &__urlMapKEY );
}

- (void)setUrlMap:(NSString *)urlMap
{
    objc_setAssociatedObject( self, &__urlMapKEY, urlMap, OBJC_ASSOCIATION_COPY_NONATOMIC );
}


@end

@implementation UINavigationController (HMURLMap)

- (void)setViewVisable:(BOOL)viewVisable{
    [super setViewVisable:viewVisable];
    NSArray *all = self.viewControllers;
    for (UIViewController*vv in all) {
        vv.viewVisable = NO;
    }
    [self.topViewController setViewVisable:viewVisable];
}

static UIViewController * (*__popViewControllerAnimated)( id, SEL ,BOOL);
static NSArray * (*__popToRootViewControllerAnimated)( id, SEL ,BOOL);
static NSArray * (*__popToViewControlleranimated)( id, SEL ,UIViewController *,BOOL);
static void (*__setViewControllersanimated)( id, SEL ,NSArray *,BOOL);
static void (*__pushViewControlleranimated)( id, SEL ,UIViewController *,BOOL);

+ (void)hook
{
    static BOOL __swizzled = NO;
    if ( NO == __swizzled )
    {
        __popViewControllerAnimated = (void*)[UINavigationController swizzleSelector:@selector(popViewControllerAnimated:) withIMP:@selector(mypopViewControllerAnimated:)];
        
        __popToRootViewControllerAnimated = (void*)[UINavigationController swizzleSelector:@selector(popToRootViewControllerAnimated:) withIMP:@selector(mypopToRootViewControllerAnimated:)];
        
        __popToViewControlleranimated = (void*)[UINavigationController swizzleSelector:@selector(popToViewController:animated:) withIMP:@selector(mypopToViewController:animated:)];
        
        __setViewControllersanimated = (void*)[UINavigationController swizzleSelector:@selector(setViewControllers:animated:) withIMP:@selector(mysetViewControllers:animated:)];
        
         __pushViewControlleranimated = (void*)[UINavigationController swizzleSelector:@selector(pushViewController:animated:) withIMP:@selector(mypushViewController:animated:)];
        
        __swizzled = YES;
    }
}

- (void)mypushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (__pushViewControlleranimated) {
        __pushViewControlleranimated(self,_cmd,viewController,animated);
        self.viewVisable = YES;
        
    }
}

- (nullable UIViewController *)mypopViewControllerAnimated:(BOOL)animated{
    UIViewController *arr = nil;
    if (__popToRootViewControllerAnimated) {
        arr = __popViewControllerAnimated(self,_cmd,animated);
        arr.viewVisable = NO;
        self.viewVisable = YES;
    }
    return arr;
}
- ( NSArray *)mypopToRootViewControllerAnimated:(BOOL)animated{
    NSArray *arr = nil;
    if (__popToRootViewControllerAnimated) {
        arr = __popToRootViewControllerAnimated(self,_cmd,animated);

        self.viewVisable = YES;
    }
    return arr;
}

- ( NSArray *)mypopToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSArray *arr = nil;
    if (__popToViewControlleranimated) {
        arr = __popToViewControlleranimated(self,_cmd,viewController,animated);

        self.viewVisable = YES;
        
    }
    return arr;
}

- (void)mysetViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    
    if (__setViewControllersanimated) {
        __setViewControllersanimated(self,_cmd,viewControllers,animated);
        self.viewVisable = YES;
        
    }
}
@end

@implementation UIViewController (HMURLMap)

@dynamic stack;
@dynamic parentBoard;
@dynamic urlMap;
@dynamic openDate;
@dynamic includesOpaque;
@dynamic nickname;
@dynamic viewVisable;



static void (*__presentViewControlleranimatedcompletion)( id, SEL ,UIViewController *,BOOL,void (^ __nullable)(void));
static void (*__dismissViewControllerAnimatedcompletion)( id, SEL ,BOOL,void (^ __nullable)(void));
static void (*__viewDidLoad)(id, SEL);
static UINavigationController* (*__navigationController)(id, SEL);

+ (void)hook
{
    static BOOL __swizzled = NO;
    if ( NO == __swizzled )
    {
        __presentViewControlleranimatedcompletion = (void*)[UIViewController swizzleSelector:@selector(presentViewController:animated:completion:) withIMP:@selector(mypresentViewController:animated:completion:)];
        
        __dismissViewControllerAnimatedcompletion = (void*)[UIViewController swizzleSelector:@selector(dismissViewControllerAnimated:completion:) withIMP:@selector(mydismissViewControllerAnimated:completion:)];
        
         __viewDidLoad = (void*)[UIViewController swizzleSelector:@selector(viewDidLoad) withIMP:@selector(myviewDidLoad)];
        
        __navigationController = (void*)[UIViewController swizzleSelector:@selector(navigationController) withIMP:@selector(mynavigationController)];
        
        __swizzled = YES;
    }
}
- (void)myviewDidLoad{
    if (__viewDidLoad) {
        __viewDidLoad(self,_cmd);
    }
    self.viewIsLoaded = YES;
}

- (void)mypresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0)
{
    if (__presentViewControlleranimatedcompletion) {
        viewControllerToPresent.viewVisable = YES;
        __presentViewControlleranimatedcompletion(self,_cmd,viewControllerToPresent,flag,completion);
        self.viewVisable = NO;
        
        
    }
}
- (void)mydismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0){
    if (__dismissViewControllerAnimatedcompletion) {
        [UIApplication sharedApplication].keyWindow.rootViewController.viewVisable = YES;
        
        __dismissViewControllerAnimatedcompletion(self,_cmd,flag,completion);
        self.viewVisable = YES;
        
    }
}

- (HMUIStack *)stack
{
    HMUIStack *ss = nil;
    if ([self isKindOfClass:[HMUIStack class]]) {
        ss =  (HMUIStack*)self;
    }else  if ( self.navigationController && [self.navigationController isKindOfClass:[HMUIStack class]] ){
        ss = (HMUIStack *)self.navigationController;
    }else if ([self isKindOfClass:[UINavigationController class]]) {
        ss = (HMUIStack*)self;
    }
    
    return ss;
}
- (UINavigationController *)mynavigationController{
    UINavigationController *controller = nil;
    if (__navigationController) {
       controller = __navigationController(self,_cmd);
    }
    if (controller.topViewController!=self&&[controller.topViewController conformsToProtocol:@protocol(HMBaseNavigatorDelegate)]){
        controller = nil;
    }
    return controller;
}

static int __parentBoardKEY;
-  (HMUIBoard *)parentBoard
{
    return objc_getAssociatedObject( self, &__parentBoardKEY );
}

- (void)setParentBoard:(HMUIBoard *)parentBoard
{
    objc_setAssociatedObject( self, &__parentBoardKEY, parentBoard, OBJC_ASSOCIATION_ASSIGN );
}

static int __includesOpaqueKEY;
- (BOOL)includesOpaque
{
    return [objc_getAssociatedObject( self, &__includesOpaqueKEY ) boolValue];
}

- (void)setIncludesOpaque:(BOOL)includesOpaque
{
    objc_setAssociatedObject( self, &__includesOpaqueKEY, @(includesOpaque), OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

static int __viewVisableKEY;
- (BOOL)viewVisable
{
    return [objc_getAssociatedObject( self, &__viewVisableKEY ) boolValue];
}

- (void)setViewVisable:(BOOL)viewVisable
{
    objc_setAssociatedObject( self, &__viewVisableKEY, @(viewVisable), OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    NSArray *all = self.childViewControllers;
    for (UIViewController*vv in all) {
        if (vv.viewIsLoaded&&vv.view.hidden) {
            vv.viewVisable = NO;
        }else{
            [vv setViewVisable:viewVisable];
        }
    }
    
    
}

static int __viewIsLoadedKEY;
- (BOOL)viewIsLoaded
{
    return [objc_getAssociatedObject( self, &__viewIsLoadedKEY ) boolValue];
}

- (void)setViewIsLoaded:(BOOL)viewIsLoaded
{
    objc_setAssociatedObject( self, &__viewIsLoadedKEY, @(viewIsLoaded), OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    
}

static int __openDateKEY;
-  (NSDate *)openDate
{
    return objc_getAssociatedObject( self, &__openDateKEY );
}

- (void)setOpenDate:(NSDate *)openDate
{
    objc_setAssociatedObject( self, &__openDateKEY, openDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)nextViewController {
    NSArray* viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        NSUInteger controllerIndex = [viewControllers indexOfObject:self];
        if (controllerIndex != NSNotFound && controllerIndex+1 < viewControllers.count) {
            return [viewControllers objectAtIndex:controllerIndex+1];
        }
    }
    return nil;
}

static int __urlMapKEY;
-  (NSString *)urlMap
{
    return objc_getAssociatedObject( self, &__urlMapKEY );
}

- (void)setUrlMap:(NSString *)urlMap
{
    objc_setAssociatedObject( self, &__urlMapKEY, urlMap, OBJC_ASSOCIATION_COPY_NONATOMIC );
}

static int __nicknameKEY;
-  (NSString *)nickname
{
    return objc_getAssociatedObject( self, &__nicknameKEY );
}

- (void)setNickname:(NSString *)nickname
{
    objc_setAssociatedObject( self, &__nicknameKEY, nickname, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

- (BOOL)isTopViewControler{
    if (self.navigationController) {
        return (self.navigationController.topViewController == self)?YES:NO;
    }
    return NO;
}

+ (instancetype)boardFromXib{
    return [[[self alloc]initWithNibName:[[self class] description] bundle:nil] autorelease];
}
+ (instancetype)board{
    return [[[self alloc]init] autorelease];
}

- (void)unload{
    
}

- (void)load{
    
}
/**
 *  查找最顶层uiviewcontroller
 *
 *  @param item            需要切换的对象
 *  @param controller
 *  @param childController
 *
 *  @return HMBaseNavigator or HMUIStack
 */
- (id<HMBaseNavigatorDelegate>)containerWith:(HMURLMAPItem *)item
                               getController:(UIViewController**)controller
                                    getChild:(UIViewController**)childController
{
    id<HMBaseNavigatorDelegate> container = nil;
    /**
     *  查询路由器
     */
    for (HMURLMAPItem *binded = [HMURLMap objectForMap:item.bindto];
         binded;
         binded = [HMURLMap objectForMap:binded.bindto]) {
        
        *controller = binded.board;
        
        if ([*controller conformsToProtocol:@protocol(HMBaseNavigatorDelegate)]) {
            container = (id<HMBaseNavigatorDelegate>)*controller;
            if ([container isKindOfClass:[UINavigationController class]]){
                //如果切换的对象本事是 stack 直接跳过，启用push
                UIViewController *vc = [[(UINavigationController*)container viewControllers] firstObject];
                if ([item.board isKindOfClass:[UINavigationController class]]&&![vc conformsToProtocol:@protocol(HMBaseNavigatorDelegate)]) {
                    container = nil;
                    continue;
                }else{
                    
                    if ([vc conformsToProtocol:@protocol(HMBaseNavigatorDelegate)]) {
                        container = (id)vc;
                    }else{
                        
                        continue;
                    }
                }
            }
        }
        break;
    }
    *childController = *controller;
    
    if (container==nil) {
        for (UIView *view = [*controller view]; view; view = view.superview) {
            if ([view.viewController conformsToProtocol:@protocol(HMBaseNavigatorDelegate)]) {
                container = (id<HMBaseNavigatorDelegate>)view.viewController;
                if ([container isKindOfClass:[UINavigationController class]]&&[item.board isKindOfClass:[UINavigationController class]]) {
                    container = nil;
                    continue;
                }
                break;
            }
            *childController = *controller;
        }
    }
    return container;
}

- (UIViewController*)viewControllerBefore:(UIViewController *)pre after:(UIViewController *)after{
    return  [self viewControllerBefore:pre after:after lastOne:NO];
}

- (UIViewController*)viewControllerLastOne{
    return  [self viewControllerBefore:nil after:nil lastOne:YES];
}

- (UIViewController*)viewControllerBefore:(UIViewController *)pre after:(UIViewController *)after lastOne:(BOOL)lastOne{
    
    NSArray* viewControllers = self.childViewControllers;
    
    viewControllers = [viewControllers sortedArrayUsingComparator:^NSComparisonResult(UIViewController * obj1, UIViewController * obj2) {
        return [obj1.openDate compare:obj2.openDate];
    }];
    if (lastOne) {
        return [viewControllers lastObject];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"openDate != %@",[NSDate dateWithTimeIntervalSince1970:0]];
    viewControllers = [viewControllers filteredArrayUsingPredicate:predicate];
    
    if (viewControllers.count==0) {
        return nil;
    }
    
    
    
    if (after) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"openDate > %@",after.openDate];
        viewControllers = [viewControllers filteredArrayUsingPredicate:predicate];
        if (pre==nil) {
            return [viewControllers firstObject];
        }
    }
    if (pre) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"openDate < %@",pre.openDate];
        viewControllers = [viewControllers filteredArrayUsingPredicate:predicate];
    }
    
    return [viewControllers lastObject];
    
}

- (UIViewController*)open:(NSString *)map close:(NSString *)close animate:(BOOL)animate{
    return [self open:map closes:[close notEmpty]?@[close]:nil animate:animate];
    
}
- (UIViewController*)open:(NSString *)map closes:(NSArray *)closes animate:(BOOL)animate{
    return [self open:map closes:closes animate:animate complete:nil];
}
- (UIViewController*)open:(NSString *)map closes:(NSArray *)closes animate:(BOOL)animate complete:(void (^)(BOOL, UIViewController *))commple{
    return [self open:map name:nil animate:animate complete:^(BOOL viewLoaded, UIViewController* toBoard) {
        if (commple) {
            commple(viewLoaded,toBoard);
        }
        if (closes&&viewLoaded) {
            
            for (NSString *close in closes) {
                if ([map isEqualToString:close]) {
                    continue;
                }
                [[HMURLMap sharedInstance] removeMap:close];
            }
            
        }
    }];
    
}
- (UIViewController *)opento:(NSString *)map animate:(BOOL)animate{
    return [self opento:map animate:animate complete:nil];
}
- (UIViewController *)opento:(NSString *)map animate:(BOOL)animate complete:(void (^)(BOOL, UIViewController *))commple{
    NSArray* viewControllers = [(UIViewController*)[HMURLMap boardForMap:@"*"] childViewControllers];
    NSMutableArray *arry = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        if ([map isEqual:vc.nickname]) {
            break;
        }
        
        if ([vc.nickname notEmpty]) {
            [arry addObject:vc.nickname];
        }
        
    }
    return [self open:map closes:arry animate:animate complete:commple];
}

- (UIViewController*)open:(NSString *)map animate:(BOOL)animate{
    return [self open:map name:nil  animate:animate mapItem:nil complete:nil];
}

- (UIViewController *)open:(NSString *)map name:(NSString *)name animate:(BOOL)animate{
    return [self open:map name:name  animate:animate mapItem:nil complete:nil];
}

- (UIViewController*)open:(NSString *)map name:(NSString *)name animate:(BOOL)animate complete:(void (^)(BOOL,UIViewController*))commple{
    return [self open:map name:name animate:animate mapItem:nil complete:commple];
}

- (UIViewController*)open:(NSString *)map name:(NSString *)name animate:(BOOL)animate mapItem:(void (^)(HMURLMAPItem *mapItem))mapItem{
    return [self open:map name:name animate:animate mapItem:mapItem complete:nil];
}

- (UIViewController*)open:(NSString *)map name:(NSString *)name animate:(BOOL)animate mapItem:(void (^)(HMURLMAPItem *mapItem))mapItem complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple{
    NSParameterAssert(map);
    if (map==nil) {
        return nil;
    }
    id<HMBaseNavigatorDelegate>  container = nil;
    UIViewController*             controller = self;      // The iterator.
    UIViewController*             childController = nil; // The last iterated controller.
    if (name==nil) {
        name = map;
        
    }
    //查找目标的map对象
    HMURLMAPItem *item = [[HMURLMap sharedInstance] objectForMap:name];
    if (item==nil) {
        item = [HMURLMap map:name bindto:@"*" URL:map];
        if (item==nil) {
            return nil;
        }
    }
    //map对象 的初始化，产生 新的board 如果需要的话
    if (![item buildStack]){
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"BUILD",@"error",item.rule,item.url);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        return nil;
    }
    if (item.type == [HMURLMAPItem TYPE_EXTERNAL]||item.type == [HMURLMAPItem TYPE_WEB]) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:item.url]];
         return nil;
    }
    
    if ([item.board respondsToSelector:@selector(setNickname:)]) {
        [item.board setValue:item.rule forKey:@"nickname"];
        if ([[item.board myTopBoard] respondsToSelector:@selector(setNickname:)]) {
            [[item.board myTopBoard] setValue:item.rule forKey:@"nickname"];
        }
    }
    
    if (mapItem) {
        mapItem(item);
    }
    
    //如果当前C带有stack，且目标是一个board，而board又没有绑定
    if ((item.type == [HMURLMAPItem TYPE_BOARD])&&self.stack&&item.bindto==nil&&item.board.stack==nil) {
        [self.stack addSubcontroller:item animated:animate complete:commple];
        return item.board;
    }
    //其他都是通过 addsubview的方式切换
    
    //查找目标的bindto是否存在，要与 self的bindto进行比较
    container = [self containerWith:item getController:&controller getChild:&childController];
    
    if ([container isKindOfClass:[UIViewController class]]) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"OPEN",item.rule);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        item.backing = NO;
        [container addSubcontroller:item animated:animate complete:commple];
    }else{
        HMUIBoard *mainBoard =  [HMURLMap boardForMap:@"*"];
        if (mainBoard==nil) {
            if ([item.board isKindOfClass:[UINavigationController class]]||(self.stack==nil)) {
                [self presentViewController:item.board animated:animate completion:nil];
            }else{
                [self pushToPath:map map:name animated:animate];
            }
            return item.board;
        }
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"OPEN",@"fail for %@",item.rule);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    }
    return item.board;
    
}

- (void)close:(NSString *)close{

    [[HMURLMap sharedInstance] removeMap:close];
}

- (void)closeAll{
    NSArray *all = [HMURLMap allMapItem];
    for (HMURLMAPItem *item in all) {
        [[HMURLMap sharedInstance] removeItem:item];
    }
}

- (void)backToRootWithAnimate:(BOOL)animate{
    if (self.stack&&self.stack.viewControllers.count>1) {
        [self.stack popToRootViewControllerAnimated:animate];
    }
}
- (void)backToPreMapClose:(BOOL)close animate:(BOOL)animate{
    HMBaseNavigator *bn = (id)[[HMURLMap boardForMap:@"*"] myFirstBoard];
    if ([bn isKindOfClass:[HMBaseNavigator class]]) {
        [self backToMap:bn.previousMap close:(close?bn.currentMap:nil) animate:animate];
    }
    
}

- (void)backToMainWithAnimate:(BOOL)animate{
    if (self.stack&&self.stack.viewControllers.count>1) {
        [self.stack popToRootViewControllerAnimated:NO];
    }
}

- (void)backToMap:(NSString *)map animate:(BOOL)animate{
    [self backToMap:map close:nil animate:animate];
}
- (void)backToMap:(NSString *)map close:(NSString *)close animate:(BOOL)animate{
    [self backToMap:map close:close animate:animate complete:nil];
}
- (void)backToMap:(NSString *)map close:(NSString *)close animate:(BOOL)animate complete:(void (^)(BOOL, UIViewController *))commple{
    if (self.stack) {
        for (UIViewController *vc in self.stack.viewControllers) {
            if ([vc.nickname is:map]) {
                [self.stack popToViewController:vc animated:animate];
                if (commple) {
                    commple(NO,vc);
                }
                return;
            }
        }
    }
    [self open:map close:close animate:animate];
}
- (void)backWithAnimate:(BOOL)animate remove:(BOOL)remove{
    [self backWithAnimate:animate remove:remove complete:nil];
}

- (void)backWithAnimate:(BOOL)animate remove:(BOOL)remove complete:(void (^)(BOOL, UIViewController *))commple{
    HMURLMAPItem *item = [[HMURLMap sharedInstance] objectForBoard:self];
    [[HMUIKeyboard sharedInstance] hideKeyboard];
    HMUIBoard *mainBoard =  [HMURLMap boardForMap:@"*"];
    
    if (item==nil||mainBoard==nil) {
        if (self.stack&&self.stack.viewControllers.count>1) {
            UIViewController *vc = [self.stack popViewControllerAnimated:animate];
            if (commple) {
                commple(NO, vc);
            }
        }else{
            if (commple) {
                commple(NO, self.presentingViewController);
            }
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        
        if (remove) {
            if (animate) {
                [[HMURLMap sharedInstance] performSelector:@selector(removeMap:) withObject:item.rule afterDelay:item.duration];
            }else{
                [[HMURLMap sharedInstance] removeMap:item.rule];
            }
            
        }
        return;
    }
    
    [self operationMapItem:item animate:(BOOL)animate complete:^(BOOL viewLoaded, UIViewController* toBoard) {
        if (commple) {
            commple(viewLoaded,toBoard);
        }
        if (!viewLoaded) {
            return ;
        }
        if (!remove) {
            return;
        }
        [[HMURLMap sharedInstance] removeMap:item.rule];
    }];
    

}
- (void)backAndRemoveWithAnimate:(BOOL)animate{
    
    [self backWithAnimate:animate remove:YES];
}


- (void)backWithAnimate:(BOOL)animate{
    
    [self backWithAnimate:animate remove:NO];
}

- (void)operationMapItem:(HMURLMAPItem*)item animate:(BOOL)animate complete:(void (^)(BOOL,UIViewController*))commple{
    
    id<HMBaseNavigatorDelegate>  container = nil;
    UIViewController*             controller = self;      // The iterator.
    UIViewController*             childController = nil; // The last iterated controller.
    
    //查找目标的bindto是否存在，要与 self的bindto进行比较
    container = [self containerWith:item getController:&controller getChild:&childController];
    
    item.backing = YES;
    if ([container isKindOfClass:[UIViewController class]]) {
        [container addSubcontroller:item animated:animate complete:commple];
    }
    
}

#pragma mark - push and put

- (HMUIBoard*)bulidViewControllerUrl:(id)path map:(NSString*)map getChild:(BOOL)getchild{
    UIViewController *controller = nil;
    if (map==nil) {
        map = path;
    }
    if ([path isKindOfClass:[UIViewController class]]){
        controller = path;
        ((UIViewController*)path).nickname = map==nil?[path description]:map;
    }else if ([path isKindOfClass:[NSString class]]&&[path notEmpty]) {
        //支持URL格式切换
        if (getchild) {
            controller = [self getChild:map];
        }
        if (controller==nil) {
            if ([path contains:@"://"]||[path rangeOfString:@"."].location==NSNotFound) {
                HMURLMAPItem *item = [HMURLMap objectForMap:map];
                if (item==nil) {
                    item = [HMURLMAPItem setupWith:path];
                }else{
                    [HMURLMAPItem setupWith:path toMap:item];
                }
                item.rule = map;
                if (item.board==nil) {

                    controller = nil;
                }else{
                    controller = item.board;
                }
            }else{
                //支持非URL格式切换，Main
                NSArray *class = [path componentsSeparatedByString:@"."];
                NSString *identifier = nil;
                BOOL hasStack = NO;
                NSString* clazzName = nil;
                if (class.count>0) {
                    identifier = [class firstObject];
                    if (class.count>1) {
                        clazzName = [class safeObjectAtIndex:1];
                        if ([clazzName rangeOfString:@"HMUIStack"].location != NSNotFound) {
                            hasStack = YES;
                            clazzName = [class safeObjectAtIndex:2];
                        }
                    }
                    UIViewController *vc = [UIStoryboard boardWithName:clazzName inStory:identifier];
                    if (hasStack) {
                        vc = ([clazzName rangeOfString:@"HMUIStackCustom"].location != NSNotFound)?[[[HMUIStack alloc] initCustomBarWithRootViewController:vc] autorelease]:[[[HMUIStack alloc]initWithRootViewController:vc]autorelease];
                    }
                    controller = vc;
                    
                }
            }
        }
        controller.nickname = map;
    }
    return (id)controller;
}

- (UIViewController*)pushToPath:(id)path animated:(BOOL)animated{
    return  [self pushToPath:path map:nil animated:animated];
}
- (UIViewController *)pushToPath:(id)path map:(NSString *)map animated:(BOOL)animated{
    return [self pushToPath:path map:map animated:animated complete:nil];
}
- (UIViewController*)pushToPath:(id)path map:(NSString*)map animated:(BOOL)animated complete:(void (^)(BOOL, UIViewController *))commple{
    
    
    UIViewController *controller = [self bulidViewControllerUrl:path map:map getChild:NO];
    
    if (controller==nil) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"PUSH",@"%@  %@",path,@"error");
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        return nil;
    }

    if (self.stack==nil||(self.stack!=nil&&[controller isKindOfClass:[UINavigationController class]])) {
//        [self presentViewController:controller animated:animated completion:nil];
        if (controller==path) {
            [HMURLMap map:controller.nickname boardOrView:controller];
        }else{
            [HMURLMap map:controller.nickname URL:path].board = controller;
        }
        
        [self open:path name:controller.nickname animate:YES mapItem:^(HMURLMAPItem *mapItem) {
            mapItem.option = UIViewAnimationOptionTransitionFromBottom;
        } complete:commple];
        
    }else{
        NSArray *all = self.stack.viewControllers;
        for (UIViewController *vv in all) {
            vv.viewVisable = NO;
        }
        controller.viewVisable = YES;
        if (commple) {
            commple(NO,controller);
        }
        
        [self.stack pushViewController:controller animated:animated];
        if (commple) {
            if (animated) {
                [self delay:.35f invoke:^{
                    
                    commple(YES,controller);
                }];
            }else{
                commple(YES,controller);
            }
            
        }
    }
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"PUSH",@"%@  %@",path,controller);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    return controller;
}

- (UIViewController*)presentToPath:(id)path map:(NSString*)map animated:(BOOL)animated{
    return [self presentToPath:path map:map animated:animated complete:nil];
}
- (UIViewController *)presentToPath:(id)path map:(NSString *)map animated:(BOOL)animated complete:(void (^)(BOOL, UIViewController *))commple{
    
    
    UIViewController *controller = [self bulidViewControllerUrl:path map:map getChild:NO];
    
    if (controller==nil) {
#if (__ON__ == __HM_DEVELOPMENT__)
        CC( @"PRESENT",@"%@  %@",path,@"error");
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
        return nil;
    }
    if (commple) {
        commple(NO,controller);
    }
    [self presentViewController:controller animated:animated completion:^{
        if (commple) {
            commple(YES,controller);
        }
    }];
    
    return controller;
}

- (HMUIBoard*)getChild:(NSString*)name{
    NSString *map = nil;
    if ([name isKindOfClass:[UIViewController class]]){
        map = [name description];
    }else{
        map = name;
    }
    for (HMUIBoard* item in self.childViewControllers) {
        if ([item.nickname isEqualToString:map]) {
            return item;
        }
    }
    return nil;
}

- (UIViewController*)myTopBoard{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController*)self topViewController];
    }
    return self;
}

- (UIViewController*)myFirstBoard{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [[(UINavigationController*)self viewControllers] firstObject];
    }
    return self;
}

- (HMUIBoard *)putChild:(id)path isNew:(BOOL*)isnew{
    return [self putChild:path map:nil isNew:isnew close:nil];
}
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew{
    return [self putChild:path map:map isNew:isnew close:nil];
}

- (HMUIBoard *)putChild:(id)path isNew:(BOOL*)isnew closePre:(BOOL)preClose{
    return [self putChild:path map:nil isNew:isnew closePre:preClose];
}
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew closePre:(BOOL)preClose{
    return [self putChild:path map:map isNew:isnew closePre:preClose complete:nil];
}
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew closePre:(BOOL)preClose complete:(void (^)(BOOL, UIViewController *))commple{
    return [self putChild:path map:map isNew:isnew close:preClose?[[self viewControllerLastOne] nickname]:nil complete:commple];
}

- (HMUIBoard *)putChild:(id)path isNew:(BOOL*)isnew close:(id)closepath{
    return [self putChild:path map:nil isNew:isnew close:closepath];
}
- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew close:(id)closepath{
    return [self putChild:path map:map isNew:isnew closePre:closepath complete:nil];
}

- (HMUIBoard *)putChild:(id)path map:(NSString*)map isNew:(BOOL*)isnew close:(id)closepath complete:(void (^)(BOOL, UIViewController *))commple{
    
    if (map==nil) {
        map = path;
    }
    
    HMUIBoard *target = [self bulidViewControllerUrl:path map:map getChild:YES];
    
    if (target) {
        if (commple) {
            commple(NO,target);
        }
        NSArray *all = self.childViewControllers;
        for (UIViewController *vv in all) {
            vv.viewVisable = NO;
        }
        target.viewVisable = YES;
        
        if (target.view.superview == nil) {
            [self.view addSubview:target.view];
            [self addChildViewController:target];
            target.view.frame = self.view.bounds;
        
            if (isnew) {
                *isnew = YES;
            }
            
        }
        HMUIBoard *from = (id)[self viewControllerLastOne];
        if (from!=target) {
            [from viewWillDisappear:NO];
            [from viewDidDisappear:NO];
            from.view.hidden = YES;
        }
        target.view.hidden = NO;
        [self.view bringSubviewToFront:target.view];
        
        if (isnew==NULL||*isnew==NO) {
            [target viewWillAppear:NO];
            [target viewDidAppear:NO];
        }
        if (commple) {
            commple(YES,target);
        }
    }
    if (closepath) {
        HMUIBoard *closetarget = nil;
        
        closetarget = [self getChild:closepath];
        if (target!=closetarget) {
            [closetarget.view removeFromSuperview];
            [closetarget removeFromParentViewController];

        }
    }
    target.openDate  =[NSDate date];
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( @"PUT",@"%@  %@",path,target?target:@"error");
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
    return target;
}




@end

