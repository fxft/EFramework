//
//  HMPhotoCell.h
//  EFExtend
//
//  Created by mac on 15/4/5.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMPhotoItem : NSObject
@property (nonatomic, assign) NSInteger         tag;
@property (nonatomic, assign) CGSize            imageSize;//整框的大小，不是image的大小
@property (nonatomic, assign) CGSize            trueSize;//整框的大小，不是image的大小
@property (nonatomic, HM_STRONG) NSString *     webUrl;
@property (nonatomic, HM_STRONG) NSString *     localUrl;

/*for photoWallBorad*/
@property (nonatomic, HM_STRONG) UIImage *image; // 完整的图片

@property (nonatomic, HM_STRONG) UIImageView *srcImageView; // 来源view
@property (nonatomic, HM_STRONG) UIImage *placeholder;
@property (nonatomic, HM_STRONG) UIImage *captureImage;
@property (nonatomic, assign) BOOL         suggestNotLoad;

//for HMUIPhotoWall
@property (nonatomic, assign) BOOL         fullScreen;
@property (nonatomic, HM_STRONG) NSIndexPath *  indexPath;
@property (nonatomic, assign) CGFloat         indent;//不需要配置时请设置为－1
@property (nonatomic, assign) CGFloat         space;//不需要配置时请设置为－1
@property (nonatomic, assign) CGFloat         leading;//不需要配置时请设置为-1

@property (nonatomic, assign) BOOL         floatScreen;//是否漂浮

// 是否已经保存到相册
@property (nonatomic, assign) BOOL save;

- (void)resetItem;
@end

@protocol HMPhotoCellDelegate <NSObject>

- (void)photoCellTouchIn:(HMPhotoCell *)cell;
@optional
- (void)photoCellDoubleTouchIn:(HMPhotoCell *)cell;
- (void)photoCellLongTouchIn:(HMPhotoCell *)cell;
- (void)photoCellTouchBegin:(HMPhotoCell *)cell;
- (void)photoCellTouchEnd:(HMPhotoCell *)cell;

@end

/**
 *  通用的图片视图单元，支持图片放大、缩小、旋转、
 */
@interface HMPhotoCell : UIScrollView

//index属性和以下属性 内部自动设置，请不要使用同名属性  start
@property (HM_STRONG, nonatomic) NSString *reuseId;
@property (nonatomic, assign) BOOL         loaded;
@property (nonatomic, assign) BOOL         reused;

@property (nonatomic, HM_WEAK) id<HMPhotoCellDelegate>   dataSource;
@property (HM_STRONG, nonatomic) HMPhotoItem *           photo;

//index属性和以下属性 内部自动设置，请不要使用同名属性  end
@property (nonatomic, readwrite) NSInteger         index;
@property (HM_STRONG, nonatomic,readonly) UIImageView * imageView;
@property (HM_STRONG, nonatomic) UIImage *              defaultImage;
@property (HM_STRONG, nonatomic) UIView *               descptionView;//默尔是一个置于底部的label，位置都是底部
@property (nonatomic, assign)BOOL                       enableZoom;
@property (nonatomic, assign)BOOL                       enableDrag;//当zoomScale为1.0时允许整个视图拖动，放开后自动复位

@property (assign, nonatomic) UIEdgeInsets               imageInsets;

- (instancetype)initWithReuseIdentifier:(NSString*)indentifer;

//开始加载网络图片
- (void)loadImageIfNotExist;
- (void)loadImageIfNotExist:(BOOL)animated;
- (void)clearView;//针对重用对象时，预先清除数据

@end
