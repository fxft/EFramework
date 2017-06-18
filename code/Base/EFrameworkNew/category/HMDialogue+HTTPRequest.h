//
//  HMDialogue+HTTPRequest.h
//  CarAssistant
//
//  Created by Eric on 14-2-26.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMDialogue.h"

@interface HMDialogue (HTTPRequest)
- (HMHTTPRequestOperation *)ownRequest;
@end


@interface NSObject (SafeForResponder)

- (void)selfWillRemoveOrCancel:(BOOL)RorC;

@end
