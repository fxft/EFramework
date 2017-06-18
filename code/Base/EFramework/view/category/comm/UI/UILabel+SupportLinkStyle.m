//
//  UILabel+SupportLinkStyle.m
//  CarAssistant
//
//  Created by Eric on 14-3-18.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "UILabel+SupportLinkStyle.h"

#import <CoreText/CoreText.h>
#import "HMViewCategory.h"

#define kTTTLineBreakWordWrapTextWidthScalingFactor (M_PI / M_E)

NSString * const kTTTStrikeOutAttributeName = @"TTTStrikeOutAttribute";
NSString * const kTTTBackgroundFillColorAttributeName = @"TTTBackgroundFillColor";
NSString * const kTTTBackgroundFillPaddingAttributeName = @"TTTBackgroundFillPadding";
NSString * const kTTTBackgroundStrokeColorAttributeName = @"TTTBackgroundStrokeColor";
NSString * const kTTTBackgroundLineWidthAttributeName = @"TTTBackgroundLineWidth";
NSString * const kTTTBackgroundCornerRadiusAttributeName = @"TTTBackgroundCornerRadius";

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
const NSTextAlignment TTTTextAlignmentLeft = NSTextAlignmentLeft;
const NSTextAlignment TTTTextAlignmentCenter = NSTextAlignmentCenter;
const NSTextAlignment TTTTextAlignmentRight = NSTextAlignmentRight;
const NSTextAlignment TTTTextAlignmentJustified = NSTextAlignmentJustified;
const NSTextAlignment TTTTextAlignmentNatural = NSTextAlignmentNatural;

const NSLineBreakMode TTTLineBreakByWordWrapping = NSLineBreakByWordWrapping;
const NSLineBreakMode TTTLineBreakByCharWrapping = NSLineBreakByCharWrapping;
const NSLineBreakMode TTTLineBreakByClipping = NSLineBreakByClipping;
const NSLineBreakMode TTTLineBreakByTruncatingHead = NSLineBreakByTruncatingHead;
const NSLineBreakMode TTTLineBreakByTruncatingMiddle = NSLineBreakByTruncatingMiddle;
const NSLineBreakMode TTTLineBreakByTruncatingTail = NSLineBreakByTruncatingTail;

typedef NSTextAlignment TTTTextAlignment;
typedef NSLineBreakMode TTTLineBreakMode;
#else
const UITextAlignment TTTTextAlignmentLeft = NSTextAlignmentLeft;
const UITextAlignment TTTTextAlignmentCenter = NSTextAlignmentCenter;
const UITextAlignment TTTTextAlignmentRight = NSTextAlignmentRight;
const UITextAlignment TTTTextAlignmentJustified = NSTextAlignmentJustified;
const UITextAlignment TTTTextAlignmentNatural = NSTextAlignmentNatural;

const UITextAlignment TTTLineBreakByWordWrapping = NSLineBreakByWordWrapping;
const UITextAlignment TTTLineBreakByCharWrapping = NSLineBreakByCharWrapping;
const UITextAlignment TTTLineBreakByClipping = NSLineBreakByClipping;
const UITextAlignment TTTLineBreakByTruncatingHead = NSLineBreakByTruncatingHead;
const UITextAlignment TTTLineBreakByTruncatingMiddle = NSLineBreakByTruncatingMiddle;
const UITextAlignment TTTLineBreakByTruncatingTail = NSLineBreakByTruncatingTail;

typedef UITextAlignment TTTTextAlignment;
typedef UILineBreakMode TTTLineBreakMode;
#endif


static inline CTTextAlignment CTTextAlignmentFromTTTTextAlignment(TTTTextAlignment alignment) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    switch (alignment) {
        case NSTextAlignmentLeft: return kCTLeftTextAlignment;
        case NSTextAlignmentCenter: return kCTCenterTextAlignment;
        case NSTextAlignmentRight: return kCTRightTextAlignment;
        default: return kCTNaturalTextAlignment;
    }
#else
    switch (alignment) {
        case NSTextAlignmentLeft: return kCTLeftTextAlignment;
        case NSTextAlignmentCenter: return kCTCenterTextAlignment;
        case UITextAlignmentRight: return kCTRightTextAlignment;
        default: return kCTNaturalTextAlignment;
    }
#endif
}

static inline CTLineBreakMode CTLineBreakModeFromTTTLineBreakMode(TTTLineBreakMode lineBreakMode) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    switch (lineBreakMode) {
        case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
        case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
        case NSLineBreakByClipping: return kCTLineBreakByClipping;
        case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
        case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
        case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
        default: return 0;
    }
#else
    return CTLineBreakModeFromUILineBreakMode(lineBreakMode);
#endif
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
static inline CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    switch (lineBreakMode) {
        case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
        case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
        case UILineBreakModeClip: return kCTLineBreakByClipping;
        case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
        case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
        case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
        default: return 0;
    }
#pragma clang diagnostic pop
}
#endif

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static inline CGFloat TTTFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case TTTTextAlignmentCenter:
            return 0.5f;
        case TTTTextAlignmentRight:
            return 1.0f;
        case TTTTextAlignmentLeft:
        default:
            return 0.0f;
    }
}

static inline NSDictionary * NSAttributedStringAttributesFromLabel(UILabel *label) {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    if ([NSMutableParagraphStyle class]) {
        [mutableAttributes setObject:label.font forKey:(NSString *)kCTFontAttributeName];
        [mutableAttributes setObject:label.textColor forKey:(NSString *)kCTForegroundColorAttributeName];
         [mutableAttributes setObject:@(label.mykern) forKey:(NSString *)kCTKernAttributeName];
        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
        paragraphStyle.alignment = label.textAlignment;
        paragraphStyle.lineSpacing = label.mylineSpacing;
        paragraphStyle.minimumLineHeight = label.myminimumLineHeight > 0 ? label.myminimumLineHeight : label.font.lineHeight * label.mylineHeightMultiple;
        paragraphStyle.maximumLineHeight = label.mymaximumLineHeight > 0 ? label.mymaximumLineHeight : label.font.lineHeight * label.mylineHeightMultiple;
        paragraphStyle.lineHeightMultiple = label.mylineHeightMultiple;
        paragraphStyle.firstLineHeadIndent = label.myfirstLineIndent;
        paragraphStyle.headIndent = paragraphStyle.firstLineHeadIndent;
        
        if (label.numberOfLines == 1) {
            paragraphStyle.lineBreakMode = label.lineBreakMode;
        } else {
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        }
        
        [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    } else {
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)label.font.fontName, label.font.pointSize, NULL);
        [mutableAttributes setObject:(__bridge id)font forKey:(NSString *)kCTFontAttributeName];
        CFRelease(font);
        
        [mutableAttributes setObject:(id)[label.textColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableAttributes setObject:@(label.mykern) forKey:(NSString *)kCTKernAttributeName];
        
        CTTextAlignment alignment = CTTextAlignmentFromTTTTextAlignment(label.textAlignment);
        CGFloat lineSpacing = label.mylineSpacing;
        CGFloat minimumLineHeight = label.myminimumLineHeight * label.mylineHeightMultiple;
        CGFloat maximumLineHeight = label.mymaximumLineHeight * label.mylineHeightMultiple;
        CGFloat lineSpacingAdjustment = CGFloat_ceil(label.font.lineHeight - label.font.ascender + label.font.descender);
        CGFloat lineHeightMultiple = label.mylineHeightMultiple;
        CGFloat firstLineIndent = label.myfirstLineIndent;
        
        CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        if (label.numberOfLines == 1) {
            lineBreakMode = CTLineBreakModeFromTTTLineBreakMode(label.lineBreakMode);
        }
        
        CTParagraphStyleSetting paragraphStyles[12] = {
            {.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void *)&alignment},
            {.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void *)&lineBreakMode},
            {.spec = kCTParagraphStyleSpecifierLineSpacing, .valueSize = sizeof(CGFloat), .value = (const void *)&lineSpacing},
            {.spec = kCTParagraphStyleSpecifierMinimumLineSpacing, .valueSize = sizeof(CGFloat), .value = (const void *)&minimumLineHeight},
            {.spec = kCTParagraphStyleSpecifierMaximumLineSpacing, .valueSize = sizeof(CGFloat), .value = (const void *)&maximumLineHeight},
            {.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment, .valueSize = sizeof (CGFloat), .value = (const void *)&lineSpacingAdjustment},
            {.spec = kCTParagraphStyleSpecifierLineHeightMultiple, .valueSize = sizeof(CGFloat), .value = (const void *)&lineHeightMultiple},
            {.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent, .valueSize = sizeof(CGFloat), .value = (const void *)&firstLineIndent},
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyles, 12);
        
        [mutableAttributes setObject:(__bridge id)paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
        
        CFRelease(paragraphStyle);
    }
    
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

#pragma mark -
@interface UILabel (HMViewStyle_private)

@property (readwrite, nonatomic, HM_STRONG) NSArray *           links_hm;

@property (readwrite, nonatomic, HM_STRONG) NSDataDetector *    dataDetector_hm;

@property (readwrite, nonatomic, assign) CTFramesetterRef      framesetter_hm;

@property (nonatomic, HM_STRONG) NSTextCheckingResult *         touchedResult_hm;

@property (nonatomic, assign) CGPoint                          touchedResultPoint_hm;

@property (nonatomic, assign) BOOL                             touchedEffective_hm;


@end



@implementation UILabel (HMViewStyle_private)

@dynamic dataDetector_hm;
@dynamic links_hm;
@dynamic framesetter_hm;
@dynamic touchedResult_hm;
@dynamic touchedResultPoint_hm;
@dynamic touchedEffective_hm;


static int __dataDectorKEY;

- (NSDataDetector *)dataDetector_hm{
    
    NSDataDetector * obj = objc_getAssociatedObject( self, &__dataDectorKEY );
	if ( obj && [obj isKindOfClass:[NSDataDetector class]] )
		return obj;
	
	return nil;
}

- (void)setDataDetector_hm:(NSDataDetector *)dataDetector{
    objc_setAssociatedObject( self, &__dataDectorKEY, dataDetector, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

static int __linksKEY;
- (NSArray *)links_hm{
    NSArray * obj = objc_getAssociatedObject( self, &__linksKEY );
	if ( obj && [obj isKindOfClass:[NSArray class]] )
		return obj;
	
	return nil;
}

- (void)setLinks_hm:(NSArray *)links{
    objc_setAssociatedObject( self, &__linksKEY, links, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}


static int __framesetterKEY;

- (CTFramesetterRef)framesetter_hm{
    
    NSObject * obj = objc_getAssociatedObject( self, &__framesetterKEY );
	if ( obj )
		return (__bridge_type CTFramesetterRef)obj;
	
	return nil;
}

- (void)setFramesetter_hm:(CTFramesetterRef)framesetter{
    objc_setAssociatedObject( self, &__framesetterKEY, (__bridge_type id)framesetter, OBJC_ASSOCIATION_ASSIGN );
}

static int __touchedResultKEY;

- (NSTextCheckingResult *)touchedResult_hm{
    
    NSTextCheckingResult * obj = objc_getAssociatedObject( self, &__touchedResultKEY );
	if ( obj && [obj isKindOfClass:[NSTextCheckingResult class]] )
		return obj;
	
	return nil;
}

- (void)setTouchedResult_hm:(NSTextCheckingResult *)touchedResult{
    objc_setAssociatedObject( self, &__touchedResultKEY, touchedResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}


static int __touchedResultPointKEY;

- (CGPoint)touchedResultPoint_hm{
    
    NSValue * obj = objc_getAssociatedObject( self, &__touchedResultPointKEY );
	if ( obj && [obj isKindOfClass:[NSValue class]])
		return [obj CGPointValue];
	
	return CGPointZero;
}

- (void)setTouchedResultPoint_hm:(CGPoint)touchedResultPoint{
    
    objc_setAssociatedObject( self, &__touchedResultPointKEY, [NSValue valueWithCGPoint:touchedResultPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

static int __touchedEffectiveKEY;

- (BOOL)touchedEffective_hm{
    
    NSNumber * obj = objc_getAssociatedObject( self, &__touchedEffectiveKEY );
	if ( obj && [obj isKindOfClass:[NSNumber class]])
		return [obj boolValue];
	
	return NO;
}

- (void)setTouchedEffective_hm:(BOOL)touchedEffective{
    
    objc_setAssociatedObject( self, &__touchedEffectiveKEY, [NSNumber numberWithBool:touchedEffective], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}


@end

@implementation UILabel (SupportLinkStyle)

DEF_SIGNAL(TOUCHLINK)

@dynamic dataDetectorTypes;
@dynamic contentFrame;
@dynamic linkAttributes;
@dynamic linkTouchedAttributes;

@dynamic mykern;
static int __kernKEY;

- (CGFloat)mykern{
    
    NSNumber * obj = objc_getAssociatedObject( self, &__kernKEY );
    if ( obj && [obj isKindOfClass:[NSNumber class]])
        return [obj floatValue];
    
    return NO;
}

- (void)setMykern:(CGFloat)mykern{
    
    objc_setAssociatedObject( self, &__kernKEY, [NSNumber numberWithFloat:mykern], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@dynamic mEnableLink;
static int __mEnableLinkKEY;

- (BOOL)mEnableLink{
    
    NSNumber * obj = objc_getAssociatedObject( self, &__mEnableLinkKEY );
    if ( obj && [obj isKindOfClass:[NSNumber class]])
        return [obj boolValue];
    
    return NO;
}

- (void)setMEnableLink:(BOOL)mEnableLink{
    
    objc_setAssociatedObject( self, &__mEnableLinkKEY, [NSNumber numberWithBool:mEnableLink], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@dynamic mylineHeightMultiple;
static int __lineHeightMultipleKEY;

- (CGFloat)mylineHeightMultiple{
    
    NSNumber * obj = objc_getAssociatedObject( self, &__lineHeightMultipleKEY );
    if ( obj && [obj isKindOfClass:[NSNumber class]])
        return [obj floatValue];
    
    return NO;
}

- (void)setMylineHeightMultiple:(CGFloat)mylineHeightMultiple{
    
    objc_setAssociatedObject( self, &__lineHeightMultipleKEY, [NSNumber numberWithFloat:mylineHeightMultiple], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@dynamic mymaximumLineHeight;
static int __maximumLineHeightKEY;

- (CGFloat)mymaximumLineHeight{
    
    NSNumber * obj = objc_getAssociatedObject( self, &__maximumLineHeightKEY );
    if ( obj && [obj isKindOfClass:[NSNumber class]])
        return [obj floatValue];
    
    return NO;
}

- (void)setMymaximumLineHeight:(CGFloat)mymaximumLineHeight{
    
    objc_setAssociatedObject( self, &__maximumLineHeightKEY, [NSNumber numberWithFloat:mymaximumLineHeight], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@dynamic myminimumLineHeight;
static int __minimumLineHeightKEY;

- (CGFloat)myminimumLineHeight{
    
    NSNumber * obj = objc_getAssociatedObject( self, &__minimumLineHeightKEY );
    if ( obj && [obj isKindOfClass:[NSNumber class]])
        return [obj floatValue];
    
    return NO;
}

- (void)setMyminimumLineHeight:(CGFloat)myminimumLineHeight{
    
    objc_setAssociatedObject( self, &__minimumLineHeightKEY, [NSNumber numberWithFloat:myminimumLineHeight], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@dynamic mylineSpacing;
static int __lineSpacingKEY;

- (CGFloat)mylineSpacing{
    
    NSNumber * obj = objc_getAssociatedObject( self, &__lineSpacingKEY );
    if ( obj && [obj isKindOfClass:[NSNumber class]])
        return [obj floatValue];
    
    return NO;
}

- (void)setMylineSpacing:(CGFloat)mylineSpacing{
    
    objc_setAssociatedObject( self, &__lineSpacingKEY, [NSNumber numberWithFloat:mylineSpacing], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

@dynamic myfirstLineIndent;
static int __firstLineIndentKEY;

- (CGFloat)myfirstLineIndent{
    
    NSNumber * obj = objc_getAssociatedObject( self, &__firstLineIndentKEY );
    if ( obj && [obj isKindOfClass:[NSNumber class]])
        return [obj floatValue];
    
    return NO;
}

- (void)setMyfirstLineIndent:(CGFloat)myfirstLineIndent{
    
    objc_setAssociatedObject( self, &__firstLineIndentKEY, [NSNumber numberWithFloat:myfirstLineIndent], OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}


+(id)spawn{
    
    UILabel *label = [[self alloc]init];
    
    [label initSelfDefault];
    
    return [label autorelease];
}

- (void)initSelfDefault{
    self.backgroundColor = [UIColor clearColor];
    
    self.font = [UIFont systemFontOfSize:14.0f];
    self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    self.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)unload_link{
    
    if (self.links_hm!=nil) {
        self.dataDetector_hm = nil;
        self.links_hm = nil;
        self.linkAttributes = nil;
        self.linkTouchedAttributes = nil;
        if (self.framesetter_hm != NULL) {
            CFRelease(self.framesetter_hm);
            self.framesetter_hm = NULL;
        }
        self.detectorFilter = nil;
        self.detector = nil;
        self.touchedResult_hm = nil;
    }
    
}

-(NSArray *)allLinks{
    return self.links_hm;
}

- (void)enableLink{
    
    self.links_hm = [NSArray array];
    NSMutableDictionary *mutableLinkAttributes = nil;
    if (!self.linkAttributes) {
        mutableLinkAttributes = [NSMutableDictionary dictionary];
        [mutableLinkAttributes setValue:[UIColor blueColor] forKey:(NSString*)NSForegroundColorAttributeName];
        [mutableLinkAttributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString *)NSUnderlineStyleAttributeName];
        self.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];

    }
    
    if (!self.linkTouchedAttributes) {
        mutableLinkAttributes = [NSMutableDictionary dictionary];
        [mutableLinkAttributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString *)NSUnderlineStyleAttributeName];
        [mutableLinkAttributes setValue:[UIColor redColor] forKey:(NSString*)NSForegroundColorAttributeName];
        self.linkTouchedAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    }
    self.mEnableLink = YES;
    
    self.userInteractionEnabled = YES;
}

#pragma mark 属性设置
- (void)drawText:(NSString*)text{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    if (self.shadowColor) {
        // Due to a bug in OS versions 3.2 and 4.0, the shadow appears upside-down. It pains me to
        // write this, but a lot of research has failed to turn up a way to detect the flipped shadow
        // programmatically
        float shadowYOffset = self.shadowOffset.height;
        
        CGSize offset = CGSizeMake(self.shadowOffset.width, shadowYOffset);
        CGContextSetShadowWithColor(ctx, offset, 0, self.shadowColor.CGColor);
    }
    
    if (self.textColor) {
        [self.textColor setFill];
    }
    
    CGRect titleRect = self.contentFrame;
    
    if (self.numberOfLines == 1) {
        
        if (self.attributedText) {
            [self.attributedText drawAtPoint:titleRect.origin];
            CGContextRestoreGState(ctx);
            return;
        }
        
    } else {
  
        if (self.attributedText) {
            [self.attributedText drawInRect:titleRect];
            CGContextRestoreGState(ctx);
            return;
        }
    }
    
    CGContextRestoreGState(ctx);
}


static inline NSTextCheckingType NSTextCheckingTypeFromUIDataDetectorType(UIDataDetectorTypes dataDetectorType) {
    NSTextCheckingType textCheckingType = 0;
    if (dataDetectorType & UIDataDetectorTypeAddress) {
        textCheckingType |= NSTextCheckingTypeAddress;
    }
    
    if (dataDetectorType & UIDataDetectorTypeCalendarEvent) {
        textCheckingType |= NSTextCheckingTypeDate;
    }
    
    if (dataDetectorType & UIDataDetectorTypeLink) {
        textCheckingType |= NSTextCheckingTypeLink;
    }
    
    if (dataDetectorType & UIDataDetectorTypePhoneNumber) {
        textCheckingType |= NSTextCheckingTypePhoneNumber;
    }
    
    return textCheckingType;
}



static int __contentFrameKEY;

- (CGRect)contentFrame{
    
    NSValue * obj = objc_getAssociatedObject( self, &__contentFrameKEY );
	if ( obj ){
        return [obj CGRectValue];
    }
    
	return CGRectZero;
}

- (void)setContentFrame:(CGRect)contentFrame{
    
    NSValue *valule = [NSValue valueWithCGRect:contentFrame];
    objc_setAssociatedObject( self, &__contentFrameKEY, valule, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

static int __dataDetectorTypesKEY;

- (UIDataDetectorTypes)dataDetectorTypes{
    
    NSObject * obj = objc_getAssociatedObject( self, &__dataDetectorTypesKEY );
	if ( obj && [obj isKindOfClass:[NSNumber class]] )
		return [(NSNumber *)obj integerValue];
	
	return 0;
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes {
    
    objc_setAssociatedObject( self, &__dataDetectorTypesKEY, [NSNumber numberWithUnsignedInteger:dataDetectorTypes], OBJC_ASSOCIATION_ASSIGN );
    
    if (dataDetectorTypes != UIDataDetectorTypeNone) {
        self.dataDetector_hm = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeFromUIDataDetectorType(dataDetectorTypes) error:nil];
        [self resetFrametter];
    }
}

static int __linkAttributesKEY;
- (NSDictionary *)linkAttributes{
    NSDictionary * obj = objc_getAssociatedObject( self, &__linkAttributesKEY );
	if ( obj && [obj isKindOfClass:[NSDictionary class]] )
		return obj;
	return nil;
}

- (void)setLinkAttributes:(NSDictionary *)linkAttributes{
    objc_setAssociatedObject( self, &__linkAttributesKEY, linkAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

static int __linkTouchedAttributesKEY;
- (NSDictionary *)linkTouchedAttributes{
    NSDictionary * obj = objc_getAssociatedObject( self, &__linkTouchedAttributesKEY );
	if ( obj && [obj isKindOfClass:[NSDictionary class]] )
		return obj;
	
	return nil;
}

- (void)setLinkTouchedAttributes:(NSDictionary *)linkTouchedAttributes{
    objc_setAssociatedObject( self, &__linkTouchedAttributesKEY, linkTouchedAttributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}

static int __detectorFilterKEY;
- (BOOL (^)(NSTextCheckingResult *))detectorFilter{
    BOOL (^obj)(NSTextCheckingResult *) = objc_getAssociatedObject( self, &__detectorFilterKEY );
	if ( obj )
		return obj;
	
	return nil;
}

- (void)setDetectorFilter:(BOOL (^)(NSTextCheckingResult *))detectorFilter{
    objc_setAssociatedObject( self, &__detectorFilterKEY, detectorFilter, OBJC_ASSOCIATION_COPY_NONATOMIC );
}

static int __detectorKEY;
- (NSArray *(^)(NSString *))detector{
    NSArray *(^obj)(NSString *) = objc_getAssociatedObject( self, &__detectorKEY );
	if ( obj )
		return obj;
	
	return nil;
}

- (void)setDetector:(NSArray *(^)(NSString *))detector{
    objc_setAssociatedObject( self, &__detectorKEY, detector, OBJC_ASSOCIATION_COPY_NONATOMIC );
}

- (void)setText:(NSString *)texts color:(UIColor *)color font:(UIFont*)font range:(NSRange)range{
    if (texts) {
        self.text = texts;
    }
    if (self.text==nil) {
        return;
    }
    NSMutableAttributedString *atString = [[[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText] autorelease];
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    
    if (font) {
        [mutableLinkAttributes setValue:font forKey:(NSString *)NSFontAttributeName];
    }
    if (color) {
        [mutableLinkAttributes setValue:color forKey:(NSString*)NSForegroundColorAttributeName];
    }
    
    if (self.text.length<range.length+range.location) {
        CGFloat location = MIN(self.text.length-1, range.location);
        CGFloat length = MIN(range.length, self.text.length-location-1);
        range = NSMakeRange(location, length);
    }
    
    [atString addAttributes:mutableLinkAttributes range:range];
    self.attributedText = atString;
}

- (void)setLinkColor:(UIColor *)color{
    if (!color) {
        return;
    }
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setValue:color forKey:(NSString*)NSForegroundColorAttributeName];
    [mutableLinkAttributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString *)NSUnderlineStyleAttributeName];
    self.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
}

- (void)enableUnderline{
    if (self.text.length==0) {
        NSAssert(NO,@"you must set text first");
        return;
    }
    [self addLinkToPhoneNumber:@"1" withRange:NSMakeRange(0, self.text.length)];
}

#pragma mark -   计算点击处是不是有link
- (CFIndex)characterIndexAtPoint:(CGPoint)p {
    if (!CGRectContainsPoint(self.bounds, p)) {
        return NSNotFound;
    }
    
    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    if (textRect.size.height<self.bounds.size.height) {
        CGFloat y = (self.bounds.size.height - textRect.size.height-textRect.origin.y)/2;
        textRect.origin.y = y;
    }
    if (!CGRectContainsPoint(textRect, p)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    p = CGPointMake(p.x - textRect.origin.x, p.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    p = CGPointMake(p.x, textRect.size.height - p.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame([self framesetter_hm], CFRangeMake(0, (CFIndex)[self.attributedText length]), path, NULL);
    if (frame == NULL) {
        CGPathRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CGPathRelease(path);
        return NSNotFound;
    }
    
    CFIndex idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = (CGFloat)floor(lineOrigin.y - descent);
        CGFloat yMax = (CGFloat)ceil(lineOrigin.y + ascent);
        
        // Apply penOffset using flushFactor for horizontal alignment to set lineOrigin since this is the horizontal offset from drawFramesetter
        CGFloat flushFactor = TTTFlushFactorForTextAlignment(self.textAlignment);
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width);
        lineOrigin.x = penOffset;
        
        // Check if we've already passed the line
        if (p.y > yMax) {
            break;
        }
        // Check if the point is within this line vertically
        if (p.y >= yMin) {
            // Check if the point is within this line horizontally
            if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    
    CFRelease(frame);
    CGPathRelease(path);
    
    return idx;
}


- (NSTextCheckingResult *)linkAtCharacterIndex:(CFIndex)idx {
    if (idx == NSNotFound) {
        return nil;
    }
    
    for (NSTextCheckingResult *result in self.links_hm) {
        NSRange range = result.range;
        if ((CFIndex)range.location <= idx && idx <= (CFIndex)(range.location + range.length)) {
            return result;
        }
    }
    
    return nil;
}

- (NSTextCheckingResult *)linkAtPoint:(CGPoint)p {
    CFIndex idx = [self characterIndexAtPoint:p];
    return [self linkAtCharacterIndex:idx];
}


#pragma mark 发出被点击link的事件
- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event
{
    if (!self.mEnableLink) {
        return [super hitTest:point withEvent:event];
    }
    if (self.touchedResult_hm==nil&&self.userInteractionEnabled) {
        self.touchedResult_hm = [self linkAtPoint:point];
    }
    
    if (!self.touchedResult_hm || !self.userInteractionEnabled || self.hidden || self.alpha < 0.01) {
        return [super hitTest:point withEvent:event];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    self.touchedResultPoint_hm = [touch locationInView:self];

    [self selected:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self selected:NO];
    
}

- (BOOL)touchedScreenEdge:(UITouch*)touch{
    CGPoint point = [touch locationInView:self.window];
    CGFloat minx = MIN(point.x, self.window.size.width-point.x);
    CGFloat miny = MIN(point.y, self.window.size.width-point.y);
    return minx <= .5 && miny <= .5;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.touchedResult_hm==nil) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat movedy = fabs(point.y-self.touchedResultPoint_hm.y);
    CGFloat movedx = fabs(point.x-self.touchedResultPoint_hm.x);
    BOOL touchEdge = [self touchedScreenEdge:touch];
    if (movedx < 80 && movedy < 80 && !touchEdge && self.touchedResult_hm!=nil) {
        [self sendSignal:[UILabel TOUCHLINK] withObject:self.touchedResult_hm];
    }
    [self selected:NO];
    self.touchedResult_hm = nil;
    self.touchedResultPoint_hm = CGPointZero;
    self.touchedEffective_hm = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.touchedResult_hm==nil) {
        [self.superview touchesMoved:touches withEvent:event];
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat movedy = fabs(point.y-self.touchedResultPoint_hm.y);
    CGFloat movedx = fabs(point.x-self.touchedResultPoint_hm.x);
    if (movedx < 80 && movedy < 80) {
        [self selected:YES];
    }else if (movedx > 90 || movedy > 90) {
        [self selected:NO];
    }
    
}

- (void)selected:(BOOL)yes{
    if (self.touchedResult_hm) {
        if (yes && !self.touchedEffective_hm) {
            
        }else if (!yes && self.touchedEffective_hm) {
            
        }else{
            return;
        }
        NSMutableAttributedString *mutableAttributedString = [[[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText] autorelease];
        if (yes) {
            self.touchedEffective_hm = YES;
            for (NSString *key in self.linkAttributes.allKeys) {
                [mutableAttributedString removeAttribute:key range:self.touchedResult_hm.range];
            }
            [mutableAttributedString addAttributes:self.linkTouchedAttributes range:self.touchedResult_hm.range];
        }else {
            self.touchedEffective_hm = NO;
            for (NSString *key in self.linkTouchedAttributes.allKeys) {
                [mutableAttributedString removeAttribute:key range:self.touchedResult_hm.range];
            }
            [mutableAttributedString addAttributes:self.linkAttributes range:self.touchedResult_hm.range];
        }
        self.attributedText = mutableAttributedString;
        
        [self setNeedsDisplay];
    }
}

#pragma mark 添加link

- (NSArray *)detectedLinksInString:(NSString *)string range:(NSRange)range error:(NSError **)error {
    
    if (self.detector) {
        NSArray *arry = self.detector(string);
        return arry==nil ? [NSArray array] : arry;
    }
    
    if (!string || !self.dataDetector_hm) {
        return [NSArray array];
    }
    
    NSMutableArray *mutableLinks = [NSMutableArray array];
    WS(weakSelf)
    [self.dataDetector_hm enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        SS(strongSelf)
        BOOL filter = YES;
        if (strongSelf.detectorFilter) {
            filter = strongSelf.detectorFilter(result);
        }
        if (filter) {
            [mutableLinks addObject:result];
        }
        
        
    }];
    
    return [NSArray arrayWithArray:mutableLinks];
}

- (void)resetFrametter{
    if ([[self.attributedText string] length]==0) {
        return;
    }
    if (self.framesetter_hm) CFRelease(self.framesetter_hm),self.framesetter_hm = NULL;
    NSMutableAttributedString *mutable = [[self.attributedText mutableCopy] autorelease];
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setValue:self.font forKey:(NSString *)NSFontAttributeName];
    
    [mutable addAttributes:mutableLinkAttributes range:NSMakeRange(0, self.attributedText.string.length)];
    self.attributedText = mutable;
    
    if (self.dataDetectorTypes != UIDataDetectorTypeNone) {
        
        for (NSTextCheckingResult *result in [self detectedLinksInString:[self.attributedText string]range:NSMakeRange(0, [[self.attributedText string] length]) error:nil]) {
            [self addLinkWithTextCheckingResult:result];
        }
    }
    
    
    self.framesetter_hm = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
}


- (CGSize)sizeToFitText:(CGSize)size{
    CGSize size1 = size;
    if (IOS6_OR_EARLIER&&self.framesetter_hm) {
        NSRange range[1];
        range[0]=NSMakeRange(0, self.attributedText.string.length);
        NSDictionary *dic = [self.attributedText attributesAtIndex:0 effectiveRange:range];
        size1 = CTFramesetterSuggestFrameSizeWithConstraints(self.framesetter_hm,  CFRangeMake(0, self.attributedText.string.length), (CFDictionaryRef)dic, CGSizeMake(size.width, CGFLOAT_MAX), NULL);
        
    }
    return size1;
}
- (void)dectecedText:(id)text{
    
    if (self.links_hm==nil && self.linkAttributes == nil) {
        return;
    }
    self.links_hm = [NSArray array];
    // for NSUnderlineStyleAttributeName error with iphone5 ios7.0.1,i'm no sure that the later version is ok.

    if (IOS6_OR_EARLIER) {
        if (self.numberOfLines==0&&self.lineBreakMode==NSLineBreakByTruncatingTail) {
            self.lineBreakMode = NSLineBreakByCharWrapping;
        }
    }
    NSParameterAssert(!text || [text isKindOfClass:[NSAttributedString class]] || [text isKindOfClass:[NSString class]]);
    
    if ([text isKindOfClass:[NSString class]]) {
        [self setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
        return;
    }
    
    self.attributedText = text;
    
    [self resetFrametter];
    
}
- (void)setText:(id)text
afterInheritingLabelAttributesAndConfiguringWithBlock:(NSMutableAttributedString * (^)(NSMutableAttributedString *mutableAttributedString))block
{
    NSMutableAttributedString *mutableAttributedString = nil;
    if ([text isKindOfClass:[NSString class]]) {
        mutableAttributedString = [[[NSMutableAttributedString alloc] initWithString:text attributes:NSAttributedStringAttributesFromLabel(self)] autorelease];
    } else {
        mutableAttributedString = [[[NSMutableAttributedString alloc] initWithAttributedString:text] autorelease];
        [mutableAttributedString addAttributes:NSAttributedStringAttributesFromLabel(self) range:NSMakeRange(0, [mutableAttributedString length])];
    }
    
    if (block) {
        mutableAttributedString = block(mutableAttributedString);
    }
    
    [self dectecedText:mutableAttributedString];
}

- (void)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    if (self.linkAttributes==nil) {
        [self enableLink];
    }
    [self addLinkWithTextCheckingResult:result attributes:self.linkAttributes];
}

- (void)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result attributes:(NSDictionary *)attributes {
    
    self.links_hm = [self.links_hm arrayByAddingObject:result];
    
    if (attributes) {
        NSMutableAttributedString *mutableAttributedString = [[[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText] autorelease];
        [mutableAttributedString addAttributes:attributes range:result.range];
        
        self.attributedText = mutableAttributedString;
        
    }
}

- (void)addLinkToURL:(NSURL *)url withRange:(NSRange)range {
    [self addLinkWithTextCheckingResult:[NSTextCheckingResult linkCheckingResultWithRange:range URL:url]];
}

- (void)addLinkToAddress:(NSDictionary *)addressComponents withRange:(NSRange)range {
    [self addLinkWithTextCheckingResult:[NSTextCheckingResult addressCheckingResultWithRange:range components:addressComponents]];
}

- (void)addLinkToPhoneNumber:(NSString *)phoneNumber withRange:(NSRange)range {
    [self addLinkWithTextCheckingResult:[NSTextCheckingResult phoneNumberCheckingResultWithRange:range phoneNumber:phoneNumber]];
}

- (void)addLinkToDate:(NSDate *)date withRange:(NSRange)range {
    [self addLinkWithTextCheckingResult:[NSTextCheckingResult dateCheckingResultWithRange:range date:date]];
}

- (void)addLinkToDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration withRange:(NSRange)range {
    [self addLinkWithTextCheckingResult:[NSTextCheckingResult dateCheckingResultWithRange:range date:date timeZone:timeZone duration:duration]];
}

@end
