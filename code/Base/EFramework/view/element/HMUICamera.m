//
//  HMUICamera.m
//  EFExtend
//
//  Created by mac on 15/7/31.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "HMUICamera.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kPhotosActionSheetTag 1
#define kVideosActionSheetTag 2
#define kVideosOrPhotosActionSheetTag 3


static NSString * const kTakePhotoKey = @"takePhoto";
static NSString * const kTakeVideoKey = @"takeVideo";
static NSString * const kChooseFromLibraryKey = @"chooseFromLibrary";
static NSString * const kChooseFromPhotoRollKey = @"chooseFromPhotoRoll";
static NSString * const kCancelKey = @"cancel";
static NSString * const kNoSourcesKey = @"noSources";
static NSString * const kStringsTableName = @"FDTake";

@interface HMUICamera() <UIActionSheetDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) NSMutableArray *sources;
@property (strong, nonatomic) NSMutableArray *buttonTitles;
@property (strong, nonatomic) HMUIActionSheet *actionSheet;
@property (strong, nonatomic) UIPopoverController *popover;

// Returns either optional view control for presenting or main window
- (UIViewController*)presentingViewController;

// encapsulation of actionsheet creation
- (void)_setUpActionSheet;
- (NSString*)textForButtonWithTitle:(NSString*)title;
@end

@implementation HMUICamera{
    BOOL _statusHidden;
}
@synthesize sources = _sources;
@synthesize buttonTitles = _buttonTitles;
@synthesize actionSheet = _actionSheet;
@synthesize imagePicker = _imagePicker;
@synthesize popover = _popover;
@synthesize viewControllerForPresentingImagePickerController = _viewControllerForPresenting;
@synthesize popOverPresentRect = _popOverPresentRect;

- (void)dealloc
{
    self.sources = nil;
    self.buttonTitles = nil;
    self.actionSheet = nil;
    self.imagePicker = nil;
    self.popover = nil;
    self.viewControllerForPresentingImagePickerController = nil;
    self.tagString = nil;
    self.cancelText = nil;
    self.tabBar = nil;
    self.takeVideoText = nil;
    self.takeVideoText = nil;
    self.chooseFromLibraryText = nil;
    self.chooseFromPhotoRollText = nil;
    self.noSourcesText = nil;
    self.takePhotoText = nil;
    
    HM_SUPER_DEALLOC();
}

- (NSMutableArray *)sources
{
    if (!_sources) _sources = [[NSMutableArray alloc] init];
    return _sources;
}

- (NSMutableArray *)buttonTitles
{
    if (!_buttonTitles) _buttonTitles = [[NSMutableArray alloc] init];
    return _buttonTitles;
}

- (CGRect)popOverPresentRect
{
    // See https://github.com/hborders/MGSplitViewController/commit/9247c81d6b8c9ad183f67ad01384a76302ed7f0b
    if (_popOverPresentRect.size.height == 0 || _popOverPresentRect.size.width == 0)
        _popOverPresentRect = CGRectMake(0, 0, 1, 1);
    return _popOverPresentRect;
}

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

- (UIPopoverController *)popover
{
    if (!_popover) _popover = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
    return _popover;
}

- (void)takePhoto
{
    self.sources = nil;
    self.buttonTitles = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypeCamera)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kTakePhotoKey]];
    }

    [self _setUpActionSheet];
    [self.actionSheet setTag:kPhotosActionSheetTag];
}


- (void)takePhotoOrChooseFromLibrary
{
    self.sources = nil;
    self.buttonTitles = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypeCamera)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kTakePhotoKey]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypePhotoLibrary)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kChooseFromLibraryKey]];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypeSavedPhotosAlbum)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kChooseFromPhotoRollKey]];
    }
    [self _setUpActionSheet];
    [self.actionSheet setTag:kPhotosActionSheetTag];
}

- (void)takeVideo
{
    self.sources = nil;
    self.buttonTitles = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypeCamera)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kTakeVideoKey]];
    }

    [self _setUpActionSheet];
    [self.actionSheet setTag:kVideosActionSheetTag];
}


- (void)takeVideoOrChooseFromLibrary
{
    self.sources = nil;
    self.buttonTitles = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypeCamera)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kTakeVideoKey]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypePhotoLibrary)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kChooseFromLibraryKey]];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypeSavedPhotosAlbum)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kChooseFromPhotoRollKey]];
    }
    [self _setUpActionSheet];
    [self.actionSheet setTag:kVideosActionSheetTag];
}

- (void)takePhotoOrVideoOrChooseFromLibrary
{
    self.sources = nil;
    self.buttonTitles = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypeCamera)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kTakePhotoKey]];
        [self.sources addObject:@(UIImagePickerControllerSourceTypeCamera)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kTakeVideoKey]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypePhotoLibrary)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kChooseFromLibraryKey]];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [self.sources addObject:@(UIImagePickerControllerSourceTypeSavedPhotosAlbum)];
        [self.buttonTitles addObject:[self textForButtonWithTitle:kChooseFromPhotoRollKey]];
    }
    [self _setUpActionSheet];
    [self.actionSheet setTag:kVideosOrPhotosActionSheetTag];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(HMUIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIViewController *aViewController = [self _topViewController:[[[UIApplication sharedApplication] keyWindow] rootViewController] ];
    if (buttonIndex == self.actionSheet.cancelButtonIndex) {
        if ([self.delegate respondsToSelector:@selector(takeController:didCancelAfterAttempting:)])
            [self.delegate takeController:self didCancelAfterAttempting:NO];
    } else {
        self.imagePicker.sourceType = [(self.sources)[buttonIndex] integerValue];
        
        if ((self.imagePicker.sourceType==UIImagePickerControllerSourceTypeCamera) || (self.imagePicker.sourceType==UIImagePickerControllerSourceTypeCamera)) {
            if (self.defaultToFrontCamera && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                [self.imagePicker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
            }

        }
        // set the media type: photo or video
        if (actionSheet.tag == kPhotosActionSheetTag) {
            self.imagePicker.allowsEditing = self.allowsEditingPhoto;
            self.imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        } else if (actionSheet.tag == kVideosActionSheetTag) {
            self.imagePicker.allowsEditing = self.allowsEditingVideo;
            self.imagePicker.mediaTypes = @[(NSString *) kUTTypeMovie];
        } else if (actionSheet.tag == kVideosOrPhotosActionSheetTag) {
            if ([self.sources count] == 1) {
                if (buttonIndex == 0) {
                    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                }
            } else {
                if (buttonIndex == 0) {
                    self.imagePicker.allowsEditing = self.allowsEditingPhoto;
                    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
                } else if (buttonIndex == 1) {
                    self.imagePicker.allowsEditing = self.allowsEditingVideo;
                    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
                } else if (buttonIndex == 2) {
                    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                }
            }
        }
        
        // On iPad use pop-overs.
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.popover presentPopoverFromRect:self.popOverPresentRect
                                          inView:aViewController.view
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
        }
        else {
            // On iPhone use full screen presentation.
            _statusHidden = [self.presentingViewController statusBarShown];
//            [self.presentingViewController hideStatusBarAnimated:YES];
            [[self presentingViewController] presentViewController:self.imagePicker animated:YES completion:nil];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(HMUIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.delegate respondsToSelector:@selector(takeController:didCancelAfterAttempting:)])
        [self.delegate takeController:self didCancelAfterAttempting:NO];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
//    [[UIApplication sharedApplication] setStatusBarHidden:_statusHidden];
//    if (_statusHidden) {
//        [picker showStatusBarAnimated:YES];
//    }else{
//        [picker hideStatusBarAnimated:YES];
//    }
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) info[UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) info[UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else if (originalImage) {
            imageToSave = originalImage;
        } else {
            if ([self.delegate respondsToSelector:@selector(takeController:didFailAfterAttempting:)])
                [self.delegate takeController:self didFailAfterAttempting:YES];
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(takeController:gotPhoto:withInfo:)])
            if(![self.delegate takeController:self gotPhoto:imageToSave withInfo:info])return;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [self.popover dismissPopoverAnimated:YES];
    }
    // Handle a movie capture
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
             == kCFCompareEqualTo) {
        if ([self.delegate respondsToSelector:@selector(takeController:gotVideo:withInfo:)])
            if (![self.delegate takeController:self gotVideo:info[UIImagePickerControllerMediaURL] withInfo:info])return;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
//    self.imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
//    [[UIApplication sharedApplication] setStatusBarHidden:_statusHidden];
//    if (_statusHidden) {
//        [picker showStatusBarAnimated:YES];
//    }else{
//        [picker hideStatusBarAnimated:YES];
//    }
    [picker dismissViewControllerAnimated:YES completion:nil];
//    self.imagePicker = nil;
    
    if ([self.delegate respondsToSelector:@selector(takeController:didCancelAfterAttempting:)])
        [self.delegate takeController:self didCancelAfterAttempting:YES];
}

#pragma mark - Private methods

- (UIViewController*)presentingViewController
{
    // Use optional view controller for presenting the image picker if set
    UIViewController *presentingViewController = nil;
    if (self.viewControllerForPresentingImagePickerController!=nil) {
        presentingViewController = self.viewControllerForPresentingImagePickerController;
    }
    else {
        // Otherwise do this stuff (like in original source code)
        presentingViewController = [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    }
    return presentingViewController;
}

//Added by me
- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)_setUpActionSheet
{
    if ([self.sources count]) {
        
        WS(weakSelf)
        self.actionSheet = [HMUIActionSheet sheetViewWithTitle:nil message:nil];
        [self.actionSheet onClicked:^(HMUIActionSheet *sheet, NSInteger index) {
            SS(strongSelf)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            
            [strongSelf actionSheet:(UIActionSheet*)sheet didDismissWithButtonIndex:index];
#pragma clang diagnostic pop
            
        }];
        for (NSString *title in self.buttonTitles)
            [self.actionSheet addButtonWithTitle:title];
        [self.actionSheet addButtonWithTitle:[self textForButtonWithTitle:kCancelKey]];
        self.actionSheet.cancelButtonIndex = self.sources.count;
        
        [self.actionSheet showInViewController:[self presentingViewController]];

    } else {
        NSString *str = [self textForButtonWithTitle:kNoSourcesKey];
        
        HMUIAlertView *alert = [HMUIAlertView alertViewWithTitle:nil message:str];
        [alert addButtonWithTitle:@"取消"];
        WS(weakSelf)
        [alert onClicked:^(HMUIAlertView *alert, NSInteger index) {
            SS(strongSelf)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            
            [strongSelf alertView:(id)alert didDismissWithButtonIndex:index];
#pragma clang diagnostic pop
        }];
        [alert showInViewController:[self presentingViewController]];

        
    }
}

// This is a hack required on iPad if you want to select a photo and you already have a popup on the screen
// see: http://stackoverflow.com/questions/11748845/present-more-than-one-modalview-in-appdelegate
- (UIViewController *)_topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil)
        return rootViewController;
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self _topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self _topViewController:presentedViewController];
}

- (NSString*)textForButtonWithTitle:(NSString*)title
{
    if ([title isEqualToString:kTakePhotoKey])
        return self.takePhotoText ?: FDLOCALIZATION(kTakePhotoKey, @"Option to take photo using camera");
    else if ([title isEqualToString:kTakeVideoKey])
        return self.takeVideoText ?: FDLOCALIZATION(kTakeVideoKey, @"Option to take video using camera");
    else if ([title isEqualToString:kChooseFromLibraryKey])
        return self.chooseFromLibraryText ?: FDLOCALIZATION(kChooseFromLibraryKey, @"Option to select photo/video from library");
    else if ([title isEqualToString:kChooseFromPhotoRollKey])
        return self.chooseFromPhotoRollText ?: FDLOCALIZATION(kChooseFromPhotoRollKey, @"Option to select photo from photo roll");
    else if ([title isEqualToString:kCancelKey])
        return self.cancelText ?: FDLOCALIZATION(kCancelKey, @"Decline to proceed with operation");
    else if ([title isEqualToString:kNoSourcesKey])
        return self.noSourcesText ?: FDLOCALIZATION(kNoSourcesKey, @"There are no sources available to select a photo");
    
    NSAssert(NO, @"Invalid title passed to textForButtonWithTitle:");
    
    return nil;
}

#pragma mark - Localization from bundle

+ (NSBundle *)frameworkBundle {
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"HMUICameraResources.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
    });
    return frameworkBundle ?: [NSBundle mainBundle];
}

static inline NSString * FDLOCALIZATION(NSString *key, NSString *comment) {
    return NSLocalizedStringWithDefaultValue((key), kStringsTableName, [HMUICamera frameworkBundle], @" ", comment);
}

#pragma mark - UINavigationControllerDelegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}


@end
