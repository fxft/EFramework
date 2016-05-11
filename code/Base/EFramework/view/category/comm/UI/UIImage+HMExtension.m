//
//  UIImage+HMExtension.m
//  CarAssistant
//
//  Created by Eric on 14-3-12.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "UIImage+HMExtension.h"
#import "HMFoundation.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (HMExtension)

#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius{
    [UIImage addRoundedRectToPath:context rect:rect radius:radius];
}
+ (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    
    if (radius == 0) {
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddRect(context, rect);
        
    } else {
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
//        CGContextScaleCTM(context, radius, radius);
        float fw = CGRectGetWidth(rect) / radius;
        float fh = CGRectGetHeight(rect) / radius;
        
        CGContextMoveToPoint(context, fw, fh/2);
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    }
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radiusTopLeft:(CGFloat)topleft bottomLeft:(CGFloat)bottomLeft topRight:(CGFloat)topRight bottomRight:(CGFloat)bottomRight {
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    
    
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGFloat fw = rect.size.width;
    CGFloat fh = rect.size.height;
    
    CGContextMoveToPoint(context, fw, floor(fh/2));
    CGContextAddArcToPoint(context, fw, fh, floor(fw/2), fh, RD(bottomRight));
    CGContextAddArcToPoint(context, 0, fh, 0, floor(fh/2), RD(bottomLeft));
    CGContextAddArcToPoint(context, 0, 0, floor(fw/2), 0, RD(topleft));
    CGContextAddArcToPoint(context, fw, 0, fw, floor(fh/2), RD(topRight));
    
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Creates a new image by resizing the receiver to the desired size, and rotating it if receiver's
 * imageOrientation shows it to be necessary (and the rotate argument is YES).
 */
- (UIImage*)transformWidth:(CGFloat)width height:(CGFloat)height rotate:(BOOL)rotate {
    CGFloat destW = width;
    CGFloat destH = height;
    CGFloat sourceW = width;
    CGFloat sourceH = height;
    if (rotate) {
        if (self.imageOrientation == UIImageOrientationRight
            || self.imageOrientation == UIImageOrientationLeft) {
            sourceW = height;
            sourceH = width;
        }
    }
    
    CGImageRef imageRef = self.CGImage;
    int bytesPerRow = destW * (CGImageGetBitsPerPixel(imageRef) >> 3);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, destW, destH,
                                                CGImageGetBitsPerComponent(imageRef), bytesPerRow, CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    if (rotate) {
        if (self.imageOrientation == UIImageOrientationDown) {
            CGContextTranslateCTM(bitmap, sourceW, sourceH);
            CGContextRotateCTM(bitmap, 180 * (M_PI/180));
            
        } else if (self.imageOrientation == UIImageOrientationLeft) {
            CGContextTranslateCTM(bitmap, sourceH, 0);
            CGContextRotateCTM(bitmap, 90 * (M_PI/180));
            
        } else if (self.imageOrientation == UIImageOrientationRight) {
            CGContextTranslateCTM(bitmap, 0, sourceW);
            CGContextRotateCTM(bitmap, -90 * (M_PI/180));
        }
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0,0,sourceW,sourceH), imageRef);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)convertRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode {
    if (self.size.width != rect.size.width || self.size.height != rect.size.height) {
        if (contentMode == UIViewContentModeLeft) {
            return CGRectMake(rect.origin.x,
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeRight) {
            return CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeTop) {
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y,
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeBottom) {
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y + floor(rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeCenter) {
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeBottomLeft) {
            return CGRectMake(rect.origin.x,
                              rect.origin.y + floor(rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeBottomRight) {
            return CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y + (rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeTopLeft) {
            return CGRectMake(rect.origin.x,
                              rect.origin.y,
                              
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeTopRight) {
            return CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y,
                              self.size.width, self.size.height);
            
        } else if (contentMode == UIViewContentModeScaleAspectFill) {
            CGSize imageSize = self.size;
            if (imageSize.height < imageSize.width) {
                imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
                imageSize.height = rect.size.height;
                
            } else {
                imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
                imageSize.width = rect.size.width;
            }
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
                              rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
                              imageSize.width, imageSize.height);
            
        } else if (contentMode == UIViewContentModeScaleAspectFit) {
            CGSize imageSize = self.size;
            if (imageSize.height < imageSize.width) {
                imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
                imageSize.width = rect.size.width;
                
            } else {
                imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
                imageSize.height = rect.size.height;
            }
            return CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
                              rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
                              imageSize.width, imageSize.height);
        }
    }
    return rect;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode {
    BOOL clip = NO;
    CGRect originalRect = rect;
    if (self.size.width != rect.size.width || self.size.height != rect.size.height) {
        clip = contentMode != UIViewContentModeScaleAspectFill
        && contentMode != UIViewContentModeScaleAspectFit;
        rect = [self convertRect:rect withContentMode:contentMode];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (clip) {
        CGContextSaveGState(context);
        CGContextAddRect(context, originalRect);
        CGContextClip(context);
    }
    
    [self drawInRect:rect];
    
    if (clip) {
        CGContextRestoreGState(context);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect radius:(CGFloat)radius {
    [self drawInRect:rect radius:radius contentMode:UIViewContentModeScaleToFill];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect radius:(CGFloat)radius contentMode:(UIViewContentMode)contentMode {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    if (radius) {
        [self addRoundedRectToPath:context rect:rect radius:radius];
        CGContextClip(context);
    }
    
    [self drawInRect:rect contentMode:contentMode];
    
    CGContextRestoreGState(context);
}


- (UIImage *)transprent
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo( self.CGImage );
    
    if ( kCGImageAlphaFirst == alpha ||
        kCGImageAlphaLast == alpha ||
        kCGImageAlphaPremultipliedFirst == alpha ||
        kCGImageAlphaPremultipliedLast == alpha )
    {
        return self;
    }
    
    CGImageRef	imageRef = self.CGImage;
    size_t		width = CGImageGetWidth(imageRef);
    size_t		height = CGImageGetHeight(imageRef);
    
    CGContextRef context = CGBitmapContextCreate( NULL, width, height, 8, 0, CGImageGetColorSpace(imageRef), kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage( context, CGRectMake(0, 0, width, height), imageRef );
    
    CGImageRef	resultRef = CGBitmapContextCreateImage( context );
    UIImage *	result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    
    CGContextRelease( context );
    CGImageRelease( resultRef );
    
    return result;
}

- (UIImage *)resize:(CGSize)newSize
{
    CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if ( width > newSize.width || height > newSize.height )
    {
        CGFloat ratio = width/height;
        if ( ratio > 1 )
        {
            bounds.size.width = newSize.width;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = newSize.height;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ( orient == UIImageOrientationRight || orient == UIImageOrientationLeft )
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage * imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
- (UIImage *)resizeWithQuality:(CGInterpolationQuality)quality
                          newSize:(CGSize)newSize{
    UIImage *resized = nil;
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIImageOrientation orient = self.imageOrientation;
    CGFloat boundHeight;
    UIImage *image = self;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(newSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, newSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = newSize.height;
            newSize.height = newSize.width;
            newSize.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(newSize.height, newSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = newSize.height;
            newSize.height = newSize.width;
            newSize.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, newSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = newSize.height;
            newSize.height = newSize.width;
            newSize.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = newSize.height;
            newSize.height = newSize.width;
            newSize.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(newSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(newSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -newSize.height);
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, newSize.width, newSize.height), image.CGImage);
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}
- (UIImage *)resizeWithQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    
    CGFloat width = self.size.width * rate;
    CGFloat height = self.size.height * rate;

    return [self resizeWithQuality:quality newSize:CGSizeMake(width, height)];
}

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/

- (void)addCircleRectToPath:(CGRect)rect context:(CGContextRef)context
{
    CGContextSaveGState( context );
    CGContextTranslateCTM( context, CGRectGetMinX(rect), CGRectGetMinY(rect) );
    CGContextSetShouldAntialias( context, true );
    CGContextSetAllowsAntialiasing( context, true );
    CGContextAddEllipseInRect( context, rect );
    CGContextClosePath( context );
    CGContextRestoreGState( context );
}

- (UIImage *)rounded
{
    UIImage * image = [self transprent];
    if ( nil == image )
        return nil;
    
    CGSize imageSize = image.size;
    imageSize.width = floorf( imageSize.width );
    imageSize.height = floorf( imageSize.height );
    
    CGFloat imageWidth = fminf(imageSize.width, imageSize.height);
    CGFloat imageHeight = imageWidth;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate( NULL,
                                                 imageWidth,
                                                 imageHeight,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 imageWidth * 4,
                                                 colorSpace,
                                                 CGImageGetBitmapInfo(image.CGImage) );
    
    CGContextBeginPath(context);
    CGRect circleRect;
    circleRect.origin.x = 0;
    circleRect.origin.y = 0;
    circleRect.size.width = imageWidth;
    circleRect.size.height = imageHeight;
    [self addCircleRectToPath:circleRect context:context];
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGRect drawRect;
    drawRect.origin.x = 0;
    drawRect.origin.y = 0;
    drawRect.size.width = imageWidth;
    drawRect.size.height = imageHeight;
    CGContextDrawImage(context, drawRect, image.CGImage);
    
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease( colorSpace );
    
    UIImage * roundedImage = [UIImage imageWithCGImage:clippedImage scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(clippedImage);
    
    return roundedImage;
}

- (UIImage *)rounded:(CGRect)circleRect
{
    UIImage * image = [self transprent];
    if ( nil == image )
        return nil;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate( NULL,
                                                 circleRect.size.width,
                                                 circleRect.size.height,
                                                 CGImageGetBitsPerComponent( image.CGImage ),
                                                 circleRect.size.width * 4,
                                                 colorSpace,
                                                 kCGBitmapAlphaInfoMask );
    
    CGContextBeginPath(context);
    [self addCircleRectToPath:circleRect context:context];
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGRect drawRect;
    drawRect.origin.x = 0; //(imageSize.width - imageWidth) / 2.0f;
    drawRect.origin.y = 0; //(imageSize.height - imageHeight) / 2.0f;
    drawRect.size.width = circleRect.size.width;
    drawRect.size.height = circleRect.size.height;
    CGContextDrawImage(context, drawRect, image.CGImage);
    
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage * roundedImage = [UIImage imageWithCGImage:clippedImage scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(clippedImage);
    
    return roundedImage;
}

- (UIImage *)stretched
{
    CGFloat leftCap = floorf(self.size.width / 2.0f);
    CGFloat topCap = floorf(self.size.height / 2.0f);
    return [self stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}

- (UIImage *)stretched:(UIEdgeInsets)capInsets
{
    return [self resizableImageWithCapInsets:capInsets];
}

- (UIImage *)stretched:(UIEdgeInsets)capInsets resizMode:(UIImageResizingMode)mode
{
    return [self resizableImageWithCapInsets:capInsets resizingMode:mode];
}



//- (UIImage *)stretcheds:(UIEdgeInsets)capInsets inSize:(CGSize)size{
//
//    CGRect tempRect = CGRectMake(0, 0, size.width, 1);
//    CGImageRef newImageRef = CGImageCreateWithImageInRect(self.CGImage, tempRect);
//
////    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
////    CGContextRef ctx = CGBitmapContextCreate( NULL,
////                                                 tempRect.size.width,
////                                                 tempRect.size.height,
////                                                 CGImageGetBitsPerComponent( newImageRef ),
////                                                 tempRect.size.width * 4,
////                                                 colorSpace,
////                                                 kCGBitmapAlphaInfoMask );
//
//    size_t		width = CGImageGetWidth(newImageRef);
//    size_t		height = CGImageGetHeight(newImageRef);
//
//    CGContextRef ctx = CGBitmapContextCreate( NULL, width, height, 8, 0, CGImageGetColorSpace(newImageRef), kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedFirst);
//    CGContextDrawImage(ctx, tempRect, newImageRef);
//    const char *data = CGBitmapContextGetData(ctx);
//    for (int i=0; i<strlen(data); i++) {
//        INFO(@"%d",data[i]);
//    }
//    CGContextRelease(ctx);
//    UIGraphicsEndImageContext();
//    if (ctx == NULL)
//        return NULL;
//
//
//    //计算切块
//    CGRect inRect = CGRectMakeBound(size.width, size.height);
//    CGSize imageSize = self.size;
//    CGRect imageRect = CGRectMakeBound(self.size.width, self.size.height);
//    CGRect capRect = UIEdgeInsetsInsetRect(imageRect, capInsets);
//    CGRect inCapRect = UIEdgeInsetsInsetRect(inRect, capInsets);
//    CGRect clipRects = CGRectMake(0, 0, capRect.origin.x, capRect.origin.y);
//    CGRect clipRectL = CGRectMake(capRect.origin.x+capRect.size.width, 0, size.width-(capRect.origin.x+capRect.size.width), capRect.origin.y);
//
//    UIImage *capImage = [self crop:CGRectMakeScale(capRect, self.scale)];
//    UIGraphicsBeginImageContextWithOptions( size, NO, self.scale );
//    CGContextRef context = UIGraphicsGetCurrentContext();
////    [capImage drawAtPoint:capRect.origin blendMode:kCGBlendModeNormal alpha:1.0f];
//    [capImage drawInRect:capRect blendMode:kCGBlendModeNormal alpha:1.0f];
//    [capImage drawInRect:clipRects blendMode:kCGBlendModeNormal alpha:1.0f];
//    [capImage drawInRect:clipRectL blendMode:kCGBlendModeNormal alpha:1.0f];
//    CGContextSaveGState(context);
//    CGContextTranslateCTM(context, 0.0, size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextDrawImage(context, clipRectL, capImage.CGImage);
//    CGContextRestoreGState(context);
//
//    CGContextStrokeRect(context, inRect);
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    newImage = [[UIImage alloc]initWithCGImage:newImage.CGImage scale:1.f orientation:self.imageOrientation];
//    return [newImage autorelease];
//}

-(void)imageDump:(NSString*)file
{
    UIImage* image = [UIImage imageNamed:file];
    CGImageRef cgimage = image.CGImage;
    
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    
    CGBitmapInfo info = CGImageGetBitmapInfo(cgimage);
    
    NSLog(
          @"\n"
          "===== %@ =====\n"
          "CGImageGetHeight: %d\n"
          "CGImageGetWidth:  %d\n"
          "CGImageGetColorSpace: %@\n"
          "CGImageGetBitsPerPixel:     %d\n"
          "CGImageGetBitsPerComponent: %d\n"
          "CGImageGetBytesPerRow:      %d\n"
          "CGImageGetBitmapInfo: 0x%.8X\n"
          "  kCGBitmapAlphaInfoMask     = %s\n"
          "  kCGBitmapFloatComponents   = %s\n"
          "  kCGBitmapByteOrderMask     = 0x%.8X\n"
          "  kCGBitmapByteOrderDefault  = %s\n"
          "  kCGBitmapByteOrder16Little = %s\n"
          "  kCGBitmapByteOrder32Little = %s\n"
          "  kCGBitmapByteOrder16Big    = %s\n"
          "  kCGBitmapByteOrder32Big    = %s\n",
          file,
          (int)width,
          (int)height,
          CGImageGetColorSpace(cgimage),
          (int)bpp,
          (int)bpc,
          (int)bpr,
          (unsigned)info,
          (info & kCGBitmapAlphaInfoMask)     ? "YES" : "NO",
          (info & kCGBitmapFloatComponents)   ? "YES" : "NO",
          (info & kCGBitmapByteOrderMask),
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrderDefault)  ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder16Little) ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little) ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder16Big)    ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Big)    ? "YES" : "NO"
          );
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData* data = (id)CGDataProviderCopyData(provider);
    [data autorelease];
    const uint8_t* bytes = [data bytes];
    
    printf("Pixel Data:\n");
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel =
            &bytes[row * bpr + col * bytes_per_pixel];
            
            printf("(");
            for(size_t x = 0; x < bytes_per_pixel; x++)
            {
                printf("%.2X", pixel[x]);
                if( x < bytes_per_pixel - 1 )
                    printf(",");
            }
            
            printf(")");
            if( col < width - 1 )
                printf(", ");
        }
        
        printf("\n");
    }
}

- (UIImage *)rotateToFit:(CGFloat)angle
{
    CGSize rotatedSize = self.size;
    CGSize rotatedSize2 = CGSizeMake(rotatedSize.width*2, rotatedSize.height*2);
    CGFloat max = MAX(rotatedSize.width, rotatedSize.height);
    if (fabs(rotatedSize.width - rotatedSize.height)<3) {
        max = sinhf(M_PI_4)*max*2;
    }
    rotatedSize2 = CGSizeMake(max, max);
    UIGraphicsBeginImageContext(rotatedSize2);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize2.width/2, rotatedSize2.height/2);
    CGContextRotateCTM(bitmap, angle * M_PI / 180);
    CGContextRotateCTM(bitmap, M_PI);
    CGContextScaleCTM(bitmap, -1.0, 1.0);
    
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    newImage = [[UIImage alloc]initWithCGImage:newImage.CGImage scale:1.f orientation:self.imageOrientation];
    //    INFO(@"%.2f%.2f,%.2f%.2f,%.1f",rotatedSize.width,rotatedSize.height,newImage.size.width,newImage.size.height,newImage.scale);
    return [newImage autorelease];
}

- (UIImage *)rotate:(CGFloat)angle
{
    return  [self rotateToFit:angle];
}

- (UIImage *)rotateCW90
{
    return [self rotate:270];
}

- (UIImage *)rotateCW180
{
    return [self rotate:180];
}

- (UIImage *)rotateCW270
{
    return [self rotate:90];
}

- (UIImage *)grayscale
{
    CGSize size = self.size;
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, CGImageGetBitmapInfo(self.CGImage));
    CGColorSpaceRelease(colorSpace);
    
    if ( context )
    {
        CGContextDrawImage(context, rect, [self CGImage]);
        CGImageRef grayscale = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        if ( grayscale )
        {
            UIImage * image = [UIImage imageWithCGImage:grayscale];
            CFRelease(grayscale);
            return image;
        }
    }
    
    return nil;
}

- (UIImage *)crop:(CGRect)rect
{
    CGImageRef imageRef = self.CGImage;
    CGImageRef newImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, rect, newImageRef);
    
    UIImage * image = [UIImage imageWithCGImage:newImageRef];
    
    UIGraphicsEndImageContext();
    
    CGImageRelease(newImageRef);
    
    return image;
}

- (UIImage *)cropWithPath:(CGPathRef)path EOC:(BOOL)eoc
{
    CGImageRef imageRef = self.CGImage;
    
    CGRect r = CGRectMakeBound(self.size.width, self.size.height);
    
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, path);
    
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    if (eoc) {
        CGContextAddRect(context, r);
        CGContextEOClip(context);
    }else{
        CGContextClip(context);
    }
    CGContextDrawImage(context, r, imageRef);

    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:image.imageOrientation];
    return image;
}

- (UIImage *)imageInRect:(CGRect)rect
{
    return [self crop:rect];
}

- (UIColor *)patternColor
{
    return [UIColor colorWithPatternImage:self];
}


+ (UIImage *)imageFromString:(NSString *)name
{
    return [self imageFromString:name atPath:nil];
}

+ (UIImage *)imageFromString:(NSString *)name atPath:(NSString *)path
{
    NSArray *	array = [name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *	imageName = [array objectAtIndex:0];
    
    imageName = [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
    imageName = imageName.unwrap.trim;
    
    if ( [imageName hasPrefix:@"url("] && [imageName hasSuffix:@")"] )
    {
        NSRange range = NSMakeRange( 4, imageName.length - 5 );
        imageName = [imageName substringWithRange:range].trim;
    }
    
    UIImage * image = nil;
    
    if ( NO == [name hasPrefix:@"http://"] && NO == [name hasPrefix:@"https://"] )
    {
        NSString *	extension = [imageName pathExtension];
        NSString *	fullName = [imageName substringToIndex:(imageName.length - extension.length - 1)];
        
        if ( NSNotFound == [name rangeOfString:@"@"].location )
        {
            NSString *	resPath = nil;
            NSString *	resPath2 = nil;
            
            if ( [HMSystemInfo isPhoneRetina4] )
            {
                resPath = [fullName stringByAppendingFormat:@"-568h@2x.%@", extension];
                resPath2 = [fullName stringByAppendingFormat:@"-568h.%@", extension];
            }
            else if ( [HMSystemInfo isPhoneRetina35] || [HMSystemInfo isPadRetina] )
            {
                resPath = [fullName stringByAppendingFormat:@"@2x.%@", extension];
            }
            
            if ( path )
            {
                if ( nil == image && resPath )
                {
                    NSString * fullPath = [NSString stringWithFormat:@"%@/%@", path, resPath];
                    
                    if ( [[NSFileManager defaultManager] fileExistsAtPath:fullPath] )
                    {
                        image = [[[UIImage alloc] initWithContentsOfFile:fullPath] autorelease];
                    }
                }
                
                if ( nil == image && resPath2 )
                {
                    NSString * fullPath = [NSString stringWithFormat:@"%@/%@", path, resPath2];
                    
                    if ( [[NSFileManager defaultManager] fileExistsAtPath:fullPath] )
                    {
                        image = [[[UIImage alloc] initWithContentsOfFile:fullPath] autorelease];
                    }
                }
            }
            
            if ( nil == image && name )
            {
                image = [UIImage imageNamed:name];
            }
            
            if ( nil == image && resPath2 )
            {
                image = [UIImage imageNamed:resPath2];
            }
        }
    }
    
    if ( nil == image && imageName )
    {
        if ( path )
        {
            NSString * fullPath = [NSString stringWithFormat:@"%@/%@", path, imageName];
            
            if ( [[NSFileManager defaultManager] fileExistsAtPath:fullPath] )
            {
                image = [[[UIImage alloc] initWithContentsOfFile:fullPath] autorelease];
            }
        }
        
        if ( nil == image )
        {
            image = [UIImage imageNamed:imageName];
        }
    }
    
    if ( nil == image )
    {
        return nil;
    }
    
    BOOL grayed = NO;
    BOOL rounded = NO;
    BOOL streched = NO;
    
    if ( array.count > 1 )
    {
        for ( NSString __strong_type* attr in [array subarrayWithRange:NSMakeRange(1, array.count - 1)] )
        {
            attr = attr.trim.unwrap;
            
            if ( NSOrderedSame == [attr compare:@"stretch" options:NSCaseInsensitiveSearch] ||
                NSOrderedSame == [attr compare:@"stretched" options:NSCaseInsensitiveSearch] )
            {
                streched = YES;
            }
            else if ( NSOrderedSame == [attr compare:@"round" options:NSCaseInsensitiveSearch] ||
                     NSOrderedSame == [attr compare:@"rounded" options:NSCaseInsensitiveSearch] )
            {
                rounded = YES;
            }
            else if ( NSOrderedSame == [attr compare:@"gray" options:NSCaseInsensitiveSearch] ||
                     NSOrderedSame == [attr compare:@"grayed" options:NSCaseInsensitiveSearch] ||
                     NSOrderedSame == [attr compare:@"grayScale" options:NSCaseInsensitiveSearch] ||
                     NSOrderedSame == [attr compare:@"gray-scale" options:NSCaseInsensitiveSearch] )
            {
                grayed = YES;
            }
        }
    }
    
    if ( image )
    {
        if ( rounded )
        {
            image = image.rounded;
        }
        
        if ( grayed )
        {
            image = image.grayscale;
        }
        
        if ( streched )
        {
            image = image.stretched;
        }
    }
    
    return image;
}

+ (UIImage *)imageFromString:(NSString *)name stretched:(UIEdgeInsets)capInsets
{
    UIImage * image = [self imageFromString:name];
    if ( nil == image )
        return nil;
    
    return [image resizableImageWithCapInsets:capInsets];
}

+ (UIImage *)imageFromVideo:(NSURL *)videoURL atTime:(CMTime)time scale:(CGFloat)scale
{
    AVURLAsset * asset = [[[AVURLAsset alloc] initWithURL:videoURL options:nil] autorelease];
    AVAssetImageGenerator * generater = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];
    generater.appliesPreferredTrackTransform = YES;
    generater.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generater.maximumSize = [UIScreen mainScreen].bounds.size;
    NSError * error = nil;
    CGImageRef image = [generater copyCGImageAtTime:time actualTime:NULL error:&error];
    UIImage * thumb = [[[UIImage alloc] initWithCGImage:image scale:scale orientation:UIImageOrientationUp] autorelease];
    CGImageRelease(image);
    return thumb;
}

+ (UIImage *)merge:(NSArray *)images
{
    UIImage * image = nil;
    
    for ( UIImage * otherImage in images )
    {
        if ( nil == image )
        {
            image = otherImage;
        }
        else
        {
            image = [image merge:otherImage];
        }
    }
    
    return image;
}

- (UIImage *)mergeText:(NSAttributedString*)text offset:(CGPoint)offset
{
    CGSize ss = [text sizeByHeight:999];
    
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [text drawAtPoint:CGPointMake((self.size.width-ss.width)/2+offset.x, (self.size.height-ss.height)/2+offset.y)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage * thumb = [[[UIImage alloc] initWithCGImage:scaledImage.CGImage scale:self.scale orientation:self.imageOrientation] autorelease];
    return thumb;
}


- (UIImage *)merge:(UIImage *)image
{
    CGSize canvasSize;
    canvasSize.width = fmaxf( self.size.width, image.size.width );
    canvasSize.height = fmaxf( self.size.height, image.size.height );
    
    //	UIGraphicsBeginImageContext( canvasSize );
    UIGraphicsBeginImageContextWithOptions( canvasSize, NO, self.scale );
    
    CGPoint offset1;
    offset1.x = (canvasSize.width - self.size.width) / 2.0f;
    offset1.y = (canvasSize.height - self.size.height) / 2.0f;
    
    CGPoint offset2;
    offset2.x = (canvasSize.width - image.size.width) / 2.0f;
    offset2.y = (canvasSize.height - image.size.height) / 2.0f;
    
    [self drawAtPoint:offset1 blendMode:kCGBlendModeNormal alpha:1.0f];
    [image drawAtPoint:offset2 blendMode:kCGBlendModeNormal alpha:1.0f];
    
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (NSData *)dataWithExt:(NSString *)ext
{
    if ( [ext compare:@"png" options:NSCaseInsensitiveSearch] )
    {
        return UIImagePNGRepresentation(self);
    }
    else if ( [ext compare:@"jpg" options:NSCaseInsensitiveSearch] )
    {
        return UIImageJPEGRepresentation(self, 0);
    }
    else
    {
        return nil;
    }
}

- (UIImage *)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)fixOrientation
{
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



/*
 Returns the color of the image pixel at point. Returns nil if point lies outside the image bounds.
 If the point coordinates contain decimal parts, they will be truncated.
 
 To get at the pixel data, this method must draw the image into a bitmap context.
 For minimal memory usage and optimum performance, only the specific requested
 pixel is drawn.
 If you need to query pixel colors for the same image repeatedly (e.g., in a loop),
 this approach is probably less efficient than drawing the entire image into memory
 once and caching it.
 */
- (UIColor *)colorAtPixel:(CGPoint)point {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIImage *)dilateWithBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 10);
    boxSize -= (boxSize % 2) + 1;
    boxSize = MAX(boxSize, 1);
    
    const size_t width = self.size.width;
    const size_t height = self.size.height;
    const size_t bytesPerRow = width * 4;
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, bytesPerRow, space, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (!bmContext)
        return nil;
    
    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, self.CGImage);
    
    UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
    if (!data)
    {
        CGContextRelease(bmContext);
        return nil;
    }
    unsigned char morphological_kernel[9] = {
        1, 1, 1,
        1, 1, 1,
        1, 1, 1,
    };
    const size_t n = sizeof(UInt8) * width * height * 4;
    void* outt = malloc(n);
    vImage_Buffer src = {data, height, width, bytesPerRow};
    vImage_Buffer dest = {outt, height, width, bytesPerRow};
    vImageDilate_ARGB8888(&src, &dest, 0, 0, morphological_kernel, boxSize, boxSize, kvImageCopyInPlace);
    
    memcpy(data, outt, n);
    
    free(outt);
    
    CGImageRef dilatedImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage* dilated = [UIImage imageWithCGImage:dilatedImageRef];
    
    CGImageRelease(dilatedImageRef);
    CGContextRelease(bmContext);
    
    return dilated;
}

- (UIImage *)blurryWithBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    boxSize = MAX(boxSize, 1);
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(self.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}
- (UIImage *)blurryImageWithBlurLevel:(CGFloat)blur iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor{
    return [self blurryImageWithBlurLevel:blur iterations:iterations tintColor:tintColor blendRect:CGRectZero radius:0];
}
- (UIImage *)blurryImageWithBlurLevel:(CGFloat)blur iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor blendRect:(CGRect)referFrame radius:(CGFloat)radius
{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.4f;
    }
    //boxsize must be an odd integer
    uint32_t boxSize = blur * 100 * self.scale;
    if (boxSize % 2 == 0) boxSize ++;
    
    //create image buffers
    CGImageRef imageRef = self.CGImage;
    vImage_Buffer buffer1, buffer2;
    buffer1.width = buffer2.width = CGImageGetWidth(imageRef);
    buffer1.height = buffer2.height = CGImageGetHeight(imageRef);
    buffer1.rowBytes = buffer2.rowBytes = CGImageGetBytesPerRow(imageRef);
    CFIndex bytes = buffer1.rowBytes * buffer1.height;
    buffer1.data = malloc(bytes);
    buffer2.data = malloc(bytes);
    
    //create temp buffer
    void *tempBuffer = malloc(vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
                                                         NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));
    
    //copy image data
    CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);
    
    for (NSUInteger i = 0; i < iterations; i++)
    {
        //perform blur
        vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        //swap buffers
        void *temp = buffer1.data;
        buffer1.data = buffer2.data;
        buffer2.data = temp;
    }
    
    //free buffers
    free(buffer2.data);
    free(tempBuffer);
    
    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
                                             8, buffer1.rowBytes, CGImageGetColorSpace(imageRef),
                                             CGImageGetBitmapInfo(imageRef));
    
    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f)
    {
        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:0.25].CGColor);
        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
        CGContextFillRect(ctx, CGRectMake(0, 0, buffer1.width, buffer1.height));
    }
    if (!CGRectEqualToRect(referFrame, CGRectZero)) {
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, 0, buffer1.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
//        CGContextSetBlendMode(ctx, kCGBlendModeClear);
//                CGContextAddRect(ctx, referFrame);
        CGAffineTransform tans=CGAffineTransformIdentity;
        CGPathRef path = CGPathCreateWithRoundedRect(referFrame, radius, radius, &tans);
        
        CGContextAddPath(ctx, path);
        CGContextFillPath(ctx);
        CGContextRestoreGState(ctx);
        CGPathRelease(path);
    }
    
    //create image from context
    imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    free(buffer1.data);
    return image;
}

- (UIImage *)imageByApplyingBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor blendRect:(CGRect)referFrame{
    UIImage *outImage = [self imageByApplyingBlurWithRadius:blurRadius tintColor:tintColor saturationDeltaFactor:1.2 maskImage:nil];
    
    UIGraphicsBeginImageContext(outImage.size);
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, outImage.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, outImage.size.width, outImage.size.height), outImage.CGImage);
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, outImage.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    
    CGRect circlePoint = (referFrame);
    CGContextSetFillColorWithColor( UIGraphicsGetCurrentContext(), [UIColor clearColor].CGColor );
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
    CGContextFillRect(UIGraphicsGetCurrentContext(), circlePoint);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return finalImage;
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (UIImage*)imageBlackToTransparentWithColor:(UIColor *)color{
    
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    red *= 255;
    green *= 255;
    blue *= 255;
    
    const int imageWidth = self.size.width;
    const int imageHeight = self.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

- (NSString*)QRCodeString NS_AVAILABLE(10_10, 8_0){
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    
    CIImage *superImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:superImage forKey:kCIInputImageKey];
    float i = 0;
    while (i <= 4) {
        //修改照片对比度参数 0---4
        [lighten setValue:@(i) forKey:@"inputContrast"];
        CIImage *result = [lighten valueForKey:kCIOutputImageKey];
        CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
        //修改后的照片
        //        image = [UIImage imageWithCGImage:cgImage];
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
        if (features.count >= 1) {
            CIQRCodeFeature *feature = [features firstObject];
            NSString *scannedResult = feature.messageString;
            return scannedResult;
        }
        //变化区间可以自行设置
        i = i+0.5;
    }
    return nil;
}

+ (CGImageRef)createImageFromBuffer:(CVImageBufferRef)buffer CF_RETURNS_RETAINED {
    return [self createImageFromBuffer:buffer
                                  left:0
                                   top:0
                                 width:CVPixelBufferGetWidth(buffer)
                                height:CVPixelBufferGetHeight(buffer)];
}

+ (CGImageRef)createImageFromBuffer:(CVImageBufferRef)buffer
                               left:(size_t)left
                                top:(size_t)top
                              width:(size_t)width
                             height:(size_t)height CF_RETURNS_RETAINED {
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    size_t dataWidth = CVPixelBufferGetWidth(buffer);
    size_t dataHeight = CVPixelBufferGetHeight(buffer);
    
    if (left + width > dataWidth ||
        top + height > dataHeight) {
        [NSException raise:NSInvalidArgumentException format:@"Crop rectangle does not fit within image data."];
    }
    
    size_t newBytesPerRow = ((width*4+0xf)>>4)<<4;
    
    CVPixelBufferLockBaseAddress(buffer,0);
    
    int8_t *baseAddress = (int8_t *)CVPixelBufferGetBaseAddress(buffer);
    
    size_t size = newBytesPerRow*height;
    int8_t *bytes = (int8_t *)malloc(size * sizeof(int8_t));
    if (newBytesPerRow == bytesPerRow) {
        memcpy(bytes, baseAddress+top*bytesPerRow, size * sizeof(int8_t));
    } else {
        for (int y=0; y<height; y++) {
            memcpy(bytes+y*newBytesPerRow,
                   baseAddress+left*4+(top+y)*bytesPerRow,
                   newBytesPerRow * sizeof(int8_t));
        }
    }
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(bytes,
                                                    width,
                                                    height,
                                                    8,
                                                    newBytesPerRow,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little|
                                                    kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef result = CGBitmapContextCreateImage(newContext);
    
    CGContextRelease(newContext);
    
    free(bytes);
    
    return result;
}

+ (CGImageRef)createRotatedImage:(CGImageRef)original degrees:(float)degrees CF_RETURNS_RETAINED {
    if (degrees == 0.0f) {
        CGImageRetain(original);
        return original;
    } else {
        double radians = degrees * M_PI / 180;
        
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
        radians = -1 * radians;
#endif
        
        size_t _width = CGImageGetWidth(original);
        size_t _height = CGImageGetHeight(original);
        
        CGRect imgRect = CGRectMake(0, 0, _width, _height);
        CGAffineTransform __transform = CGAffineTransformMakeRotation(radians);
        CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, __transform);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     rotatedRect.size.width,
                                                     rotatedRect.size.height,
                                                     CGImageGetBitsPerComponent(original),
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
        CGContextSetAllowsAntialiasing(context, FALSE);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGColorSpaceRelease(colorSpace);
        
        CGContextTranslateCTM(context,
                              +(rotatedRect.size.width/2),
                              +(rotatedRect.size.height/2));
        CGContextRotateCTM(context, radians);
        
        CGContextDrawImage(context, CGRectMake(-imgRect.size.width/2,
                                               -imgRect.size.height/2,
                                               imgRect.size.width,
                                               imgRect.size.height),
                           original);
        
        CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
        CFRelease(context);
        
        return rotatedImage;
    }
}

- (UIImage*)imageByApplyingBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
#define ENABLE_BLUR                     1
#define ENABLE_SATURATION_ADJUSTMENT    1
#define ENABLE_TINT                     1
    UIImage *inputImage = self;
    // Check pre-conditions.
    if (inputImage.size.width < 1 || inputImage.size.height < 1)
    {
        NSLog(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", inputImage.size.width, inputImage.size.height, inputImage);
        return nil;
    }
    if (!inputImage.CGImage)
    {
        NSLog(@"*** error: inputImage must be backed by a CGImage: %@", inputImage);
        return nil;
    }
    if (maskImage && !maskImage.CGImage)
    {
        NSLog(@"*** error: effectMaskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    
    CGImageRef inputCGImage = inputImage.CGImage;
    CGFloat inputImageScale = inputImage.scale;
    CGBitmapInfo inputImageBitmapInfo = CGImageGetBitmapInfo(inputCGImage);
    CGImageAlphaInfo inputImageAlphaInfo = (inputImageBitmapInfo & kCGBitmapAlphaInfoMask);
    
    CGSize outputImageSizeInPoints = inputImage.size;
    CGRect outputImageRectInPoints = { CGPointZero, outputImageSizeInPoints };
    
    // Set up output context.
    BOOL useOpaqueContext;
    if (inputImageAlphaInfo == kCGImageAlphaNone || inputImageAlphaInfo == kCGImageAlphaNoneSkipLast || inputImageAlphaInfo == kCGImageAlphaNoneSkipFirst)
        useOpaqueContext = YES;
    else
        useOpaqueContext = NO;
    UIGraphicsBeginImageContextWithOptions(outputImageRectInPoints.size, useOpaqueContext, inputImageScale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -outputImageRectInPoints.size.height);
    
    if (hasBlur || hasSaturationChange)
    {
        vImage_Buffer effectInBuffer;
        vImage_Buffer scratchBuffer1;
        
        vImage_Buffer *inputBuffer;
        vImage_Buffer *outputBuffer;
        
        vImage_CGImageFormat format = {
            .bitsPerComponent = 8,
            .bitsPerPixel = 32,
            .colorSpace = NULL,
            // (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little)
            // requests a BGRA buffer.
            .bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little,
            .version = 0,
            .decode = NULL,
            .renderingIntent = kCGRenderingIntentDefault
        };
        
        vImage_Error e = vImageBuffer_InitWithCGImage(&effectInBuffer, &format, NULL, inputImage.CGImage, kvImagePrintDiagnosticsToConsole);
        if (e != kvImageNoError)
        {
            NSLog(@"*** error: vImageBuffer_InitWithCGImage returned error code %zi for inputImage: %@", e, inputImage);
            UIGraphicsEndImageContext();
            return nil;
        }
        
        vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, kvImageNoFlags);
        inputBuffer = &effectInBuffer;
        outputBuffer = &scratchBuffer1;
        
#if ENABLE_BLUR
        if (hasBlur)
        {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * inputImageScale;
            if (inputRadius - 2. < __FLT_EPSILON__)
                inputRadius = 2.;
            uint32_t radius = floor((inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5) / 2);
            
            radius |= 1; // force radius to be odd so that the three box-blur methodology works.
            
            NSInteger tempBufferSize = vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, NULL, 0, 0, radius, radius, NULL, kvImageGetTempBufferSize | kvImageEdgeExtend);
            void *tempBuffer = malloc(tempBufferSize);
            
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
            
            free(tempBuffer);
            
            vImage_Buffer *temp = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = temp;
        }
#endif
        
#if ENABLE_SATURATION_ADJUSTMENT
        if (hasSaturationChange)
        {
            CGFloat s = saturationDeltaFactor;
            // These values appear in the W3C Filter Effects spec:
            // https://dvcs.w3.org/hg/FXTF/raw-file/default/filters/index.html#grayscaleEquivalent
            //
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,                    1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            vImageMatrixMultiply_ARGB8888(inputBuffer, outputBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            
            vImage_Buffer *temp = inputBuffer;
            inputBuffer = outputBuffer;
            outputBuffer = temp;
        }
#endif
        
        CGImageRef effectCGImage;
        if ( (effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, &cleanupBuffer, NULL, kvImageNoAllocate, NULL)) == NULL ) {
            effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, NULL, NULL, kvImageNoFlags, NULL);
            free(inputBuffer->data);
        }
        if (maskImage) {
            // Only need to draw the base image if the effect image will be masked.
            CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
        }
        
        // draw effect image
        CGContextSaveGState(outputContext);
        if (maskImage)
            CGContextClipToMask(outputContext, outputImageRectInPoints, maskImage.CGImage);
        CGContextDrawImage(outputContext, outputImageRectInPoints, effectCGImage);
        CGContextRestoreGState(outputContext);
        
        // Cleanup
        CGImageRelease(effectCGImage);
        free(outputBuffer->data);
    }
    else
    {
        // draw base image
        CGContextDrawImage(outputContext, outputImageRectInPoints, inputCGImage);
    }
    
#if ENABLE_TINT
    // Add in color tint.
    if (tintColor)
    {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, outputImageRectInPoints);
        CGContextRestoreGState(outputContext);
    }
#endif
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
#undef ENABLE_BLUR
#undef ENABLE_SATURATION_ADJUSTMENT
#undef ENABLE_TINT
}

void cleanupBuffer(void *userData, void *buf_data)
{ free(buf_data); }

#pragma mark - imageEmboss
+ (UIImage*)cacheImage:(UIImage*)image forKey:(NSString*)key{
    
    static dispatch_once_t once;
    static NSMutableDictionary * __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[NSMutableDictionary alloc] init]; } );
    
    @synchronized(__singleton__){
        if (image&&key) {
            if (__singleton__.allKeys.count>10) {
                [__singleton__ removeAllObjects];
            }
            [__singleton__ setValue:image forKey:key];
        }else if (key){
            return [__singleton__ valueForKey:key];
        }
    }
    return image;
}


+ (UIImage *)imageForStyle:(HMUIStyle *)style size:(CGSize)size scale:(CGFloat)scale{
    
    UIImage *transparentBackground = nil;
    
    
    HMUIStyleContext *context = [[HMUIStyleContext alloc]init];
    context.frame = CGRectMakeBound(size.width, size.height);
    context.contentFrame = context.frame;
//    context.layer = self.layer;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    [style draw:context];
    
    transparentBackground = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [context release];
    
    return transparentBackground;

}

+ (UIImage *)imageForColor:(UIColor *)color scale:(CGFloat)scale size:(CGSize)size{
    return [self imageForColor:color scale:scale size:size radius:0.f];
}
+ (UIImage *)imageForColor:(UIColor *)color scale:(CGFloat)scale size:(CGSize)size radius:(CGFloat)radius{
    HMUIStyle *style = [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithRadius:radius] next:[HMUISolidFillStyle styleWithColor:color next:nil]];
    
    return [self imageForStyle:style size:size scale:scale];
}

#define embossKey(style,width,height,hex,blur,level) [NSString stringWithFormat:@"EmbossStyle%d:%d-%d-%ld-%f-%f",style,(int)width/10,(int)height/10,hex,blur,level]

+ (UIImage *)imageEmbossStyle:(StyleEmbossShadow)style{
    return [UIImage imageEmbossStyle:style color:nil];
}

+ (UIImage *)imageEmbossStyle:(StyleEmbossShadow)style color:(UIColor *)shadowColor{
    
    return  [UIImage imageEmbossStyle:style blur:CGFLOAT_MAX level:CGFLOAT_MAX color:shadowColor];
    
}

+ (UIImage *)imageEmbossStyle:(StyleEmbossShadow)style blur:(CGFloat)blur level:(CGFloat)level color:(UIColor*)shadowColor{
    CGSize size = CGSizeZero;
    CGFloat h = 10;
    
    CGFloat mblur = .9;
    CGFloat mlevel = .11;
    
    switch (style) {
            
        case styleEmbossDarkLineLeftBottom:
        case styleEmbossDarkLineRightTop:
        case styleEmbossDarkLineLeftTop:
        case styleEmbossDarkLineRightBottom:
        case styleEmbossDarkLineArround:
        case styleEmbossDarkLineLeftBottomRight:
        case styleEmbossDarkLineLeftTopRight:
        case styleEmbossDarkLineTopLeftBottom:
        case styleEmbossDarkLineTopRightBottom:
            size.height = 30;
            size.width = 30;
            mblur = .9;
            mlevel = .35;
            break;
        case styleEmbossDarkLineBottom:
        case styleEmbossDarkLineTop:
            size.height = 10;
            size.width = 20;
            break;
        case styleEmbossDarkLineLeft:
        case styleEmbossDarkLineRight:
            size.height = 20;
            size.width = 10;
            break;
        default:
            size.height = h;
            break;
    }
    if (blur != CGFLOAT_MAX) {
        mblur = blur;
    }
    
    if (level != CGFLOAT_MAX) {
        mlevel = level;
    }
    
    return  [UIImage imageEmbossStyle:style toViewSize:size blur:mblur level:mlevel color:shadowColor];
}

+ (UIImage *)imageEmbossStyle:(StyleEmbossShadow)style toViewSize:(CGSize)size blur:(CGFloat)blur level:(CGFloat)level color:(UIColor*)shadowColor{

    NSString *key = embossKey(style, size.width,size.height,(unsigned long)[shadowColor hex],blur,level);
    UIImage *image = [UIImage cacheImage:nil forKey:key];
    if (image==nil) {
        image = [UIImage imageEmboss:size color:shadowColor blurAndLevel:CGSizeMake(blur, level) style:style];
        image = [image stretched];
        [UIImage cacheImage:image forKey:key];
    }
    
    return image;
}

+ (UIImage *)imageEmboss:(CGSize)shadowSize color:(UIColor *)shadowColor blurAndLevel:(CGSize)bl style:(StyleEmbossShadow)style{
    
    if (CGSizeEqualToSize(shadowSize, CGSizeZero)) {
        return nil;
    }
    
    if (shadowColor==nil) {
        shadowColor = [UIColor blackColor];
    }
   CGFloat blur = MIN(1, bl.width);
    blur = MAX(-1, bl.width);
    
    UIColor *drak = [shadowColor colorWithAlphaComponent:.9f];
    UIColor *light3 = [shadowColor colorWithAlphaComponent:.4f];
    UIColor *light2 = [shadowColor colorWithAlphaComponent:.2f];
    UIColor *light5 = [shadowColor colorWithAlphaComponent:.0f];
    
    CGFloat level = bl.height;
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, shadowSize.width, shadowSize.height);
    
    layer.startPoint = CGPointMake(0, .5);
    layer.endPoint = CGPointMake(1, .5);
    
    if (style==styleEmbossDarkLineRight||style==styleEmbossDarkLineBottom) {
        layer.colors = @[(id)light3.CGColor,(id)light2.CGColor,(id)light5.CGColor];
        layer.locations = @[@(0),@(.3),@(1)];
    }else if (style==styleEmbossDarkLineLeft||style==styleEmbossDarkLineTop) {
        layer.colors = @[(id)light5.CGColor,(id)light2.CGColor,(id)light3.CGColor];
        layer.locations = @[@(0),@(.7),@(1)];
    }
    if (styleEmbossDarkLineTop==style || styleEmbossDarkLineBottom==style) {
        layer.startPoint = CGPointMake(0.5, 0);
        layer.endPoint = CGPointMake(.5, 1);
    }
    
    if ((style>=styleEmbossDarkLineLeftBottom)&&(style<=styleEmbossDarkLineArround)) {
        layer.colors = @[(id)drak.CGColor,(id)drak.CGColor,(id)drak.CGColor];
        layer.locations = @[@(0),@(.5),@(1)];
        layer.startPoint = CGPointMake(0.5, 0);
        layer.endPoint = CGPointMake(.5, 1);
    }
    
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    CGFloat insetWidth = floor(layer.bounds.size.width/3);
    CGFloat insetHeight = floor(layer.bounds.size.height/3);
    CGFloat insetWidthBlur = floor(insetWidth*blur);
    CGFloat insetHeightBlur = floor(insetHeight*blur);
    
    if (style==styleEmbossDarkLineBottom){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsTBAndHor(0, insetHeightBlur, 0));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineTop){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsTBAndHor(insetHeightBlur, 0, 0));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineLeft){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsVerAndLR(0, insetWidthBlur, 0));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineRight){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsVerAndLR(0, 0, insetWidthBlur));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if ((style>=styleEmbossDarkLineLeftBottom)&&(style<=styleEmbossDarkLineArround)){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsAll(insetWidthBlur));
        path = [UIBezierPath bezierPathWithRect:r];
    }else{
        [path moveToPoint:CGPointMake(0, 0)];
        [path addQuadCurveToPoint:CGPointMake(layer.bounds.size.width, 0) controlPoint:CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height)];
        [path closePath];
    }
    
    CAShapeLayer * trackLayer = [CAShapeLayer layer];
    trackLayer.frame = layer.bounds;
    trackLayer.path = [path CGPath];
    trackLayer.fillColor = [[UIColor blackColor] CGColor];//填充颜色，这里应该是  clearColor
    [layer setMask:trackLayer];
    
    UIImage *image = [layer capture];
    image = [image blurryWithBlurLevel:level];
    
    if (style==styleEmbossDarkLineLeftTop){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsMake(insetWidth, insetWidth, 0, 0));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineRightTop){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsMake(insetWidth, 0, 0, insetWidth));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineLeftBottom){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsMake(0, insetWidth, insetWidth, 0));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineRightBottom){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsMake(0, 0, insetWidth, insetWidth));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineLeftBottomRight){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsMake(0, insetWidth, insetWidth, insetWidth));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineLeftTopRight){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsMake(insetWidth, insetWidth, 0, insetWidth));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineTopLeftBottom){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsMake(insetWidth, insetWidth, insetWidth, 0));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineTopRightBottom){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsMake(insetWidth, 0, insetWidth, insetWidth));
        path = [UIBezierPath bezierPathWithRect:r];
    }else if (style==styleEmbossDarkLineArround){
        CGRect r = CGRectEdgeInsets(layer.bounds, UIEdgeInsetsAll(insetWidth));
        path = [UIBezierPath bezierPathWithRect:r];
    }else{
        return image;
    }
    image = [image cropWithPath:path.CGPath EOC:YES];
    
    return image;
}

#pragma mark -

+ (UIImage *)sd_imageWithData:(NSData *)data
{
    UIImage *image;
    
    if ([data sd_isGIF])
    {
        image = [UIImage sd_animatedGIFWithData:data];
    }
    else
    {
        image = [[[UIImage alloc] initWithData:data]autorelease];
    }
    
#ifdef SD_WEBP
    if (!image) // TODO: detect webp signature
    {
        image = [UIImage sd_imageWithWebPData:data];
    }
#endif
    
    return image;
}

+ (UIImage *)sd_animatedGIFWithData:(NSData *)data
{
    if (!data)
    {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1)
    {
        animatedImage = [[[UIImage alloc] initWithData:data]autorelease];
    }
    else
    {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++)
        {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            NSDictionary *frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));
            duration += [[[frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary] objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration)
        {
            duration = (1.0f/10.0f)*count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (UIImage *)sd_animatedGIFNamed:(NSString *)name
{
    CGFloat scale = [UIScreen mainScreen].scale;
    NSData *data = nil;
    
    if (scale > 1.0f)
    {
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:retinaPath];
        
        if (!data)
        {
            
        
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
            
            data = [NSData dataWithContentsOfFile:path];
        
        }
    }
    else
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
       data = [NSData dataWithContentsOfFile:path];
        
    }
    
    if (data)
    {
        return [UIImage sd_animatedGIFWithData:data];
    }
    
    return [UIImage imageNamed:name];
}

- (UIImage *)sd_animatedImageByScaling:(CGFloat)scale{
    
    CGSize sizez = CGSizeMake(self.size.width*scale, self.size.height*scale);
    return [self sd_animatedImageByScalingAndCroppingToSize:sizez];
    
}

- (UIImage *)sd_animatedImageByScalingAndCroppingToSize:(CGSize)size
{
    if (CGSizeEqualToSize(self.size, size) || CGSizeEqualToSize(size, CGSizeZero))
    {
        return self;
    }
    
    CGSize scaledSize = size;
    CGPoint thumbnailPoint = CGPointZero;
    
    CGFloat widthFactor = size.width / self.size.width;
    CGFloat heightFactor = size.height / self.size.height;
    CGFloat scaleFactor = (widthFactor > heightFactor) ? widthFactor :heightFactor;
    scaledSize.width = self.size.width * scaleFactor;
    scaledSize.height = self.size.height * scaleFactor;
    
    if (widthFactor > heightFactor)
    {
        thumbnailPoint.y = (size.height - scaledSize.height) * 0.5;
    }
    else if (widthFactor < heightFactor)
    {
        thumbnailPoint.x = (size.width - scaledSize.width) * 0.5;
    }
    
    NSMutableArray *scaledImages = [NSMutableArray array];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    for (UIImage *image in self.images)
    {
        [image drawInRect:CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledSize.width, scaledSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        [scaledImages addObject:newImage];
    }
    
    UIGraphicsEndImageContext();
    
    return [UIImage animatedImageWithImages:scaledImages duration:self.duration];
}

HM_EXTERN_C_BEGIN
UIImage *SDScaledImageForScale(CGFloat scale, UIImage *image)
{
    if ([image.images count] > 0)
    {
        NSMutableArray *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images)
        {
            [scaledImages addObject:SDScaledImageForScale(scale, tempImage)];
        }
        
        return [UIImage animatedImageWithImages:scaledImages duration:image.duration];
    }
    else
    {
        image = [[[UIImage alloc] initWithCGImage:[image CGImage] scale:scale orientation:image.imageOrientation]autorelease];
        return image;
    }
}
HM_EXTERN_C_END
+ (UIImage *)imageWithDataAtScale:(NSData *)data scale:(CGFloat) scale {
    
    UIImage *image = [UIImage sd_imageWithData:data];
    if (image==nil) {
        return nil;
    }
    return SDScaledImageForScale(scale, image);
}

@end
