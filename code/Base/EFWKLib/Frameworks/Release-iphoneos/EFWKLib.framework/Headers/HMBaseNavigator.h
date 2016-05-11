//
//  HMBaseNavigator.h
//  GPSService
//
//  Created by Eric on 14-4-3.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIBoard.h"
#import "HMURLMap.h"


@protocol HMBaseNavigatorDelegate <NSObject>

- (UIViewController*)previousViewController;

- (void)addSubcontroller:(HMURLMAPItem *)controller animated:(BOOL)animated complete:(void (^)(BOOL viewLoaded, UIViewController* toBoard))commple;
@optional
- (UIViewController*)visableViewController;

@end

/**
 *  视图转场路由导航控制器中心,配合HMURLMap使用,支持open、push、child方式进行视图转场
 */
@interface HMBaseNavigator : HMUIBoard <HMBaseNavigatorDelegate>

AS_SINGLETON(HMBaseNavigator)

@property (nonatomic, HM_STRONG) HMURLMap *map;

+ (HMURLMap*)map;
- (NSString *)currentMap;
- (NSString *)previousMap;
@end

@interface UINavigationController (HMBaseNavigatorDelegate) <HMBaseNavigatorDelegate>
//@property (nonatomic, copy) NSString *				name;

@end