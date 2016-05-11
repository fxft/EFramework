#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "UIView+Screenshot.h"
#import "NSArray+HMExtension.h"

#pragma mark -

@implementation UIView(Screenshot)

@dynamic screenshot;
@dynamic screenshotOneLayer;

- (UIImage *)screenshot
{
	return [self capture];
}

- (UIImage *)screenshotOneLayer
{
	NSMutableArray * temp = [NSMutableArray nonRetainingArray];
	
	for ( UIView * subview in self.subviews )
	{
		if ( NO == subview.hidden )
		{
			subview.hidden = YES;

			[temp addObject:subview];
		}
	}

	UIImage * image = [self capture];
	
	for ( UIView * subview in temp )
	{
		subview.hidden = NO;
	}
	
	return image;
}

- (UIImage *)capture
{
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	CGRect captureBounds = CGRectZero;
	captureBounds.size = self.bounds.size;
	
	if ( captureBounds.size.width > screenSize.width )
	{
		captureBounds.size.width = screenSize.width;
	}

	if ( captureBounds.size.height > screenSize.height )
	{
		captureBounds.size.height = screenSize.height;
	}
	
	return [self capture:captureBounds];
}

- (UIImage *)capture:(CGRect)frame
{
	UIImage * result = nil;
	
    UIGraphicsBeginImageContextWithOptions( frame.size, NO, [UIScreen mainScreen].scale );

    CGContextRef context = UIGraphicsGetCurrentContext();
	if ( context )
	{
		CGContextTranslateCTM( context, -frame.origin.x, -frame.origin.y );
		
//		CGContextScaleCTM(context, 0.5, 0.5);
		[self.layer renderInContext:context];
		
		result = UIGraphicsGetImageFromCurrentImageContext();
	}

    UIGraphicsEndImageContext();
	
    return result;
}

+ (UIImage *)screenFull{
    UIWindow *window = nil;
    if (![HMUIApplication sharedInstance].window) {
        window = [UIApplication sharedApplication].keyWindow;
    }else{
        window = [HMUIApplication sharedInstance].window;
    }
    return [window capture];
//    return [[UIApplication sharedApplication].keyWindow capture];
}

@end

@implementation CALayer (Screenshot)

- (UIImage *)capture
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect captureBounds = CGRectZero;
    captureBounds.size = self.bounds.size;
    
    if ( captureBounds.size.width > screenSize.width )
    {
        captureBounds.size.width = screenSize.width;
    }
    
    if ( captureBounds.size.height > screenSize.height )
    {
        captureBounds.size.height = screenSize.height;
    }
    
    return [self capture:captureBounds];
}

- (UIImage *)capture:(CGRect)frame
{
    UIImage * result = nil;
    
    UIGraphicsBeginImageContextWithOptions( frame.size, NO, [UIScreen mainScreen].scale );
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( context )
    {
        CGContextTranslateCTM( context, -frame.origin.x, -frame.origin.y );
        
        //		CGContextScaleCTM(context, 0.5, 0.5);
        [self renderInContext:context];
        
        result = UIGraphicsGetImageFromCurrentImageContext();
    }
    
    UIGraphicsEndImageContext();
    
    return result;
}

@end
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
