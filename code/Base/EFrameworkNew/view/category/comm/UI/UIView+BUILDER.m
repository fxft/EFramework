//
//  UIView+BUILDER.m
//  LightAll
//
//  Created by mac on 15/5/17.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "UIView+BUILDER.h"


@implementation UIView (BUILDER)

+ (instancetype)view{
    UIView *view = [self spawn];
    return view;
}
+ (UIImageView*)viewAsImage{
    UIImageView *imageView = [UIImageView spawn];
    return imageView;
}

+ (UIButten *)viewAsButten{
    UIButten *btn = [UIButten spawn];
    return btn;
}

+ (UIButten *)viewAsIcon{
    UIButten *btn = [UIButten spawn];
    btn.buttenType = UIButtenTypeIconSideTop;
    return btn;
}

+ (UIButten *)viewAsCheckbox{
    UIButten *btn = [UIButten spawn];
    btn.buttenType = UIButtenTypeCheckBox;
    return btn;
}

+ (UIButten *)viewAsCheckboxRight{
    UIButten *btn = [UIButten spawn];
    btn.buttenType = UIButtenTypeCheckBox|UIButtenTypeIconSideRight;
    return btn;
}

+ (HMUITextField*)viewAsInput{
    HMUITextField *field = [HMUITextField spawn];
    return field;
}

+ (HMUITextView*)viewAsTextView{
    HMUITextView *field = [HMUITextView spawn];
    return field;
}


+ (UILabel*)viewAsLabel{
    UILabel *label = [UILabel spawn];
    return label;
}

+ (HMUITextField*)viewAsInputTopic{
    HMUITextField *field = [HMUITextField spawn];
    field.fieldStyle = TextFieldStyleTopTips;
    return field;
}

+ (HMUIPhotoBrowser*)viewAsImageBrowser{
    HMUIPhotoBrowser *browser = [HMUIPhotoBrowser spawn];
    
    return browser;
}

- (instancetype)EFOwner:(UIView *)view{
    [view addSubview:self];
    return self;
}


- (instancetype)EFSubview:(UIView*)view{
    
    if (![self.subviews containsObject:view]) {
        [self addSubview:view];
    }
    
    return self;
}

- (instancetype)EFTag:(NSInteger)tag{
    self.tag = tag;
    return self;
}

- (instancetype)EFTagString:(NSString *)tag{
    self.tagString = tag;
    return self;
}

- (instancetype)EFImage:(id)image{
    return [self EFImage:image forState:(1<<10)];
}

- (instancetype)EFImage:(id)image forState:(UIControlState)state{
    if ([self isKindOfClass:[UIImageView class]]) {
        
        if ([image isKindOfClass:[NSString class]]){
            [(UIImageView*)self setImageWithURLString:image];
        }else{
            [(UIImageView*)self setImage:image];
        }
        
    }else if ([self isKindOfClass:[UIButten class]]){
        
        if ([image isKindOfClass:[NSString class]]){
            if (state==(1<<10)) {
                [(UIButten*)self setImagePrefixName:image title:nil];
            }else{
                if ([image isUrl]){
                    [(UIButten*)self setImageWithURLString:(NSString*)image forState:state];
                }else {
                    [(UIButten*)self setImage:[UIImage imageNamed:image] forState:state];
                }
            }
        }else{
            [(UIButten*)self setImage:image forState:state];
        }
    }
    return self;
}

- (instancetype)EFBackgroundImage:(id)image{
    return [self EFBackgroundImage:image forState:(1<<10)];
}

- (instancetype)EFBackgroundImage:(id)image forState:(UIControlState)state{
    if ([self isKindOfClass:[UIButten class]]){
        
        if ([image isKindOfClass:[NSString class]]){
            if (state==(1<<10)) {
                [(UIButten*)self setBackgroundImagePrefixName:image title:nil];
            }else{
                if ([image isUrl]){
                    [(UIButten*)self setBackgroundImageWithURLString:(NSString*)image forState:state];
                }else {
                    [(UIButten*)self setBackgroundImage:[[UIImage imageNamed:image] stretched] forState:state];
                }
            }
        }else {
            [(UIButten*)self setBackgroundImage:image forState:state];
        }
        
        
    }else{
        
        if ([image isKindOfClass:[NSString class]]){
            [self.backgroundImageView setImageWithURLString:image];
        }else{
            [self setBackgroundImage:image];
        }

    }
    return self;
}

- (instancetype)EFBackgroundColor:(UIColor*)color{
    self.backgroundColor = color;
    return self;
}

- (instancetype)EFPlaceText:(NSString *)title{
    if ([self respondsToSelector:@selector(setPlaceholder:)]){
        [self performSelector:@selector(setPlaceholder:) withObject:title];
    }
    return self;
}

- (instancetype)EFPlaceTextColor:(UIColor *)color{
    if ([self respondsToSelector:@selector(setPlaceholderColor:)]){
        [self performSelector:@selector(setPlaceholderColor:) withObject:color];
    }
    return self;
}

- (instancetype)EFTextColor:(UIColor *)color{
    if ([self isKindOfClass:[UIButten class]]){
        [(UIButten*)self setTitleColor:color forState:UIControlStateNormal];
    }else if ([self respondsToSelector:@selector(setTextColor:)]){
        [self performSelector:@selector(setTextColor:) withObject:color];
    }
    return self;
}

- (instancetype)EFTextDisabledColor:(UIColor *)color{
    if ([self isKindOfClass:[UIButten class]]){
        [(UIButten*)self setTitleColor:color forState:UIControlStateDisabled];
    }
    return self;
}

- (instancetype)EFTextHightLightColor:(UIColor *)color{
    if ([self isKindOfClass:[UIButten class]]){
        [(UIButten*)self setTitleColor:color forState:UIControlStateHighlighted];
    }
    return self;
}

- (instancetype)EFTextSelectedColor:(UIColor *)color{
    if ([self isKindOfClass:[UIButten class]]){
        [(UIButten*)self setTitleColor:color forState:UIControlStateSelected];
    }
    return self;
}

- (instancetype)EFText:(id)title{
    
    if ([title isKindOfClass:[NSString class]]) {
        if ([self isKindOfClass:[UIButten class]]){
            [(UIButten*)self setTitle:title forState:UIControlStateNormal];
        }else if ([self respondsToSelector:@selector(setText:)]){
            [self performSelector:@selector(setText:) withObject:title];
        }
    }else if ([title isKindOfClass:[NSAttributedString class]]){
        if ([self isKindOfClass:[UIButten class]]){
            [(UIButten*)self setAttributedTitle:title forState:UIControlStateNormal];
        }else if ([self respondsToSelector:@selector(setAttributedText:)]){
            [self performSelector:@selector(setAttributedText:) withObject:title];
        }
    }else if ([title respondsToSelector:@selector(description)]){
        [self EFText:[title description]];
    }else if (title==nil){
        if ([self isKindOfClass:[UIButten class]]){
            [(UIButten*)self setTitle:title forState:UIControlStateNormal];
            [(UIButten*)self setAttributedTitle:title forState:UIControlStateNormal];
        }
        if ([self respondsToSelector:@selector(setText:)]){
            [self performSelector:@selector(setText:) withObject:title];
        }
        if ([self respondsToSelector:@selector(setAttributedText:)]){
            [self performSelector:@selector(setAttributedText:) withObject:title];
        }
    }
    
    return self;
}

- (instancetype)EFTextHightLight:(id)title{
    
    if ([self isKindOfClass:[UIButten class]]){
        if ([title isKindOfClass:[NSString class]])
            [(UIButten*)self setTitle:title forState:UIControlStateHighlighted];
        else if ([title isKindOfClass:[NSAttributedString class]])
            [(UIButten*)self setAttributedTitle:title forState:UIControlStateHighlighted];
        else if (title==nil){
            [(UIButten*)self setTitle:title forState:UIControlStateHighlighted];
            [(UIButten*)self setAttributedTitle:title forState:UIControlStateHighlighted];
        }
    }
    
    return self;
}

- (instancetype)EFTextSelected:(id)title{
    if ([self isKindOfClass:[UIButten class]]){
        if ([title isKindOfClass:[NSString class]])
            [(UIButten*)self setTitle:title forState:UIControlStateSelected];
        else if ([title isKindOfClass:[NSAttributedString class]])
            [(UIButten*)self setAttributedTitle:title forState:UIControlStateSelected];
        else if (title==nil){
            [(UIButten*)self setTitle:title forState:UIControlStateSelected];
            [(UIButten*)self setAttributedTitle:title forState:UIControlStateSelected];
        }
    }
    
    return self;
}

- (instancetype)EFTextDisabled:(id)title{
    if ([self isKindOfClass:[UIButten class]]){
        if ([title isKindOfClass:[NSString class]])
            [(UIButten*)self setTitle:title forState:UIControlStateDisabled];
        else if ([title isKindOfClass:[NSAttributedString class]])
            [(UIButten*)self setAttributedTitle:title forState:UIControlStateDisabled];
        else if (title==nil){
            [(UIButten*)self setTitle:title forState:UIControlStateDisabled];
            [(UIButten*)self setAttributedTitle:title forState:UIControlStateDisabled];
        }
    }
    return self;
}

- (instancetype)EFTextFont:(UIFont *)font{
    if ([self isKindOfClass:[UIButten class]]){
        [(UIButten*)self setTitleFont:font forState:UIControlStateNormal];
    }else if ([self respondsToSelector:@selector(setFont:)]){
        [self performSelector:@selector(setFont:) withObject:font];
    }
    return self;
}

- (instancetype)EFTextAlign:(NSTextAlignment)align{
    if ([self isKindOfClass:[UIButten class]]){
        [[(UIButten*)self titleLabel] setTextAlignment:align];
    }else if ([self respondsToSelector:@selector(setTextAlignment:)]){
        [(UILabel*)self setTextAlignment:align];
    }
    
    return self;
}

- (instancetype)EFContentMode:(UIViewContentMode)mode{
    [self setContentMode:mode];
    return self;
}

- (instancetype)EFPlaceTextFont:(UIFont *)font{
    if ([self respondsToSelector:@selector(setPlaceholderFont:)]){
        [self performSelector:@selector(setPlaceholderFont:) withObject:font];
    }
    return self;
}

- (instancetype)EFEdgeInsets:(UIEdgeInsets)insets{
    if ([self isKindOfClass:[HMUITextField class]]) {
        [(HMUITextField*)self setTextEdgeInsets:insets];
    }else{
        [self addViewStyle:[HMUIInsetStyle styleWithInset:insets next:nil]];
    }
    return self;
}

- (instancetype)EFAutoSelect:(BOOL)autoSelect{
    if ([self isKindOfClass:[UIButten class]]){
        [(UIButten*)self setButtenType:autoSelect?([(UIButten*)self buttenType]|UIButtenTypeAutoSelect):([(UIButten*)self buttenType]&!UIButtenTypeAutoSelect)];
    }
    return self;
}

- (instancetype)EFEventResponder:(id)responder{
    if ([self respondsToSelector:@selector(setEventReceiver:)]){
        [self performSelector:@selector(setEventReceiver:) withObject:responder];
    }
    return self;
}

- (instancetype)EFNextResponder:(UIResponder *)responder{
    if ([self respondsToSelector:@selector(setNextChain:)]){
        [self performSelector:@selector(setNextChain:) withObject:responder];
    }
    return self;
}

- (instancetype)EFAutoHideKeyboardWhenReturn:(BOOL)autoHide{
    if ([self isKindOfClass:[HMUITextField class]]){
        [(HMUITextField*)self setShouldHideIfReturn:autoHide];
    }else if ([self isKindOfClass:[HMUITextView class]]){
        [(HMUITextView*)self setShouldHideIfReturn:autoHide];
    }
    return self;
}

- (instancetype)EFKeyBoardType:(UIKeyboardType)type{
    if ([self respondsToSelector:@selector(setKeyboardType:)]){
        [(HMUITextField*)self setKeyboardType:type];
    }
    return self;
}

- (instancetype)EFReturnType:(UIReturnKeyType)type{
    if ([self respondsToSelector:@selector(setReturnKeyType:)]){
        [(HMUITextField*)self setReturnKeyType:type];
    }
    return self;
}

- (instancetype)EFInputAccessory:(UIView*)accessory{
    if ([self respondsToSelector:@selector(setInputAccessoryView:)]){
        [(HMUITextField*)self setInputAccessoryView:accessory];
    }
    return self;
}

- (instancetype)EFInputView:(UIView*)input{
    if ([self respondsToSelector:@selector(setInputView:)]){
        [(HMUITextField*)self setInputView:input];
    }
    return self;
}

- (instancetype)EFRight:(id)source{
    if ([self isKindOfClass:[HMUITextField class]]) {
        if ([source isKindOfClass:[UIView class]]) {
            [(HMUITextField*)self setRightView:source];
        }else if ([source isKindOfClass:[UIImage class]]||[source isKindOfClass:[NSString class]]){
            [(HMUITextField*)self setRightView:[[UIView viewAsImage] EFImage:source]];
        }else if (source==nil){
            [(HMUITextField*)self setRightView:source];
        }
        [(HMUITextField*)self setRightViewMode:UITextFieldViewModeAlways];
    }else if ([self isKindOfClass:[UIButten class]]){
        
    }
    return self;
}

- (instancetype)EFLeft:(id)source{
    if ([self isKindOfClass:[HMUITextField class]]) {
        if ([source isKindOfClass:[UIView class]]) {
            [(HMUITextField*)self setLeftView:source];
        }else if ([source isKindOfClass:[UIImage class]]||[source isKindOfClass:[NSString class]]){
            [(HMUITextField*)self setLeftView:[[UIView viewAsImage] EFImage:source]];
        }else if (source==nil){
            [(HMUITextField*)self setLeftView:source];
        }
        [(HMUITextField*)self setLeftViewMode:UITextFieldViewModeAlways];
    }
    return self;
}

- (instancetype)EFRightFrame:(CGRect)frame{
    if ([self isKindOfClass:[HMUITextField class]]) {
        [(HMUITextField*)self rightView].frame = frame;
    }
    return self;
}

- (instancetype)EFLeftFrame:(CGRect)frame{
    if ([self isKindOfClass:[HMUITextField class]]) {
        [(HMUITextField*)self leftView].frame = frame;
    }
    return self;
}

- (instancetype)EFFrame:(CGRect)frame{
    self.frame = frame;
    return self;
}

- (instancetype)EFImageSize:(CGSize)size{
    if ([self isKindOfClass:[UIImageView class]]) {
        
        self.size = size;
        
    }else if ([self isKindOfClass:[UIButten class]]){
        
        [(UIButten*)self setImageSize:size];
        
    }
    return self;
}

- (instancetype)EFTextMargin:(CGFloat)margin{
    
    if ([self isKindOfClass:[UIButten class]]){
        
        [(UIButten*)self setTextMargin:margin];
        
    }
    return self;
}

@end
