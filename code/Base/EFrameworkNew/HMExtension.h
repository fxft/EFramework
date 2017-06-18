//
//  HMExtension.h
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

/*
 add frameworks:
 
 coreLocation.framework
 coreText.framework
 AVFoundation.framework
 MapKit.framework
 
 
 */

#import "HMMacros.h"
#import "HMFoundation.h"
#import "HMViewCategory.h"
#import "HMUIConfig.h"
#import "HMDeviceCapacity.h"
#import "Presenter.h"

#warning @l@o@o@k@@a@t@@m@e@@@以下通用库均可用，直接引用对应头文件即可使用@@@@
//#import <CSStickyHeaderFlowLayout/CSStickyHeaderFlowLayout.h>/*collection瀑布流*/
//#import <MJRefresh/MJRefresh.h>/*下拉刷新*/
//#import <Masonry/Masonry.h>/*autolayout库*/
//#import <JHChainableAnimations/JHChainableAnimations.h>/*动画库*/
//#import <Ono/Ono.h>/*xml库*/
//#import <UITableView_FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>/*表格高度自适应*/
//#import <StreamingKit/StreamingKit.h>/*音乐播放库*/
//#import <ZipArchive/ZipArchive.h>/*压缩、解压缩*/

/*socket 库*/
//#import <CocoaAsyncSocket/GCDAsyncSocket.h>//ios7+
//#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>//ios7+
//
//#import <CocoaAsyncSocket/AsyncUdpSocket.h>//ios8+
//#import <CocoaAsyncSocket/AsyncSocket.h>//ios8+

/* masonry pian
 //针对label textfield等可变长度的控件，可用以下方式控制其位置不会影响到其他控件
 make.right.mas_equalTo(self.mas_right).offset(-5).priorityMedium();
 make.width.mas_lessThanOrEqualTo(self.mas_width);
 make.width.mas_equalTo(self.mas_width).priorityLow();
 
 
 */
@interface HMExtension : NSObject

@end
