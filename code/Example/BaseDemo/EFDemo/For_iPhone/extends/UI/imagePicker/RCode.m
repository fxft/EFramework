//
//  RCode.m
//  EFExtend
//
//  Created by mac on 16/3/1.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "RCode.h"


@interface RCode ()

@end

@implementation RCode

- (void)dealloc
{
   
    HM_SUPER_DEALLOC();
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
    
}

- (void)initSubviews{
    
    UIView *input = [[UIView viewAsTextView] EFOwner:self.view];
    input.tagString = @"input";
    [input EFText:@"https://github.com/SnapKit/Masonry"];
    [input mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(20);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.height.mas_equalTo(40);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
    }];
    
    UIButten *btn = [[UIView viewAsButten] EFOwner:self.view];
    [btn setTitle:@"生成" forState:UIControlStateNormal];
    [btn setBackgroundImage:[[UIImage imageForColor:[UIColor redColor] scale:2.0 size:CGSizeMake(30, 30) radius:5] stretched] forState:UIControlStateNormal];
    [btn setBackgroundImage:[[UIImage imageForColor:[UIColor grayColor] scale:2.0 size:CGSizeMake(30, 30) radius:5] stretched] forState:UIControlStateHighlighted];
    btn.tagString = @"generate";
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(input.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(200);
    }];
    
    UIImageView *image = (id)[[UIView viewAsImage] EFOwner:self.view];
    image.tagString = @"image";
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(btn.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.height.mas_equalTo(80);
        make.width.mas_equalTo(80);
    }];
    
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
        }else if ([btn is:@"generate"]){//customNavRightBtn
            UITextView *text = (id)[self.view viewWithTagString:@"input"];
            
            UIImageView *image = (id)[self.view viewWithTagString:@"image"];
            image.image = [text.text QRCode];
            
//            [image setImageWithURLString:@"http://img03.sogoucdn.com/net/a/04/link?appid=100520031&url=http%3A%2F%2Fmmbiz.qpic.cn%2Fmmbiz%2FYcZQuZUOvwRJytY6ibxbvYOvgRibzP12znWfEcPKS2n1hQ48icVAwsDrJmtvjkLCdSHQYAfOIZQTrZzZPsibCCeeww%2F0%3Fwx_fmt%3Djpeg"];
        }
    }
}

@end
