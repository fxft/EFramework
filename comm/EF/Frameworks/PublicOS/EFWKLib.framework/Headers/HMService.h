//
//  HMService.h
//  CarAssistant
//
//  Created by Eric on 14-2-20.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMDialogue.h"
#import "HMFoundation.h"

#undef	AS_SERVICE
#define AS_SERVICE( __name )	AS_STATIC_PROPERTY( __name )

#undef	DEF_SERVICE
#define DEF_SERVICE( __name )	DEF_STATIC_PROPERTY3( __name, @"service", [[self class] description] )

#undef	DEF_SERVICE2
#define DEF_SERVICE2( __name, __dial ) \
DEF_STATIC_PROPERTY3( __name, @"service", [[self class] description] ); \
- (void)__name:(HMDialogue *)__dial

#undef	ON_SERVICE
#define ON_SERVICE( __dlg ) \
- (void)handle_service:(HMDialogue *)__dlg

#undef	ON_SERVICE2
#define ON_SERVICE2( __class, __dlg ) \
- (void)handle_service_##__class:(HMDialogue *)__dlg

#undef	ON_SERVICE3
#define ON_SERVICE3( __class, __name, __dlg ) \
- (void)handle_service_##__class##_##__name:(HMDialogue *)__dlg


#undef AS_SERVICE_AUTOSHARE
#define AS_SERVICE_AUTOSHARE \
+(instancetype)shareAutoLoad;


#undef DEF_SERVICE_AUTOSHARE
#define DEF_SERVICE_AUTOSHARE(__class)\
+(instancetype)shareAutoLoad{ \
    for (HMService *service in [HMService allServices]) { \
        if ([service isKindOfClass:[__class class]]) { \
            return (__class *)service; \
        } \
    } \
    return nil; \
}

@protocol ON_SERVICE_handle <NSObject>

ON_SERVICE( __dlg );
ON_SERVICE2( __class, __dlg );
ON_SERVICE3( __class, __name, __dlg );

@end

/**
 *  自启动服务；HMWebAPI就是一个服务
 */
@interface HMService : HMAutoLoad<HMDialogueExecutor>
AS_SINGLETON(HMService)

@property (nonatomic, HM_STRONG) NSString *			prefix;

+ (NSArray *)allServices;
+ (HMService *)routes:(NSString *)order;

- (void)load;
- (void)unload;

@end
