//
//  HMUITableViewCell.m
//  JNLuckyStar
//
//  Created by Eric on 14-10-22.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUITableViewCell.h"

@implementation HMUITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect{
//    CGRect titleRect = rect;
    HMUIStyleContext *context = [self drawStyleInRect:rect];
//    titleRect = context.contentFrame;
    if (context==nil) {
        [super drawRect:rect];
    }
}
@end

@implementation UISearchBar (Extend)

- (void)clearBackBar{
    self.backgroundColor = [UIColor clearColor];
    for (UIView *view in self.subviews) {
        // for before iOS7.0
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [view removeFromSuperview];
            break;
        }
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
}

@end
