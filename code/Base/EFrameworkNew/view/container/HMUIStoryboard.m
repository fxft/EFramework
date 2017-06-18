//
//  HMUIStoryboard.m
//  CarAssistant
//
//  Created by Eric on 14-3-11.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMUIStoryboard.h"

@implementation UIStoryboard(HMUIStoryboard)

static  NSMutableDictionary * storys=nil;


+(UIStoryboard *)storyBoard:(NSString *)boardName{
   
    if (boardName.length==0) {
        return nil;
    }
    UIStoryboard *story = nil;
    @synchronized(storys) {
        if (storys==nil) {
            storys = [[NSMutableDictionary dictionary]retain];
        }
        story = [storys valueForKey:boardName];
        if (story==nil) {
            story = [UIStoryboard storyboardWithName:boardName bundle:nil];
            [storys setObject:story forKey:boardName];
        }
    }
    
    return story;
}

+(UIViewController *)firstBoardInStory:(NSString *)board{
    return [UIStoryboard storyBoard:board].firstBoard;
}

+(UIViewController *)boardWithName:(NSString *)name inStory:(NSString *)board{
    return [[UIStoryboard storyBoard:board] boardWithName:name];
}


-(UIViewController *)firstBoard{
    return [self instantiateInitialViewController];
}

-(UIViewController *)boardWithName:(NSString *)name{
    if (name==nil) {
        return [self firstBoard];
    }
    return [self instantiateViewControllerWithIdentifier:name];
}

@end
