
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#pragma mark -
//截屏

@interface UIView(Screenshot)

@property (nonatomic, readonly) UIImage *	screenshot;
@property (nonatomic, readonly) UIImage *	screenshotOneLayer;

- (UIImage *)capture;
- (UIImage *)capture:(CGRect)area;
+ (UIImage *)screenFull;
@end

@interface CALayer(Screenshot)
- (UIImage *)capture;
- (UIImage *)capture:(CGRect)area;
@end
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
