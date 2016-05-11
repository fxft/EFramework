
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "UIColor+HMExtension.h"
#import "HMMacros.h"

#define MAX3(a,b,c) (a > b ? (a > c ? a : c) : (b > c ? b : c))
#define MIN3(a,b,c) (a < b ? (a < c ? a : c) : (b < c ? b : c))


///////////////////////////////////////////////////////////////////////////////////////////////////
void RGBtoHSV(CGFloat r, CGFloat g, CGFloat b, CGFloat* h, CGFloat* s, CGFloat* v) {
    CGFloat min, max, delta;
    min = MIN3(r, g, b);
    max = MAX3(r, g, b);
    *v = max;        // v
    delta = max - min;
    if ( max != 0 )
        *s = delta / max;    // s
    else {
        // r = g = b = 0    // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    if ( r == max )
        *h = ( g - b ) / delta;    // between yellow & magenta
    else if ( g == max )
        *h = 2 + ( b - r ) / delta;  // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta;  // between magenta & cyan
    *h *= 60;        // degrees
    if ( *h < 0 )
        *h += 360;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void HSVtoRGB( CGFloat *r, CGFloat *g, CGFloat *b, CGFloat h, CGFloat s, CGFloat v ) {
    int i;
    float f, p, q, t;
    if ( s == 0 ) {
        // achromatic (grey)
        *r = *g = *b = v;
        return;
    }
    h /= 60;      // sector 0 to 5
    i = floor( h );
    f = h - i;      // factorial part of h
    p = v * ( 1 - s );
    q = v * ( 1 - s * f );
    t = v * ( 1 - s * ( 1 - f ) );
    switch( i ) {
        case 0:
            *r = v;
            *g = t;
            *b = p;
            break;
        case 1:
            *r = q;
            *g = v;
            *b = p;
            break;
        case 2:
            *r = p;
            *g = v;
            *b = t;
            break;
        case 3:
            *r = p;
            *g = q;
            *b = v;
            break;
        case 4:
            *r = t;
            *g = p;
            *b = v;
            break;
        default:    // case 5:
            *r = v;
            *g = p;
            *b = q;
            break;
    }
}

#pragma mark -

@implementation UIColor(Theme)

+ (UIColor *)fromHexValue:(NSUInteger)hex
{
	NSUInteger a = ((hex >> 24) & 0x000000FF);
	float fa = ((0 == a) ? 1.0f : (a * 1.0f) / 255.0f);

	return [UIColor fromHexValue:hex alpha:fa];
}

+ (UIColor *)fromHexValue:(NSUInteger)hex alpha:(CGFloat)alpha
{
    if ( hex == 0xECE8E3 ) {
        
    }
	NSUInteger r = ((hex >> 16) & 0x000000FF);
	NSUInteger g = ((hex >> 8) & 0x000000FF);
	NSUInteger b = ((hex >> 0) & 0x000000FF);
	
	float fr = (r * 1.0f) / 255.0f;
	float fg = (g * 1.0f) / 255.0f;
	float fb = (b * 1.0f) / 255.0f;
	
	return [UIColor colorWithRed:fr green:fg blue:fb alpha:alpha];
}

+ (UIColor *)fromShortHexValue:(NSUInteger)hex
{
	return [UIColor fromShortHexValue:hex alpha:1.0f];
}

+ (UIColor *)fromShortHexValue:(NSUInteger)hex alpha:(CGFloat)alpha
{
	NSUInteger r = ((hex >> 8) & 0x0000000F);
	NSUInteger g = ((hex >> 4) & 0x0000000F);
	NSUInteger b = ((hex >> 0) & 0x0000000F);
	
	float fr = (r * 1.0f) / 15.0f;
	float fg = (g * 1.0f) / 15.0f;
	float fb = (b * 1.0f) / 15.0f;
	
	return [UIColor colorWithRed:fr green:fg blue:fb alpha:alpha];
}


+ (UIColor *)colorWithString:(NSString *)string
{
    if ( nil == string || 0 == string.length )
        return [UIColor clearColor];
    
    string = string.trim;
    
    NSArray *	array = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *	color = [array objectAtIndex:0];
    CGFloat		alpha = 1.0f;
    
    if ( array.count == 2 )
    {
        alpha = [[array objectAtIndex:1] floatValue];
    }
    
    if ( [color hasPrefix:@"#"] ) // #FFF
    {
        color = [color substringFromIndex:1];
        
        if ( color.length == 3 )
        {
            NSUInteger hexRGB = strtol(color.UTF8String , nil, 16);
            return [UIColor fromShortHexValue:hexRGB alpha:alpha];
        }
        else if ( color.length == 6 )
        {
            NSUInteger hexRGB = strtol(color.UTF8String , nil, 16);
            return [UIColor fromHexValue:hexRGB];
        }
    }
    else if ( [color hasPrefix:@"0x"] || [color hasPrefix:@"0X"] ) // #FFF
    {
        color = [color substringFromIndex:2];
        
        if ( color.length == 8 )
        {
            NSUInteger hexRGB = strtol(color.UTF8String , nil, 16);
            return [UIColor fromHexValue:hexRGB];
        }
        else if ( color.length == 6 )
        {
            NSUInteger hexRGB = strtol(color.UTF8String , nil, 16);
            return [UIColor fromHexValue:hexRGB alpha:1.0f];
        }
    }
    else
    {
        static NSMutableDictionary * __colors = nil;
        
        if ( nil == __colors )
        {
            __colors = [[NSMutableDictionary alloc] init];
            [__colors setObject:[UIColor clearColor] forKey:@"clear"];
            [__colors setObject:[UIColor clearColor] forKey:@"transparent"];
            [__colors setObject:[UIColor redColor] forKey:@"red"];
            [__colors setObject:[UIColor blackColor] forKey:@"black"];
            [__colors setObject:[UIColor darkGrayColor] forKey:@"darkGray"];
            [__colors setObject:[UIColor lightGrayColor] forKey:@"lightGray"];
            [__colors setObject:[UIColor whiteColor] forKey:@"white"];
            [__colors setObject:[UIColor grayColor] forKey:@"gray"];
            [__colors setObject:[UIColor redColor] forKey:@"red"];
            [__colors setObject:[UIColor greenColor] forKey:@"green"];
            [__colors setObject:[UIColor blueColor] forKey:@"blue"];
            [__colors setObject:[UIColor cyanColor] forKey:@"cyan"];
            [__colors setObject:[UIColor yellowColor] forKey:@"yellow"];
            [__colors setObject:[UIColor magentaColor] forKey:@"magenta"];
            [__colors setObject:[UIColor orangeColor] forKey:@"orange"];
            [__colors setObject:[UIColor purpleColor] forKey:@"purple"];
            [__colors setObject:[UIColor brownColor] forKey:@"brown"];
        }
        
        return [__colors objectForKey:color.lowercaseString];
    }
    
    return [UIColor clearColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIColor*)colorWithHue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v alpha:(CGFloat)a {
    CGFloat r, g, b;
    HSVtoRGB(&r, &g, &b, h, s, v);
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)multiplyHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    CGFloat r = rgba[0];
    CGFloat g = rgba[1];
    CGFloat b = rgba[2];
    CGFloat a = rgba[3];
    
    CGFloat h, s, v;
    RGBtoHSV(r, g, b, &h, &s, &v);
    
    h *= hd;
    v *= vd;
    s *= sd;
    
    HSVtoRGB(&r, &g, &b, h, s, v);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)copyWithAlpha:(CGFloat)newAlpha {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    CGFloat r = rgba[0];
    CGFloat g = rgba[1];
    CGFloat b = rgba[2];
    
    return [[UIColor colorWithRed:r green:g blue:b alpha:newAlpha]retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)addHue:(CGFloat)hd saturation:(CGFloat)sd value:(CGFloat)vd {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    CGFloat r = rgba[0];
    CGFloat g = rgba[1];
    CGFloat b = rgba[2];
    CGFloat a = rgba[3];
    
    CGFloat h, s, v;
    RGBtoHSV(r, g, b, &h, &s, &v);
    
    h += hd;
    v += vd;
    s += sd;
    
    HSVtoRGB(&r, &g, &b, h, s, v);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)highlight {
    return [self multiplyHue:1 saturation:0.4 value:1.2];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)shadow {
    return [self multiplyHue:1 saturation:0.6 value:0.6];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger)hex {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    NSUInteger r = rgba[0]*255;
    NSUInteger g = rgba[1]*255;
    NSUInteger b = rgba[2]*255;
    NSUInteger hex = (r*0x10000)|(g*0x100)|b;
    return hex;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)hue {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    CGFloat h, s, v;
    RGBtoHSV(rgba[0], rgba[1], rgba[2], &h, &s, &v);
    return h;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)saturation {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    CGFloat h, s, v;
    RGBtoHSV(rgba[0], rgba[1], rgba[2], &h, &s, &v);
    return s;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)value {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    CGFloat h, s, v;
    RGBtoHSV(rgba[0], rgba[1], rgba[2], &h, &s, &v);
    return v;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)alpha {
    const CGFloat* rgba = CGColorGetComponents(self.CGColor);
    return rgba[3];
}

@end

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
