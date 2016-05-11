

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)


#pragma mark -

// 颜色值可以是十六进制(大于1小于255)或浮点型(小于1.0)
#undef	RGBA
#define RGBA(R,G,B,A)	[UIColor colorWithRed:(((R)<=1.0f)?(R):((R)/255.0f)) green:(((G)<=1.0f)?(G):((G)/255.0f)) blue:(((B)<=1.0f)?(B):((B)/255.0f)) alpha:(A)]

#undef	RGB
#define RGB(R,G,B)      RGBA(R,G,B,1.f)

#undef	HEX_RGB
#define HEX_RGB(V)		[UIColor fromHexValue:V]

#undef	HEX_RGBA
#define HEX_RGBA(V, A)	[UIColor fromHexValue:V alpha:A]

#undef	RGBHEX
#define RGBHEX		HEX_RGB

#undef	SHORT_RGB
#define SHORT_RGB(V)	[UIColor fromShortHexValue:V]


#undef RGBGLASSA
#define RGBGLASSA RGBA(255, 255, 255,.685)

#undef RGBGLASSB
#define RGBGLASSB RGBA(255, 255, 255,.13)

#pragma mark -

@interface UIColor(Theme)

+ (UIColor *)fromHexValue:(NSUInteger)hex;
+ (UIColor *)fromHexValue:(NSUInteger)hex alpha:(CGFloat)alpha;

+ (UIColor *)fromShortHexValue:(NSUInteger)hex;
+ (UIColor *)fromShortHexValue:(NSUInteger)hex alpha:(CGFloat)alpha;

//#ff000,0xfffff
+ (UIColor *)colorWithString:(NSString *)string;
/**
 * Accepted ranges:
 *        hue: 0.0 - 360.0
 * saturation: 0.0 - 1.0
 *      value: 0.0 - 1.0
 *      alpha: 0.0 - 1.0
 */
+ (UIColor*)colorWithHue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v alpha:(CGFloat)a;

/**
 * Accepted ranges:
 *        hue: 0.0 - 1.0
 * saturation: 0.0 - 1.0
 *      value: 0.0 - 1.0
 */
- (UIColor*)multiplyHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd;

- (UIColor*)addHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd;

/**
 * Returns a new UIColor with the given alpha.
 */
- (UIColor*)copyWithAlpha:(CGFloat)newAlpha;

/**
 * Uses multiplyHue:saturation:value:alpha: to create a lighter version of the color.
 */
- (UIColor*)highlight;

/**
 * Uses multiplyHue:saturation:value:alpha: to create a darker version of the color.
 */
- (UIColor*)shadow;

- (NSUInteger)hex;

- (CGFloat)hue;

- (CGFloat)saturation;

- (CGFloat)value;

- (CGFloat)alpha;
@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
