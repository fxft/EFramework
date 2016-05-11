//
//  HMUICamera.h
//  EFExtend
//
//  Created by mac on 15/7/31.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HMUICamera;

@protocol HMUICameraDelegate <NSObject>

@optional
/**
 * Delegate method after the user has started a take operation but cancelled it
 */
- (void)takeController:(HMUICamera *)controller didCancelAfterAttempting:(BOOL)madeAttempt;

/**
 * Delegate method after the user has started a take operation but it failed
 */
- (void)takeController:(HMUICamera *)controller didFailAfterAttempting:(BOOL)madeAttempt;

/**
 * Delegate method after the user has successfully taken or selected a photo
 */
- (void)takeController:(HMUICamera *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info;

/**
 * Delegate method after the user has successfully taken or selected a video
 */
- (void)takeController:(HMUICamera *)controller gotVideo:(NSURL *)video withInfo:(NSDictionary *)info;
@end

@interface HMUICamera : NSObject <UIImagePickerControllerDelegate>

/**
 * Presents the user with an option to take a photo
 */
- (void)takePhoto;

/**
 * Presents the user with an option to take a photo or choose a photo from the library
 */
- (void)takePhotoOrChooseFromLibrary;

/**
 * Presents the user with an option to take a video or choose a video from the library
 */
- (void)takeVideo;

/**
 * Presents the user with an option to take a video or choose a video from the library
 */
- (void)takeVideoOrChooseFromLibrary;

/**
 * Presents the user with an option to take a photo/video or choose a photo/video from the library
 */
- (void)takePhotoOrVideoOrChooseFromLibrary;

/**
 * The delegate to receive updates from FDTake
 */
@property (nonatomic, unsafe_unretained) id <HMUICameraDelegate> delegate;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic, unsafe_unretained) UIViewController *viewControllerForPresentingImagePickerController;
@property (nonatomic, readwrite) CGRect popOverPresentRect; // used in presentPopoverFromRect on iPads
@property (strong, nonatomic) UITabBar *tabBar;

@property (nonatomic,assign) NSInteger tag;
@property (nonatomic,copy) NSString * tagString;

/**
 * Whether to allow editing the photo
 */
@property (nonatomic, assign) BOOL allowsEditingPhoto;

/**
 * Whether to allow editing the video
 */
@property (nonatomic, assign) BOOL allowsEditingVideo;

/**
 * Selfie mode
 */
@property (nonatomic, assign) BOOL defaultToFrontCamera;


// Set these strings for custom action sheet button titles
/**
 * Custom UI text (skips localization)
 */
@property (nonatomic, copy) NSString *takePhotoText;

/**
 * Custom UI text (skips localization)
 */
@property (nonatomic, copy) NSString *takeVideoText;

/**
 * Custom UI text (skips localization)
 */
@property (nonatomic, copy) NSString *chooseFromLibraryText;

/**
 * Custom UI text (skips localization)
 */
@property (nonatomic, copy) NSString *chooseFromPhotoRollText;

/**
 * Custom UI text (skips localization)
 */
@property (nonatomic, copy) NSString *cancelText;

/**
 * Custom UI text (skips localization)
 */
@property (nonatomic, copy) NSString *noSourcesText;

@end